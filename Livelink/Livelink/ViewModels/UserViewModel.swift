//
//  UserViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 14.11.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

// ViewModel für die Verwaltung der Nutzer- und Authentifizierungsdaten
class UserViewModel: ObservableObject {
    // Zugriff auf die Firebase-Instanzen
    private let auth = FirebaseManager.shared.auth
    private let database = FirebaseManager.shared.database
    private let usersCollectionReference: CollectionReference
    private let channelsReference: CollectionReference
    
    @Published var currentUser: User? // Aktuell angemeldeter Benutzer
    @Published var userData: UserData? // User-Daten des aktuellen Benutzers
    @Published var profileUserData: UserData? // User-Daten eines anderen Benutzers (Profil)
    @Published var searchResults: [UserData] = [] // Suchergebnisse
    @Published var showProfilePopup: Bool = false // Anzeige für Profil-Popup
    @Published var isLoadingUserData: Bool = true // Ladeanzeige für Userdaten
    @Published var errorMessage: String? // Fehlermeldungen
    
    private var cancellables = Set<AnyCancellable>() // Für Combine
    private var userDataListener: ListenerRegistration? // Echtzeit-Listener für Userdaten
    
    init() {
        self.usersCollectionReference = database.collection("users")
        self.channelsReference = database.collection("channels")
        setupUserEnv() // Benutzerumgebung einrichten
        print("Neues UserViewModel erstellt")
    }
    
    // Benutzerumgebung einrichten
    func setupUserEnv() {
        guard let user = auth.currentUser else {
            currentUser = nil
            userData = nil
            return
        }
        currentUser = user
        loadUserData(for: user.uid)
    }
    
