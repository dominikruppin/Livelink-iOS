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
            if authViewModel.currentUser != nil {
                // Lade die Benutzerdaten, bevor zur OverView navigiert wird
                if userDatasViewModel.isLoadingUserData {
                    // Ladebildschirm anzeigen
                    LoadingView()
                        .environmentObject(userDatasViewModel)
                        .onAppear {
                            if let uid = Auth.auth().currentUser?.uid {
                                userDatasViewModel.loadUserData(for: uid)
                            }
                        }
                } else {
                    // Falls die Benutzerdaten bereits geladen sind, zeige die OverView
                    OverView()
                        .environmentObject(userDatasViewModel)
                }
            } else {
                // Falls nicht eingeloggt, zur LoginView
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
