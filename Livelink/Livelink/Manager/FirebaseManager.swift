//
//  FirebaseManager.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


// Verwaltet/hält die Instanzen der Firebase Dienste
class FirebaseManager {

    static let shared = FirebaseManager()

    private init() {}

    let auth = Auth.auth()
    let database = Firestore.firestore()
    let storage = Storage.storage()

    var userId: String? {
        auth.currentUser?.uid
    }
}
