import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var exercises: [RoutineExercise]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.exercises = []
    }
}

@Model
final class RoutineExercise {
    var id: UUID
    var order: Int
    var exercise: Exercise?

    init(order: Int, exercise: Exercise) {
        self.id = UUID()
        self.order = order
        self.exercise = exercise
    }
}
