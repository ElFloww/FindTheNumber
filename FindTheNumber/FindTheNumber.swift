import SwiftUI
import FirebaseCore
import Combine

@main
struct FindItApp: App {
    @StateObject private var scoreStore = FirebaseScoreStore()
    @State private var showSplashScreen = true
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView(isActive: $showSplashScreen)
            } else {
                MainMenuView()
                    .environmentObject(scoreStore)
            }
        }
    }
}