    // Laden der Nutzerdaten mit Echtzeitupdates
    func loadUserData(for uid: String) {
        isLoadingUserData = true
        userDataListener?.remove() // Vorherigen Listener entfernen, falls vorhanden
        let userDataDocumentReference = usersCollectionReference.document(uid)
        
        userDataListener = userDataDocumentReference.addSnapshotListener { [weak self] documentSnapshot, error in
            if let error = error {
                print("Fehler beim Laden der User-Daten: \(error.localizedDescription)")
                self?.isLoadingUserData = false
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let data = document.data() else {
                print("Dokument existiert nicht oder enthält keine Daten.")
                self?.userData = nil
                self?.isLoadingUserData = false
                return
            }
            
            do {
                let loadedUserData = try Firestore.Decoder().decode(UserData.self, from: data)
                self?.userData = loadedUserData
                print("Benutzerdaten erfolgreich geladen: \(loadedUserData)")
            } catch {
                print("Fehler beim Decodieren der User-Daten: \(error.localizedDescription)")
            }
            self?.isLoadingUserData = false
        }
    }
    
    // Benutzerregistrierung
    func register(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Fehler bei der Registrierung: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = result?.user else { return }
            
            let newUserData = UserData(
                username: username,
                usernameLowercase: username.lowercased(),
                email: email,
                regDate: nil
            )
            
            do {
                var data = try Firestore.Encoder().encode(newUserData)
                data["regDate"] = FieldValue.serverTimestamp()
                
                self.usersCollectionReference.document(user.uid).setData(data) { error in
                    if let error = error {
                        print("Fehler beim Speichern der UserData: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } catch {
                print("Fehler beim Kodieren der User-Daten: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    // Benutzeranmeldung
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Fehler beim Einloggen: \(error.localizedDescription)")
                completion(false)
            } else if let uid = result?.user.uid {
                self?.setupUserEnv()
                self?.loadUserData(for: uid)
                completion(true)
            }
        }
    }
    
    // Benutzerabmeldung
    func logout() {
        do {
            try auth.signOut()
            currentUser = nil
            userData = nil
            userDataListener?.remove()
            print("User erfolgreich ausgeloggt")
        } catch {
            print("Fehler beim Ausloggen: \(error.localizedDescription)")
        }
    }
    
    // Benutzername-Verfügbarkeit prüfen
    func isUsernameTaken(username: String, completion: @escaping (Bool) -> Void) {
        let lowercaseUsername = username.lowercased()
        usersCollectionReference.whereField("usernameLowercase", isEqualTo: lowercaseUsername).getDocuments { snapshot, error in
            if let error = error {
                print("Fehler bei der Überprüfung des Benutzernamens: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(snapshot?.isEmpty == false)
            }
        }
    }
    
    // E-Mail anhand eines Benutzernamens abrufen
    func getMailFromUsername(username: String, completion: @escaping (String?) -> Void) {
        let lowercaseUsername = username.lowercased()
        usersCollectionReference.whereField("usernameLowercase", isEqualTo: lowercaseUsername).getDocuments { snapshot, error in
            if let error = error {
                print("Fehler beim Abrufen der E-Mail: \(error.localizedDescription)")
                completion(nil)
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                let email = documents[0].get("email") as? String
                completion(email)
            } else {
                completion(nil)
            }
        }
    }
    
    // Profil-Besucher hinzufügen
    func addProfileVisitor(visitedUser: UserData, visitor: ProfileVisitor) {
        var updatedProfileVisitors = visitedUser.recentProfileVisitors
        if let existingVisitorIndex = updatedProfileVisitors.firstIndex(where: { $0.username == visitor.username }) {
            updatedProfileVisitors.remove(at: existingVisitorIndex)
        }
        updatedProfileVisitors.insert(visitor, at: 0)
        if updatedProfileVisitors.count > 30 {
            updatedProfileVisitors.removeLast()
        }
        
        let updatedProfileVisitorsDicts = updatedProfileVisitors.map { $0.toDictionary() }
        let updates: [String: Any] = ["recentProfileVisitors": updatedProfileVisitorsDicts]
        
        usersCollectionReference
            .whereField("usernameLowercase", isEqualTo: visitedUser.usernameLowercase)
            .getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    print("Nutzer mit dem Namen \(visitedUser.usernameLowercase) nicht gefunden.")
                    return
                }
                document.reference.updateData(updates) { error in
                    if let error = error {
                        print("Fehler beim Hinzufügen des Profilbesuchers: \(error.localizedDescription)")
                    } else {
                        print("Profilbesucher erfolgreich hinzugefügt.")
                    }
                }
            }
    }
    
    // Nutzer-Daten anhand des Usernames laden
    func loadUserDataByUsername(username: String) {
        let lowercaseUsername = username.lowercased()
        usersCollectionReference
            .whereField("usernameLowercase", isEqualTo: lowercaseUsername)
            .getDocuments { [weak self] snapshot, error in
                guard let document = snapshot?.documents.first,
                      let data = try? document.data(as: UserData.self) else {
                    self?.profileUserData = nil
                    return
                }
                
                self?.profileUserData = data
                self?.showProfilePopup = true
            }
    }
    
    // Suche nach Nutzern
    func searchUsers(query: String) {
        let queryLowercase = query.lowercased()
        let queryEnd = queryLowercase + "\u{f8ff}"
        
        usersCollectionReference
            .whereField("usernameLowercase", isGreaterThanOrEqualTo: queryLowercase)
            .whereField("usernameLowercase", isLessThanOrEqualTo: queryEnd)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Fehler bei der Benutzersuche: \(error.localizedDescription)")
                    self?.searchResults = []
                } else {
                    self?.searchResults = snapshot?.documents.compactMap { try? $0.data(as: UserData.self) } ?? []
                }
            }
    }
    
    // Aktualisiere Benutzer-Daten
    func updateUserData(uid: String, newData: [String: Any], completion: @escaping (Bool) -> Void) {
        usersCollectionReference.document(uid).updateData(newData) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der User-Daten: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Benutzer-Daten erfolgreich aktualisiert.")
                completion(true)
            }
        }
    }
    
    
    // Wird beim schließen eines Profiles aufgerufen um den Boolean zurück zu setzen
    func closeProfilePopup() {
        showProfilePopup = false
    }
    

    // Funktion zum hochladen eines neuen Profilbildes
    func uploadProfileImage(image: UIImage) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let timestamp = Int(Date().timeIntervalSince1970) // Aktueller Timestamp in Sekunden
        // Speicherpfad des Bildes
        let storageRef = Storage.storage().reference().child("images/\(uid)/profilepics/\(timestamp).jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    if let url = url {
                        self.updateUserProfilePicURL(url.absoluteString)
                    }
                }
            }
        }
    }
    
    // Funktion um die URL des neuen Profilbildes in den Userdaten zu speichern
    func updateUserProfilePicURL(_ url: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let newData: [String: Any] = [
            "profilePicURL": url
        ]
        
        self.updateUserData(uid: uid, newData: newData) { success in
            if success {
                print("Profilbild-URL erfolgreich aktualisiert.")
            } else {
                print("Fehler beim Aktualisieren der Profilbild-URL.")
            }
        }
    }
}
