//
//  ProfileVisitor.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

// Datenstruktur zum Speichern eines Profilbesuchers in UserData
struct ProfileVisitor: Codable {
    var username: String = ""
    var profilePicURL: String = ""
    
    func toDictionary() -> [String: Any] {
            return [
                "username": username,
                "profilePicURL": profilePicURL
            ]
        }
}
