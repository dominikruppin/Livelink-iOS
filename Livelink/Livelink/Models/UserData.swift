//
//  UserData.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import FirebaseFirestore

// Datenstruktur zum Speichern (Firestore) und Abrufen der Daten eines Nutzers
struct UserData: Codable {
    var username: String = ""
    var usernameLowercase: String = ""
    var email: String = ""
    var profilePicURL: String = ""
    var status: Int = 0
    var name: String = ""
    var age: String = ""
    var birthday: String = ""
    var gender: String = ""
    var relationshipStatus: String = ""
    var zipCode: String = ""
    var country: String = ""
    var state: String = ""
    var city: String = ""
    var lastChannels: [Channel] = []
    var recentProfileVisitors: [ProfileVisitor] = []
    var lockInfo: LockInfo? = nil
    var regDate: Timestamp = Timestamp(date: Date())
    var wildspace: String = ""
}
