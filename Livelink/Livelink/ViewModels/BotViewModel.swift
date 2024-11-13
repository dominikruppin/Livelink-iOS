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
    func sendMessage(apiKey: String, request: BotRequest) {
        botRepository.sendMessage(apiKey: apiKey, request: request) { [weak self] result in
            DispatchQueue.main.async {
                // API Antwort bzw. mögliche Fehler verarbeiten
                switch result {
                case .success(let response):
                    self?.response = response
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
