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
            
            ScrollView {
                VStack(spacing: 20) {
                    let groupedChannels = Dictionary(grouping: channelsViewModel.channels, by: { $0.category })
                    
                    ForEach(groupedChannels.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading) {
                            Text(category)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.leading)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(groupedChannels[category] ?? [], id: \.name) { channel in
                                        ChannelView(channel: channel)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    ChannelsView()
        .environmentObject(ChannelsViewModel())
}
