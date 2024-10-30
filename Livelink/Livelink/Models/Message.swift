//
//  Message.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import FirebaseFirestore

// Definiert das Format einer Chatnachricht (Message).
// Enthält den Benutzernamen des Senders, den Nachrichtentext und den Timestamp der Nachricht
struct Message: Codable {
    var senderId: String = ""
    var content: String = ""
    var timestamp: Timestamp = Timestamp(date: Date())
}
