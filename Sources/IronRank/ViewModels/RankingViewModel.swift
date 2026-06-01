import Foundation
import SwiftData

@MainActor
@Observable
final class RankingViewModel {
    var exercises: [Exercise] = []
    var selectedExercise: Exercise?
    var userBodyweight: Double = 80
    var userGender: String = "Hombre"
    var userAge: Int = 25

    private let rankingService: RankingService
    private let workoutService: WorkoutService

    init(modelContext: ModelContext, rankingService: RankingService) {
        self.rankingService = rankingService
        self.workoutService = WorkoutService(modelContext: modelContext)
        loadExercises()
    }

    private func loadExercises() {
        exercises = workoutService.fetchExercises()
    }

    func tierFor(_ exercise: Exercise) -> Tier {
        guard let best = workoutService.bestSet(for: exercise) else { return .bronze }
        return rankingService.tierFor(
            estimatedMax: best.estimatedMax,
            bodyweight: userBodyweight,
            gender: userGender,
            age: userAge,
            exerciseName: exercise.name
        )
    }

    func milestone(for exercise: Exercise) -> (Tier, Double)? {
        guard let best = workoutService.bestSet(for: exercise) else { return nil }
        return rankingService.nextMilestone(
            estimatedMax: best.estimatedMax,
            bodyweight: userBodyweight,
            gender: userGender,
            age: userAge,
            exerciseName: exercise.name
        )
    }

    var overallTier: Tier {
        let benchMax = workoutService.bestSet(forExerciseNamed: "Press Banca")?.estimatedMax ?? 0
        let squatMax = workoutService.bestSet(forExerciseNamed: "Sentadilla")?.estimatedMax ?? 0
        let dlMax = workoutService.bestSet(forExerciseNamed: "Peso Muerto")?.estimatedMax ?? 0

        let score = rankingService.rankedScore(
            benchRM: benchMax,
            squatRM: squatMax,
            deadliftRM: dlMax,
            bodyweight: userBodyweight
        )
        return rankingService.tierFromScore(score)
    }
}
