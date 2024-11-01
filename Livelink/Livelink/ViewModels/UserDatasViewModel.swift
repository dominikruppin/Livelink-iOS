//
//  UserDatasViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 01.11.24.
//

import FirebaseFirestore
import Combine

class UserDatasViewModel: ObservableObject {
    private let database = Firestore.firestore()
    private let usersCollectionReference: CollectionReference
    private let channelsReference: CollectionReference
    private var cancellables = Set<AnyCancellable>() // Für Combine
    
    @Published var userData: UserData?
    @Published var profileUserData: UserData?
    @Published var searchResults: [UserData] = []
    @Published var onlineUsers: [OnlineUser] = []
    @Published var currentChannel: ChannelJoin?
    @Published var messages: [Message] = []
    
    init() {
        self.usersCollectionReference = database.collection("users")
        self.channelsReference = database.collection("channels")
    }
    
    // Laden der Nutzerdaten mit Snapshot-Listener
    func loadUserData(for uid: String) {
        let userDataDocumentReference = usersCollectionReference.document(uid)
        
        userDataDocumentReference.addSnapshotListener { [weak self] documentSnapshot, error in
            if let error = error {
                print("Fehler beim Laden der User-Daten: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists,
                  let data = document.data() else {
                print("Dokument existiert nicht oder enthält keine Daten.")
                self?.userData = nil
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
