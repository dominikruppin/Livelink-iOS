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

// ViewModel für Firebase Auth Verwaltung
class AuthViewModel: ObservableObject {
    // Zugriff auf die globale Instanzen
    private let auth = FirebaseManager.shared.auth
    private let database = FirebaseManager.shared.database
    private let usersCollectionReference: CollectionReference
    
    @Published var currentUser: User? // Aktuell angemeldeter Benutzer
    @Published var errorMessage: String? // Fehlermeldungen
    @Published var userDataViewModel = UserDatasViewModel()
    private var cancellables = Set<AnyCancellable>() // Für Combine
    
    init() {
        self.usersCollectionReference = database.collection("users") // Speicherort der Userdaten
        setupUserEnv() // Userumgebung einrichten
    }
    
    // Laden der Nutzerdaten
    func setupUserEnv() {
        print("setupUserEnv aufgerufen")
        guard let user = auth.currentUser else {
            currentUser = nil // Aktuellen Nutzer entfernen
            userDataViewModel.userData = nil // UserDaten entfernen
            return
        }
        print("aktueller user: \(user)")
        currentUser = user
        userDataViewModel.loadUserData(for: user.uid)
    }
    
    // Funktion zur Registrierung eines neuen Nutzers (Firebase Auth + Userdaten in FireStore anlegen)
    func register(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Fehler bei der Registrierung: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = result?.user else { return }

            // Erstellen einer Instanz von UserData
            let newUserData = UserData(
                username: username,
                usernameLowercase: username.lowercased(),
                email: email,
                regDate: nil
            )

            // User-Daten in Firestore speichern
            do {
                // Umwandeln der neuen User-Daten
                var data = try Firestore.Encoder().encode(newUserData)
                data["regDate"] = FieldValue.serverTimestamp() // Serverseitiger Timestamp

                self.usersCollectionReference.document(user.uid).setData(data) { error in
                    if let error = error {
                        print("Fehler beim Speichern der UserData: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true) // Erfolgreich gespeichert
                    }
                }
            } catch {
                print("Fehler beim Kodieren der User-Daten: \(error.localizedDescription)")
                completion(false)
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
            try auth.signOut() // Aus Firebase Auth ausloggen
            currentUser = nil // Benutzerstatus zurücksetzen
            print("User erfolgreich ausgeloggt")
        } catch {
            print("Fehler beim Ausloggen: \(error.localizedDescription)")
        }
    }
}
