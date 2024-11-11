//
//  ProfileViewPopup.swift
//  Livelink
//
//  Created by Dominik Ruppin on 11.11.24.
//

import SwiftUI

struct ProfileViewPopup: View {
    var profile: UserData
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    
    var body: some View {
        VStack {
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
            
            Text(profile.username)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 8)
            
            Button(action: {
                userDatasViewModel.closeProfilePopup()
            }) {
                Text("Schließen")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .padding()
    }
}
