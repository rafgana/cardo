import Foundation

struct WarmupSet {
    let weight: Double
    let reps: Int
    let label: String
}

struct WarmupCalculator {
    let workingWeight: Double
    let barWeight: Double

    init(workingWeight: Double, barWeight: Double = 20) {
        self.workingWeight = workingWeight
        self.barWeight = barWeight
    }

    var warmupSets: [WarmupSet] {
        guard workingWeight > barWeight else { return [] }

        var sets: [WarmupSet] = []

        // Bar only
        sets.append(WarmupSet(weight: barWeight, reps: 10, label: "Barra x 10"))

        if workingWeight >= barWeight + 30 {
            let w1 = barWeight + (workingWeight - barWeight) * 0.3
            let rounded1 = roundToNearest(w1, nearest: 5)
            sets.append(WarmupSet(weight: rounded1, reps: 8, label: "\(Int(rounded1)) x 8"))
        }

        if workingWeight >= barWeight + 50 {
            let w2 = barWeight + (workingWeight - barWeight) * 0.5
            let rounded2 = roundToNearest(w2, nearest: 5)
            sets.append(WarmupSet(weight: rounded2, reps: 5, label: "\(Int(rounded2)) x 5"))
        }

        if workingWeight >= barWeight + 70 {
            let w3 = barWeight + (workingWeight - barWeight) * 0.7
            let rounded3 = roundToNearest(w3, nearest: 5)
            sets.append(WarmupSet(weight: rounded3, reps: 3, label: "\(Int(rounded3)) x 3"))
        }

        return sets
    }

    private func roundToNearest(_ value: Double, nearest: Double) -> Double {
        return (value / nearest).rounded() * nearest
    }
}
