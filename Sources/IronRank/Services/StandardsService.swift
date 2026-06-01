import Foundation

@MainActor
final class StandardsService {
    private var standards: [String: [String: [AgeGenderStandards]]] = [:]

    init() {
        loadStandards()
    }

    private func loadStandards() {
        guard let url = Bundle.module.url(forResource: "strength_standards", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: ExerciseStandards].self, from: data) else {
            return
        }
        standards = decoded.mapValues { $0.entries }
    }

    func thresholds(for exerciseName: String, gender: String, age: Int) -> [TierThreshold] {
        let key = exerciseName.lowercased().replacingOccurrences(of: " ", with: "_")
        guard let exerciseStandards = standards[key],
              let genderStandards = exerciseStandards[gender.lowercased()] else {
            return defaultThresholds
        }

        let matched = genderStandards.first { age >= $0.ageMin && age <= $0.ageMax }
        let entry = matched ?? genderStandards.first

        guard let entry else { return defaultThresholds }

        return [
            TierThreshold(tier: .bronze, minRatio: 0, maxRatio: entry.bronze),
            TierThreshold(tier: .prata, minRatio: entry.bronze, maxRatio: entry.prata),
            TierThreshold(tier: .ouro, minRatio: entry.prata, maxRatio: entry.ouro),
            TierThreshold(tier: .platina, minRatio: entry.ouro, maxRatio: entry.platina),
            TierThreshold(tier: .esmeralda, minRatio: entry.platina, maxRatio: entry.esmeralda),
            TierThreshold(tier: .diamante, minRatio: entry.esmeralda, maxRatio: entry.diamante),
            TierThreshold(tier: .retador, minRatio: entry.diamante, maxRatio: nil)
        ]
    }

    private let defaultThresholds: [TierThreshold] = [
        TierThreshold(tier: .bronze, minRatio: 0, maxRatio: 0.6),
        TierThreshold(tier: .prata, minRatio: 0.6, maxRatio: 0.8),
        TierThreshold(tier: .ouro, minRatio: 0.8, maxRatio: 1.0),
        TierThreshold(tier: .platina, minRatio: 1.0, maxRatio: 1.2),
        TierThreshold(tier: .esmeralda, minRatio: 1.2, maxRatio: 1.4),
        TierThreshold(tier: .diamante, minRatio: 1.4, maxRatio: 1.6),
        TierThreshold(tier: .retador, minRatio: 1.6, maxRatio: nil)
    ]
}

// MARK: - Decoding

struct ExerciseStandards: Codable {
    let entries: [String: [AgeGenderStandards]]
}

struct AgeGenderStandards: Codable {
    let ageMin: Int
    let ageMax: Int
    let bronze: Double
    let prata: Double
    let ouro: Double
    let platina: Double
    let esmeralda: Double
    let diamante: Double
}
