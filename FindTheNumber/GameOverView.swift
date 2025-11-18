//
//  GameOverView.swift
//  FindTheNumber
//
//  Created by Florent Dubut on 18/11/2025.
//

import SwiftUI

struct GameOverView: View {
    let score: Int
    @Binding var pseudo: String
    var onSave: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Temps écoulé !")
                    .font(.title)
                    .bold()
                
                Text("Ton score : \(score)")
                    .font(.title2)
                
                TextField("Ton pseudo", text: $pseudo)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 8)
                
                Button {
                    let trimmed = pseudo.trimmingCharacters(in: .whitespacesAndNewlines)
                    let name = trimmed.isEmpty ? "Anonyme" : trimmed
                    onSave(name)
                } label: {
                    Text("Enregistrer le score")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top)
                
                Button("Annuler") {
                    dismiss()
                }
                .padding(.top, 8)
                .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Fin de partie")
        }
    }
}

#Preview {
    GameOverView(score: 12, pseudo: .constant(""), onSave: { _ in })
}
