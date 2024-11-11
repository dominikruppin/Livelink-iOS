//
//  Message.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import FirebaseFirestore

// Definiert das Format einer Chatnachricht (Message).
// Enthält den Benutzernamen des Senders, den Nachrichtentext und den Timestamp der Nachricht
struct Message: Codable, Equatable {
    var senderId: String = ""
    var content: String = ""
    var timestamp: Timestamp = Timestamp(date: Date())

    // Implementierung des Vergleichs (Equatable)
    static func == (lhs: Message, rhs: Message) -> Bool {
        // Vergleiche senderId und timestamp um zu schauen ob ein Message Objekt das gleiche ist
        return lhs.senderId == rhs.senderId && lhs.timestamp.dateValue() == rhs.timestamp.dateValue()
    }
}
