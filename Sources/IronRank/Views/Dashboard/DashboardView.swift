import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var vm: DashboardViewModel
    @State private var showTierAnim = false

    init(modelContext: ModelContext) {
        let rankingService = RankingService(standardsService: StandardsService())
        _vm = State(initialValue: DashboardViewModel(modelContext: modelContext, rankingService: rankingService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    tierCard
                    lastWorkoutCard
                    weeklyCard
                    statsGrid
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("IronRank")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticFeedback.medium()
                        vm.refresh()
                        showTierAnim = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { showTierAnim = false }
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear { vm.refresh() }
        }
    }

    private var tierCard: some View {
        VStack(spacing: 8) {
            Text(vm.tier.icon)
                .font(.system(size: 48))
                .scaleEffect(showTierAnim ? 1.2 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.5).repeatCount(2, autoreverses: true), value: showTierAnim)

            Text(vm.tier.rawValue)
                .font(.title.bold())

            Text("Rango General")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    private var lastWorkoutCard: some View {
        GroupBox("Ultimo Entreno") {
            if let w = vm.lastWorkout {
                HStack {
                    VStack(alignment: .leading) {
                        Text(w.date, formatter: DateFormatter.workoutDate)
                            .font(.headline)
                        Text("\(Int(w.totalVolume))kg totales")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(w.durationFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            } else {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(.secondary)
                    Text("Completa tu primer entreno")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .groupBoxStyle(CardGroupBoxStyle())
    }

    private var weeklyCard: some View {
        GroupBox("Volumen Semanal") {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(vm.weeklyVolume))kg")
                        .font(.title2.bold())
                        .contentTransition(.numericText())
                    Text("vs \(Int(vm.lastWeekVolume))kg semana pasada")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if vm.volumeChangePercent != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: vm.volumeChangePercent > 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                        Text("\(abs(Int(vm.volumeChangePercent)))%")
                    }
                    .foregroundStyle(vm.volumeChangePercent > 0 ? .green : .red)
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((vm.volumeChangePercent > 0 ? Color.green : Color.red).opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
        .groupBoxStyle(CardGroupBoxStyle())
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]) {
            StatBox(value: "\(vm.totalWorkouts)", label: "Entrenos", icon: "figure.strengthtraining.traditional")
            StatBox(value: "\(vm.streakDays)", label: "Racha", icon: "flame.fill")
            StatBox(value: "\(Int(vm.lastWorkout?.totalVolume ?? 0))", label: "Ultimo kg", icon: "dumbbell.fill")
        }
    }
}

struct CardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            configuration.content
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
            Text(value).font(.title2.bold())
                .contentTransition(.numericText())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
