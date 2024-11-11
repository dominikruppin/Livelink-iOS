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
    @State private var searchQuery: String = ""
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                // Begrüßung
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
                        ForEach(userDatasViewModel.searchResults, id: \.username) { user in
                            Text(user.username)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .padding(.horizontal, 16)
                                .foregroundColor(.black)
                                .onTapGesture {
                                    searchQuery = user.username
                                }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
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
                                    }
                            }
                            Spacer(minLength: 16)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Profilbesucher anzeigen
                if let userData = userDatasViewModel.userData, !userData.lastChannels.isEmpty {
                    Text("Letzte Channel:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Spacer(minLength: 16)
                            ForEach(userData.lastChannels, id: \.name) { channel in
                                ChannelView(channel: channel)
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
                ProfileViewPopup(profile: profileData)  // Zeige das Profil im Sheet
            }
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

