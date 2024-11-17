//
//  Choice.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenstruktur für die Antwort der Perplexity API
struct Choice: Codable {
    var message: BotMessage
}
