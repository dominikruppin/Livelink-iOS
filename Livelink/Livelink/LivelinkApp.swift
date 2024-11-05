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
    @StateObject private var channelsViewModel = ChannelsViewModel()
    
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.currentUser != nil {
                if userDatasViewModel.isLoadingUserData {
                    LoadingView()
                        .environmentObject(userDatasViewModel)
                        .onAppear {
                            if let uid = Auth.auth().currentUser?.uid {
                                userDatasViewModel.loadUserData(for: uid)
                            }
                        }
                } else {
                    OverView()
                        .environmentObject(userDatasViewModel)
                        .environmentObject(channelsViewModel)
                        .environmentObject(authViewModel)
                }
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
