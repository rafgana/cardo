import SwiftUI
import SwiftData

struct AppTabView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("useDarkMode") private var useDarkMode = false

    var body: some View {
        TabView {
            DashboardView(modelContext: modelContext)
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }

            WorkoutListView(modelContext: modelContext)
                .tabItem {
                    Label("Entreno", systemImage: "figure.strengthtraining.traditional")
                }

            ProgressView(modelContext: modelContext)
                .tabItem {
                    Label("Progreso", systemImage: "chart.line.uptrend.xyaxis")
                }

            RankingView(modelContext: modelContext)
                .tabItem {
                    Label("Ranked", systemImage: "trophy.fill")
                }

            ProfileView(modelContext: modelContext)
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
        .tint(.orange)
        .preferredColorScheme(useDarkMode ? .dark : nil)
    }
}
