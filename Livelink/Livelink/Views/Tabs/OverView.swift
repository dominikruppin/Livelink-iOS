//
//  OverView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

// Repräsentiert die Anzeige der Tabview samt zugehöriger Views
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

