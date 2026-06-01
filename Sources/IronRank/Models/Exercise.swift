import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var musclePrimary: String
    var muscleSecondary: String?
    var equipment: String
    var instructions: String
    var alternatives: [String]

    init(
        name: String,
        musclePrimary: String,
        muscleSecondary: String? = nil,
        equipment: String,
        instructions: String,
        alternatives: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.musclePrimary = musclePrimary
        self.muscleSecondary = muscleSecondary
        self.equipment = equipment
        self.instructions = instructions
        self.alternatives = alternatives
    }
}

enum MuscleGroup: String, CaseIterable {
    case pecho = "Pecho"
    case espalda = "Espalda"
    case hombros = "Hombros"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case piernas = "Piernas"
    case pantorrillas = "Pantorrillas"
    case abdominales = "Abdominales"
    case cuerpoCompleto = "Cuerpo Completo"
}

enum Equipment: String, CaseIterable {
    case barra = "Barra"
    case mancuerna = "Mancuerna"
    case polea = "Polea"
    case maquina = "Maquina"
    case pesoCorporal = "Peso Corporal"
    case kettebell = "Kettlebell"
}
