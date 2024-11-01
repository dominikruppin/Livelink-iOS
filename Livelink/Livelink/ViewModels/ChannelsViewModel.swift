//
//  ChannelsViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 02.11.24.
//

import Firebase
import Combine

class ChannelsViewModel: ObservableObject {
    @Published var channels = [Channel]()
    @Published var currentChannel: ChannelJoin?
    @Published private var messages = [Message]()
    @Published var onlineUsers = [OnlineUser]()
    
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

    // Funktion um einen Channel zu betreten
    func joinChannel(channel: Channel) {
        messages = []
        currentChannel = ChannelJoin(channelID: channel.name, backgroundURL: channel.backgroundUrl)

        // Nutzer-Daten aktualisieren (Platzhalter für den Nutzer)
        let username = "currentUserUsername" // Ersetze mit dem aktuellen Benutzernamen
        let userDataRef = database.collection("users").document(username)
        
        // Hier fügen wir nun den betretenen Channel in die UserData des
        // eingeloggten Users bei den lastChannels hinzu
        userDataRef.updateData([
            "lastChannels": FieldValue.arrayUnion([channel])
        ]) { error in
            if let error = error {
                print("Error adding channel to lastChannels: \(error)")
            } else {
                print("Channel successfully added to lastChannels.")
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

    // Funktion zum Abrufen der Nachrichten eines Channels
    func fetchMessages() {
        guard let channelID = currentChannel?.channelID else { return }

        database.collection("channels").document(channelID).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }

                self.messages = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Message.self)
                } ?? []
                print("Loaded messages: \(self._messages)")
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
