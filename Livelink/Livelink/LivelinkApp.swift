//
//  LivelinkApp.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct LivelinkApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userDatasViewModel = UserDatasViewModel()
    
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            // Überprüfen, ob ein Nutzer eingeloggt ist...
            if authViewModel.currentUser != nil {
                // Falls ja, ab in die HomeView
                OverView()
                    .environmentObject(userDatasViewModel)
            } else {
                // Falls nein, ab in die LoginView du Schlingel
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
