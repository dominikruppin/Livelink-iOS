//
//  MainTabView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

// Tabview
struct MainTabView: View {
    @State private var isChannelActive = false
    @State private var selectedChannel: Channel? = nil
    
    var body: some View {
        ZStack {
            if !isChannelActive {
                // TabView anzeigen, wenn kein Channel aktiv ist
                TabView {
                    HomeView(isChannelActive: $isChannelActive, selectedChannel: $selectedChannel)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    ChannelsView(isChannelActive: $isChannelActive, selectedChannel: $selectedChannel)
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
            } else {
                // Anzeige der JoinedChannelView ohne Tabview
                if let selectedChannel = selectedChannel {
                    NavigationView {
                        JoinedChannelView(channel: selectedChannel, isChannelActive: $isChannelActive, selectedChannel: $selectedChannel)
                    }
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
