import Foundation

extension DateFormatter {
    static let workoutDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE d MMM"
        f.locale = Locale(identifier: "es_ES")
        return f
    }()

    static let workoutTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}

extension Double {
    var clean: String {
        self == floor(self) ? "\(Int(self))" : String(format: "%.1f", self)
    }
}

extension Array where Element == Double {
    var average: Double { isEmpty ? 0 : reduce(0, +) / Double(count) }
}
