import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var id: UUID
    var order: Int
    var exercise: Exercise?
    @Relationship(deleteRule: .cascade) var sets: [Set]

    init(order: Int, exercise: Exercise) {
        self.id = UUID()
        self.order = order
        self.exercise = exercise
        self.sets = []
    }

    var lastHistory: String {
        guard !sets.isEmpty else { return "Sin historial" }
        let completed = sets.filter { $0.isCompleted }
        guard !completed.isEmpty else { return "Sin series completadas" }
        return completed.suffix(3).map { "\(Int($0.weight))x\($0.reps)" }.joined(separator: ", ")
    }
}
