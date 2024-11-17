//
//  LockInfoView.swift
//  Livelink
//
//  Created by Dominik Ruppin on 17.11.24.
//

import SwiftUI

struct LockInfoView: View {
    var profile: UserData
    
    var body: some View {
        if let lockInfo = profile.lockInfo {
            VStack(spacing: 4) {
                Text("Sperrinformationen:")
                    .font(.headline)
                    .foregroundColor(.red)
                
                let lockStatusText = getLockStatusText(for: lockInfo)
                
                Text(lockStatusText)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                
                Text("Begründung:")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text(lockInfo.reason)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(8)
        }
    }
    
    // Berechnung der Sperrinfo-Text basierend auf dem Timestamp
    private func getLockStatusText(for lockInfo: LockInfo) -> String {
        if lockInfo.expirationTimestamp == -1 {
            return "Permanent gesperrt von \(lockInfo.lockedBy)"
        } else {
            let expirationDate = Date(timeIntervalSince1970: TimeInterval(lockInfo.expirationTimestamp))
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let formattedDate = dateFormatter.string(from: expirationDate)
            return "Bis zum \(formattedDate) gesperrt von \(lockInfo.lockedBy)."
        }
    }
}
