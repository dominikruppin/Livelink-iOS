//
//  ZipCodeRepository.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation

class ZipCodeRepository: ZipCodeApiService {
    private let baseUrl = URL(string: "https://openplzapi.org/")!
    
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
        let url = baseUrl.appendingPathComponent("\(countryCode)/Localities")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "postalCode", value: postalCode)]
        
        guard let finalUrl = urlComponents.url else {
            completion(.failure(NSError(domain: "URL Error", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: finalUrl) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }
            
            let jsonString = String(data: data, encoding: .utf8)
            print("API Response: \(jsonString ?? "")")
            
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
