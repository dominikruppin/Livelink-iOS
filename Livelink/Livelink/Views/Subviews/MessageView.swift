//
//  MessageView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 11.11.24.
//

import SwiftUI

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
                Spacer()
            }
            Text(message.content)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func loadUserProfile(username: String) {
        userDatasViewModel.loadUserDataByUsername(username: username)
        userDatasViewModel.showProfilePopup = true
    }
}
