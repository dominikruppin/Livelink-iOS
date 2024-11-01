//
//  BotRequest.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenstruktur für die Anfrage an die Perplexity API
struct BotRequest: Codable {
    let model: String
    let messages: [BotMessage]
    var language: String = "de"
}
