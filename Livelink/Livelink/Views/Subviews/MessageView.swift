//
//  MessageView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 11.11.24.
//

import SwiftUI

struct MessageView: View {
    var message: Message
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(message.senderId)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(message.content)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

