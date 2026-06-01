import Observation
import Foundation
import SwiftData

struct ProgressPoint: Identifiable {
    let id = UUID()
    let date: Date
    let estimatedMax: Double
}

@MainActor
@Observable
final class ProgressViewModel {
    var selectedExercise: Exercise?
    var progressData: [ProgressPoint] = []
    var prs: [PRInfo] = []

    private let workoutService: WorkoutService

    init(modelContext: ModelContext) {
        self.workoutService = WorkoutService(modelContext: modelContext)
    }

    func loadProgress(for exercise: Exercise) {
        selectedExercise = exercise
        let allWorkouts = workoutService.fetchWorkouts()

        var points: [ProgressPoint] = []
        for workout in allWorkouts {
            for we in workout.exercises where we.exercise?.id == exercise.id {
                for set in we.sets where set.isCompleted {
                    points.append(ProgressPoint(date: workout.date, estimatedMax: set.estimatedMax))
                }
            }
        }
        progressData = points.sorted { $0.date < $1.date }
    }

    var currentMax: Double { progressData.map(\.estimatedMax).max() ?? 0 }
    var startMax: Double { progressData.first?.estimatedMax ?? 0 }
    var changePercent: Double {
        guard startMax > 0 else { return 0 }
        return ((currentMax - startMax) / startMax) * 100
    }
}

struct PRInfo: Identifiable {
    let id = UUID()
    let type: String
    let value: String
    let date: Date
    let isNew: Bool
}
