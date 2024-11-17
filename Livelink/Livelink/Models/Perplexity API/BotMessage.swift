//
//  BotMessage.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenstruktur für die Nachricht an die Perplexity API
struct BotMessage: Codable {
    let role: String
    let content: String
}
