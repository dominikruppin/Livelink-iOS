//
//  UserDatasViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 01.11.24.
//

import Firebase
import FirebaseStorage
import FirebaseFirestore
import Combine
import SwiftUICore

class UserDatasViewModel: ObservableObject {
    private let database = FirebaseManager.shared.database
    private let usersCollectionReference: CollectionReference
    private let channelsReference: CollectionReference
    private var cancellables = Set<AnyCancellable>() // Für Combine
    
    @Published var userData: UserData?
    @Published var profileUserData: UserData?
    @Published var searchResults: [UserData] = []
    @Published var isLoadingUserData: Bool = true
    
    init() {
        self.usersCollectionReference = database.collection("users")
        self.channelsReference = database.collection("channels")
    }
    
    // Laden der Nutzerdaten mit Snapshot-Listener
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
    
    
    // User-Daten aktualisieren
    func updateUserData(uid: String, newData: [String: Any]) {
        usersCollectionReference.document(uid).updateData(newData) { error in
            if let error = error {
                print("Fehler beim Aktualisieren der User-Daten: \(error.localizedDescription)")
            }
        }
    }
    
    func uploadProfileImage(image: UIImage) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let timestamp = Int(Date().timeIntervalSince1970) // Aktueller Timestamp in Sekunden
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
    
    // Prüfen, ob ein Benutzername bereits existiert
    func isUsernameTaken(username: String, completion: @escaping (Bool) -> Void) {
        let lowercaseUsername = username.lowercased()
        usersCollectionReference.whereField("usernameLowercase", isEqualTo: lowercaseUsername)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Fehler bei der Überprüfung des Benutzernamens: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(snapshot?.isEmpty == false)
                }
            }
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
}
