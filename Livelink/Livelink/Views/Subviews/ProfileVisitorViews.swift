//
//  ProfileVisitorViews.swift
//  Livelink
//
//  Created by Dominik Ruppin on 01.11.24.
//

import SwiftUI

struct ProfileVisitorView: View {
    var visitor: ProfileVisitor

    var body: some View {
        VStack {
            if visitor.profilePicURL.isEmpty {
                Image("placeholder_profilepic")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                    .shadow(radius: 5)
            } else {
                AsyncImage(url: URL(string: visitor.profilePicURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                        .shadow(radius: 5)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                }
            }

            // Benutzername
            Text(visitor.username)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(1) // Limitiert die Zeilenanzahl
                .multilineTextAlignment(.center)
                .frame(maxWidth: 50)
        }
        .padding(.top, 8)
        .padding(.horizontal, 5)
    }
}

#Preview {
    ProfileVisitorView(visitor: ProfileVisitor(username: "benutzername", profilePicURL: ""))
}

