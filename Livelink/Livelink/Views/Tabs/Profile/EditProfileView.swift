//
//  EditProfileView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 05.11.24.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct EditProfileView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var birthday: Date = Date()
    @State private var zipCode: String = ""
    @State private var gender: String = ""
    @State private var country: String = "Deutschland"
    @State private var relationshipStatus: String = ""
    @State private var wildspace: String = ""
    
    @State private var profileImage: UIImage? // Für das ausgewählte Profilbild
    @State private var isImagePickerPresented = false // Zustandsvariable für den Picker
    
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    private var canEdit: Bool {
        userDatasViewModel.userData != nil
    }

    @available(iOS 16.0, *)
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
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
                            isImagePickerPresented.toggle()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 20)

                    Form {
                        Section(header: Text("Name")) {
                            TextField("Name", text: $name)
                                .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))

                        Section(header: Text("Alter")) {
                            TextField("Alter", text: $age)
                                .keyboardType(.numberPad)
                                .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))

                        Section(header: Text("Geburtsdatum")) {
                            if let userBirthday = userDatasViewModel.userData?.birthday {
                                if let birthdayDate = stringToDate(userBirthday) {
                                    Text("\(formattedDate(birthdayDate))")
                                        .font(.headline)
                                } else {
                                    Text("Ungültiges Geburtsdatum")
                                        .font(.headline)
                                }
                            } else {
                                DatePicker("Geburtsdatum", selection: $birthday, displayedComponents: .date)
                                    .disabled(!canEdit)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))

                        Section(header: Text("Postleitzahl")) {
                            TextField("Postleitzahl", text: $zipCode)
                                .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))

                        Section(header: Text("Geschlecht")) {
                            Picker("Geschlecht", selection: $gender) {
                                Text("Männlich").tag("Männlich")
                                Text("Weiblich").tag("Weiblich")
                                Text("Divers").tag("Divers")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))

                        Section(header: Text("Beziehungsstatus")) {
                            Picker("\(relationshipStatus)", selection: $relationshipStatus) {
                                Text("Verheiratet").tag("Verheiratet")
                                Text("Ledig").tag("Ledig")
                                Text("In einer Beziehung").tag("In einer Beziehung")
                            }
                            .pickerStyle(DefaultPickerStyle())
                            .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))

                        Section(header: Text("Land")) {
                            Picker("\(country)", selection: $country) {
                                Text("Test").tag("Test")
                                Text("Deutschland").tag("Deutschland")
                                Text("Österreich").tag("Österreich")
                                Text("Schweiz").tag("Schweiz")
                            }
                            .pickerStyle(.automatic)
                            .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))

                        Section(header: Text("Wildspace")) {
                            TextEditor(text: $wildspace)
                                .frame(height: 150)
                                .padding(.bottom, 10)
                                .disabled(!canEdit)
                                .border(Color.gray, width: 1)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 32)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    Spacer().frame(height: 10)
                }
                .padding(.horizontal)
            }
            .onAppear {
                loadUserData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveProfileData()
                    }) {
                        Text("Speichern")
                            .font(.headline)
                    }
                    .disabled(!canEdit)
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $profileImage)
                .onDisappear {
                    if let image = profileImage {
                        userDatasViewModel.uploadProfileImage(image: image)
                    }
                }
        }
    }

    private func loadUserData() {
        if let userData = userDatasViewModel.userData {
            name = userData.name
            age = userData.age
            birthday = stringToDate(userData.birthday) ?? Date()
            zipCode = userData.zipCode
            gender = userData.gender
            relationshipStatus = userData.relationshipStatus
            wildspace = userData.wildspace
        }
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
        let birthdayString = formatter.string(from: birthday)

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

// Custom ImagePicker View to select the image
struct ImagePicker: View {
    @Binding var selectedImage: UIImage?

    @State private var isImagePickerPresented = false

    var body: some View {
        ImagePickerController(isPresented: $isImagePickerPresented, selectedImage: $selectedImage)
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerController

        init(parent: ImagePickerController) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}


#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserDatasViewModel())
}
