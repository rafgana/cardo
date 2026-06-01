import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @State var vm: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPRCelebration = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                exerciseList
                if vm.isResting {
                    RestTimerView(timeRemaining: $vm.restTimeRemaining, onStop: { vm.stopRestTimer() })
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Entreno")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar", role: .destructive) {
                        HapticFeedback.medium()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Completar") {
                        HapticFeedback.success()
                        vm.completeWorkout()
                        dismiss()
                    }
                    .bold()
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.isResting)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.completedSetsCount)
            .overlay {
                if let pr = vm.showPR {
                    PRCelebrationView(prType: pr, isPresented: Binding(
                        get: { vm.showPR != nil },
                        set: { if !$0 { vm.showPR = nil } }
                    ))
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    private var progressBar: some View {
        let total = vm.totalSetsCount
        let done = vm.completedSetsCount
        return VStack(spacing: 4) {
            SwiftUI.ProgressView(value: total > 0 ? Double(done) / Double(total) : 0)
                .tint(.orange)
                .animation(.spring(response: 0.3), value: done)
            Text("\(done)/\(total) series")
                .font(.caption)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var exerciseList: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let active = vm.activeWorkout {
                    ForEach(Array(active.exercises.enumerated()), id: \.element.id) { index, we in
                        ExerciseSectionView(
                            workoutExercise: we,
                            isCurrent: index == vm.currentExerciseIndex,
                            onAddSet: { weight, reps, rir in
                                vm.addSet(weight: weight, reps: reps, rir: rir)
                            },
                            onToggleSet: { set in
                                HapticFeedback.setCompleted()
                                vm.toggleSetCompletion(set)
                            },
                            suggestion: we.exercise.flatMap { vm.suggestion(for: $0) },
                            isStalled: we.exercise.map { vm.isStalled($0) } ?? false
                        )
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
            .padding()
        }
    }
}

struct ExerciseSectionView: View {
    let workoutExercise: WorkoutExercise
    let isCurrent: Bool
    let onAddSet: (Double, Int, Int?) -> Void
    let onToggleSet: (Set) -> Void
    let suggestion: ProgressionSuggestion?
    let isStalled: Bool

    @State private var weightStr: String = ""
    @State private var repsStr: String = ""
    @State private var selectedRIR: Int? = nil
    @State private var animateContent = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workoutExercise.exercise?.name ?? "")
                    .font(.headline)
                Spacer()
                if isStalled {
                    Label("Estancado", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
                if let sug = suggestion {
                    Text(sug.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !workoutExercise.lastHistory.isEmpty && workoutExercise.lastHistory != "Sin historial" {
                Text("Ultima vez: \(workoutExercise.lastHistory)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(workoutExercise.sets.sorted(by: { $0.order < $1.order })) { set in
                SetRowView(set: set, onToggle: {
                    HapticFeedback.setCompleted()
                    onToggleSet(set)
                })
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .opacity
                ))
            }

            if isCurrent {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        TextField("Peso", text: $weightStr)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 80)
                        Text("kg")
                        TextField("Reps", text: $repsStr)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 60)
                        Text("rep")
                    }

                    RIRSelector(selected: $selectedRIR)

                    Button {
                        let w = Double(weightStr) ?? 0
                        let r = Int(repsStr) ?? 0
                        guard w > 0, r > 0 else { return }
                        HapticFeedback.medium()
                        withAnimation(.spring(response: 0.3)) {
                            onAddSet(w, r, selectedRIR)
                        }
                        weightStr = ""
                        repsStr = ""
                        selectedRIR = nil
                    } label: {
                        Label("Anadir Serie", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(weightStr.isEmpty || repsStr.isEmpty)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(isCurrent ? AnyShapeStyle(Color.orange.opacity(0.08)) : AnyShapeStyle(.ultraThinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            isCurrent ? RoundedRectangle(cornerRadius: 12).stroke(Color.orange, lineWidth: 1) : nil
        )
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.05)) {
                animateContent = true
            }
        }
    }
}

struct RIRSelector: View {
    @Binding var selected: Int?

    var body: some View {
        HStack {
            Text("RIR:").font(.caption)
            ForEach([0, 1, 2, 3, 4], id: \.self) { rir in
                Button {
                    HapticFeedback.selection()
                    selected = selected == rir ? nil : rir
                } label: {
                    Text(rir == 0 ? "Fallo" : "\(rir)")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(selected == rir ? Color.orange : Color.gray.opacity(0.2))
                        .foregroundStyle(selected == rir ? .white : .primary)
                        .clipShape(Capsule())
                        .animation(.spring(response: 0.2), value: selected)
                }
            }
        }
    }
}

struct SetRowView: View {
    let set: Set
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.isCompleted ? .green : .gray)
                    .font(.title3)
                    .contentTransition(.symbolEffect(.automatic))
            }

            Text("\(set.weight.clean)kg x \(set.reps)")
                .font(.body)

            if let rir = set.rir {
                Text("RIR: \(rir)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .clipShape(Capsule())
            }

            if set.isDropSet {
                Text("DROP")
                    .font(.caption2.bold())
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.2))
                    .clipShape(Capsule())
            }

            Spacer()

            Text(set.estimatedMax.clean)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .modifier(SetRowModifier(isCompleted: set.isCompleted))
    }
}

struct RestTimerView: View {
    @Binding var timeRemaining: Int
    let onStop: () -> Void
    @State private var animateRing = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Descanso")
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: animateRing ? 1 : 0)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            Button("Saltar", action: {
                HapticFeedback.light()
                onStop()
            })
            .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .onAppear {
            withAnimation(.linear(duration: Double(timeRemaining))) {
                animateRing = true
            }
        }
    }
}
