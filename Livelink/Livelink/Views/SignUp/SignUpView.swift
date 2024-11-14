//
//  SignUpView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import SwiftUI
import Combine

// View für die Registrierung
struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode // Für die Navigation zurück
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var registrationError: String?
    @State private var isUsernameAvailable: Bool = true
    @State private var isUsernameValid: Bool = true
    @State private var isEmailValid: Bool = true
    @State private var isPasswordConfirmed: Bool = true
    
    // Für den Hinweis zur Registrierung
    @State private var registrationMessage: String?
    @State private var showRegistrationMessage: Bool = false
    
    // Regex für gültige Zeichen in Nutzernamen
    private let validUsernameRegex = "^[A-Za-z0-9 ]+$"
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Registrieren")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                Spacer().frame(height: 60)
                
                // Benutzername-Eingabefeld mit Verfügbarkeit-Check
                VStack(alignment: .leading) {
                    TextField("Benutzername", text: $username)
                        .onChange(of: username, perform: { _ in validateUsername() })
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)
                    
                    if !isUsernameAvailable {
                        Text("Benutzername bereits vergeben")
                            .foregroundColor(.red)
                    } else if !isUsernameValid {
                        Text("Ungültiger Benutzername (nur Buchstaben, Zahlen und Leerzeichen)")
                            .foregroundColor(.red)
                    }
                }
                
                // E-Mail-Eingabefeld mit Validierung
                VStack(alignment: .leading) {
                    TextField("E-Mail", text: $email)
                        .onChange(of: email) { _ in isEmailValid = validateEmail(email) }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)
                    
                    if !isEmailValid {
                        Text("Ungültige E-Mail-Adresse")
                            .foregroundColor(.red)
                    }
                }
                
                // Passwort-Eingabefelder mit Passwort-Bestätigung
                SecureField("Passwort", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .frame(maxWidth: 300)
                    .padding(.horizontal)
                
                SecureField("Passwort bestätigen", text: $confirmPassword)
                    .onChange(of: confirmPassword) { _ in
                        isPasswordConfirmed = (password == confirmPassword)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .frame(maxWidth: 300)
                    .padding(.horizontal)
                
                if !isPasswordConfirmed {
                    Text("Passwörter stimmen nicht überein")
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                if let errorMessage = registrationError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if showRegistrationMessage, let message = registrationMessage {
                    Text(message)
                        .foregroundColor(.green)
                        .padding()
                        .transition(.opacity)
                }
                
                Spacer().frame(height: 30)
                
                // Registrieren-Button
                Button(action: register) {
                    Text("Registrieren")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .frame(maxWidth: 300)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.bottom, 40)
        }
    }
    
    private func register() {
        // Vor der Registrierung alle Felder überprüfen
        guard isUsernameAvailable, isUsernameValid, isEmailValid, isPasswordConfirmed else {
            registrationError = "Bitte alle Felder korrekt ausfüllen."
            return
        }
        
        userViewModel.register(username: username, email: email, password: password) { success in
            if success {
                registrationMessage = "Registrierung erfolgreich! Du wirst weitergeleitet..."
                showRegistrationMessage = true
                
                // Zeige den Hinweis und leite zur LoginView um
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    presentationMode.wrappedValue.dismiss() // Zurück zur LoginView
                }
            } else {
                registrationError = "Fehler bei der Registrierung. Versuche es erneut."
                registrationMessage = nil
                showRegistrationMessage = false
            }
        }
    }
    
    private func validateUsername() {
        // Überprüfen, ob der Benutzername gültig ist
        isUsernameValid = username.range(of: validUsernameRegex, options: .regularExpression) != nil
        if isUsernameValid {
            userViewModel.isUsernameTaken(username: username) { isTaken in
                isUsernameAvailable = !isTaken
            }
        } else {
            isUsernameAvailable = true
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        // Regex Prüfung für die Emailadresse
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}
