//
//  ChannelsView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct ChannelsView: View {
    @EnvironmentObject var channelsViewModel: ChannelsViewModel
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
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
                                            ChannelView(channel: channel)
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



#Preview {
    ChannelsView()
        .environmentObject(ChannelsViewModel())
}
