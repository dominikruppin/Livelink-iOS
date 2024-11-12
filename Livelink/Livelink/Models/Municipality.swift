//
//  Municipality.swift
//  Livelink
//
//  Created by Dominik Ruppin on 07.11.24.
//

// Repräsentiert einen Kreis für die openPLZ API
struct Municipality: Codable {
    var key: String
    var name: String
    var type: String
}
