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
    @EnvironmentObject var userViewModel: UserViewModel
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
                            .font(.headline)
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
                    .frame(maxWidth: .infinity)
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
                        .padding(.bottom)
                        .padding(.horizontal)
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
            }
            .onAppear {
                Task {
                    await joinChannelAndFetchMessages()
                }
            }
            .onDisappear {
                channelsViewModel.onChannelLeave(username: userViewModel.userData!.username)
            }
            // Sheet für das Profil-Popup
            .sheet(isPresented: $userViewModel.showProfilePopup) {
                if let profileData = userViewModel.profileUserData {
                    ProfileViewPopup(profile: profileData)
                        .background(
                            Image("background")
                                .resizable()
                                .scaledToFill()
                                .edgesIgnoringSafeArea(.all)
                        )
                        .edgesIgnoringSafeArea(.all)
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
        if messageContent.lowercased().hasPrefix("paul") {
            let commandText = messageContent.dropFirst(4).trimmingCharacters(in: .whitespacesAndNewlines)
            let botRequest = BotRequest(
                model: "llama-3.1-sonar-small-128k-chat",
                messages: [
                    BotMessage(role: "system", content: "Du bist ein deutscher Chatbot namens Paul. Antworte nur auf Deutsch. Du arbeitest beim Syntax Institut."),
                    BotMessage(role: "user", content: commandText)
                ]
            )

            BotViewModel().sendMessage(apiKey: "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", request: botRequest) { botResponse in
                if let botResponse = botResponse {
                    let botMessage = Message(
                        senderId: "Paul", // Bot-Name
                        content: botResponse.choices.first?.message.content ?? "Ich mache aktuell eine Pause."
                    )
                    DispatchQueue.main.async {
                        channelsViewModel.sendMessage(message: botMessage)
                    }
                }
            }
        }

        let message = Message(senderId: userViewModel.userData!.username, content: messageContent)
        channelsViewModel.sendMessage(message: message)
        messageContent = ""
    }

}

