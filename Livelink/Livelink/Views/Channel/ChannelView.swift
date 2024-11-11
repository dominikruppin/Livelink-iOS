//
//  ChannelView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 11.11.24.
//

import SwiftUI

struct JoinedChannelView: View {
    @ObservedObject var channelsViewModel = ChannelsViewModel()
    @State private var messageContent = ""
    var channel: Channel
    
    var body: some View {
        VStack {
            // Channel Information
            Text(channel.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Nachrichten-Anzeige
            ScrollView {
                VStack {
                    ForEach(channelsViewModel.messages, id: \.timestamp) { message in
                        MessageView(message: message)
                            .padding(.vertical, 4)
                    }
                }
            }

            // Nachricht-Eingabe
            HStack {
                TextField("Nachricht senden...", text: $messageContent)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                
                Button(action: sendMessage) {
                    Text("Senden")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarTitle(channel.name, displayMode: .inline)
        .onAppear {
            channelsViewModel.joinChannel(channel: channel)
            channelsViewModel.fetchMessages()
        }
    }
    
    private func sendMessage() {
        let message = Message(senderId: "currentUser", content: messageContent)
        channelsViewModel.sendMessage(message: message)
        messageContent = ""  // Nachricht zurücksetzen
    }
}
