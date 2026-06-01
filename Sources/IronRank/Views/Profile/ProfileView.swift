import SwiftUI
import SwiftData

struct ProfileView: View {
    @State private var vm: ProfileViewModel

    init(modelContext: ModelContext) {
        _vm = State(initialValue: ProfileViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Perfil") {
                    if let profile = vm.profile {
                        HStack {
                            Text("Edad")
                            Spacer()
                            TextField("Edad", value: $profile.age, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }

                        Picker("Genero", selection: $profile.gender) {
                            ForEach(Gender.allCases.map(\.rawValue), id: \.self) { g in
                                Text(g).tag(g)
                            }
                        }

                        HStack {
                            Text("Peso (kg)")
                            Spacer()
                            TextField("Peso", value: $profile.bodyweight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }

                        HStack {
                            Text("Descanso (seg)")
                            Spacer()
                            TextField("Timer", value: $profile.restTimerDefault, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("Estadisticas") {
                    LabeledContent("Total Entrenos", value: "\(vm.totalWorkouts)")
                    LabeledContent("Peso Total", value: "\(Int(vm.totalVolume))kg")
                    LabeledContent("PRs Batidos", value: "\(vm.totalPRs)")
                }

                Section("Preferencias") {
                    if let profile = vm.profile {
                        Toggle("Usar kg", isOn: $profile.useKg)
                    }
                    @AppStorage("useDarkMode") var useDarkMode = false
                    Toggle("Modo Oscuro", isOn: $useDarkMode)
                }
            }
            .navigationTitle("Perfil")
            .onChange(of: vm.profile?.age ?? 0) { _, _ in vm.saveProfile() }
            .onChange(of: vm.profile?.bodyweight ?? 0) { _, _ in vm.saveProfile() }
        }
    }
}
