//
//  HomeView.swift
//  FindTheNumber
//
//  Created by Florent Dubut on 18/11/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Calcul Mystère")
                .font(.largeTitle)
                .bold()
            
            Text("Devine les chiffres cachés\net réponds à un max de calculs en 60s !")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            NavigationLink {
                GameView()
            } label: {
                Text("Jouer")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            
            NavigationLink {
                LeaderboardView()
            } label: {
                Text("Classement")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(16)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(FirebaseScoreStore())
    }
}
