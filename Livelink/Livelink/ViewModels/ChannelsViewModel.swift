//
//  ChannelsViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 02.11.24.
//

import Firebase
import FirebaseAuth
import Combine

class ChannelsViewModel: ObservableObject {
    @Published var channels = [Channel]()
    @Published var currentChannel: ChannelJoin?
    @Published var messages = [Message]()
    @Published var onlineUsers = [OnlineUser]()
    private var joinTimestamp: Timestamp?
    private var database = FirebaseManager.shared.database
    
    init() {
        fetchChannels()
    }
    
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
            print("Fetched channels: \(self._channels)")
        }
    }
    
    func joinChannel(channel: Channel, username: String) async {
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

    func fetchMessages() {
        print("Fetch Messages aufgerufen")
            guard let channelID = currentChannel?.channelID else { return }
        guard let joinTimestamp = currentChannel?.timestamp else { return }

            // Neue Nachrichten mit einem höheren Timestamp als der Beitritts-Timestamp
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
    
    // Funktion zum Abrufen der Online User eines Channels
    func fetchOnlineUsersInChannel() {
        guard let channelID = currentChannel?.channelID else { return }
        
        database.collection("channels").document(channelID).collection("onlineUsers")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching online users: \(error)")
                    return
                }
                
                self.onlineUsers = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: OnlineUser.self)
                } ?? []
                print("Fetched online users: \(self.onlineUsers)")
            }
    }
    
    // Funktion zum Hinzufügen oder Aktualisieren von Online User Daten
    func addOrUpdateOnlineUserData(username: String, age: String, gender: String, profilePic: String, status: Int) {
        guard let channelID = currentChannel?.channelID else { return }
        
        let onlineUserData: [String: Any] = [
            "username": username,
            "age": age,
            "gender": gender,
            "profilePic": profilePic,
            "status": status,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        database.collection("channels").document(channelID).collection("onlineUsers").document(username)
            .setData(onlineUserData) { error in
                if let error = error {
                    print("Error updating user data: \(error)")
                } else {
                    print("User data updated for \(username)")
                    self.fetchOnlineUsersInChannel()
                }
            }
    }
    
    // Funktion zum Aktualisieren des eigenen Timestamps in den Online Usern
    func updateOnlineUserTimestamp(username: String) {
        guard let channelID = currentChannel?.channelID else { return }
        
        database.collection("channels").document(channelID).collection("onlineUsers").document(username)
            .updateData(["timestamp": FieldValue.serverTimestamp()]) { error in
                if let error = error {
                    print("Error updating timestamp for \(username): \(error)")
                } else {
                    print("Timestamp updated for \(username)")
                    self.fetchOnlineUsersInChannel()
                }
            }
    }
    
    // Funktion um den Nutzer aus dem Channel zu entfernen
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
