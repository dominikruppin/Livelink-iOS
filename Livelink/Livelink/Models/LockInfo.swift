//
//  LockInfo.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenstruktur für die Sperrung eines Nutzers
struct LockInfo: Codable {
    var lockedBy: String = ""
    var reason: String = ""
    var expirationTimestamp: Int64 = 0 
}
