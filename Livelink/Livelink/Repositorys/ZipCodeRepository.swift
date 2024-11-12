//
//  ZipCodeRepository.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation

// Repository für den Zugriff auf die openPLZ API
class ZipCodeRepository: ZipCodeApiService {
    private let baseUrl = URL(string: "https://openplzapi.org/")! // Basis-URL
    
    // Funktion zum abrufen der Infos zu einer Postleitzahl (Land Angabe DE/CH/AT erforderlich)
    func getZipInfos(country: String, postalCode: String, completion: @escaping (Result<[ZipCodeInfos], Error>) -> Void) {
        let countryCode: String
        switch country.lowercased() {
        case "deutschland":
            countryCode = "de"
        case "schweiz":
            countryCode = "ch"
        case "österreich":
            countryCode = "at"
        default:
            completion(.failure(NSError(domain: "UnsupportedCountry", code: -1, userInfo: [NSLocalizedDescriptionKey: "Country not supported"])))
            return
        }
        let url = baseUrl.appendingPathComponent("\(countryCode)/Localities") // Erweiterer URL Pfad, Countrycode hinzugefügt
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        // Hinzufügen der Postleitzahl als Query-Parameter zur URL
        urlComponents.queryItems = [URLQueryItem(name: "postalCode", value: postalCode)]
        
        // Sicherstellen, dass die URL korrekt aufgebaut wurde, ansonsten Fehler zurückgeben
        guard let finalUrl = urlComponents.url else {
            completion(.failure(NSError(domain: "URL Error", code: -1, userInfo: nil)))
            return
        }
        
        // API Call mit der erstellten URL sowie Fehlerbehandlung
        let task = URLSession.shared.dataTask(with: finalUrl) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let zipCodeInfos = try JSONDecoder().decode([ZipCodeInfos].self, from: data)
                completion(.success(zipCodeInfos)) // Erfolgreiche Antwort zurückgeben
            } catch {
                completion(.failure(error)) // Fehler bei der Dekodierung zurückgeben
            }
        }
        task.resume()
    }
}
