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
    // Für Fehlermeldungen wenn ein / Befehl nicht existiert
    @State private var commandStatusMessage: String?
    
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
                            print("Userliste hier rein")
                        }) {
                            Image(systemName: "person.2.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    
                    // Statusmeldung für unbekannte Befehle
                    if let commandStatusMessage = self.commandStatusMessage {
                        Text(commandStatusMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeOut(duration: 0.3), value: commandStatusMessage)
                    }
                    
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
    
    
    // Funktion um den Channel zu betreten und das abrufen der Nachrichten zu starten
    private func joinChannelAndFetchMessages() async {
        await channelsViewModel.joinChannel(channel: channel)
        channelsViewModel.fetchMessages()
    }
    
    // Funktion zum Senden der Nachricht an den Channel
    private func sendMessage() {
        guard !messageContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if messageContent.starts(with: "/") {
            handleCommands(command: messageContent)
        } else {
            channelsViewModel.handleSendMessage(username: userViewModel.userData!.username, content: messageContent)
        }
        messageContent = ""  // Eingabefeld leeren
    }
    
    // Funktion zum steuern von Chatbefehlen (/)
    private func handleCommands(command: String) {
        let commandParts = command.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        let commandString = String(commandParts.first ?? "")
        let commandText = commandParts.count > 1 ? String(commandParts[1]) : ""
        let commandEnum = Command(commandString: commandString)
        
        switch commandEnum {
            case .userlock:
                if userViewModel.userData?.status ?? 0 < 3 {
                    showCommandMessage(message: "Du besitzt nicht die notwendigen Rechte.")
                } else {
                    userViewModel.lockUser(command: commandText) { message in
                        showCommandMessage(message: message)
                    }
                }
            case .profil:
                userViewModel.loadUserDataByUsername(username: commandText)
            case .unknown:
                showCommandMessage(message: "Unbekannter Befehl. Bitte probiere es erneut.")
            }
    }
    
    private func showCommandMessage(message: String) {
        self.commandStatusMessage = message
        
        // Nach 3 Sekunden die Statusnachricht wieder entfernen
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.commandStatusMessage = nil
        }
    }
}
