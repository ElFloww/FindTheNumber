 import SwiftUI

struct SplashScreenView: View {
    @Binding var isActive: Bool

    @State private var handleScale: CGFloat = 0.0
    @State private var handleOffset: CGFloat = 100

    @State private var circleTrim: CGFloat = 0.0
    @State private var lensOpacity: Double = 0.0
    
    @State private var questionMarkScale: CGFloat = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var textYOffset: CGFloat = 30

    @Environment(\.colorScheme) var colorScheme
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.blue.opacity(0.4), Color.purple.opacity(0.3)]
                : [Color.blue.opacity(0.2), Color.purple.opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    let metalGradient = LinearGradient(
        colors: [Color(white: 0.8), Color(white: 0.6), Color(white: 0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    let textGradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 50) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(metalGradient)
                        .frame(width: 22, height: 90)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                        .rotationEffect(.degrees(45))
                        .offset(x: -75, y: 75)
                        .scaleEffect(handleScale)
                        .offset(x: -handleOffset, y: handleOffset)

                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                    .blur(radius: 4)
                                    .offset(x: -8, y: -8)
                            )
                            .shadow(color: Color.blue.opacity(0.5), radius: 20, x: 0, y: 0)
                            .opacity(lensOpacity)

                        Circle()
                            .trim(from: 0, to: circleTrim)
                            .stroke(
                                metalGradient,
                                style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round)
                            )
                            .frame(width: 134, height: 134)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 5)

                        Text("?")
                            .font(.system(size: 70, weight: .bold, design: .monospaced))
                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                            .scaleEffect(questionMarkScale)
                            .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 0)
                    }
                }
                .offset(y: -20)

                Text("Find It")
                    .font(.system(size: 55, weight: .bold, design: .rounded))
                    .foregroundStyle(textGradient)
                    .tracking(6)
                    .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    .opacity(textOpacity)
                    .offset(y: textYOffset)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            handleScale = 1.0
            handleOffset = 0
        }

        withAnimation(.easeInOut(duration: 1.2).delay(0.5)) {
            circleTrim = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeIn(duration: 0.5)) {
                lensOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                questionMarkScale = 1.0
            }
        }

        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(1.9)) {
            textOpacity = 1.0
            textYOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeInOut(duration: 0.6)) {
                isActive = false
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(true))
}