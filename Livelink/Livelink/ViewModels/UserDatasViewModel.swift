//
//  UserDatasViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 01.11.24.
//

import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import SwiftUICore

// Verwaltet die UserDaten des eingeloggten Nutzers und der aufgerufenen Profile
class UserDatasViewModel: ObservableObject {
    // Zugriff auf die globale Instanz
    private let database = FirebaseManager.shared.database
    // Speicherpfad der userdaten
    private let usersCollectionReference: CollectionReference
    // Speicherpfad der channeldaten
    private let channelsReference: CollectionReference
    // Speichert die UserDaten des eingeloggten Nutzers
    @Published var userData: UserData?
    // Speichert die UserDaten der Person, dessen Profil aufgerufen wird
    @Published var profileUserData: UserData?
    // Speichert die Liste der Suchergebnisse (Nutzersuche)
    @Published var searchResults: [UserData] = []
    // Gibt an ob gerade userdaten geladen werden
    @Published var isLoadingUserData: Bool = true
    // Gibt an ob gerade ein Profil geöffnet ist
    @Published var showProfilePopup: Bool = false
    private var userDataListener: ListenerRegistration?
    
    // Setzen der Pfade
    init() {
        self.usersCollectionReference = database.collection("users")
        self.channelsReference = database.collection("channels")
        print("Neues UserDatasViewModel erstellt")
    }
    
    // Laden der Nutzerdaten mit Echtzeitupdates durch Snapshot-Listener
    func loadUserData(for uid: String) {
        isLoadingUserData = true
        let userDataDocumentReference = usersCollectionReference.document(uid)
        
        userDataDocumentReference.addSnapshotListener { [weak self] documentSnapshot, error in
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
                // Benutzerdaten erfolgreich decodieren und zuweisen
                let loadedUserData = try Firestore.Decoder().decode(UserData.self, from: data)
                self?.userData = loadedUserData
                print("Benutzerdaten erfolgreich geladen: \(loadedUserData)")
            } catch {
                print("Fehler beim Decodieren der User-Daten: \(error.localizedDescription)")
            }
            self?.isLoadingUserData = false
        }
    }
    
    // Fügt einen Nutzer zu den "letzten Profilbesuchern" hinzu
    func addProfileVisitor(visitedUser: UserData, visitor: ProfileVisitor) {
        // Aktuelle Liste der Profilbesucher aus dem userData des aufgerufenen Nutzers laden
        var updatedProfileVisitors = visitedUser.recentProfileVisitors
        
        // Prüfen, ob der aufrufende Nutzer (visitor) bereits in der Liste vorhanden ist
        if let existingVisitorIndex = updatedProfileVisitors.firstIndex(where: { $0.username == visitor.username }) {
            // Falls vorhanden, entfernen, um später wieder hinzugefügt zu werden
            updatedProfileVisitors.remove(at: existingVisitorIndex)
        }
        
        // Hinzufügen des aufrufenden Nutzers (visitor) an die vorderste Position der Liste
        updatedProfileVisitors.insert(visitor, at: 0)
        
        // Falls die Liste mehr als 30 Besucher enthält, den ältesten entfernen
        if updatedProfileVisitors.count > 30 {
            updatedProfileVisitors.removeLast()
        }
        
        // Umwandeln in Dictionary
        let updatedProfileVisitorsDicts = updatedProfileVisitors.map { $0.toDictionary() }
        
        // Updates für das UserData
        let updates: [String: Any] = ["recentProfileVisitors": updatedProfileVisitorsDicts]
        
        // Profil des Besuchten Nutzers in der Datenbank aktualisieren
        usersCollectionReference
            .whereField("usernameLowercase", isEqualTo: visitedUser.usernameLowercase)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Fehler beim Suchen des Nutzers: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("Nutzer mit dem Namen \(visitedUser.usernameLowercase) nicht gefunden.")
                    return
                }
                
                let userDocumentRef = document.reference
                
                // Profilbesucher in den UserData updaten
                userDocumentRef.updateData(updates) { error in
                    if let error = error {
                        print("Fehler beim Hinzufügen des Profilbesuchers: \(error.localizedDescription)")
                    } else {
                        print("Profilbesucher erfolgreich hinzugefügt.")
                    }
                }
            }
    }
    
    
    // Funktion zum laden der Profiluserdaten anderer Nutzer
    func loadUserDataByUsername(username: String) {
        let lowercaseUsername = username.lowercased()
        
        usersCollectionReference
            .whereField("usernameLowercase", isEqualTo: lowercaseUsername)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Fehler beim Laden der User-Daten für den Benutzernamen \(username): \(error.localizedDescription)")
                    self?.profileUserData = nil
                    return
                }
                
                guard let document = snapshot?.documents.first,
                      let data = try? document.data(as: UserData.self) else {
                    print("Benutzer mit dem Namen \(username) nicht gefunden oder keine Daten.")
                    self?.profileUserData = nil
                    return
                }
                
                self?.profileUserData = data
                self?.showProfilePopup = true
                print("Benutzerdaten für \(username) erfolgreich geladen: \(data)")
                
                // Füge den aufrufenden Nutzer als Profilbesucher hinzu
                if let currentUser = self?.userData, currentUser.username != data.username {
                    let visitor = ProfileVisitor(username: currentUser.username, profilePicURL: currentUser.profilePicURL)
                    self?.addProfileVisitor(visitedUser: data, visitor: visitor)
                }
            }
    }
    
    // Wird beim schließen eines Profiles aufgerufen um den Boolean zurück zu setzen
    func closeProfilePopup() {
        showProfilePopup = false
    }
    
    // User-Daten aktualisieren (Profil Änderungen) - Nur die übergebenen Felder werden aktualisiert
    func updateUserData(uid: String, newData: [String: Any]) {
        usersCollectionReference.document(uid).updateData(newData) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der User-Daten: \(error.localizedDescription)")
            }
        }
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
        
        self.updateUserData(uid: uid, newData: newData)
    }
    
    // Nutzer suchen
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
    
    func logout() {
        // Entferne den Snapshot-Listener
        userDataListener?.remove()
        userDataListener = nil
        
        // Setze User-Daten zurück
        self.userData = nil
        self.isLoadingUserData = true
        print("UserData: \(String(describing: userData))")
    }
}
