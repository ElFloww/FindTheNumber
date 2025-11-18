//
//  ContentView.swift
//  FindTheNumber
//
//  Created by Florent Dubut on 18/11/2025.
//

import SwiftUI
import FirebaseCore
import Combine

@main
struct FindTheNumberApp: App {
    @StateObject private var scoreStore = FirebaseScoreStore()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(scoreStore)
        }
    }
}
