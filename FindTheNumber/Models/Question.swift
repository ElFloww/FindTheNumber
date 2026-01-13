import Foundation

// Math operations available for questions
enum Operation: CaseIterable {
    case plus
    case minus
    case multiply
    
    var symbol: String {
        switch self {
        case .plus: return "+"
        case .minus: return "-"
        case .multiply: return "×"
        }
    }
}

struct Question {
    let left: Int
    let right: Int
    let op: Operation
    
    var text: String {
        "\(left) \(op.symbol) \(right) = ?"
    }
    
    var answer: Int {
        switch op {
        case .plus:
            return left + right
        case .minus:
            return left - right
        case .multiply:
            return left * right
        }
    }
    
    // Generate a random math question
    static func random() -> Question {
        // Pick a random operation
        let op = Operation.allCases.randomElement()!
        
        switch op {
        case .plus:
            // Addition: both numbers 0-50
            let a = Int.random(in: 0...50)
            let b = Int.random(in: 0...50)
            return Question(left: a, right: b, op: .plus)
            
        case .minus:
            // Subtraction: ensure result is non-negative by limiting b to a
            let a = Int.random(in: 0...50)
            let b = Int.random(in: 0...a)
            return Question(left: a, right: b, op: .minus)
            
        case .multiply:
            // Multiplication: smaller numbers (0-10) for easier mental math
            let a = Int.random(in: 0...10)
            let b = Int.random(in: 0...10)
            return Question(left: a, right: b, op: .multiply)
        }
    }
}
