import SwiftUI
import Combine
import AVFoundation

struct MovingCharacter: Identifiable {
    let id = UUID()
    let characterName: String
    var position: CGPoint
    var velocity: CGPoint
}

struct FindTheCharacterView: View {
    @EnvironmentObject var scoreStore: FirebaseScoreStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var soundManager = SoundManager.shared
    
    let movementTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    let roundTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var isRunning = false
    @State private var score: Int = 0
    @State private var currentRound: Int = 1
    @State private var targetCharacter: String = ""
    @State private var movingCharacters: [MovingCharacter] = []
    
    // Modification 1: Variables de taille
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
    
    // Available characters for the game
    let characters = ["mario", "luigi", "wario", "yoshi"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fond avec gradient adaptatif
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color.green.opacity(0.3), Color.blue.opacity(0.25)]
                        : [Color.green.opacity(0.1), Color.blue.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header avec round, temps et score
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            // Round
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
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .green.opacity(0.2), radius: 8)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Temps total restant
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
                            
                            // Score
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
                                    colors: [.green, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .green.opacity(0.2), radius: 8)
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        // Timer du round
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
                    
                    // Personnage à trouver
                    VStack(spacing: 8) {
                        Text("Trouve")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Image(targetCharacter)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .green.opacity(0.3), radius: 15)
                            )
                        
                        // Feedback avec hauteur fixe
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
                    
                    // Zone de jeu avec les personnages qui bougent
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
                            
                            ForEach(movingCharacters) { character in
                                Image(character.characterName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .position(character.position)
                                    .onTapGesture {
                                        guard isRunning else { return }
                                        characterTapped(character)
                                    }
                            }
                        }
                        .drawingGroup()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .bottom) // Modification 3: Ignore la zone en bas
                }
                
                // Transition entre les rounds
                if showRoundTransition {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("Round \(currentRound)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .blue],
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
                soundManager.playBackgroundMusic(named: "wanted-music")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startNewRound()
                }
            }
            .onDisappear {
                soundManager.stopBackgroundMusic()
            }
        }
        .navigationBarTitle("Wanted!", displayMode: .inline)
        .onReceive(gameTimer) { _ in
            guard isRunning else { return }
            if totalTimeRemaining > 0 {
                totalTimeRemaining -= 1
                if totalTimeRemaining == 0 {
                    isRunning = false
                    movingCharacters.removeAll()
                    soundManager.stopBackgroundMusic()
                    soundManager.playSoundEffect(named: "gameover")
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
                scoreStore.add(score: score, for: name, gameType: "findTheCharacter") {
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
    
    // Initialize a new round with random target and distractors
    private func initializeRound() {
        // Pick a random character as target
        targetCharacter = characters.randomElement()!
        
        // Sécurité
        guard playAreaSize.width > 0, playAreaSize.height > 0 else { return }
        
        let characterSize: CGFloat = 70
        let padding: CGFloat = 35
        
        // Modification 4: Utilisation des dimensions réelles
        let playableWidth = playAreaSize.width
        let playableHeight = playAreaSize.height
        
        // More distractors each round (5, 7, 9, 11...)
        let numberOfDistractors = 5 + (currentRound - 1) * 2
        
        var chars: [MovingCharacter] = []
        
        let targetX = CGFloat.random(in: padding...(playableWidth - padding))
        let targetY = CGFloat.random(in: characterSize/2...(playableHeight - characterSize/2))
        let targetVelocityX = CGFloat.random(in: -3...3)
        let targetVelocityY = CGFloat.random(in: -3...3)
        
        chars.append(MovingCharacter(
            characterName: targetCharacter,
            position: CGPoint(x: targetX, y: targetY),
            velocity: CGPoint(x: targetVelocityX, y: targetVelocityY)
        ))
        
        // Generate distractor characters
        for _ in 0..<numberOfDistractors {
            var distractorCharacter: String
            // Ensure distractor is different from target
            repeat {
                distractorCharacter = characters.randomElement()!
            } while distractorCharacter == targetCharacter
            
            let randomX = CGFloat.random(in: padding...(playableWidth - padding))
            let randomY = CGFloat.random(in: characterSize/2...(playableHeight - characterSize/2))
            let randomVelocityX = CGFloat.random(in: -3...3)
            let randomVelocityY = CGFloat.random(in: -3...3)
            
            chars.append(MovingCharacter(
                characterName: distractorCharacter,
                position: CGPoint(x: randomX, y: randomY),
                velocity: CGPoint(x: randomVelocityX, y: randomVelocityY)
            ))
        }
        
        movingCharacters = chars.shuffled()
    }
    
    // Update character positions 60 times per second
    private func updatePositions() {
        // Sécurité
        guard playAreaSize.width > 0, playAreaSize.height > 0 else { return }
        
        let characterSize: CGFloat = 70
        let padding: CGFloat = 35
        
        // Modification 5: Logique de rebond avec dimensions réelles
        let playableWidth = playAreaSize.width
        let playableHeight = playAreaSize.height
        
        // Calcul du multiplicateur de vitesse basé sur le round
        let speedMultiplier = 1.0 + (CGFloat(currentRound - 1) * 0.1)
        
        let maxX = playableWidth - padding
        let maxY = playableHeight - characterSize/2
        let minY = characterSize/2
        
        for index in movingCharacters.indices {
            var character = movingCharacters[index]
            
            // Mise à jour de la position avec vitesse augmentée
            character.position.x += character.velocity.x * speedMultiplier
            character.position.y += character.velocity.y * speedMultiplier
            
            // Rebond sur les bords gauche/droit
            if character.position.x <= padding || character.position.x >= maxX {
                character.velocity.x = -character.velocity.x
                character.position.x = max(padding, min(maxX, character.position.x))
            }
            
            // Rebond sur les bords haut/bas
            if character.position.y <= minY || character.position.y >= maxY {
                character.velocity.y = -character.velocity.y
                character.position.y = max(minY, min(maxY, character.position.y))
            }
            
            movingCharacters[index] = character
        }
    }
    
    // Handle character tap
    private func characterTapped(_ character: MovingCharacter) {
        if character.characterName == targetCharacter {
            // Correct character tapped
            isRunning = false
            
            soundManager.playSoundEffect(named: "\(targetCharacter)-success")
            
            // Award time bonus (faster = more points)
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
            // Wrong character tapped - penalty
            soundManager.playSoundEffect(named: "\(character.characterName)-failed")
            
            // Remove the wrong character from screen
            movingCharacters.removeAll { $0.id == character.id }
            
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
            
            if totalTimeRemaining <= 0 {
                showGameOver = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showFeedback = false
                    feedback = nil
                    showTimeFeedback = false
                    timeFeedback = nil
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FindTheCharacterView()
            .environmentObject(FirebaseScoreStore())
    }
}