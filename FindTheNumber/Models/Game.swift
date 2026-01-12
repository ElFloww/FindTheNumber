import SwiftUI

struct Game: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
    let isSystemImage: Bool // true pour SF Symbol, false pour asset
    let color: Color
    let gameType: GameType
    
    enum GameType {
        case calculMystere
        case findTheMovingNumber
        case findTheCharacter
    }
}

extension Game {
    static let availableGames: [Game] = [
        Game(
            name: "Calcul Mystère",
            description: "Devine les chiffres cachés et résous un maximum de calculs en 60 secondes ! Chaque bonne réponse rapporte un point. Es-tu assez rapide pour battre les meilleurs scores ?",
            imageName: "function",
            isSystemImage: true,
            color: .purple,
            gameType: .calculMystere
        ),
        Game(
            name: "Trouve le Nombre",
            description: "Les nombres de 0 à 9 se déplacent partout sur l'écran ! Clique rapidement sur le nombre demandé avant qu'il ne s'échappe. Tu as 60 secondes pour marquer un maximum de points !",
            imageName: "target",
            isSystemImage: true,
            color: .orange,
            gameType: .findTheMovingNumber
        ),
        Game(
            name: "Wanted!",
            description: "Retrouve Mario, Luigi, Wario ou Yoshi parmi les personnages qui bougent ! Sois rapide et précis pour gagner un maximum de points en 60 secondes !",
            imageName: "person.3.fill",
            isSystemImage: true,
            color: .green,
            gameType: .findTheCharacter
        )
    ]
}
