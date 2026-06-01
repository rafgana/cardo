import Observation
import Foundation
import SwiftData

@MainActor
@Observable
final class DashboardViewModel {
    var lastWorkout: Workout?
    var weeklyVolume: Double = 0
    var lastWeekVolume: Double = 0
    var streakDays: Int = 0
    var totalWorkouts: Int = 0
    var benchRM: Double = 0
    var squatRM: Double = 0
    var deadliftRM: Double = 0

    private let workoutService: WorkoutService
    private let rankingService: RankingService

    init(modelContext: ModelContext, rankingService: RankingService) {
        self.workoutService = WorkoutService(modelContext: modelContext)
        self.rankingService = rankingService
        refresh()
    }

    func refresh() {
        let workouts = workoutService.fetchWorkouts()
        lastWorkout = workouts.first
        totalWorkouts = workouts.count
        calculateWeeklyVolume(workouts)
        calculateStreak(workouts)
        calculateTopLifts(workouts)
    }

    private func calculateWeeklyVolume(_ workouts: [Workout]) {
        let calendar = Calendar.current
        let thisWeek = workouts.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
        let lastWeek = workouts.filter {
            let weekAgo = Date().addingTimeInterval(-7*24*3600)
            return $0.date < weekAgo && calendar.isDate($0.date, equalTo: weekAgo, toGranularity: .weekOfYear)
        }
        weeklyVolume = thisWeek.reduce(0) { $0 + $1.totalVolume }
        lastWeekVolume = lastWeek.reduce(0) { $0 + $1.totalVolume }
    }

    private func calculateStreak(_ workouts: [Workout]) {
        guard !workouts.isEmpty else { return }
        let calendar = Calendar.current
        var streak = 0
        var date = Date()

        for workout in workouts {
            if calendar.isDate(workout.date, inSameDayAs: date) {
                streak += 1
                date = date.addingTimeInterval(-86400)
            } else if workout.date < date.addingTimeInterval(-86400) {
                break
            }
        }
        streakDays = streak
    }

    private func calculateTopLifts(_ workouts: [Workout]) {
        let benchSets = workouts.flatMap { w in
            w.exercises.filter { $0.exercise?.name.lowercased().contains("press banca") ?? false }
                .flatMap(\.sets).filter(\.isCompleted)
        }
        benchRM = benchSets.map(\.estimatedMax).max() ?? 0

        let squatSets = workouts.flatMap { w in
            w.exercises.filter { $0.exercise?.name.lowercased().contains("sentadilla") ?? false }
                .flatMap(\.sets).filter(\.isCompleted)
        }
        squatRM = squatSets.map(\.estimatedMax).max() ?? 0

        let dlSets = workouts.flatMap { w in
            w.exercises.filter { $0.exercise?.name.lowercased().contains("peso muerto") ?? false }
                .flatMap(\.sets).filter(\.isCompleted)
        }
        deadliftRM = dlSets.map(\.estimatedMax).max() ?? 0
    }

    var volumeChangePercent: Double {
        guard lastWeekVolume > 0 else { return weeklyVolume > 0 ? 100 : 0 }
        return ((weeklyVolume - lastWeekVolume) / lastWeekVolume) * 100
    }

    var tier: Tier {
        rankingService.tierFromScore(
            rankingService.rankedScore(benchRM: benchRM, squatRM: squatRM, deadliftRM: deadliftRM, bodyweight: 80)
        )
    }
}
