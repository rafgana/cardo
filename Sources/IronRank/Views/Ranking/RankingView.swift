import SwiftUI
import SwiftData

struct RankingView: View {
    @State private var vm: RankingViewModel
    @State private var selectedExercise: String = "Press Banca"
    @State private var animateTier = false

    init(modelContext: ModelContext) {
        let rankingService = RankingService(standardsService: StandardsService())
        _vm = State(initialValue: RankingViewModel(
            modelContext: modelContext,
            rankingService: rankingService
        ))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Text(vm.overallTier.icon)
                            .font(.system(size: 64))
                            .scaleEffect(animateTier ? 1 : 0.5)
                            .rotationEffect(.degrees(animateTier ? 0 : -30))

                        Text(vm.overallTier.rawValue)
                            .font(.largeTitle.bold())
                            .opacity(animateTier ? 1 : 0)

                        Text("Rango General")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Section("Tus Mejores") {
                    if vm.exercises.isEmpty {
                        Text("Completa entrenos para ver tu ranking")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(vm.exercises.prefix(10)) { exercise in
                        HStack {
                            Text(exercise.name)
                                .font(.headline)
                            Spacer()
                            Text(vm.tierFor(exercise).icon)
                                .font(.title3)
                            Text(vm.tierFor(exercise).rawValue)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)

                            if let (nextTier, weightNeeded) = vm.milestone(for: exercise) {
                                Text("\(nextTier.icon) +\(weightNeeded.clean)kg")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.orange.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 4)
                        .transition(.slide)
                    }
                }
            }
            .navigationTitle("Ranked")
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateTier = true
                }
            }
        }
    }
}

struct TierCardView: View {
    let tier: Tier
    @State private var animate = false

    var body: some View {
        VStack(spacing: 12) {
            Text(tier.icon)
                .font(.system(size: 64))
                .scaleEffect(animate ? 1 : 0.3)
                .rotationEffect(.degrees(animate ? 0 : -180))

            Text(tier.rawValue)
                .font(.title.bold())
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)

            if let idx = Tier.allCases.firstIndex(of: tier) {
                HStack(spacing: 4) {
                    ForEach(Array(Tier.allCases.prefix(idx + 1)).indices, id: \.self) { i in
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animate ? 1 : 0)
                            .animation(.spring(response: 0.3).delay(Double(i) * 0.05), value: animate)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

struct BellCurveView: View {
    let percentile: Double
    @State private var animate = false

    var body: some View {
        VStack(spacing: 8) {
            Text("\(Int(percentile * 100))%")
                .font(.largeTitle.bold())
                .foregroundStyle(.orange)
                .contentTransition(.numericText())
            Text("de la poblacion")
                .font(.caption)
                .foregroundStyle(.secondary)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack(alignment: .bottom) {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: h))
                        path.addQuadCurve(
                            to: CGPoint(x: w, y: h),
                            control: CGPoint(x: w / 2, y: -h * 0.5)
                        )
                    }
                    .fill(.orange.opacity(0.1))

                    Rectangle()
                        .fill(.orange)
                        .frame(width: 3, height: animate ? geo.size.height * (1 - abs(percentile - 0.5) * 2) : 0)
                        .position(x: w * percentile, y: geo.size.height / 2)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animate)
                }
            }
            .frame(height: 100)
        }
        .onAppear {
            withAnimation {
                animate = true
            }
        }
    }
}
