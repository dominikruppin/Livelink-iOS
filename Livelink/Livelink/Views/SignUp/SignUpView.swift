//
//  SignUpView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 28.10.24.
//

import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var registrationError: String?

    var body: some View {
        VStack {
            Text("Registrierung")
                .font(.largeTitle)
                .padding()

            TextField("Benutzername", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("E-Mail", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Passwort", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Passwort bestätigen", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = registrationError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                // Registrierung durchführen
            }) {
                Text("Registrieren")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

