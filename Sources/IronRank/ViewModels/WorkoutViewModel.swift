import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class WorkoutViewModel {
    var workouts: [Workout] = []
    var activeWorkout: Workout?
    var currentExerciseIndex: Int = 0
    var restTimeRemaining: Int = 0
    var isResting: Bool = false
    var showPR: PRType?

    private let workoutService: WorkoutService
    private let progressionService: ProgressionService
    private var restTimer: Timer?

    init(modelContext: ModelContext) {
        self.workoutService = WorkoutService(modelContext: modelContext)
        self.progressionService = ProgressionService(workoutService: workoutService)
        loadWorkouts()
    }

    func loadWorkouts() {
        workouts = workoutService.fetchWorkouts()
    }

    func startWorkout(from routine: Routine? = nil) {
        activeWorkout = workoutService.createWorkout(from: routine)
        currentExerciseIndex = 0
        isResting = false
    }

    func addSet(weight: Double, reps: Int, rir: Int? = nil) {
        guard let active = activeWorkout,
              currentExerciseIndex < active.exercises.count else { return }

        let exercise = active.exercises[currentExerciseIndex]
        workoutService.addSet(to: exercise, weight: weight, reps: reps, rir: rir)

        // Check PR
        if let exerciseRef = exercise.exercise,
           let lastSet = exercise.sets.last {
            if let pr = progressionService.detectPR(exercise: exerciseRef, newSet: lastSet) {
                showPR = pr
            }
        }

        startRestTimer()
    }

    func toggleSetCompletion(_ set: Set) {
        workoutService.toggleSetCompletion(set)
    }

    func completeWorkout() {
        guard let active = activeWorkout else { return }
        active.duration = Date().timeIntervalSince(active.date)
        workoutService.deleteWorkout(active)
        loadWorkouts()
        activeWorkout = nil
        stopRestTimer()
    }

    func deleteWorkout(_ workout: Workout) {
        workoutService.deleteWorkout(workout)
        loadWorkouts()
    }

    func suggestion(for exercise: Exercise) -> ProgressionSuggestion? {
        let lastSets = workoutService.lastSets(for: exercise)
        return progressionService.suggestNext(for: exercise, lastSets: lastSets)
    }

    func isStalled(_ exercise: Exercise) -> Bool {
        progressionService.checkStall(for: exercise)
    }

    // MARK: - Rest Timer

    private func startRestTimer(duration: Int = 90) {
        restTimeRemaining = duration
        isResting = true
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if restTimeRemaining > 0 {
                    restTimeRemaining -= 1
                } else {
                    stopRestTimer()
                }
            }
        }
    }

    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isResting = false
        restTimeRemaining = 0
    }

    // MARK: - Helpers

    var currentExercise: WorkoutExercise? {
        guard let active = activeWorkout,
              currentExerciseIndex < active.exercises.count else { return nil }
        return active.exercises[currentExerciseIndex]
    }

    var currentOrLastExercise: WorkoutExercise? {
        guard let active = activeWorkout else { return nil }
        if currentExerciseIndex < active.exercises.count {
            return active.exercises[currentExerciseIndex]
        }
        return active.exercises.last
    }

    var completedSetsCount: Int {
        activeWorkout?.exercises.reduce(0) { $0 + $1.sets.filter(\.isCompleted).count } ?? 0
    }

    var totalSetsCount: Int {
        activeWorkout?.exercises.reduce(0) { $0 + $1.sets.count } ?? 0
    }
}
