//
//  Channel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenstruktur, die einen Channel repräsentiert, in dem man chatten kann
struct Channel: Codable {
    var name: String = ""
    var backgroundUrl: String = ""
    var category: String = ""
}
