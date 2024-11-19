//
//  EditProfileView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 05.11.24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import SwiftSoup

struct EditProfileView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var birthday: Date = Date()
    @State private var zipCode: String = ""
    @State private var gender: String = ""
    @State private var country: String = ""
    @State private var relationshipStatus: String = ""
    @State private var wildspace: String = ""
    @State private var state: String = ""
    @State private var city: String = ""
    @State private var profileImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var saveStatus: SaveStatus?
    @State private var showWildspaceHelp = false
    @StateObject var zipCodeViewModel = ZipCodeViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    
    private var canEdit: Bool {
        userViewModel.userData != nil
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
                    // Benachrichtigungen
                    if let saveStatus = saveStatus {
                        Text(saveStatus.message)
                            .font(.headline)
                            .foregroundColor(saveStatus.isSuccess ? .green : .red)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: saveStatus)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        self.saveStatus = nil
                                    }
                                }
                            }
                    }
                    
                    HStack {
                        AsyncImage(url: URL(string: userViewModel.userData?.profilePicURL ?? "")) { image in
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
                            if let userBirthday = userViewModel.userData?.birthday, !userBirthday.isEmpty {
                                if let birthdayDate = stringToDate(userBirthday) {
                                    Text("\(calculateAge(from: birthdayDate)) Jahre") // Berechnetes Alter anzeigen
                                        .font(.headline)
                                } else {
                                    Text("Ungültiges Geburtsdatum")
                                        .font(.headline)
                                }
                            } else {
                                TextField("Alter", text: $age)
                                    .keyboardType(.numberPad)
                                    .disabled(true)
                            }
                        }
                        
                        Section(header: Text("Geburtsdatum")) {
                            if let userBirthday = userViewModel.userData?.birthday, !userBirthday.isEmpty {
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
                        
                        Section(header: Text("Geschlecht")) {
                            Picker("Geschlecht", selection: $gender) {
                                Text("Männlich").tag("Männlich")
                                Text("Weiblich").tag("Weiblich")
                                Text("Divers").tag("Divers")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        
                        Section(header: Text("Beziehungsstatus")) {
                            Picker("\(relationshipStatus)", selection: $relationshipStatus) {
                                Text("Keine Angabe").tag("Keine Angabe")
                                Text("Single").tag("Single")
                                Text("Vergeben").tag("Vergeben")
                                Text("Verheiratet").tag("Verheiratet")
                            }
                            .pickerStyle(DefaultPickerStyle())
                            .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        
                        Section(header: Text("Land")) {
                            Picker("\(country)", selection: $country) {
                                Text("Keine Angabe").tag("Keine Angabe")
                                Text("Deutschland").tag("Deutschland")
                                Text("Österreich").tag("Österreich")
                                Text("Schweiz").tag("Schweiz")
                            }
                            .pickerStyle(.automatic)
                            .disabled(!canEdit)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        
                        if country != "Keine Angabe" {
                            Section(header: Text("Postleitzahl")) {
                                TextField("Postleitzahl", text: $zipCode)
                                    .disabled(!canEdit)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                        }
                        
                        Section(header: HStack {
                            Text("Wildspace")
                                .padding(.horizontal, 16)
                            Button(action: {
                                showWildspaceHelp.toggle()
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                            .sheet(isPresented: $showWildspaceHelp) {
                                VStack(spacing: 16) {
                                    Text("Hilfe zur Wildspace")
                                        .font(.headline)
                                        .padding(.top)
                                        .textCase(.none)
                                    
                                    Text("""
                                    Hier kannst du dich ein wenig austoben und deinen eigenen Bereich gestalten. Dazu steht dir eingeschränktes HTML zur Verfügung. Du kannst jegliche Formatierungen nutzen sowie Zeilenumbrüche. Außerdem hast du die Möglichkeit ein einziges Bild einzufügen. Nutze dazu einfach den Tag [LINK]. Link muss natürlich durch deine Bildurl ersetzt werden.
                                    """)
                                    .padding()
                                    .textCase(.none)
                                    
                                    Button("Schließen") {
                                        showWildspaceHelp = false
                                    }
                                    .padding(.bottom)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(20)
                            }
                        }) {
                            TextEditor(text: $wildspace)
                                .frame(height: 150)
                                .disabled(!canEdit)
                                .border(Color.gray, width: 1)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal)
                }
                .padding()
            }
            .onAppear {
                loadUserData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        userViewModel.logout()
                    }) {
                        Text("Logout")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveProfileData) {
                        Text("Speichern")
                            .font(.headline)
                    }
                    .disabled(!canEdit)
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $profileImage, isPresented: $isImagePickerPresented)
        }
    }
    
    private func loadUserData() {
        if let userData = userViewModel.userData {
            name = userData.name
            age = userData.age
            birthday = stringToDate(userData.birthday) ?? Date()
            zipCode = userData.zipCode
            country = userData.country.isEmpty ? "Keine Angabe" : userData.country
            gender = userData.gender
            relationshipStatus = userData.relationshipStatus
            wildspace = userData.wildspace
            state = userData.state
            city = userData.city
        }
    }
    
    // Datumsobjekt in String umwandeln (DD.MM.YYYY)
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    // Geburtsdatum vom String ins Datumsobjekt umwandeln
    func stringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.date(from: dateString)
    }
    
    // Berechnen des Alters anhand des Geburtsdatums
    func calculateAge(from dateOfBirth: Date) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: today)
        return ageComponents.year ?? 0
    }
    
    // Wird beim speichern aufgerufen, prüft ob wir noch die openPLZ API Anfragen müssen oder nicht. Ruft entweder direkt die Speichern Funktion auf oder wartet auf API Antwort und falls diese gültig ist, dann die Speichern Funktion auf
    func saveProfileData() {
        // Wenn Postleitzahl und Land angegeben sind laden wir infos über openPLZ API
        if !zipCode.isEmpty, country != "Keine Angabe" {
            zipCodeViewModel.fetchZipInfos(country: country, postalCode: zipCode) { (state: String?, city: String?, error: String?) in
                // Falls ein Fehler vorliegt, speichern beenden und Fehlermeldung ausgeben
                if let error = error {
                    withAnimation {
                        saveStatus = SaveStatus(message: error, isSuccess: false)
                    }
                    return
                }
                
                // Checken ob die API Daten gefunden/geliefert hat
                if state == nil || city == nil {
                    withAnimation {
                        saveStatus = SaveStatus(message: "Ungültige Postleitzahl oder keine Daten gefunden.", isSuccess: false)
                    }
                    return
                }
                
                // Falls wir Daten erhalten haben setzen wir sie
                self.state = state ?? ""
                self.city = city ?? ""
                
                saveProfileDataToDatabase()
            }
        } else {
            // Wenn Postleitzahl und Land nicht angegeben sind speichern wir den Rest
            saveProfileDataToDatabase()
        }
    }
    
    // Funktion um die Profildaten in Firebase dann auch zu speichern
    private func saveProfileDataToDatabase() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let birthdayString = formatter.string(from: birthday)
        let calculatedAge = calculateAge(from: birthday)
        let filteredWildspace = filterHTMLTags(input: wildspace)
        
        let newData: [String: Any] = [
            "name": name,
            "age": "\(calculatedAge)",
            "birthday": birthdayString,
            "zipCode": zipCode,
            "gender": gender,
            "relationshipStatus": relationshipStatus,
            "country": country,
            "wildspace": filteredWildspace,
            "state": state,
            "city": city
        ]
        
        userViewModel.updateUserData(uid: userViewModel.currentUser?.uid ?? "", newData: newData) { success in
            withAnimation {
                saveStatus = success
                ? SaveStatus(message: "Profil erfolgreich gespeichert!", isSuccess: true)
                : SaveStatus(message: "Fehler beim Speichern des Profils.", isSuccess: false)
            }
        }
    }
}

// Hilfsfunktion zum filtern von HTML
func filterHTMLTags(input: String) -> String {
    do {
        let whitelist = try Whitelist.basic()
        try whitelist.addTags("b", "i", "u", "br", "strong", "em") // Erlaubte HTML Tags
        let cleanHTML = try SwiftSoup.clean(input, whitelist)
        return cleanHTML ?? ""
    } catch {
        print("Error sanitizing HTML: \(error.localizedDescription)")
        return input
    }
}


struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    @State private var isImagePickerPresented = false
    
    var body: some View {
        ImagePickerController(isPresented: $isPresented, selectedImage: $selectedImage)
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
