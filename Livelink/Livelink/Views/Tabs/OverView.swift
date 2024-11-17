//
//  OverView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

// Repräsentiert die Anzeige der Tabview samt zugehöriger Views
struct OverView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isUserLocked = false
    
    var body: some View {
        ZStack {
            MainTabView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Überprüfen ob der Nutzer gesperrt ist
            if let currentUser = userViewModel.userData, currentUser.lockInfo != nil {
                isUserLocked = true
            }
        }
        .alert(isPresented: $isUserLocked) {
            let expirationTimestamp = userViewModel.userData!.lockInfo!.expirationTimestamp
            let duration: String

            if expirationTimestamp == -1 {
                duration = "permanent gesperrt."
            } else {
                let expirationDate = Date(timeIntervalSince1970: TimeInterval(expirationTimestamp))
                let calendar = Calendar.current
                let expirationDateNextDay = calendar.date(byAdding: .day, value: 1, to: expirationDate)!

                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none

                let formattedDate = dateFormatter.string(from: expirationDate)
                duration = "bis zum \(formattedDate) gesperrt und wird im Laufe des darauffolgenden Tages automatisch entsperrt."
            }

            return Alert(
                title: Text("Account gesperrt."),
                message: Text("Dein Account \(userViewModel.userData!.username) wurde von \(userViewModel.userData!.lockInfo!.lockedBy) \(duration) \n\nBegründung:\n\(userViewModel.userData!.lockInfo!.reason)"),
                dismissButton: .default(Text("OK"), action: {
                    userViewModel.logout()
                })
            )
        }
    }
}
