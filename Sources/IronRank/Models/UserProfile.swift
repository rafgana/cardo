import Foundation
import SwiftData

enum Gender: String, Codable, CaseIterable {
    case male = "Hombre"
    case female = "Mujer"
}

@Model
final class UserProfile {
    var id: UUID
    var age: Int
    var gender: String
    var bodyweight: Double
    var height: Double
    var restTimerDefault: Int
    var useKg: Bool
    var availablePlates: [Double]

    init(
        age: Int = 25,
        gender: String = "Hombre",
        bodyweight: Double = 75,
        height: Double = 175,
        restTimerDefault: Int = 90,
        useKg: Bool = true,
        availablePlates: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]
    ) {
        self.id = UUID()
        self.age = age
        self.gender = gender
        self.bodyweight = bodyweight
        self.height = height
        self.restTimerDefault = restTimerDefault
        self.useKg = useKg
        self.availablePlates = availablePlates
    }
}
