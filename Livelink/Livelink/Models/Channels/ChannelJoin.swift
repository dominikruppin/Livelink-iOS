//
//  ChannelJoin.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import FirebaseFirestore

// Datenstruktur für die Speicherung des Channels, den man aktuell betreten hat
// Speichert die Channel-ID (gleichzeitig Channelname) und den Zeitpunkt, wann der Channel betreten wurde
struct ChannelJoin: Codable {
    var channelID: String
    var backgroundURL: String
    var timestamp: Timestamp = Timestamp(date: Date())
}
