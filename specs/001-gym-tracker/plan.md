# Implementation Plan: IronRank - Gym Tracker

**Branch**: `001-gym-tracker` | **Spec**: `specs/001-gym-tracker/spec.md`

## Summary

iOS app de tracking de gym con sistema ranked tipo LoL. Core: registro rapido de workouts (Hevy-style) con peso, reps, RIR, supersets y dropsets. Sistema de rangos (Bronze -> Retador) basado en estimated 1RM normalizado por peso corporal/genero/edad con datos poblacionales reales.

## Technical Context

- **Language/Version**: Swift 6
- **Primary Dependencies**: SwiftUI, Swift Charts, SwiftData
- **Storage**: SwiftData (offline-first, 100% local, iCloud backup opcional)
- **Testing**: Swift Testing
- **Target Platform**: iOS 17+, iPhone
- **Project Type**: iOS app (SwiftUI)
- **Performance Goals**: UI a 60fps, registro en <100ms por set, graficas en <500ms
- **Constraints**: Offline-first (sin internet), datos locales, <50MB app size
- **Scale/Scope**: 1 usuario, datos locales, 80-100 ejercicios en biblioteca

## Project Structure

```
MiAppiOS/
├── MiAppiOS.swift              (App entry + SwiftData config)
├── Models/
│   ├── Workout.swift           (fecha, duracion, notas, [exercises])
│   ├── WorkoutExercise.swift   (exercise ref, order, [sets])
│   ├── Set.swift               (peso, reps, rir: Int?, isDropSet, supersetGroupId, note)
│   ├── Exercise.swift          (nombre, musculo, equipo, instrucciones)
│   ├── Routine.swift           (nombre, [exercises])
│   └── UserProfile.swift       (edad, genero, peso, preferencias)
├── Services/
│   ├── WorkoutService.swift    (SwiftData CRUD operations)
│   ├── RankingService.swift    (calculo de percentiles + rangos)
│   ├── ProgressionService.swift (sugerencia peso, deteccion PR, estancamiento)
│   └── StandardsService.swift  (carga y consulta strength_standards.json)
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── WorkoutViewModel.swift  (core: CRUD sets, timer, sugerencias)
│   ├── ProgressViewModel.swift
│   ├── RankingViewModel.swift
│   ├── LibraryViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── AppTabView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── WeeklySummaryView.swift
│   ├── Workout/
│   │   ├── WorkoutListView.swift
│   │   ├── ActiveWorkoutView.swift
│   │   ├── ExerciseSectionView.swift
│   │   ├── SetRowView.swift        (peso, reps, RIR selector, completar)
│   │   ├── RestTimerView.swift
│   │   ├── PlateCalculatorView.swift
│   │   └── WarmupCalculatorView.swift
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   └── PRBadgeView.swift
│   ├── Ranking/
│   │   ├── RankingView.swift
│   │   ├── TierCardView.swift
│   │   └── BellCurveView.swift
│   ├── Library/
│   │   ├── LibraryView.swift
│   │   ├── ExerciseDetailView.swift
│   │   └── MuscleFilterView.swift
│   └── Profile/
│       ├── ProfileView.swift
│       └── StatsView.swift
├── Utilities/
│   ├── Estimators.swift         (Epley, Brzycki con ajuste RIR)
│   ├── PlateCalculator.swift
│   ├── WarmupCalculator.swift
│   └── Extensions.swift
└── Resources/
    ├── strength_standards.json   (thresholds de rangos)
    └── exercises.json            (80-100 ejercicios precargados)
```

## Implementation Phases

### Phase 1: Data Layer + Models (SwiftData)
1. Crear todos los modelos SwiftData: Workout, WorkoutExercise, Set, Exercise, Routine, UserProfile
2. Crear ExerciseStore con 80+ ejercicios precargados desde JSON
3. Crear UserProfileStore (singleton)
4. Seed data: ejercicios iniciales

### Phase 2: Workout Core (la pantalla mas importante)
1. WorkoutListView: historial de workouts, swipe para continuar/borrar
2. ActiveWorkoutView: ejercicio actual con sets, contador de series
3. SetRowView: input peso + reps, RIR selector [0][1][2][3][4][5+], check completar
4. ExerciseSectionView: historial "ultima vez" del ejercicio
5. RestTimerView: temporizador automatico configurable
6. ProgressionService: sugerencia de peso basada en historial + RIR
7. Superset support: agrupar ejercicios, UI intercalada
8. Dropset support: boton dropset con reduccion de peso automatica
9. PlateCalculatorView: muestra discos necesarios
10. WarmupCalculatorView: series de calentamiento

### Phase 3: Ranking System
1. StandardsService: carga de strength_standards.json con thresholds
2. RankingService: calculo de estimated 1RM (Epley + ajuste RIR) -> normalizacion -> rango
3. TierCardView: tarjeta visual del rango con colores y animacion
4. BellCurveView: grafica de campana con posicion del usuario
5. Ranking general compuesto (banca + sentadilla + peso muerto)

### Phase 4: Progress + PRs
1. ProgressView: grafica 1RM vs tiempo por ejercicio (Swift Charts)
2. PR detection: al completar set, comparar contra historial
3. PRBadgeView: badge animado cuando hay nuevo PR
4. Weekly volume chart por grupo muscular

### Phase 5: Library + Routines
1. LibraryView: busqueda + filtro por grupo muscular
2. ExerciseDetailView: instrucciones, musculos, alternativos
3. Routine CRUD: crear, editar, reordenar ejercicios
4. Iniciar workout desde rutina

### Phase 6: Profile + Dashboard
1. ProfileView: edad, genero, peso, preferencias (timer, unidades, discos disponibles)
2. StatsView: workouts totales, peso total, racha actual, PRs totales
3. DashboardView: rango general, ultimo workout, progreso semanal

## Data Flow

```
[User] -> SetRowView -> WorkoutViewModel -> WorkoutService -> SwiftData
                                              |
                                              v
                                       ProgressionService -> sugerencia
                                       RankingService -> rango actualizado
                                       PR detection -> notificacion si PR
```

## Key Algorithms

### Estimated 1RM con RIR
```
func estimatedMax(weight: Double, reps: Int, rir: Int?) -> Double {
    let effectiveReps = reps + (rir ?? 1)
    if effectiveReps <= 10 { return weight * (1 + Double(effectiveReps) / 30) } // Epley
    return weight * (36 / (37 - Double(effectiveReps))) // Brzycki
}
```

### Ranking Tier
```
func tier(weight: Double, bodyweight: Double, gender: Gender, age: Int, exercise: Exercise) -> Tier {
    let relative = weight / pow(bodyweight, 0.67)
    let standard = standardsService.lookup(exercise: exercise, gender: gender, age: age)
    return Tier.from(ratio: relative / standard.baseline)
}
```

### Progression Suggestion
```
func suggestedNext(history: [Set]) -> (weight: Double, reps: Int) {
    let lastSet = history.last!
    let avgRIR = lastSet.rir ?? 1
    if avgRIR >= 3 { return (lastSet.weight + 5, lastSet.reps) }     // muy facil
    if avgRIR == 2 { return (lastSet.weight + 2.5, lastSet.reps) }   // facil
    if avgRIR == 1 { return (lastSet.weight, lastSet.reps + 1) }     // justo
    return (lastSet.weight, lastSet.reps)                             // al fallo, igual
}
```
