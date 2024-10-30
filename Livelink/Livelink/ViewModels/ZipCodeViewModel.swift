//
//  ZipCodeViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation
import Combine

// ViewModel für den Zugriff auf die ZipCode-Daten
class ZipCodeViewModel: ObservableObject {
    private let zipCodeRepository: ZipCodeRepository
    
    // Published Properties für die Beobachtung durch die View
    @Published var zipCodeInfos: [ZipCodeInfos] = [] // Liste der PLZ-Infos
    @Published var errorMessage: String?  // Fehlernachricht bei API-Fehlern

    // Initialisierung des ViewModels mit dem Repository
    init(zipCodeRepository: ZipCodeRepository = ZipCodeRepository()) {
        self.zipCodeRepository = zipCodeRepository
    }

    // Funktion zum Abrufen der PLZ-Infos
    func fetchZipInfos(country: String, postalCode: String) {
        zipCodeRepository.getZipInfos(country: country, postalCode: postalCode) { [weak self] result in
            DispatchQueue.main.async {
                // Verarbeitung des API-Antwort- oder Fehlerergebnisses
                switch result {
                case .success(let infos):
                    self?.zipCodeInfos = infos
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
