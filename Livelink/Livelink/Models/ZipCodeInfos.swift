//
//  ZipCodeInfos.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenklasse für die openPLZ API, zum abrufen der Postleitzahl Infos
// Name ist dabei der Städtename
// postalCode natürlich die Postleitzahl (welche man sowieso übergeben hat)
// Sowie das Bundesland als eigenes Objekt
struct ZipCodeInfos: Codable {
    var name: String
    var postalCode: String
    var federalState: FederalState?
}

