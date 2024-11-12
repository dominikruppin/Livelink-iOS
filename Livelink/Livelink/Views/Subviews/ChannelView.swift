//
//  ChannelView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 02.11.24.
//

import SwiftUI

// Repräsentiert die Anzeige eines Channels (Subview)
struct ChannelView: View {
    var channel: Channel

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: channel.backgroundUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(15)
                    .frame(width: 120, height: 100)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 100)
                    .cornerRadius(15)
            }

            Text(channel.name)
                .font(.headline)
                .padding(.top, 4)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2) // Maximal zwei Zeilen
                .frame(width: 115) // Gleiche Breite wie das Bild
                .frame(minHeight: 50, maxHeight: 50)
        }
        .frame(width: 120, height: 150) // Feste Gesamtgröße des ChannelView
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    ChannelView(channel: Channel(name: "Beispiel Kanal mit langem Namen", backgroundUrl: "https://example.com/image.jpg", category: ""))
}
