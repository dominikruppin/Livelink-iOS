//
//  HomeView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    @State private var searchQuery: String = ""
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                // Begrüßung mit Nutzername und Tageszeit
                Text("\(greetingMessage()), \(userDatasViewModel.userData?.username ?? "Gast")!")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Suchleiste
                HStack {
                    TextField("Nutzer suchen...", text: $searchQuery, onCommit: {
                        userDatasViewModel.searchUsers(query: searchQuery)
                    })
                    .padding(10)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Spacer()
                            if !searchQuery.isEmpty {
                                Button(action: { searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    )
                    .padding(.horizontal, 16)
                }

                // Suchergebnisse anzeigen
                ScrollView {
                    ForEach(userDatasViewModel.searchResults, id: \.username) { user in
                        Text(user.username)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
    
    // Begrüßung basierend auf der Tageszeit
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
