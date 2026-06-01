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
                if let profile = vm.profile {
                    let p = Bindable(profile)

                    Section("Perfil") {
                        HStack {
                            Text("Edad")
                            Spacer()
                            TextField("Edad", value: p.age, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }

                        Picker("Genero", selection: p.gender) {
                            ForEach(Gender.allCases.map(\.rawValue), id: \.self) { g in
                                Text(g).tag(g)
                            }
                        }

                        HStack {
                            Text("Peso (kg)")
                            Spacer()
                            TextField("Peso", value: p.bodyweight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }

                        HStack {
                            Text("Descanso (seg)")
                            Spacer()
                            TextField("Timer", value: p.restTimerDefault, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    Section("Estadisticas") {
                        LabeledContent("Total Entrenos", value: "\(vm.totalWorkouts)")
                        LabeledContent("Peso Total", value: "\(Int(vm.totalVolume))kg")
                        LabeledContent("PRs Batidos", value: "\(vm.totalPRs)")
                    }

                    Section("Preferencias") {
                        Toggle("Usar kg", isOn: p.useKg)
                    }
                }

                Section {
                    @AppStorage("useDarkMode") var useDarkMode = false
                    Toggle("Modo Oscuro", isOn: $useDarkMode)
                }
            }
            .navigationTitle("Perfil")
        }
    }
}
