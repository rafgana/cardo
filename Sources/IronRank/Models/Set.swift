import Foundation
import SwiftData

enum RIR: Int, Codable, CaseIterable {
    case failure = 0
    case one = 1
    case two = 2
    case three = 3
    case fourPlus = 4

    var label: String {
        switch self {
        case .failure: return "Fallo"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .fourPlus: return "4+"
        }
    }

    var emoji: String {
        switch self {
        case .failure: return "🔥"
        case .one: return "💪"
        case .two: return "👍"
        case .three: return "✅"
        case .fourPlus: return "😮‍💨"
        }
    }
}

enum SetNote: String, Codable, CaseIterable {
    case easy = "facil"
    case hard = "dura"
    case pump = "bomba"
    case failure_ = "fallo"

    var emoji: String {
        switch self {
        case .easy: return "😊"
        case .hard: return "😤"
        case .pump: return "🩸"
        case .failure_: return "⚡"
        }
    }
}

@Model
final class Set {
    var id: UUID
    var weight: Double
    var reps: Int
    var rir: Int?
    var note: String?
    var order: Int
    var isCompleted: Bool
    var isDropSet: Bool
    var supersetGroupId: UUID?

    init(
        weight: Double = 0,
        reps: Int = 0,
        rir: Int? = nil,
        note: String? = nil,
        order: Int = 0,
        isDropSet: Bool = false,
        supersetGroupId: UUID? = nil
    ) {
        self.id = UUID()
        self.weight = weight
        self.reps = reps
        self.rir = rir
        self.note = note
        self.order = order
        self.isCompleted = false
        self.isDropSet = isDropSet
        self.supersetGroupId = supersetGroupId
    }

    var volume: Double { weight * Double(reps) }

    var estimatedMax: Double {
        let effectiveReps = reps + (rir ?? 1)
        if effectiveReps <= 10 { return weight * (1 + Double(effectiveReps) / 30) }
        return weight * (36.0 / (37.0 - Double(effectiveReps)))
    }
}
