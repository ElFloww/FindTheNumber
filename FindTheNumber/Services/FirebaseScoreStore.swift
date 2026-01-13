import SwiftUI
import FirebaseFirestore
import Combine

// Manages score data with Firebase Firestore
final class FirebaseScoreStore: ObservableObject {
    @Published var scores: [PlayerScore] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "scores"
    private var gameType: String?
    private var listener: ListenerRegistration?
    
    init(gameType: String? = nil) {
        self.gameType = gameType
        if gameType != nil {
            listenForScores()
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    // Save a new score to Firestore
    func add(score: Int, for name: String, gameType: String, completion: (() -> Void)? = nil) {
        let data: [String: Any] = [
            "name": name,
            "score": score,
            "date": Timestamp(date: Date()),
            "gameType": gameType
        ]
        
        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                print("Erreur ajout score : \(error)")
            } else {
                print("Score ajouté avec succès")
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    // Listen for real-time score updates from Firestore
    func listenForScores(gameType: String? = nil) {
        listener?.remove()
        
        let type = gameType ?? self.gameType
        
        var query: Query = db.collection(collectionName)
        
        if let type = type {
            query = query.whereField("gameType", isEqualTo: type)
        }
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Erreur écoute scores : \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { 
                return 
            }
            
            // Map Firestore documents to PlayerScore objects
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
                // Sort scores by highest first
                self?.scores = mapped.sorted { $0.score > $1.score }
            }
        }
    }
}
