//
//  ChannelsViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 02.11.24.
//

import Firebase
import FirebaseAuth

// ViewModel zur Verwaltung der Channelaktionen
class ChannelsViewModel: ObservableObject {
    // Speichert das Array welches alle verfügbaren Channel beinhaltet
    @Published var channels = [Channel]()
    // Beinhaltet den aktuellen Channel in dem sich der Nutzer aufhält (falls er sich in einem aufhält)
    @Published var currentChannel: ChannelJoin?
    // Speichert die Nachrichten des Channels
    @Published var messages = [Message]()
    // Speichert die Liste der OnlineUser
    @Published var onlineUsers = [OnlineUser]()
    private var database = FirebaseManager.shared.database
    private let botViewModel = BotViewModel()
    private var onlineUsersListener: ListenerRegistration?
    
    // Direkt beim starten der App holen wir uns die aktuelle Channelliste
    init() {
        fetchChannels()
    }
    
    // Funktion zum laden der aktuellen Channelliste - Auf Snapshotlistener verzichtet da diese sich selten ändert
    func fetchChannels() {
        database.collection("channels").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching channels: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No channels found")
                return
            }
            
            self.channels = documents.compactMap { document in
                try? document.data(as: Channel.self)
            }
        }
    }
    
    // Funktion um einen Channel zu betreten (lastChannel wird aktualisiert, messages geleert falls noch Nachrichten von altem Channelbeitritt vorhanden und das ChannelJoin Objekt erstellt)
    func joinChannel(channel: Channel) async {
        DispatchQueue.main.async {
            self.messages = []
            self.currentChannel = ChannelJoin(channelID: channel.name, backgroundURL: channel.backgroundUrl)
        }
        
        let userDataRef = database.collection("users").document(Auth.auth().currentUser!.uid)
        
        do {
            // Aktuelle Liste der lastChannels abrufen
            let userDocument = try await userDataRef.getDocument()
            var updatedLastChannels = userDocument.data()?["lastChannels"] as? [[String: Any]] ?? []
            
            // Channel in Dictionary umwandeln
            let channelDict: [String: Any] = [
                "name": channel.name,
                "backgroundUrl": channel.backgroundUrl,
                "category": channel.category
            ]
            
            // Prüfen, ob der Channel bereits in der Liste vorhanden ist
            if let existingChannelIndex = updatedLastChannels.firstIndex(where: { ($0["name"] as? String) == channel.name }) {
                // Channel entfernen, damit wir ihn später an die erste Position hinzufügen können
                updatedLastChannels.remove(at: existingChannelIndex)
            }
            
            // Channel am Anfang der Liste einfügen
            updatedLastChannels.insert(channelDict, at: 0)
            
            // Falls die Liste mehr als 10 Channels enthält, entfernen wir den ältesten
            if updatedLastChannels.count > 10 {
                updatedLastChannels.removeFirst()
            }
            
            // Aktualisierte Liste in Firebase speichern
            try await userDataRef.updateData([
                "lastChannels": updatedLastChannels
            ])
            
            print("Channel erfolgreich zu lastChannels hinzugefügt.")
        } catch {
            print("Fehler beim Hinzufügen des Channels zu lastChannels: \(error)")
        }
    }
    
    // Funktion zum abrufen der Nachrichten in einem Channel (samt Echtzeitupdate durch Snapshotlistener)
    func fetchMessages() {
        print("Fetch Messages aufgerufen")
        guard let channelID = currentChannel?.channelID else { return }
        guard let joinTimestamp = currentChannel?.timestamp else { return }
        
        // Neue Nachrichten mit einem höheren Timestamp als der Beitritts-Timestamp laden
        database.collection("channels")
            .document(channelID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .whereField("timestamp", isGreaterThan: joinTimestamp)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No messages found")
                    return
                }
                
                // Nachrichten aus dem Snapshot extrahieren
                self.messages = documents.compactMap { document in
                    try? document.data(as: Message.self)
                }
                
                print("Loaded messages: \(self.messages)")
            }
    }
    
    // Ist für das senden von Nachrichten an FireStore zuständig. Prüft ebenfalls ob der Bot angesprochen wurde und führt API Call aus
    func handleSendMessage(username: String, content: String) {
        let message = Message(senderId: username, content: content)
        
        DispatchQueue.main.async {
            self.sendMessage(message: message)
        }
        // Prüfen, ob die Nachricht mit "Paul" beginnt
        if content.lowercased().hasPrefix("paul") {
            let commandText = content.dropFirst(4).trimmingCharacters(in: .whitespacesAndNewlines)
            let botRequest = BotRequest(
                model: "llama-3.1-sonar-small-128k-chat",
                messages: [
                    BotMessage(role: "system", content: "Du bist ein deutscher Chatbot namens Paul. Antworte nur auf Deutsch."),
                    BotMessage(role: "user", content: commandText)
                ]
            )
            
            // Bot-Nachricht senden
            botViewModel.sendMessage(apiKey: apiKey, request: botRequest) { botResponse in
                if let botResponse = botResponse {
                    let botMessage = Message(
                        senderId: "Paul",
                        content: botResponse.choices.first?.message.content ?? "Ich mache aktuell eine Pause."
                    )
                    DispatchQueue.main.async {
                        self.sendMessage(message: botMessage)
                    }
                }
            }
        }
    }
    
    // Funktion zum Senden einer Nachricht an einen Channel
    func sendMessage(message: Message) {
        guard let channelID = currentChannel?.channelID else { return }
        
        let messageData: [String: Any] = [
            "senderId": message.senderId,
            "content": message.content,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        database.collection("channels").document(channelID).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent successfully.")
            }
        }
    }
    
    // Funktion zum Hinzufügen oder Aktualisieren von Online User Daten
    func addOrUpdateOnlineUserData(username: String, age: String, gender: String, profilePic: String, status: Int) {
        guard let channelID = currentChannel?.channelID else { return }
        
        let onlineUserData = OnlineUser(username: username, age: age, gender: gender, profilePic: profilePic, status: status)
        
        database.collection("channels").document(channelID).collection("onlineUsers").document(username)
            .setData(onlineUserData.toDictionary(), merge: true) { error in
                if let error = error {
                    print("Error updating user data: \(error)")
                } else {
                    print("User data updated for \(username)")
                }
            }
    }
    
    // Funktion um die OnlineUser abzurufen
    func fetchOnlineUsers() {
        guard let channelID = currentChannel?.channelID else { return }
        
        let currentTime = Date()
        let sixSecondsAgo = currentTime.addingTimeInterval(-6)
        
        // Abrufen der OnlineUser, die innerhalb der letzten 6 Sekunden aktiv waren und nach joinTimestamp sortiert
        database.collection("channels")
            .document(channelID)
            .collection("onlineUsers")
            .whereField("timestamp", isGreaterThan: sixSecondsAgo) // Nur Nutzer innerhalb der letzten 6 Sekunden
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Fehler beim Abrufen der Online-User: \(error)")
                    return
                }
                
                // OnlineUser extrahieren
                let newUsers = querySnapshot?.documents.compactMap {
                    try? $0.data(as: OnlineUser.self)
                } ?? []
                
                // Liste der OnlineUser aktualisieren
                self.onlineUsers = newUsers
            }
    }
    
    func checkUserOnlineInAnyChannel(username: String, completion: @escaping (String?) -> Void) {
        let channelsReference = database.collection("channels")
        // Alle Channels durchgehen, um nach dem Nutzer zu suchen
        channelsReference.getDocuments { (channelsSnapshot, error) in
            if let error = error {
                print("Error checking user online status: \(error.localizedDescription)") // Fehler bei der Abfrage der Channels
                completion(nil)
                return
            }
            
            for channelDoc in channelsSnapshot!.documents {
                let channelID = channelDoc.documentID
                
                let onlineUserRef = channelsReference
                    .document(channelID)
                    .collection("onlineUsers")
                    .document(username)
                
                onlineUserRef.getDocument { (onlineUserDoc, error) in
                    if let error = error {
                        print("Error checking online user in channel \(channelID): \(error.localizedDescription)") // Fehler bei der Abfrage des Nutzers im Channel
                        return
                    }
                    
                    if let onlineUserDoc = onlineUserDoc, onlineUserDoc.exists {
                        // Benutzer gefunden, Rückgabe des Channelnamens
                        completion(channelID)
                        return
                    }
                }
            }
            // Falls der Benutzer in keinem Channel online ist
            completion(nil)
        }
    }
    
    
    // Funktion um den Timestamp eines OnlineUsers zu updaten
    func updateOnlineUserTimestamp(username: String) {
        guard let channelID = currentChannel?.channelID else { return }
        
        let onlineUsersRef = database.collection("channels")
            .document(channelID)
            .collection("onlineUsers")
            .document(username)
        
        // Timestamp updaten
        onlineUsersRef.updateData(["timestamp": FieldValue.serverTimestamp()]) { error in
            if let error = error {
                print("Error updating timestamp for \(username): \(error)")
            } else {
                print("Timestamp updated for \(username)")
                self.fetchOnlineUsers() // OnlineUser updaten
            }
        }
    }
    
    
    // Funktion um den Nutzer aus den Online Users des Channels zu entfernen
    func onChannelLeave(username: String) {
        guard let channelID = currentChannel?.channelID else { return }
        
        database.collection("channels").document(channelID).collection("onlineUsers").document(username)
            .delete() { error in
                if let error = error {
                    print("Error removing user: \(error)")
                } else {
                    print("User removed: \(username)")
                }
            }
    }
}
