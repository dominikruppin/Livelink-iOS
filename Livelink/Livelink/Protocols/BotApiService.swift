//
//  BotApiService.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation

// Protokoll für die Perplexity API
protocol BotApiService {
    func sendMessage(apiKey: String, request: BotRequest, completion: @escaping (Result<BotResponse, Error>) -> Void)
}
