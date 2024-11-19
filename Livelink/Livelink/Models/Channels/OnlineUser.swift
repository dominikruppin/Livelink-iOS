//
//  OnlineUser.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import FirebaseFirestore

// Datenstruktur für das Speichern eines Nutzers in der Online-Benutzerliste
struct OnlineUser: Codable {
    var username: String = ""
    var age: String = ""
    var gender: String = ""
    var profilePic: String = ""
    var status: Int = 0
    var joinTimestamp: Timestamp = Timestamp(date: Date())
    var timestamp: Timestamp = Timestamp(date: Date())
    
    func toDictionary() -> [String: Any] {
            return [
                "username": username,
                "age": age,
                "gender": gender,
                "profilePic": profilePic,
                "status": status,
                "joinTimestamp": FieldValue.serverTimestamp(),
                "timestamp": FieldValue.serverTimestamp(),
            ]
        }
}
