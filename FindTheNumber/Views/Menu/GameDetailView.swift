import SwiftUI

struct GameDetailView: View {
    let game: Game
    @State private var showAnimation = false
    @StateObject private var scoreStore: FirebaseScoreStore
    @State private var refreshID = UUID()
    @State private var numberOfScoresToShow = 10
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var soundManager = SoundManager.shared
    
    init(game: Game) {
        self.game = game
        // Map game type to string for Firestore queries
        let gameTypeString: String
        switch game.gameType {
        case .calculMystere:
            gameTypeString = "calculMystere"
        case .findTheMovingNumber:
            gameTypeString = "findTheMovingNumber"
        case .findTheCharacter:
            gameTypeString = "findTheCharacter"
        }
        _scoreStore = StateObject(wrappedValue: FirebaseScoreStore(gameType: gameTypeString))
    }
    
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
            
            ScrollView {
                VStack(spacing: 24) {
                    Group {
                        if game.isSystemImage {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [game.color, game.color.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(color: game.color.opacity(0.4), radius: 20)
                                
                                Image(systemName: game.imageName)
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(game.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140, height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(color: .black.opacity(0.2), radius: 15)
                        }
                    }
                    .scaleEffect(showAnimation ? 1.0 : 0.8)
                    .opacity(showAnimation ? 1.0 : 0.0)
                    .padding(.top, 20)
                    
                    Text(game.name)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    NavigationLink(destination: destinationView(for: game.gameType)) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Jouer")
                                .font(.title2)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("À propos")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(game.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(.systemGray5).opacity(0.5) : Color.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.05), radius: 8)
                    )
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("Meilleurs joueurs")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        if scoreStore.scores.isEmpty {
                            Text("Sois le premier à jouer !")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(Array(scoreStore.scores.prefix(numberOfScoresToShow).enumerated()), id: \.element.id) { index, entry in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(medalGradient(for: index))
                                                .frame(width: 36, height: 36)
                                            
                                            if index < 3 {
                                                Image(systemName: "trophy.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14))
                                            } else {
                                                Text("\(index + 1)")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
                                        Text(entry.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                            Text("\(entry.score)")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                
                                if numberOfScoresToShow < scoreStore.scores.count {
                                    Button {
                                        withAnimation {
                                            numberOfScoresToShow += 10
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "chevron.down.circle.fill")
                                            Text("Afficher plus")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                        .padding(.vertical, 8)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                                if numberOfScoresToShow > 10 {
                                    Button {
                                        withAnimation {
                                            numberOfScoresToShow = max(10, numberOfScoresToShow - 10)
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "chevron.up.circle.fill")
                                            Text("Afficher moins")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                        .padding(.vertical, 8)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(.systemGray5).opacity(0.5) : Color.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.05), radius: 8)
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            soundManager.playBackgroundMusic(named: "mainmenu-music")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                scoreStore.listenForScores()
            }
            refreshID = UUID()
        }
        .environmentObject(scoreStore)
    }
    
    // Return the appropriate game view based on game type
    @ViewBuilder
    private func destinationView(for gameType: Game.GameType) -> some View {
        switch gameType {
        case .calculMystere:
            FindTheAnswerView()
                .environmentObject(scoreStore)
        case .findTheMovingNumber:
            FindTheMovingNumberView()
                .environmentObject(scoreStore)
        case .findTheCharacter:
            FindTheCharacterView()
                .environmentObject(scoreStore)
        }
    }
    
    private func medalGradient(for index: Int) -> LinearGradient {
        switch index {
        case 0:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 1:
            return LinearGradient(colors: [.gray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2:
            return LinearGradient(colors: [.orange, .brown], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: Game.availableGames[0])
    }
}
