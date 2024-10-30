//
//  BotResponse.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenstruktur für die Antwort von der Perplexity API
struct BotResponse: Codable {
    let choices: [Choice]
}
