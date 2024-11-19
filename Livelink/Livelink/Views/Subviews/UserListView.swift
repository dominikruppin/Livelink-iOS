//
//  UserListView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 17.11.24.
//

import SwiftUI

struct UserListView: View {
    @EnvironmentObject var channelsViewModel: ChannelsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var isUserListVisible: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Nutzer im Channel")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                
                ScrollView {
                    UserList(users: channelsViewModel.onlineUsers)
                }
            }
            .frame(width: 250)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .transition(.move(edge: .trailing))
            .animation(.easeInOut, value: isUserListVisible)
        }
        .sheet(isPresented: $userViewModel.showProfilePopup) {
            if let profileData = userViewModel.profileUserData {
                ProfileViewPopup(profile: profileData)
                    .background(
                        Image("background")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                    )
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct UserList: View {
    let users: [OnlineUser]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(users, id: \.username) { user in
                UserRow(user: user)
            }
        }
        .padding([.top, .horizontal])
    }
}

struct UserRow: View {
    let user: OnlineUser
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            // Profilbild
            AsyncImage(url: URL(string: user.profilePic)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } placeholder: {
                Color.gray.frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(user.username)
                        .font(.headline)
                        .foregroundColor(.white)

                    if user.gender == "Männlich" {
                        Text("👨")
                            .foregroundColor(.white)
                    } else if user.gender == "Weiblich" {
                        Text("👩")
                            .foregroundColor(.white)
                    }
                }
                
                HStack(spacing: 5) {
                    Text("\(user.age) Jahre")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 0)
        }
        .padding(.vertical, 5)
        .onTapGesture {
            // User Profil öffnen
            userViewModel.loadUserDataByUsername(username: user.username)
        }
    }
}
