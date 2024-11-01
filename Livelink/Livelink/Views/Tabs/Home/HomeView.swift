//
//  HomeView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userDatasViewModel: UserDatasViewModel
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Willkommen in der Übersicht!")
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}

