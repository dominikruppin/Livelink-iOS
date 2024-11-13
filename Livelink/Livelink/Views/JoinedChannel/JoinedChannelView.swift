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
    @State private var messageContent = ""
    var channel: Channel
    @Binding var isChannelActive: Bool
    @Binding var selectedChannel: Channel?
    
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
                    // Custom Toolbar
                    HStack {
                        Button(action: {
                            isChannelActive = false
                            selectedChannel = nil
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Channel: \(channel.name)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            print("More options pressed")
                        }) {
                            Image(systemName: "ellipsis.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    
                    // Chat Content
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
                    
                    // Nachricht senden
                    HStack {
                        TextField("Nachricht senden...", text: $messageContent)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(maxWidth: geometry.size.width * 0.7) // Breite für das Textfeld
                    
                        Button(action: sendMessage) {
                            Text("Senden")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .frame(width: geometry.size.width * 0.25) // Breite für den  Senden Button
                    }
                    .padding(.horizontal, 4)
                    .frame(width: geometry.size.width * 0.95)
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                print("JoinedChannelView appeared for \(channel.name)")
                Task {
                    await joinChannelAndFetchMessages()
                }
            }
            .onDisappear {
                print("Leaving channel: \(channel.name)")
                channelsViewModel.onChannelLeave(username: userDatasViewModel.userData!.username)
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
