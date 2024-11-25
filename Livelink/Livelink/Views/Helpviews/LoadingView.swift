//
//  LoadingView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 01.11.24.
//

// Wird gezeigt, wenn die Userdaten noch aus Firebase geladen werden
import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Hintergrundbild
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ZStack {
                ForEach(0..<8) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 4)
                        .frame(width: 50, height: 50)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .opacity(isAnimating ? 0 : 1)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            .frame(width: 100, height: 100)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView()
}
