//
//  ProfileViewPopup.swift
//  Livelink
//
//  Created by Dominik Ruppin on 11.11.24.
//

import SwiftUI
import WebKit

// Zeigt die HTML Inhalte in der Wildspace an
struct WebView: UIViewRepresentable {
    var htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

// Zeigt das Profil an
struct ProfileViewPopup: View {
    var profile: UserData
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                VStack {
                    // Profilbild
                    AsyncImage(url: URL(string: profile.profilePicURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    } placeholder: {
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .padding(20)
                            .background(Circle().fill(Color.white).shadow(radius: 10))
                    }
                    
                    // Username
                    Text(profile.username)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    // Status
                    Text(getStatusText(for: profile.status))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if isProfileEmpty() {
                            Text("Leider wissen wir noch nichts über \(profile.username).")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Profilinformationen anzeigen
                        Group {
                            if !profile.name.isEmpty {
                                ProfileInfoView(label: "Name", value: profile.name)
                            }
                            
                            if !profile.age.isEmpty {
                                ProfileInfoView(label: "Alter", value: profile.age)
                            }
                            
                            if !profile.birthday.isEmpty {
                                ProfileInfoView(label: "Geburtstag", value: profile.birthday)
                            }
                            
                            if !profile.gender.isEmpty {
                                ProfileInfoView(label: "Geschlecht", value: profile.gender)
                            }
                            
                            if !profile.relationshipStatus.isEmpty {
                                ProfileInfoView(label: "Beziehungsstatus", value: profile.relationshipStatus)
                            }
                            
                            if !profile.country.isEmpty {
                                ProfileInfoView(label: "Land", value: profile.country)
                            }
                            
                            if !profile.city.isEmpty {
                                ProfileInfoView(label: "Stadt", value: profile.city)
                            }
                            
                            if !profile.state.isEmpty {
                                ProfileInfoView(label: "Bundesland", value: profile.state)
                            }
                            
                            if !profile.wildspace.isEmpty {
                                Text("Wildspace")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(alignment: .leading)
                                WebView(htmlContent: transformWildspace(profile.wildspace))
                                    .frame(height: 400)
                            }
                        }
                    }
                }
                
                Button(action: {
                    userDatasViewModel.closeProfilePopup()
                }) {
                    Text("Schließen")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private func getStatusText(for status: Int) -> String {
        switch status {
        case 6:
            return "Admin"
        case 11:
            return "Sysadmin"
        default:
            return "Mitglied"
        }
    }
    
    private func isProfileEmpty() -> Bool {
        return profile.name.isEmpty &&
        profile.age.isEmpty &&
        profile.birthday.isEmpty &&
        profile.gender.isEmpty &&
        profile.relationshipStatus.isEmpty &&
        profile.country.isEmpty &&
        profile.city.isEmpty &&
        profile.state.isEmpty &&
        profile.wildspace.isEmpty
    }
    
    // Funktion, die das erste Bild ersetzt und alle anderen entfernt
    // TODO! FUNKTIONIERT NOCH NICHT.
    private func transformWildspace(_ content: String) -> String {
        // Finde alle [LINK] Tags mit einer URL
        let pattern = #"\[LINK\](http[^\s]+)"# // Sucht nach [LINK] gefolgt von einer URL
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        
        // Falls ein Link gefunden wird, ersetze ihn durch ein <img>-Tag
        if let match = regex?.firstMatch(in: content, options: [], range: NSRange(location: 0, length: content.count)) {
            let linkRange = match.range(at: 1) // Die URL befindet sich im ersten Capture Group
            
            if let linkRange = Range(linkRange, in: content) {
                let imageURL = String(content[linkRange])
                let imageTag = "<img src=\"\(imageURL)\" />"
                
                // Ersetze das erste Vorkommen des Links durch das <img>-Tag und entferne alle anderen [LINK] Tags
                var updatedContent = content.replacingOccurrences(of: "[LINK]\(imageURL)", with: imageTag)
                
                // Entferne alle anderen [LINK] Tags
                updatedContent = updatedContent.replacingOccurrences(of: "\\[LINK\\][^\\s]+", with: "", options: .regularExpression)
                
                return updatedContent
            }
        }
        
        return content
    }
}

struct ProfileInfoView: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.gray)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.body)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileViewPopup(profile: UserData(username: "Max Mustermann", profilePicURL: "https://example.com/profile.jpg", name: "Max Mustermann", age: "28", birthday: "1996-05-10", gender: "Männlich", relationshipStatus: "Verheiratet", country: "Deutschland", state: "Berlin", city: "Berlin", wildspace: "Das ist mein Wildspace. [LINK]https://example.com/image.jpg Mehr Text hier."))
        .environmentObject(UserDatasViewModel())
}
