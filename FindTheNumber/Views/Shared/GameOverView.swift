import SwiftUI

struct GameOverView: View {
    let score: Int
    @Binding var pseudo: String
    var onSave: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showAnimation = false
    
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
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(showAnimation ? 1.0 : 0.5)
                        .opacity(showAnimation ? 1.0 : 0.0)
                    
                    Text("Temps écoulé !")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    VStack(spacing: 8) {
                        Text("Ton score")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(score)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color(.systemGray5).opacity(0.6) : Color.white.opacity(0.9))
                            .shadow(color: .orange.opacity(0.3), radius: 15)
                    )
                    .scaleEffect(showAnimation ? 1.0 : 0.8)
                    
                    TextField("Ton pseudo", text: $pseudo)
                        .font(.headline)
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
                        )
                        .padding(.horizontal)
                    
                    Button {
                        let trimmed = pseudo.trimmingCharacters(in: .whitespacesAndNewlines)
                        let name = trimmed.isEmpty ? "Anonyme" : trimmed
                        onSave(name)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Enregistrer le score")
                                .font(.headline)
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
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.4), radius: 10)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Annuler")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Fin de partie")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showAnimation = true
                }
            }
        }
    }
}

#Preview {
    GameOverView(score: 12, pseudo: .constant(""), onSave: { _ in })
}
