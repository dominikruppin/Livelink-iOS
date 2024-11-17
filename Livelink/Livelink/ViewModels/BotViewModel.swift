//
//  BotViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation

// ViewModel für die Bot-Kommunikation
class BotViewModel: ObservableObject {
    private let botRepository: BotRepository
    
    // Published Properties für die Beobachtung durch die View
    @Published var response: BotResponse? // Antwort von der API
    @Published var errorMessage: String?  // Fehlernachricht bei API-Fehlern

    // Initialisierung des ViewModels mit dem Repository
    init(botRepository: BotRepository = BotRepository()) {
        self.botRepository = botRepository
    }

    // Sendet eine Nachricht an die Perplexity API
    func sendMessage(apiKey: String, request: BotRequest, completion: @escaping (BotResponse?) -> Void) {
        botRepository.sendMessage(apiKey: apiKey, request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(response)
                case .failure(let error):
                    print("Bot API Error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
}
