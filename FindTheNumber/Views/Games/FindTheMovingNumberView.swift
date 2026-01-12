import SwiftUI
import Combine

struct MovingNumber: Identifiable {
    let id = UUID()
    let value: Int
    var position: CGPoint
    var velocity: CGPoint
}

struct FindTheMovingNumberView: View {
    @EnvironmentObject var scoreStore: FirebaseScoreStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let movementTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    let roundTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var isRunning = false
    @State private var score: Int = 0
    @State private var currentRound: Int = 1
    @State private var targetNumber: Int = 0
    @State private var movingNumbers: [MovingNumber] = []
    
    // Modification 1: On stocke la taille de la zone de jeu spécifique
    @State private var screenSize: CGSize = .zero
    @State private var playAreaSize: CGSize = .zero
    
    @State private var showGameOver = false
    @State private var pseudo: String = ""
    @State private var feedback: String? = nil
    @State private var showFeedback = false
    @State private var timeFeedback: String? = nil
    @State private var showTimeFeedback = false
    @State private var roundTime: TimeInterval = 0
    @State private var showRoundTransition = false
    @State private var totalTimeRemaining: Int = 60
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color.orange.opacity(0.3), Color.red.opacity(0.25)]
                        : [Color.orange.opacity(0.1), Color.red.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- HEADER ---
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "flag.fill")
                                    .font(.caption)
                                Text("Round \(currentRound)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .monospacedDigit()
                            }
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .orange.opacity(0.2), radius: 8)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                Text("\(totalTimeRemaining)s")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .monospacedDigit()
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.6))
                                    .shadow(color: .black.opacity(0.2), radius: 8)
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                Text("\(score)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .monospacedDigit()
                            }
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .orange.opacity(0.2), radius: 8)
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        HStack {
                            Image(systemName: "timer")
                            Text(String(format: "%.2f s", roundTime))
                                .font(.system(.title3, design: .monospaced, weight: .semibold))
                        }
                        .foregroundColor(roundTime < 10.0 ? .green : (roundTime < 15.0 ? .orange : .red))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        )
                    }
                    .padding()
                    
                    // --- CIBLE ---
                    VStack(spacing: 8) {
                        Text("Trouve le")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(targetNumber)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .orange.opacity(0.3), radius: 15)
                            )
                        
                        VStack(spacing: 4) {
                            Group {
                                if let feedback = feedback {
                                    Text(feedback)
                                        .font(.headline)
                                        .foregroundColor(feedback.contains("+") ? .green : .red)
                                        .scaleEffect(showFeedback ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showFeedback)
                                } else {
                                    Text(" ")
                                        .font(.headline)
                                }
                            }
                            .frame(height: 24)
                            
                            Group {
                                if let timeFeedback = timeFeedback {
                                    Text(timeFeedback)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .scaleEffect(showTimeFeedback ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showTimeFeedback)
                                } else {
                                    Text(" ")
                                        .font(.subheadline)
                                }
                            }
                            .frame(height: 20)
                        }
                    }
                    .frame(height: 180)
                    .padding(.vertical)
                    
                    // --- ZONE DE JEU ---
                    GeometryReader { playAreaGeometry in
                        ZStack {
                            // Modification 2: Capture de la taille exacte
                            Color.clear
                                .onAppear {
                                    playAreaSize = playAreaGeometry.size
                                }
                                .onChange(of: playAreaGeometry.size) { newSize in
                                    playAreaSize = newSize
                                }
                            
                            ForEach(movingNumbers) { number in
                                Text("\(number.value)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: number.value == targetNumber 
                                                        ? [.orange, .red]
                                                        : [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: .black.opacity(0.2), radius: 5)
                                    )
                                    // La position est relative à ce GeometryReader
                                    .position(number.position)
                                    .onTapGesture {
                                        guard isRunning else { return }
                                        numberTapped(number)
                                    }
                            }
                        }
                        .drawingGroup()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .bottom) // Modification 3: Permet d'aller tout en bas
                }
                
                if showRoundTransition {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("Round \(currentRound)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Prêt?")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .scaleEffect(showRoundTransition ? 1.0 : 0.5)
                        .opacity(showRoundTransition ? 1.0 : 0)
                    }
                }
            }
            .onAppear {
                screenSize = geometry.size
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startNewRound()
                }
            }
        }
        .navigationBarTitle("Trouve le Nombre", displayMode: .inline)
        .onReceive(gameTimer) { _ in
            guard isRunning else { return }
            if totalTimeRemaining > 0 {
                totalTimeRemaining -= 1
                if totalTimeRemaining == 0 {
                    isRunning = false
                    movingNumbers.removeAll()
                    DispatchQueue.main.async {
                        showGameOver = true
                    }
                }
            }
        }
        .onReceive(roundTimer) { _ in
            guard isRunning else { return }
            roundTime += 0.1
        }
        .onReceive(movementTimer) { _ in
            guard isRunning else { return }
            updatePositions()
        }
        .sheet(isPresented: $showGameOver) {
            GameOverView(score: score, pseudo: $pseudo) { name in
                scoreStore.add(score: score, for: name, gameType: "findTheMovingNumber") {
                    dismiss()
                }
            }
        }
    }
    
    private func startNewRound() {
        isRunning = false
        showRoundTransition = true
        roundTime = 0
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showRoundTransition = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showRoundTransition = false
            }
            initializeRound()
            isRunning = true
        }
    }
    
    private func initializeRound() {
        targetNumber = Int.random(in: 0...9)
        
        // Sécurité si la taille n'est pas encore chargée
        guard playAreaSize.width > 0, playAreaSize.height > 0 else { return }
        
        let numberSize: CGFloat = 60
        let padding: CGFloat = 30
        
        // Modification 4: Utilisation directe de la taille réelle
        let playableWidth = playAreaSize.width
        let playableHeight = playAreaSize.height
        
        let numberOfDistractors = 5 + (currentRound - 1) * 3
        
        var numbers: [MovingNumber] = []
        
        let targetX = CGFloat.random(in: padding...(playableWidth - padding))
        let targetY = CGFloat.random(in: numberSize/2...(playableHeight - numberSize/2))
        let targetVelocityX = CGFloat.random(in: -3...3)
        let targetVelocityY = CGFloat.random(in: -3...3)
        
        numbers.append(MovingNumber(
            value: targetNumber,
            position: CGPoint(x: targetX, y: targetY),
            velocity: CGPoint(x: targetVelocityX, y: targetVelocityY)
        ))
        
        for _ in 0..<numberOfDistractors {
            var distractorValue: Int
            repeat {
                distractorValue = Int.random(in: 0...9)
            } while distractorValue == targetNumber
            
            let randomX = CGFloat.random(in: padding...(playableWidth - padding))
            let randomY = CGFloat.random(in: numberSize/2...(playableHeight - numberSize/2))
            let randomVelocityX = CGFloat.random(in: -3...3)
            let randomVelocityY = CGFloat.random(in: -3...3)
            
            numbers.append(MovingNumber(
                value: distractorValue,
                position: CGPoint(x: randomX, y: randomY),
                velocity: CGPoint(x: randomVelocityX, y: randomVelocityY)
            ))
        }
        
        movingNumbers = numbers.shuffled()
    }
    
    private func updatePositions() {
        // Sécurité
        guard playAreaSize.width > 0, playAreaSize.height > 0 else { return }
        
        let numberSize: CGFloat = 60
        let padding: CGFloat = 30
        
        // Modification 5: Logique de rebond basée sur la taille réelle
        let playableWidth = playAreaSize.width
        let playableHeight = playAreaSize.height
        
        let speedMultiplier = 1.0 + (CGFloat(currentRound - 1) * 0.1)
        
        for index in movingNumbers.indices {
            var number = movingNumbers[index]
            
            number.position.x += number.velocity.x * speedMultiplier
            number.position.y += number.velocity.y * speedMultiplier
            
            // Rebond Latéral
            if number.position.x <= padding || number.position.x >= playableWidth - padding {
                number.velocity.x = -number.velocity.x
                number.position.x = max(padding, min(playableWidth - padding, number.position.x))
            }
            
            // Rebond Vertical
            if number.position.y <= numberSize/2 || number.position.y >= playableHeight - numberSize/2 {
                number.velocity.y = -number.velocity.y
                number.position.y = max(numberSize/2, min(playableHeight - numberSize/2, number.position.y))
            }
            
            movingNumbers[index] = number
        }
    }
    
    private func numberTapped(_ number: MovingNumber) {
        if number.value == targetNumber {
            isRunning = false
            
            let timeBonus = max(100, Int(1000 - (roundTime * 150)))
            
            score += timeBonus
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                totalTimeRemaining += 15
            }
            
            feedback = "+\(timeBonus) pts"
            timeFeedback = "+15 secondes"
            withAnimation {
                showFeedback = true
                showTimeFeedback = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showFeedback = false
                    feedback = nil
                    showTimeFeedback = false
                    timeFeedback = nil
                }
                
                if totalTimeRemaining <= 0 {
                    showGameOver = true
                } else {
                    currentRound += 1
                    startNewRound()
                }
            }
        } else {
            isRunning = false
            
            score = max(0, score - 200)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                totalTimeRemaining = max(0, totalTimeRemaining - 5)
            }
            
            feedback = "-200 pts"
            timeFeedback = "-5 secondes"
            withAnimation {
                showFeedback = true
                showTimeFeedback = true
            }
            
            let hasTimeLeft = totalTimeRemaining > 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showFeedback = false
                    feedback = nil
                    showTimeFeedback = false
                    timeFeedback = nil
                }
                
                if !hasTimeLeft || totalTimeRemaining <= 0 {
                    showGameOver = true
                } else {
                    startNewRound()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FindTheMovingNumberView()
            .environmentObject(FirebaseScoreStore())
    }
}