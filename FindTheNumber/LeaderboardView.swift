//
//  LeaderboardView.swift
//  FindTheNumber
//
//  Created by Florent Dubut on 18/11/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var scoreStore: FirebaseScoreStore
    
    var body: some View {
        List {
            if scoreStore.scores.isEmpty {
                Text("Pas encore de score.\nLance une partie pour commencer !")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(scoreStore.scores.enumerated()), id: \.element.id) { index, entry in
                    HStack {
                        Text("#\(index + 1)")
                            .font(.headline)
                            .frame(width: 40, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text(entry.name)
                                .font(.headline)
                            Text("Score : \(entry.score)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Classement")
        .onAppear {
            scoreStore.listenForScores()
        }
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
            .environmentObject(FirebaseScoreStore())
    }
}
