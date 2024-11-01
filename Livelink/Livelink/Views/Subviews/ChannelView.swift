//
//  ChannelView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 02.11.24.
//

import SwiftUI

struct ChannelView: View {
    var channel: Channel

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: channel.backgroundUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(15)
                    .frame(height: 100)
                    .frame(width: 100)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .frame(width: 100)
                    .cornerRadius(15)
            }

            Text(channel.name)
                .font(.headline)
                .padding(.top, 8)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    ChannelView(channel: Channel(name: "Beispiel Kanal", backgroundUrl: "https://example.com/image.jpg", category: ""))
}

