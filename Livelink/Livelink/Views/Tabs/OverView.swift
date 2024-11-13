//
//  OverView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

// Repräsentiert die Anzeige der Tabview samt zugehöriger Views
struct OverView: View {
    @EnvironmentObject private var userDatasViewModel: UserDatasViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // Flag für gesperrten Nutzer
    @State private var isUserLocked = false
    
    var body: some View {
        ZStack {
            // Die Hauptansicht der App
            MainTabView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Überprüfe, ob der Nutzer gesperrt ist
            if let currentUser = userDatasViewModel.userData, currentUser.lockInfo != nil {
                // Setze das Flag für gesperrten Nutzer
                isUserLocked = true
                authViewModel.logout()
            }
        }
        .alert(isPresented: $isUserLocked) {
            Alert(
                title: Text("Du wurdest gesperrt."),
                message: Text("Du kannst dich nicht mehr anmelden."),
                dismissButton: .default(Text("OK"), action: {
                })
            )
        }
    }
}
