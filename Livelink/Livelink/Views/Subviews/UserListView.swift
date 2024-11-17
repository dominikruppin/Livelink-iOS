//
//  UserListView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 17.11.24.
//

import SwiftUI

struct UserListView: View {
    @EnvironmentObject var channelsViewModel: ChannelsViewModel
    @Binding var isUserListVisible: Bool

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Benutzerliste")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)

                ScrollView {
                    VStack(alignment: .leading) {
                        /*ForEach(channelsViewModel.users, id: \.username) { user in
                            Text(user.username)
                                .padding(.vertical, 5)
                        }*/
                    }
                    .padding()
                }

                Spacer()
            }
            .frame(width: 250)  // Breite der Benutzerliste
            .background(Color.gray.opacity(0.8))
            .cornerRadius(10)
            .transition(.move(edge: .trailing))
            .animation(.easeInOut, value: isUserListVisible)
            .onTapGesture {
                // Verhindert, dass das Panel geschlossen wird, wenn der Benutzer auf die Benutzerliste klickt
            }
        }
    }
}

