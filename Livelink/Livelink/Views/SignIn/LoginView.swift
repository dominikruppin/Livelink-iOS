//
//  LoginView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import SwiftUI

// View für den Login
struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var username: String = "" // Benutzername speichern
    @State private var password: String = "" // Passwort speichern
    @State private var loginError: String? // Fehlernachricht

    var body: some View {
        NavigationView {
            ZStack {
                // Hintergrundbild
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

                    // Benutzername-Eingabefeld
                    TextField("Benutzername", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)

                    // Passwort-Eingabefeld
                    SecureField("Passwort", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)

                    // Fehlermeldung anzeigen
                    if let errorMessage = loginError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Einloggen-Button
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

                    // Navigationslink zur Registrierung
                    NavigationLink(destination: SignUpView()) {
                        Text("Noch kein Konto? Registriere dich hier.")
                            .foregroundColor(Color.white)
                            .padding()
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(.bottom, 40)
                .onAppear {
                    viewModel.setupUserEnv()
                }
            }
        }
    }

    private func login() {
        // E-Mail aus dem Benutzernamen abrufen
        viewModel.getMailFromUsername(username: username) { email in
            guard let email = email else {
                loginError = "Benutzername nicht gefunden."
                return
            }
            print(email)

            // Anmelden mit der E-Mail-Adresse
            viewModel.login(email: email, password: password) { success in
                if success {
                    // Login erfolgreich
                    print("Benutzer erfolgreich eingeloggt!")
                } else {
                    // Login fehlgeschlagen
                    loginError = "Ungültige Anmeldedaten."
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AuthViewModel())
    }
}
