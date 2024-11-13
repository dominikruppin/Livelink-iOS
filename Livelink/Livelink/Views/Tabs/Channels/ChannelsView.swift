//
//  ChannelsView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

// Zeigt die Übersicht aller Channel, unterteilt in Kategorien + Channels
struct ChannelsView: View {
    @EnvironmentObject var channelsViewModel: ChannelsViewModel
    @Binding var isChannelActive: Bool // Bindung zum Zustand der aktiven Channel
    @Binding var selectedChannel: Channel? // Bindung zur aktuell ausgewählten Channel
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Gruppierung der Channels nach Kategorie
                            let groupedChannels = Dictionary(grouping: channelsViewModel.channels, by: { $0.category })
                            
                            ForEach(groupedChannels.keys.sorted(), id: \.self) { category in
                                VStack(alignment: .leading) {
                                    Text(category)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 32)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(groupedChannels[category] ?? [], id: \.name) { channel in
                                                Button(action: {
                                                    selectedChannel = channel
                                                    isChannelActive = true
                                                }) {
                                                    ChannelView(channel: channel)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 32)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal, 32)
                    Spacer().frame(height: 10)
                }
            }
        }
    }
}

#Preview {
    ChannelsView(isChannelActive: .constant(false), selectedChannel: .constant(nil))
        .environmentObject(ChannelsViewModel())
}
