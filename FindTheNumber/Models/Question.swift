import Foundation

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
    
    static func random() -> Question {
        let op = Operation.allCases.randomElement()!
        
        switch op {
        case .plus:
            let a = Int.random(in: 0...50)
            let b = Int.random(in: 0...50)
            return Question(left: a, right: b, op: .plus)
            
        case .minus:
            let a = Int.random(in: 0...50)
            let b = Int.random(in: 0...a)
            return Question(left: a, right: b, op: .minus)
            
        case .multiply:
            let a = Int.random(in: 0...10)
            let b = Int.random(in: 0...10)
            return Question(left: a, right: b, op: .multiply)
        }
    }
}
