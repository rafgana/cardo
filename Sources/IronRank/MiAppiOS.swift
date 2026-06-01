import SwiftUI
import SwiftData

@main
struct IronRankApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Workout.self,
                WorkoutExercise.self,
                Set.self,
                Exercise.self,
                Routine.self,
                RoutineExercise.self,
                UserProfile.self
            ])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("No se pudo crear ModelContainer: \(error)")
        }
        seedExercisesIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
        }
        .modelContainer(container)
    }

    private func seedExercisesIfNeeded() {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Exercise>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let exercises = try? JSONDecoder().decode([ExerciseSeed].self, from: data) else {
            return
        }

        for seed in exercises {
            let exercise = Exercise(
                name: seed.name,
                musclePrimary: seed.musclePrimary,
                muscleSecondary: seed.muscleSecondary,
                equipment: seed.equipment,
                instructions: seed.instructions,
                alternatives: seed.alternatives
            )
            context.insert(exercise)
        }
        try? context.save()
    }
}

struct ExerciseSeed: Codable {
    let name: String
    let musclePrimary: String
    let muscleSecondary: String?
    let equipment: String
    let instructions: String
    let alternatives: [String]
}
