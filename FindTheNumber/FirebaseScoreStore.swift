//
//  FirebaseScoreStore.swift
//  FindTheNumber
//
//  Created by Florent Dubut on 18/11/2025.
//

import SwiftUI
import FirebaseFirestore
import Combine

final class FirebaseScoreStore: ObservableObject {
    @Published var scores: [PlayerScore] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "scores"
    
    init() {
        listenForScores()
    }
    
    func add(score: Int, for name: String) {
        let data: [String: Any] = [
            "name": name,
            "score": score,
            "date": Timestamp(date: Date())
        ]
        
        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                print("Erreur ajout score : \(error)")
            }
        }
    }F
    
    func listenForScores() {
        db.collection(collectionName)
            .order(by: "score", descending: true)
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Erreur écoute scores : \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let mapped: [PlayerScore] = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let name = data["name"] as? String,
                        let score = data["score"] as? Int,
                        let timestamp = data["date"] as? Timestamp
                    else {
                        return nil
                    }
                    
                    return PlayerScore(
                        id: doc.documentID,
                        name: name,
                        score: score,
                        date: timestamp.dateValue()
                    )
                }
                
                DispatchQueue.main.async {
                    self?.scores = mapped
                }
            }
    }
}
