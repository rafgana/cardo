import Foundation

enum Tier: String, CaseIterable, Comparable {
    case bronze = "Bronze"
    case prata = "Prata"
    case ouro = "Ouro"
    case platina = "Platina"
    case esmeralda = "Esmeralda"
    case diamante = "Diamante"
    case retador = "Retador"

    var color: String {
        switch self {
        case .bronze: return "#CD7F32"
        case .prata: return "#C0C0C0"
        case .ouro: return "#FFD700"
        case .platina: return "#E5E4E2"
        case .esmeralda: return "#50C878"
        case .diamante: return "#B9F2FF"
        case .retador: return "#FF4500"
        }
    }

    var icon: String {
        switch self {
        case .bronze: return "🥉"
        case .prata: return "🥈"
        case .ouro: return "🥇"
        case .platina: return "💎"
        case .esmeralda: return "🟢"
        case .diamante: return "🔷"
        case .retador: return "👑"
        }
    }

    static func < (lhs: Tier, rhs: Tier) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

struct TierThreshold {
    let tier: Tier
    let minRatio: Double
    let maxRatio: Double?
}

@MainActor
final class RankingService {
    private let standardsService: StandardsService

    init(standardsService: StandardsService) {
        self.standardsService = standardsService
    }

    func tierFor(estimatedMax: Double, bodyweight: Double, gender: String, age: Int, exerciseName: String) -> Tier {
        let relative = Estimators.relativeStrength(weight: estimatedMax, bodyweight: bodyweight)
        let thresholds = standardsService.thresholds(for: exerciseName, gender: gender, age: age)

        for threshold in thresholds {
            if relative >= threshold.minRatio {
                if let maxRatio = threshold.maxRatio, relative < maxRatio {
                    return threshold.tier
                } else if threshold.maxRatio == nil {
                    return threshold.tier
                }
            }
        }
        return .bronze
    }

    func nextMilestone(estimatedMax: Double, bodyweight: Double, gender: String, age: Int, exerciseName: String) -> (nextTier: Tier, weightNeeded: Double)? {
        let current = tierFor(estimatedMax: estimatedMax, bodyweight: bodyweight, gender: gender, age: age, exerciseName: exerciseName)
        let thresholds = standardsService.thresholds(for: exerciseName, gender: gender, age: age)

        guard let currentIdx = Tier.allCases.firstIndex(of: current),
              currentIdx + 1 < Tier.allCases.count else { return nil }

        let nextTier = Tier.allCases[currentIdx + 1]
        guard let nextThreshold = thresholds.first(where: { $0.tier == nextTier }) else { return nil }

        let neededRelative = nextThreshold.minRatio
        let neededWeight = neededRelative * pow(bodyweight, 0.67)
        let weightNeeded = neededWeight - estimatedMax

        return (nextTier, max(0, weightNeeded))
    }

    func rankedScore(benchRM: Double, squatRM: Double, deadliftRM: Double, bodyweight: Double) -> Double {
        guard bodyweight > 0 else { return 0 }
        let benchRel = Estimators.relativeStrength(weight: benchRM, bodyweight: bodyweight)
        let squatRel = Estimators.relativeStrength(weight: squatRM, bodyweight: bodyweight)
        let deadliftRel = Estimators.relativeStrength(weight: deadliftRM, bodyweight: bodyweight)

        let maxBench: Double = 2.5, maxSquat: Double = 3.0, maxDeadlift: Double = 3.5
        let score = (benchRel / maxBench) * 0.4 + (squatRel / maxSquat) * 0.35 + (deadliftRel / maxDeadlift) * 0.25
        return min(1, max(0, score))
    }

    func tierFromScore(_ score: Double) -> Tier {
        let tiers: [(Tier, Double)] = [
            (.retador, 0.95), (.diamante, 0.80), (.esmeralda, 0.65),
            (.platina, 0.50), (.ouro, 0.35), (.prata, 0.20), (.bronze, 0)
        ]
        return tiers.first { score >= $0.1 }?.0 ?? .bronze
    }
}
