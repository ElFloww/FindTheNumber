//
//  ScoreStore.swift
//  FindTheNumber
//
//  Created by Florent Dubut on 18/11/2025.
//

import Foundation
import Combine

struct PlayerScore: Identifiable, Codable {
    let id: String
    let name: String
    let score: Int
    let date: Date
    
    init(id: String = UUID().uuidString, name: String, score: Int, date: Date = Date()) {
        self.id = id
        self.name = name
        self.score = score
        self.date = date
    }
}
