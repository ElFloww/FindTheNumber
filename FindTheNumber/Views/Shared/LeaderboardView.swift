import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var scoreStore: FirebaseScoreStore
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if scoreStore.scores.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Pas encore de score.\nLance une partie pour commencer !")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(scoreStore.scores.enumerated()), id: \.element.id) { index, entry in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(medalGradient(for: index))
                                        .frame(width: 50, height: 50)
                                        .shadow(color: medalColor(for: index).opacity(0.4), radius: 5)
                                    
                                    if index < 3 {
                                        Image(systemName: "trophy.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20))
                                    } else {
                                        Text("#\(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.name)
                                        .font(.headline)
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.orange, .pink],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .font(.caption)
                                        Text("\(entry.score) points")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Classement")
        .onAppear {
            scoreStore.listenForScores()
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
    
    private func medalColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
            .environmentObject(FirebaseScoreStore())
    }
}
