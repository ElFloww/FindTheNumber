import SwiftUI

struct MainMenuView: View {
    let games = Game.availableGames
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var soundManager = SoundManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color.blue.opacity(0.4), Color.purple.opacity(0.3)]
                        : [Color.blue.opacity(0.2), Color.purple.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Find It")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Choisis ton jeu")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            ForEach(games) { game in
                                NavigationLink(destination: GameDetailView(game: game)) {
                                    GameCardView(game: game)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                soundManager.playBackgroundMusic(named: "mainmenu-music")
            }
        }
    }
}

struct GameCardView: View {
    let game: Game
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if game.isSystemImage {
                    Image(systemName: game.imageName)
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [game.color, game.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    Image(game.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
            }
            .frame(width: 70, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(game.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(game.description.prefix(60) + "...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray5).opacity(0.5) : Color.white.opacity(0.9))
                .shadow(color: game.color.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    MainMenuView()
        .environmentObject(FirebaseScoreStore())
}
