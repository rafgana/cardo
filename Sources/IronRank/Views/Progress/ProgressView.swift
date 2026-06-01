import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm: ProgressViewModel
    @State private var exerciseName: String = "Press Banca"
    @State private var exercises: [Exercise] = []

    private let commonExercises = ["Press Banca", "Sentadilla", "Peso Muerto", "Press Militar", "Remo Barra", "Dominadas"]

    init(modelContext: ModelContext) {
        _vm = State(initialValue: ProgressViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Ejercicio") {
                    Picker("Selecciona", selection: $exerciseName) {
                        ForEach(commonExercises, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: exerciseName) { _, new in
                        if let ex = exercises.first(where: { $0.name == new }) {
                            vm.loadProgress(for: ex)
                        }
                    }
                }

                if !vm.progressData.isEmpty {
                    Section("1RM Estimado") {
                        Chart(vm.progressData) { point in
                            LineMark(
                                x: .value("Fecha", point.date),
                                y: .value("1RM", point.estimatedMax)
                            )
                            .foregroundStyle(.orange)
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Fecha", point.date),
                                y: .value("1RM", point.estimatedMax)
                            )
                            .foregroundStyle(.orange)
                        }
                        .frame(height: 200)
                    }

                    Section("Stats") {
                        LabeledContent("Actual", value: "\(vm.currentMax.clean)kg")
                        LabeledContent("Inicio", value: "\(vm.startMax.clean)kg")
                        LabeledContent("Cambio", value: "\(Int(vm.changePercent))%")
                    }
                } else {
                    ContentUnavailableView(
                        "Sin datos",
                        systemImage: "chart.line.downtrend.xyaxis",
                        description: Text("Completa entrenos para ver progreso")
                    )
                }
            }
            .navigationTitle("Progreso")
            .onAppear {
                let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)])
                exercises = (try? modelContext.fetch(descriptor)) ?? []
                if let ex = exercises.first(where: { $0.name == exerciseName }) {
                    vm.loadProgress(for: ex)
                }
            }
        }
    }
}
