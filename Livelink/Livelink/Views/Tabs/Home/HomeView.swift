import SwiftUI
import SwiftUIX

// Anzeigen der HomeView, also Übersicht bei eingeloggten Nutzer
// Beinhaltet Uhrzeitabhängig Begrüßung, Searchbar zur Nutzersuche, Anzeige der letzten Profilbesucher sowie besuchten Channel
struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var channelsViewModel: ChannelsViewModel
    @State private var searchQuery: String = ""
    @Binding var isChannelActive: Bool
    @Binding var selectedChannel: Channel?
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("\(greetingMessage()), \(userViewModel.userData?.username ?? "Gast")!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(16)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    
                    // SearchBar
                    SearchBar("Nutzer suchen...", text: $searchQuery)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    // Dropdown für Suchergebnisse
                    if !searchQuery.isEmpty && !userViewModel.searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(userViewModel.searchResults, id: \.username) { user in
                                        Text(user.username)
                                            .padding(.bottom)
                                            .cornerRadius(8)
                                            .padding(.horizontal, 16)
                                            .foregroundColor(.black)
                                            .onTapGesture {
                                                userViewModel.loadUserDataByUsername(username: user.username)
                                                userViewModel.showProfilePopup = true
                                            }
                                    }
                                }
                            }
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                            .frame(maxHeight: min(500, CGFloat(userViewModel.searchResults.count * 30))) // Dynamische Höhe basierend auf der Anzahl der Suchergebnisse
                        }
                    }
                    
                    // Profilbesucher anzeigen
                    if let userData = userViewModel.userData, !userData.recentProfileVisitors.isEmpty {
                        Text("Profilbesucher:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Spacer(minLength: 16)
                                ForEach(userData.recentProfileVisitors, id: \.username) { visitor in
                                    ProfileVisitorView(visitor: visitor)
                                        .onTapGesture {
                                            userViewModel.loadUserDataByUsername(username: visitor.username)
                                            userViewModel.showProfilePopup = true
                                        }
                                }
                                Spacer(minLength: 16)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Letzte Channel anzeigen
                    if let userData = userViewModel.userData, !userData.lastChannels.isEmpty {
                        Text("Letzte Channel:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Spacer(minLength: 16)
                                ForEach(userData.lastChannels, id: \.name) { channel in
                                    Button(action: {
                                        selectedChannel = channel
                                        isChannelActive = true
                                        print("Navigating to channel: \(channel.name)")
                                    }) {
                                        ChannelView(channel: channel)
                                    }
                                }
                                Spacer(minLength: 16)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .onAppear() {
                if let data = userViewModel.userData {
                    print("HomeViewData: \(data)")
                } else {
                    print("Keine Daten")
                }
            }
            .onChange(of: searchQuery) { newValue in
                userViewModel.searchUsers(query: newValue)
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
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Guten Morgen"
        case 12..<18: return "Guten Tag"
        case 18..<22: return "Guten Abend"
        default: return "Hallo"
        }
    }
}
