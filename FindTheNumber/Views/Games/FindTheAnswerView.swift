import SwiftUI
import Combine

struct FindTheAnswerView: View {
    @EnvironmentObject var scoreStore: FirebaseScoreStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var soundManager = SoundManager.shared
    
    private let gameDuration = 60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var remainingTime: Int = 60
    @State private var isRunning = true
    
    @State private var question: Question = .random()
    @State private var userAnswer: String = ""
    @State private var score: Int = 0
    @State private var feedback: String? = nil
    @State private var showFeedback = false
    
    @State private var digitButtons: [Int] = Array(0...9).shuffled()
    
    @State private var showGameOver = false
    @State private var pseudo: String = ""
    
    @State private var pulseTimer = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color.blue.opacity(0.3), Color.purple.opacity(0.25)]
                    : [Color.blue.opacity(0.1), Color.purple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "timer")
                        Text("\(remainingTime)s")
                            .font(.headline)
                            .monospacedDigit()
                    }
                    .foregroundColor(remainingTime <= 10 ? .red : .blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: remainingTime <= 10 ? .red.opacity(0.3) : .blue.opacity(0.2), radius: 8)
                    )
                    .scaleEffect(pulseTimer && remainingTime <= 10 ? 1.1 : 1.0)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "star.fill")
                        Text("\(score)")
                            .font(.headline)
                            .monospacedDigit()
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: .orange.opacity(0.2), radius: 8)
                    )
                }
                .padding(.horizontal)
                .padding(.horizontal)
                
                VStack(spacing: 16) {
                    Text(question.text)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(.systemGray5).opacity(0.6) : Color.white.opacity(0.8))
                                .shadow(color: .blue.opacity(0.2), radius: 15)
                        )
                    
                    Text(userAnswer.isEmpty ? "?" : userAnswer)
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: .black.opacity(0.1), radius: 8)
                        )
                    
                    if let feedback = feedback {
                        Text(feedback)
                            .font(.headline)
                            .foregroundColor(feedback.contains("✅") ? .green : .red)
                            .scaleEffect(showFeedback ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showFeedback)
                    }
                }
                .padding(.horizontal)
            
            Spacer()
            
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
                                    .font(.system(size: 32))
                                    .frame(width: 65, height: 65)
                                    .background(Color.indigo)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(color: .indigo.opacity(0.4), radius: 8)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button {
                        guard isRunning else { return }
                        checkAnswer()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("=")
                                .font(.title)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.4), radius: 8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button {
                        guard isRunning else { return }
                        if !userAnswer.isEmpty {
                            _ = userAnswer.removeLast()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "delete.left.fill")
                            Text("DEL")
                                .font(.title3)
                                .bold()
                        }
                        .frame(width: 100)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.red.opacity(0.9), Color.orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .red.opacity(0.4), radius: 8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        }
        .navigationBarTitle("Partie", displayMode: .inline)
        .onAppear {
            soundManager.playBackgroundMusic(named: "wanted-reverse-music")
            remainingTime = gameDuration
            isRunning = true
            question = .random()
            digitButtons = Array(0...9).shuffled()
        }
        .onDisappear {
            soundManager.stopBackgroundMusic()
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            
            if remainingTime > 0 {
                remainingTime -= 1
                if remainingTime <= 10 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        pulseTimer.toggle()
                    }
                }
                if remainingTime == 0 {
                    isRunning = false
                    showGameOver = true
                }
            }
        }
        .sheet(isPresented: $showGameOver) {
            GameOverView(score: score, pseudo: $pseudo) { name in
                scoreStore.add(score: score, for: name, gameType: "calculMystere") {
                    dismiss()
                }
            }
        }
    }
    
    private func checkAnswer() {
        guard let value = Int(userAnswer) else {
            feedback = "Réponse invalide"
            showFeedback = true
            userAnswer = ""
            return
        }
        
        if value == question.answer {
            score += 1
            feedback = "✅ Bravo !"
        } else {
            feedback = "❌ Mauvaise réponse"
        }
        
        withAnimation {
            showFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showFeedback = false
                userAnswer = ""
                question = .random()
                digitButtons.shuffle()
            }
        }
    }
}

#Preview {
    NavigationStack {
        FindTheAnswerView()
            .environmentObject(FirebaseScoreStore())
    }
}
