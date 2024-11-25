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
    // Globale Instanzen welche an die Views weitergegeben werden
    @StateObject private var channelsViewModel = ChannelsViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    
    init() {
            FirebaseConfiguration.shared.setLoggerLevel(.min)
            FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {            
            // AuthViewModel mit userViewModel
            if userViewModel.currentUser != nil {
                if userViewModel.isLoadingUserData {
                    LoadingView()
                        .environmentObject(userViewModel)
                        .onAppear {
                            if let uid = Auth.auth().currentUser?.uid {
                                userViewModel.loadUserData(for: uid)
                            }
                        }
                } else {
                    OverView()
                        .environmentObject(userViewModel)
                        .environmentObject(channelsViewModel)
                }
            } else {
                LoginView()
                    .environmentObject(userViewModel)
            }
        }
    }
}
