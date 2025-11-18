//
//  GamePage.swift
//  FindTheNumber
//
//  Created by Florent Dubut on 18/11/2025.
//

import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var scoreStore: FirebaseScoreStore
    @Environment(\.dismiss) private var dismiss
    
    private let gameDuration = 60
    
    // Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var remainingTime: Int = 60
    @State private var isRunning = true
    
    // Jeu
    @State private var question: Question = .random()
    @State private var userAnswer: String = ""
    @State private var score: Int = 0
    @State private var feedback: String? = nil
    
    // Clavier
    @State private var digitButtons: [Int] = Array(0...9).shuffled()
    
    // Fin de partie
    @State private var showGameOver = false
    @State private var pseudo: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Timer + score
            HStack {
                Text("Temps : \(remainingTime)s")
                    .font(.headline)
                Spacer()
                Text("Score : \(score)")
                    .font(.headline)
            }
            
            // Question
            Text(question.text)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            // Réponse utilisateur
            Text(userAnswer.isEmpty ? "?" : userAnswer)
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            if let feedback = feedback {
                Text(feedback)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Clavier caché
            VStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { col in
                            let index = row * 5 + col
                            let digit = digitButtons[index]
                            
                            Button {
                                guard isRunning else { return }
                                userAnswer.append(String(digit))
                            } label: {
                                Text("❓")
                                    .font(.title)
                                    .frame(width: 70, height: 70)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button {
                        guard isRunning else { return }
                        checkAnswer()
                    } label: {
                        Text("=")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        guard isRunning else { return }
                        if !userAnswer.isEmpty {
                            _ = userAnswer.removeLast()
                        }
                    } label: {
                        Text("DEL")
                            .font(.title3)
                            .frame(width: 80)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Partie", displayMode: .inline)
        .onAppear {
            remainingTime = gameDuration
            isRunning = true
            question = .random()
            digitButtons = Array(0...9).shuffled()
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            
            if remainingTime > 0 {
                remainingTime -= 1
                if remainingTime == 0 {
                    isRunning = false
                    showGameOver = true
                }
            }
        }
        .sheet(isPresented: $showGameOver) {
            GameOverView(score: score, pseudo: $pseudo) { name in
                scoreStore.add(score: score, for: name)
                dismiss()    // retour à l'accueil après enregistrement
            }
        }
    }
    
    private func checkAnswer() {
        guard let value = Int(userAnswer) else {
            feedback = "Réponse invalide"
            userAnswer = ""
            return
        }
        
        if value == question.answer {
            score += 1
            feedback = "✅ Bravo !"
        } else {
            feedback = "❌ Mauvaise réponse"
        }
        
        // Nouvelle question, on efface la réponse
        userAnswer = ""
        question = .random()
        
        // Optionnel : remélanger les boutons à chaque question
        digitButtons.shuffle()
    }
}

#Preview {
    NavigationStack {
        GameView()
            .environmentObject(FirebaseScoreStore())
    }
}
