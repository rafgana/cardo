import Foundation

enum Estimators {
    /// Estimated 1RM using Epley formula, adjusted for RIR
    /// - Parameters:
    ///   - weight: weight used
    ///   - reps: reps performed
    ///   - rir: reps in reserve (nil = assumes 1)
    /// - Returns: estimated 1RM
    static func estimatedMax(weight: Double, reps: Int, rir: Int? = nil) -> Double {
        let effectiveReps = reps + (rir ?? 1)
        if effectiveReps <= 10 {
            return weight * (1 + Double(effectiveReps) / 30)
        }
        return weight * (36.0 / (37.0 - Double(effectiveReps)))
    }

    /// Normalize weight by bodyweight^0.67 for fair comparison across bodyweights
    static func relativeStrength(weight: Double, bodyweight: Double) -> Double {
        guard bodyweight > 0 else { return 0 }
        return weight / pow(bodyweight, 0.67)
    }

    /// RPE from RIR (simplified: RIR 0 = RPE 10, RIR 1 = RPE 9, etc.)
    static func rpeFromRIR(_ rir: Int) -> Int {
        return min(10, max(1, 10 - rir))
    }
}
