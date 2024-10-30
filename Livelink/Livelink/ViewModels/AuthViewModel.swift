//
//  AuthViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    private let auth = Auth.auth()
    private let database = Firestore.firestore()
    private let usersCollectionReference: CollectionReference
    
    @Published var currentUser: User? // Aktuell angemeldeter Benutzer
    @Published var userData: UserData? // UserData des angemeldeten Benutzers
    @Published var errorMessage: String? // Fehlermeldungen
    private var cancellables = Set<AnyCancellable>() // Für Combine
    
    init() {
        self.usersCollectionReference = database.collection("users")
        setupUserEnv() // Userumgebung einrichten
    }
    
    // Laden der Nutzerdaten
    func setupUserEnv() {
        print("setupUserEnv aufgerufen")
        guard let user = auth.currentUser else {
            currentUser = nil // Kein Benutzer eingeloggt
            userData = nil // Benutzer-Daten zurücksetzen
            return
        }
        
        print("aktueller user: \(user)")
        currentUser = user
        
        // UserData laden, falls der Benutzer eingeloggt ist
        loadUserData(for: user.uid)
    }
    
    // UserData für den angemeldeten Benutzer laden
    private func loadUserData(for uid: String) {
        let userDataDocumentReference = usersCollectionReference.document(uid)
        
        // Snapshot-Listener hinzufügen
        userDataDocumentReference.addSnapshotListener { [weak self] documentSnapshot, error in
            if let error = error {
                print("Fehler beim Laden der User-Daten: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Dokument existiert nicht.")
                return
            }
            
            if document.exists, let data = document.data() {
                do {
                    // Versuche die Daten in UserData zu decodieren
                    let userData = try Firestore.Decoder().decode(UserData.self, from: data)
                    self?.userData = userData // Speichere die Benutzer-Daten
                    print("Benutzerdaten erfolgreich geladen: \(userData)")
                } catch {
                    print("Fehler beim Decodieren der Benutzerdaten: \(error.localizedDescription)")
                }
            } else {
                print("Benutzerdaten existieren nicht.")
                self?.userData = nil // Benutzer-Daten zurücksetzen, wenn sie nicht existieren
            }
        }
    }
    
    
    // Funktion zum Registrieren eines neuen Nutzers
    func register(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Fehler bei der Registrierung: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = result?.user else { return }
            
            let userData = [
                "username": username,
                "usernameLowercase": username.lowercased(),
                "email": email
            ]
            
            // UserData in Firestore speichern
            self.usersCollectionReference.document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Fehler beim Speichern der UserData: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true) // Erfolgreich gespeichert
                }
            }
        }
    }
    
    // Funktion prüft, ob ein Username vergeben ist
    func isUsernameTaken(username: String, completion: @escaping (Bool) -> Void) {
        let lowercaseUsername = username.lowercased()
        usersCollectionReference.whereField("usernameLowercase", isEqualTo: lowercaseUsername).getDocuments { (snapshot, error) in
            if let error = error {
                print("Fehler bei der Überprüfung des Benutzernamens: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(snapshot?.isEmpty == false) // True, wenn Benutzername vergeben ist
            }
        }
    }
    
    // Funktion zum Abrufen der E-Mail-Adresse zu einem Benutzernamen
    func getMailFromUsername(username: String, completion: @escaping (String?) -> Void) {
        let lowercaseUsername = username.lowercased()
        usersCollectionReference.whereField("usernameLowercase", isEqualTo: lowercaseUsername).getDocuments { (snapshot, error) in
            if let error = error {
                print("Fehler beim Abrufen der E-Mail: \(error.localizedDescription)")
                completion(nil)
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                let email = documents[0].get("email") as? String
                completion(email) // E-Mail zurückgeben
            } else {
                completion(nil) // Kein Benutzer gefunden
            }
        }
    }
    
    // Funktion zum Einloggen eines Nutzers
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Fehler beim Einloggen: \(error.localizedDescription)")
                completion(false)
            } else {
                self?.setupUserEnv() // Benutzerumgebung einrichten
                completion(true) // Erfolgreich eingeloggt
            }
        }
    }
    
    // Funktion zum Ausloggen eines Nutzers
    func logout() {
        do {
            try auth.signOut()
            currentUser = nil // Benutzerstatus zurücksetzen
            print("User erfolgreich ausgeloggt")
        } catch {
            print("Fehler beim Ausloggen: \(error.localizedDescription)")
        }
    }
}
