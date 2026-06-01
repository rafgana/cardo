import Observation
import Foundation
import SwiftData

@MainActor
@Observable
final class ProfileViewModel {
    var profile: UserProfile?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProfile()
    }

    func loadProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        let results = try? modelContext.fetch(descriptor)
        profile = results?.first ?? createDefaultProfile()
    }

    private func createDefaultProfile() -> UserProfile {
        let p = UserProfile()
        modelContext.insert(p)
        try? modelContext.save()
        return p
    }

    func saveProfile() {
        try? modelContext.save()
    }

    var totalWorkouts: Int {
        let descriptor = FetchDescriptor<Workout>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    var totalVolume: Double {
        let descriptor = FetchDescriptor<Workout>()
        let workouts = (try? modelContext.fetch(descriptor)) ?? []
        return workouts.reduce(0) { $0 + $1.totalVolume }
    }

    var totalPRs: Int {
        // Simplified: count unique exercises with completed sets
        let descriptor = FetchDescriptor<Workout>()
        let workouts = (try? modelContext.fetch(descriptor)) ?? []
        let exerciseIds = Set(workouts.flatMap { w in
            w.exercises.compactMap { $0.exercise?.id }
        })
        return exerciseIds.count
    }
}
