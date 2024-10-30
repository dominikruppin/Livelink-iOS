//
//  ZipCodeRepository.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation

// Repository für den Zugriff auf die OpenPLZ API
class ZipCodeRepository: ZipCodeApiService {
    private let baseUrl = URL(string: "https://openplzapi.org/")! // Basis-URL der OpenPLZ API

    // Holt die PLZ-Infos für ein bestimmtes Land und eine PLZ
    func getZipInfos(country: String, postalCode: String, completion: @escaping (Result<[ZipCodeInfos], Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("\(country)/Localities") // Endpunkt zusammensetzen
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "postalCode", value: postalCode)] // Parameter hinzufügen
        
        guard let finalUrl = urlComponents.url else {
            completion(.failure(NSError(domain: "URL Error", code: -1, userInfo: nil))) // Fehler bei der URL-Erstellung zurückgeben
            return
        }
        
        let task = URLSession.shared.dataTask(with: finalUrl) { data, response, error in
            if let error = error {
                completion(.failure(error)) // Fehler zurückgeben
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil))) // Fehler, wenn keine Daten empfangen werden
                return
            }
            
            do {
                let zipCodeInfos = try JSONDecoder().decode([ZipCodeInfos].self, from: data) // Antwort dekodieren
                completion(.success(zipCodeInfos)) // Erfolgreiche Antwort zurückgeben
            } catch {
                completion(.failure(error)) // Fehler bei der Dekodierung zurückgeben
            }
        }
        task.resume() // Anfrage ausführen
    }
}
