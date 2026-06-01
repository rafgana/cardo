import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @State private var vm: WorkoutViewModel
    @State private var showActiveWorkout = false

    init(modelContext: ModelContext) {
        _vm = State(initialValue: WorkoutViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            List {
                if let active = vm.activeWorkout {
                    Section("Entreno Actual") {
                        Button {
                            showActiveWorkout = true
                        } label: {
                            HStack {
                                Text(active.date, formatter: DateFormatter.workoutTime)
                                Spacer()
                                Text("\(active.exercises.count) ejercicios")
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                }

                Section("Historial") {
                    if vm.workouts.isEmpty {
                        ContentUnavailableView(
                            "Sin entrenos",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Toca + para empezar")
                        )
                    }
                    ForEach(vm.workouts) { workout in
                        NavigationLink {
                            WorkoutDetailView(workout: workout)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(workout.date, formatter: DateFormatter.workoutDate)
                                        .font(.headline)
                                    Text("\(workout.exercises.count) ejercicios · \(Int(workout.totalVolume))kg")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(workout.durationFormatted)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            vm.deleteWorkout(vm.workouts[i])
                        }
                    }
                }
            }
            .navigationTitle("Entrenos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.startWorkout()
                        showActiveWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showActiveWorkout) {
                ActiveWorkoutView(vm: vm)
            }
            .onAppear { vm.loadWorkouts() }
        }
    }
}

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        List {
            Section("Resumen") {
                LabeledContent("Fecha", value: workout.date, format: .dateTime)
                LabeledContent("Duracion", value: workout.durationFormatted)
                LabeledContent("Volumen", value: "\(Int(workout.totalVolume))kg")
            }

            ForEach(workout.exercises.sorted(by: { $0.order < $1.order })) { we in
                Section(we.exercise?.name ?? "Ejercicio") {
                    ForEach(we.sets.sorted(by: { $0.order < $1.order })) { set in
                        HStack {
                            Text("\(set.weight.clean)kg x \(set.reps)")
                            if let rir = set.rir {
                                Text("RIR: \(rir)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if set.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Detalle")
    }
}
