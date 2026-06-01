import Foundation
import SwiftData

@MainActor
final class WorkoutService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Workouts

    func fetchWorkouts() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func createWorkout(from routine: Routine? = nil) -> Workout {
        let workout = Workout()
        modelContext.insert(workout)

        if let routine {
            for re in routine.exercises.sorted(by: { $0.order < $1.order }) {
                guard let exercise = re.exercise else { continue }
                let we = WorkoutExercise(order: re.order, exercise: exercise)
                workout.exercises.append(we)
            }
        }

        try? modelContext.save()
        return workout
    }

    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
        try? modelContext.save()
    }

    // MARK: - Sets

    func addSet(to exercise: WorkoutExercise, weight: Double, reps: Int, rir: Int? = nil) {
        let set = Set(weight: weight, reps: reps, rir: rir, order: exercise.sets.count)
        exercise.sets.append(set)
        try? modelContext.save()
    }

    func toggleSetCompletion(_ set: Set) {
        set.isCompleted.toggle()
        try? modelContext.save()
    }

    func updateSet(_ set: Set, weight: Double? = nil, reps: Int? = nil, rir: Int? = nil) {
        if let weight { set.weight = weight }
        if let reps { set.reps = reps }
        if let rir { set.rir = rir }
        try? modelContext.save()
    }

    // MARK: - History

    func lastSets(for exercise: Exercise, limit: Int = 5) -> [Set] {
        let workoutIds = fetchWorkouts().filter { $0.exercises.contains { $0.exercise?.id == exercise.id } }.map(\.id)
        guard !workoutIds.isEmpty else { return [] }

        let predicate = #Predicate { (s: Set) -> Bool in
            s.isCompleted == true
        }
        var descriptor = FetchDescriptor<Set>(predicate: predicate, sortBy: [SortDescriptor(\.order, order: .reverse)])
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func bestSet(for exercise: Exercise) -> Set? {
        let all = fetchWorkouts().flatMap { workout in
            workout.exercises.filter { $0.exercise?.id == exercise.id }.flatMap(\.sets)
        }.filter { $0.isCompleted }
        return all.max(by: { $0.estimatedMax < $1.estimatedMax })
    }

    func bestSet(forExerciseNamed name: String) -> Set? {
        let all = fetchWorkouts().flatMap { workout in
            workout.exercises.filter { $0.exercise?.name.localizedCaseInsensitiveContains(name) ?? false }
                .flatMap(\.sets)
        }.filter { $0.isCompleted }
        return all.max(by: { $0.estimatedMax < $1.estimatedMax })
    }

    // MARK: - Exercises

    func fetchExercises() -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
