//
//  EditProfileView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 05.11.24.
//

import SwiftUI

import SwiftUI

struct EditProfileView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var birthday: Date = Date()
    @State private var zipCode: String = ""
    @State private var gender: String = ""
    @State private var country: String = ""
    @State private var relationshipStatus: String = ""
    @State private var wildspace: String = ""

    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    private var canEdit: Bool {
        userDatasViewModel.userData != nil
    }

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            Form {
                // Profilbild
                AsyncImage(url: URL(string: userDatasViewModel.userData?.profilePicURL ?? "")) { image in
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
                .onTapGesture {
                    uploadProfileImage() // Funktion zum Auswählen und Hochladen eines neuen Bildes
                }

                // Benutzerinformationen
                TextField("Name", text: $name)
                    .disabled(!canEdit)
                
                TextField("Alter", text: $age)
                    .keyboardType(.numberPad)
                    .disabled(!canEdit)

                if let userBirthday = userDatasViewModel.userData?.birthday {
                    if let birthdayDate = stringToDate(userBirthday) {
                        Text("Geburtsdatum: \(formattedDate(birthdayDate))")
                    } else {
                        Text("Ungültiges Geburtsdatum")
                    }
                } else {
                    DatePicker("Geburtsdatum", selection: $birthday, displayedComponents: .date)
                        .disabled(!canEdit)
                }

                TextField("Postleitzahl", text: $zipCode)
                    .disabled(!canEdit)
                    
                Picker("Geschlecht", selection: $gender) {
                    Text("Männlich").tag("Männlich")
                    Text("Weiblich").tag("Weiblich")
                    Text("Divers").tag("Divers")
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(!canEdit)

                // Dropdown für Beziehungsstatus
                Picker("Beziehungsstatus", selection: $relationshipStatus) {
                    Text("Verheiratet").tag("Verheiratet")
                    Text("Ledig").tag("Ledig")
                    Text("In einer Beziehung").tag("In einer Beziehung")
                }
                .pickerStyle(MenuPickerStyle())
                .disabled(!canEdit)

                Picker("Land", selection: $country) {
                    Text("Deutschland").tag("Deutschland")
                    Text("Österreich").tag("Österreich")
                    Text("Schweiz").tag("Schweiz")
                }
                .pickerStyle(MenuPickerStyle())
                .disabled(!canEdit)

                TextField("Wildspace", text: $wildspace)
                    .disabled(!canEdit)

                Button(action: {
                    saveProfileData()
                }) {
                    Text("Speichern")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .disabled(!canEdit) // Button nur aktiv, wenn Felder bearbeitet werden können
            }
            .padding(.top, 50)
            .background(Color.white.opacity(0.7))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .onAppear {
            loadUserData()
        }
    }

    private func loadUserData() {
        if let userData = userDatasViewModel.userData {
            name = userData.name
            age = userData.age
            birthday = stringToDate(userData.birthday) ?? Date()
            zipCode = userData.zipCode
            gender = userData.gender
            country = userData.country
            relationshipStatus = userData.relationshipStatus
            wildspace = userData.wildspace
        }
    }

    func uploadProfileImage() {
        // Logik für das Hochladen des Profilbilds
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.date(from: dateString)
    }

    func saveProfileData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let birthdayString = formatter.string(from: birthday) // Konvertiere Date in String für das Speichern

        let newData: [String: Any] = [
            "name": name,
            "age": age,
            "birthday": birthdayString,
            "zipCode": zipCode,
            "gender": gender,
            "relationshipStatus": relationshipStatus,
            "country": country,
            "wildspace": wildspace
        ]
        
        
        
        userDatasViewModel.updateUserData(uid: authViewModel.currentUser?.uid ?? "<default value>", newData: newData)
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserDatasViewModel())
        .environmentObject(AuthViewModel())
}
