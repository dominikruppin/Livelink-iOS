//
//  ChannelsView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct ChannelsView: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)


        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserDatasViewModel())
}
