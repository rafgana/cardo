import Observation
import Foundation
import SwiftData

@MainActor
@Observable
final class LibraryViewModel {
    var exercises: [Exercise] = []
    var searchText: String = ""
    var selectedMuscle: String?
    var routines: [Routine] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadExercises()
        loadRoutines()
    }

    func loadExercises() {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)])
        exercises = (try? modelContext.fetch(descriptor)) ?? []
    }

    func loadRoutines() {
        let descriptor = FetchDescriptor<Routine>(sortBy: [SortDescriptor(\.createdAt)])
        routines = (try? modelContext.fetch(descriptor)) ?? []
    }

    var filteredExercises: [Exercise] {
        var result = exercises
        if let muscle = selectedMuscle {
            result = result.filter { $0.musclePrimary == muscle }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    var muscleGroups: [String] {
        Array(Swift.Set(exercises.map(\.musclePrimary))).sorted()
    }

    func createRoutine(name: String) {
        let routine = Routine(name: name)
        modelContext.insert(routine)
        try? modelContext.save()
        loadRoutines()
    }

    func addExerciseToRoutine(_ exercise: Exercise, routine: Routine) {
        let re = RoutineExercise(order: routine.exercises.count, exercise: exercise)
        routine.exercises.append(re)
        try? modelContext.save()
    }

    func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
        try? modelContext.save()
        loadRoutines()
    }
}
