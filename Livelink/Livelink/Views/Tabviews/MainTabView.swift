//
//  MainTabView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct MainTabView: View {
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
            
            EditProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .tint(.white)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithTransparentBackground()
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().unselectedItemTintColor = UIColor(white: 1.0, alpha: 0.5)
        }
    }
}
