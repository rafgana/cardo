import Foundation

struct ProgressionSuggestion {
    let weight: Double
    let reps: Int
    let reason: String
}

@MainActor
final class ProgressionService {
    private let workoutService: WorkoutService

    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    func suggestNext(for exercise: Exercise, lastSets: [Set]) -> ProgressionSuggestion? {
        let completed = lastSets.filter { $0.isCompleted }
        guard let last = completed.last else { return nil }

        let avgRIR = completed.compactMap { $0.rir }.map(Double.init).average

        if avgRIR >= 3 {
            return ProgressionSuggestion(
                weight: last.weight + 5,
                reps: last.reps,
                reason: "Muy facil: sube \(Int(last.weight + 5))kg"
            )
        } else if avgRIR >= 2 {
            return ProgressionSuggestion(
                weight: last.weight + 2.5,
                reps: last.reps,
                reason: "Sube a \(last.weight.clean) -> \((last.weight + 2.5).clean)"
            )
        } else if avgRIR >= 1 {
            return ProgressionSuggestion(
                weight: last.weight,
                reps: last.reps + 1,
                reason: "Mismo peso, intenta \(last.reps + 1) reps"
            )
        } else {
            return ProgressionSuggestion(
                weight: last.weight - 2.5,
                reps: last.reps,
                reason: "Al fallo: baja un poco o iguala"
            )
        }
    }

    func checkStall(for exercise: Exercise) -> Bool {
        let allSets = workoutService.lastSets(for: exercise, limit: 15)
        let recentMax = allSets.prefix(9).compactMap { $0.rir }.map(Double.init).average
        return recentMax <= 0.5 && allSets.count >= 9
    }

    func detectPR(exercise: Exercise, newSet: Set) -> PRType? {
        let history = workoutService.lastSets(for: exercise, limit: 50)
        let allMax = history.map(\.estimatedMax).max() ?? 0

        if newSet.estimatedMax > allMax && allMax > 0 {
            return .estimated1RM(old: allMax, new: newSet.estimatedMax)
        }

        let bestRepPR = history.filter { abs($0.weight - newSet.weight) < 1 }.map(\.reps).max() ?? 0
        if newSet.reps > bestRepPR && bestRepPR > 0 {
            return .reps(weight: newSet.weight, old: bestRepPR, new: newSet.reps)
        }

        let bestVolume = history.map(\.volume).max() ?? 0
        if newSet.volume > bestVolume && bestVolume > 0 {
            return .volume(old: bestVolume, new: newSet.volume)
        }

        return nil
    }
}

enum PRType {
    case estimated1RM(old: Double, new: Double)
    case reps(weight: Double, old: Int, new: Int)
    case volume(old: Double, new: Double)

    var title: String {
        switch self {
        case .estimated1RM: return "Nuevo 1RM Estimado"
        case .reps: return "Nuevo Record de Reps"
        case .volume: return "Nuevo Record de Volumen"
        }
    }

    var emoji: String { "🏆" }
}
