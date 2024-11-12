//
//  JoinedChannelView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 11.11.24.
//

import SwiftUI

// Wird angezeigt wenn man einen Channel betritt. Beinhaltet die Anzeige der Chatnachrichten sowie Eingabeleiste zum senden von Nachrichten an den Channel.
// TODO: USERLISTE
struct JoinedChannelView: View {
    @EnvironmentObject var channelsViewModel: ChannelsViewModel
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageContent = ""
    var channel: Channel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let backgroundURL = channelsViewModel.currentChannel?.backgroundURL {
                    AsyncImage(url: URL(string: backgroundURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width)
                            .edgesIgnoringSafeArea(.all)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                }
                
                VStack {
                    ScrollViewReader { scrollView in
                        ScrollView {
                            VStack {
                                ForEach(channelsViewModel.messages, id: \.timestamp) { message in
                                    MessageView(message: message)
                                        .padding(.vertical, 4)
                                        .id(message.timestamp)
                                }
                            }
                            .onChange(of: channelsViewModel.messages) { _ in
                                if let latestMessage = channelsViewModel.messages.last {
                                    withAnimation {
                                        scrollView.scrollTo(latestMessage.timestamp, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    HStack {
                        TextField("Nachricht senden...", text: $messageContent)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(maxWidth: geometry.size.width * 0.7) // 80% der Breite für das Textfeld
                    
                        Button(action: sendMessage) {
                            Text("Senden")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .frame(width: geometry.size.width * 0.25) // 18% für den Button
                    }
                    .padding(.horizontal, 4)
                    .frame(width: geometry.size.width * 0.95)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitle("Channel: " + channel.name, displayMode: .inline)
            .onAppear {
                Task {
                    await joinChannelAndFetchMessages()
                }
            }
            .onDisappear {
                channelsViewModel.onChannelLeave(username: userDatasViewModel.userData!.username)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Channel: " + channel.name)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
    }
    
    private func joinChannelAndFetchMessages() async {
        await channelsViewModel.joinChannel(channel: channel)
        channelsViewModel.fetchMessages()
    }
    
    private func sendMessage() {
        guard !messageContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let message = Message(senderId: userDatasViewModel.userData!.username, content: messageContent)
        channelsViewModel.sendMessage(message: message)
        messageContent = ""
    }
}

