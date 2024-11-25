//
//  LoginView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import SwiftUI

// View für den Login
struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @State private var showResetPasswordView: Bool = false
    @State private var resetPasswordMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    Spacer().frame(height: 60)
                    
                    TextField("Benutzername", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)
                    
                    SecureField("Passwort", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)
                    
                    if let errorMessage = loginError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .frame(maxWidth: 300)
                        .padding(.top, 10)
                    }
                    
                    Button(action: {
                        login()
                    }) {
                        Text("Einloggen")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: 300)
                    .padding(.horizontal)
                    
                    Button("Passwort vergessen?") {
                        showResetPasswordView = true
                    }
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    
                    NavigationLink(destination: SignUpView().environmentObject(userViewModel)) {
                        Text("Noch kein Konto? Registriere dich hier.")
                            .foregroundColor(Color.white)
                            .padding()
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .sheet(isPresented: $showResetPasswordView) {
                ZStack {
                    VStack(spacing: 20) {
                        Text("Passwort vergessen")
                            .font(.title2)
                            .bold()
                        
                        TextField("Benutzername", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .frame(maxWidth: 300)
                            .shadow(radius: 10)
                        
                        if let message = resetPasswordMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        
                        Button("Passwort zurücksetzen") {
                            userViewModel.resetPassword(username: username) { success, message in
                                resetPasswordMessage = message
                            }
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        
                        Button("Abbrechen") {
                            showResetPasswordView = false
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: 400)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(15)
                }
                .presentationDetents([.fraction(0.4)]) // Anzeige auf 40% vom Bildschirm beschränken
            }
        }
    }

    private func login() {
        userViewModel.getMailFromUsername(username: username) { email in
            guard let email = email else {
                loginError = "Benutzername nicht gefunden."
                return
            }
            userViewModel.login(email: email, password: password) { success in
                if success {
                    loginError = nil
                } else {
                    loginError = "Ungültige Anmeldedaten."
                }
            }
        }
    }
}
