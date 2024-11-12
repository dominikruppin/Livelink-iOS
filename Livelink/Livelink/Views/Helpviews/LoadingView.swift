//
//  LoadingView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 01.11.24.
//

import SwiftUI

// Wird beim starten der App angezeigt bis die UserDaten aus Firebase geladen worden sind
// TODO
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Lade Daten...")
                .progressViewStyle(CircularProgressViewStyle())
                .font(.title)
                .padding()
            
            Text("Bitte warten Sie, während die Daten geladen werden.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingView()
}
