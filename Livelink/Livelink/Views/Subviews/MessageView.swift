//
//  MessageView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 11.11.24.
//

import SwiftUI

// Repräsentiert die Anzeige einer Chatnachricht (Subview)
struct MessageView: View {
    var message: Message
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(message.senderId)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        loadUserProfile(username: message.senderId)
                    }
            }
            
            Text(message.content)
                .font(.body)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)  // Verhindert horizontales Dehnen, passt sich aber vertikal an
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity, alignment: .leading)  // Maximal die Breite des Textes einnehmen, nicht mehr
    }
    
    private func loadUserProfile(username: String) {
        userDatasViewModel.loadUserDataByUsername(username: username)
        userDatasViewModel.showProfilePopup = true
    }
}
