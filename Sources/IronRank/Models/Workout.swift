import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    var notes: String
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise]

    init(date: Date = Date(), duration: TimeInterval = 0, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.notes = notes
        self.exercises = []
    }

    var totalVolume: Double {
        exercises.reduce(0) { total, ex in
            total + ex.sets.reduce(0) { $0 + $1.volume }
        }
    }

    var durationFormatted: String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return "\(m)m \(s)s"
    }
}
