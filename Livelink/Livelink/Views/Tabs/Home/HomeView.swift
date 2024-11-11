//
//  HomeView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI
import SwiftUIX

struct HomeView: View {
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    @EnvironmentObject var channelsViewModel: ChannelsViewModel
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("\(greetingMessage()), \(userDatasViewModel.userData?.username ?? "Gast")!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(16)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    
                    // SearchBar
                    SearchBar("Nutzer suchen...", text: $searchQuery)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    // Dropdown für Suchergebnisse
                    if !searchQuery.isEmpty && !userDatasViewModel.searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(userDatasViewModel.searchResults, id: \.username) { user in
                                        Text(user.username)
                                            .padding(.bottom)
                                            .cornerRadius(8)
                                            .padding(.horizontal, 16)
                                            .foregroundColor(.black)
                                            .onTapGesture {
                                                userDatasViewModel.loadUserDataByUsername(username: user.username)
                                                userDatasViewModel.showProfilePopup = true
                                            }
                                    }
                                }
                            }
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                            .frame(maxHeight: 300)
                        }
                    }
                    
                    // Profilbesucher anzeigen
                    if let userData = userDatasViewModel.userData, !userData.recentProfileVisitors.isEmpty {
                        Text("Profilbesucher:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Spacer(minLength: 16)
                                ForEach(userData.recentProfileVisitors, id: \.username) { visitor in
                                    ProfileVisitorView(visitor: visitor)
                                        .onTapGesture {
                                            userDatasViewModel.loadUserDataByUsername(username: visitor.username)
                                            userDatasViewModel.showProfilePopup = true
                                        }
                                }
                                Spacer(minLength: 16)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Letzte Channel anzeigen
                    if let userData = userDatasViewModel.userData, !userData.lastChannels.isEmpty {
                        Text("Letzte Channel:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Spacer(minLength: 16)
                                ForEach(userData.lastChannels, id: \.name) { channel in
                                    NavigationLink(destination: JoinedChannelView(channel: channel)
                                        .environmentObject(channelsViewModel)) {
                                            ChannelView(channel: channel)
                                        }
                                }
                                Spacer(minLength: 16)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .onChange(of: searchQuery) { newValue in
                userDatasViewModel.searchUsers(query: newValue)
            }
            
            // Sheet für das Profil-Popup
            .sheet(isPresented: $userDatasViewModel.showProfilePopup) {
                if let profileData = userDatasViewModel.profileUserData {
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
            .navigationTitle("") // Optional: Titel für die NavigationBar
            .navigationBarHidden(true) // Optional: NavigationBar ausblenden
        }
    }
    
    private func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Guten Morgen"
        case 12..<18: return "Guten Tag"
        case 18..<22: return "Guten Abend"
        default: return "Hallo"
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserDatasViewModel())
}
