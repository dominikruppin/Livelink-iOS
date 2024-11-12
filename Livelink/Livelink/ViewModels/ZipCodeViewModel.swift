//
//  ZipCodeViewModel.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation
import Combine

// ViewModel für den Zugriff auf die openPLZ API
class ZipCodeViewModel: ObservableObject {
    private let zipCodeRepository: ZipCodeRepository
    @Published var zipCodeInfos: [ZipCodeInfos] = [] // Liste der PLZ-Infos
    @Published var errorMessage: String?  // Fehlernachricht bei API-Fehlern

    // Repository initialisieren
    init(zipCodeRepository: ZipCodeRepository = ZipCodeRepository()) {
        self.zipCodeRepository = zipCodeRepository
    }

    // Funktion zum laden der Infos zu einer Postleitzahl (Angabe des Landes mit kürzel DE/AT/CH nötig)
    func fetchZipInfos(country: String, postalCode: String, completion: @escaping (String?, String?, String?) -> Void) {
        zipCodeRepository.getZipInfos(country: country, postalCode: postalCode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let infos):
                    guard let info = infos.first else {
                        self?.errorMessage = "Keine PLZ-Informationen gefunden."
                        completion(nil, nil, nil)
                        return
                    }
                    
                    // Extrahiere Bundesland und Ort
                    let state = info.federalState.name // Bundesland
                    let city = info.name // Stadtname
                    
                    completion(state, city, nil)
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(nil, nil, error.localizedDescription)
                }
            }
        }
    }
}
