//
//  BotRepository.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation

// Repository für den Zugriff auf die Bot-API
class BotRepository: BotApiService {
    private let baseUrl = URL(string: "https://api.perplexity.ai/chat/completions")! // Basis-URL der Bot-API

    // Sendet eine Nachricht an die Bot-API
    func sendMessage(apiKey: String, request: BotRequest, completion: @escaping (Result<BotResponse, Error>) -> Void) {
        var urlRequest = URLRequest(url: baseUrl)
        urlRequest.httpMethod = "POST" // HTTP-Methode setzen
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type") // Content-Type für JSON
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // API-Key im Header hinzufügen
        
        do {
            let requestData = try JSONEncoder().encode(request) // Anfrage in JSON kodieren
            urlRequest.httpBody = requestData
        } catch {
            completion(.failure(error)) // Fehler bei der Kodierung zurückgeben
            return
        }
        
        // Anfrage mit URLSession senden
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error)) // Fehler zurückgeben
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil))) // Fehler, wenn keine Daten empfangen werden
                return
            }
            
            do {
                let botResponse = try JSONDecoder().decode(BotResponse.self, from: data) // Antwort dekodieren
                completion(.success(botResponse)) // Erfolgreiche Antwort zurückgeben
            } catch {
                completion(.failure(error)) // Fehler bei der Dekodierung zurückgeben
            }
        }
        task.resume() // Anfrage ausführen
    }
}
