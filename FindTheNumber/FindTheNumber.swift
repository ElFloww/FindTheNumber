import SwiftUI
import FirebaseCore
import Combine

// Main app entry point
@main
struct FindItApp: App {
    @StateObject private var scoreStore = FirebaseScoreStore()
    @State private var showSplashScreen = true
    
    init() {
        // Initialize Firebase on app startup
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
