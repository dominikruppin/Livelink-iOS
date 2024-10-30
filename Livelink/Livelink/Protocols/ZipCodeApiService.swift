//
//  ZipCodeApiService.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import Foundation

// Protokoll für den Zugriff auf die OpenPLZ API
protocol ZipCodeApiService {
    func getZipInfos(country: String, postalCode: String, completion: @escaping (Result<[ZipCodeInfos], Error>) -> Void)
}
