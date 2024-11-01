//
//  OverView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 30.10.24.
//

import SwiftUI

struct OverView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            MainTabView()
        }
    }
}

#Preview {
    OverView()
        .environmentObject(AuthViewModel())
}

