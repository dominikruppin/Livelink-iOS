//
//  MainTabView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ChannelsView()
                .tabItem {
                    Label("Channels", systemImage: "person.2")
                }

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .tint(.white)
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor(white: 1.0, alpha: 0.5)
        }
    }
}
