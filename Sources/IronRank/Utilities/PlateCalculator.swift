import Foundation

struct PlateCalculator {
    let barWeight: Double
    let availablePlates: [Double]

    init(barWeight: Double = 20, availablePlates: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]) {
        self.barWeight = barWeight
        self.availablePlates = availablePlates.sorted(by: >)
    }

    func platesFor(weight: Double) -> [Double] {
        guard weight > barWeight else { return [] }
        let perSide = (weight - barWeight) / 2
        var remaining = perSide
        var result: [Double] = []

        for plate in availablePlates {
            while remaining >= plate - 0.01 {
                result.append(plate)
                remaining -= plate
            }
        }

        return result
    }

    func platesDescription(weight: Double) -> String {
        let plates = platesFor(weight: weight)
        guard !plates.isEmpty else { return "Solo barra" }

        let counts = Dictionary(grouping: plates, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.key > $1.key }

        let parts = counts.map { "\($0.value)x\(Int($0.key))" }
        return parts.joined(separator: " + ") + " cada lado"
    }

    func suggestedWeight(from targetWeight: Double) -> Double {
        guard targetWeight > barWeight else { return barWeight }
        let perSide = (targetWeight - barWeight) / 2
        let sorted = availablePlates.sorted(by: >)
        var remaining = perSide
        var loaded = 0.0

        for plate in sorted {
            while remaining >= plate - 0.01 {
                loaded += plate
                remaining -= plate
            }
        }

        return barWeight + loaded * 2
    }
}
