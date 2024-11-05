//
//  OverView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct OverView: View {
    var body: some View {
        ZStack {
            MainTabView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OverView()
        .environmentObject(UserDatasViewModel())
        .environmentObject(ChannelsViewModel())
}

