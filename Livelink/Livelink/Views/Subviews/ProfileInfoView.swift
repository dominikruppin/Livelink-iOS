//
//  ProfileInfoView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 17.11.24.
//

import SwiftUI

struct ProfileInfoView: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.gray)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.body)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
