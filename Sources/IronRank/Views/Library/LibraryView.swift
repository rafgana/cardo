import SwiftUI
import SwiftData

struct LibraryView: View {
    @State private var vm: LibraryViewModel
    @State private var searchText = ""
    @State private var selectedMuscle: String?
    @State private var showNewRoutine = false
    @State private var newRoutineName = ""

    init(modelContext: ModelContext) {
        _vm = State(initialValue: LibraryViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button("Todos") {
                                selectedMuscle = nil
                            }
                            .buttonStyle(.bordered)
                            .tint(selectedMuscle == nil ? .orange : .gray)

                            ForEach(vm.muscleGroups, id: \.self) { muscle in
                                Button(muscle) {
                                    selectedMuscle = muscle == selectedMuscle ? nil : muscle
                                }
                                .buttonStyle(.bordered)
                                .tint(selectedMuscle == muscle ? .orange : .gray)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Section("Rutinas") {
                    ForEach(vm.routines) { routine in
                        NavigationLink {
                            RoutineDetailView(routine: routine, vm: vm)
                        } label: {
                            Text(routine.name)
                        }
                    }
                    .onDelete { i in
                        for idx in i { vm.deleteRoutine(vm.routines[idx]) }
                    }

                    Button("Nueva Rutina") {
                        showNewRoutine = true
                    }
                }

                Section("Ejercicios") {
                    if vm.filteredExercises.isEmpty {
                        ContentUnavailableView.search
                    }
                    ForEach(vm.filteredExercises) { exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    Text(exercise.musclePrimary)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(exercise.equipment)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar ejercicio")
            .onChange(of: searchText) { _, new in
                vm.searchText = new
            }
            .navigationTitle("Biblioteca")
            .alert("Nueva Rutina", isPresented: $showNewRoutine) {
                TextField("Nombre", text: $newRoutineName)
                Button("Crear") {
                    guard !newRoutineName.isEmpty else { return }
                    vm.createRoutine(name: newRoutineName)
                    newRoutineName = ""
                }
                Button("Cancelar", role: .cancel) {}
            }
            .onAppear {
                vm.loadExercises()
                vm.loadRoutines()
            }
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        List {
            Section("Informacion") {
                LabeledContent("Musculo Principal", value: exercise.musclePrimary)
                if let sec = exercise.muscleSecondary {
                    LabeledContent("Musculo Secundario", value: sec)
                }
                LabeledContent("Equipo", value: exercise.equipment)
            }

            Section("Instrucciones") {
                Text(exercise.instructions)
            }

            if !exercise.alternatives.isEmpty {
                Section("Alternativos") {
                    ForEach(exercise.alternatives, id: \.self) { alt in
                        Text(alt)
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
    }
}

struct RoutineDetailView: View {
    let routine: Routine
    @State var vm: LibraryViewModel

    var body: some View {
        List {
            Section("Ejercicios") {
                ForEach(routine.exercises.sorted(by: { $0.order < $1.order })) { re in
                    HStack {
                        Text(re.exercise?.name ?? "")
                        Spacer()
                        Text("\(re.order + 1)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(routine.name)
    }
}
