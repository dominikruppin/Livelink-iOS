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
    
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
