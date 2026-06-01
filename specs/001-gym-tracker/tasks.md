# Tasks: IronRank - Gym Tracker

**Input**: `specs/001-gym-tracker/spec.md`, `specs/001-gym-tracker/plan.md`

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Crear Xcode project: iOS 17+, SwiftUI, SwiftData, Swift Testing
- [ ] T002 [P] Crear estructura de directorios (Models, Services, ViewModels, Views, Utilities, Resources)
- [ ] T003 [P] Configurar Resources: exercises.json (80 ejercicios), strength_standards.json
- [ ] T004 [P] Crear archivo Entry Point: MiAppiOS.swift con modelContainer

---

## Phase 2: Models + Data Layer (Foundational - BLOCKING)

- [ ] T005 Crear Exercise.swift (SwiftData): id, nombre, musculoPrimario, musculoSecundario, equipo, instrucciones, alternativos
- [ ] T006 [P] Crear Set.swift: id, peso, reps, rir, isDropSet, supersetGroupId, nota, orden, completado
- [ ] T007 [P] Crear WorkoutExercise.swift: id, exercise ref, orden, sets
- [ ] T008 [P] Crear Workout.swift: id, fecha, duracion, notas, exercises
- [ ] T009 [P] Crear Routine.swift: id, nombre, ejercicios (ordenados), createdAt
- [ ] T010 [P] Crear UserProfile.swift: id, edad, genero, pesoCorporal, altura, timerDefault, unidadKg, discosDisponibles
- [ ] T011 Crear StandardsService.swift: carga de strength_standards.json, lookup por ejercicio/genero/edad
- [ ] T012 Crear ExerciseStore.swift: carga de exercises.json, seed data en la primera ejecucion

**Checkpoint**: Modelos y datos listos

---

## Phase 3: Workout Core (US1 - Registrar entrenamiento) PRIORIDAD MAXIMA

### P3a: Lista de Workouts

- [ ] T013 Crear WorkoutService.swift: CRUD de workouts con SwiftData
- [ ] T014 [P] Crear WorkoutViewModel.swift: estado del workout activo, sets, timer, sugerencias
- [ ] T015 [P] Crear WorkoutListView.swift: historial cronologico inverso, swipe para continuar/borrar
- [ ] T016 [P] Crear WorkoutDetailView.swift: detalle de workout completado

### P3b: Workout en Vivo (LA PANTALLA MAS IMPORTANTE)

- [ ] T017 Crear ActiveWorkoutView.swift: lista de ejercicios del workout actual, barra de progreso
- [ ] T018 [P] Crear ExerciseSectionView.swift: header del ejercicio con historial "Ultima vez: 80x8, 85x6..."
- [ ] T019 [P] Crear SetRowView.swift: peso, reps, RIR selector [0][1][2][3][4][5+], checkmark completar
- [ ] T020 [P] Crear RestTimerView.swift: temporizador automatico, configurable por tipo de ejercicio
- [ ] T021 Crear ProgressionService.swift: sugerencia de peso basada en ultimo set + RIR

### P3c: Plate + Warmup

- [ ] T022 [P] Crear PlateCalculatorView.swift: muestra discos necesarios, configurable por discos disponibles
- [ ] T023 [P] Crear WarmupCalculatorView.swift: genera series de calentamiento basadas en peso de trabajo

### P3d: Supersets + Dropsets

- [ ] T024 Anadir soporte de supersets en WorkoutViewModel: agrupar ejercicios, UI intercalada, timer conjunto
- [ ] T025 Anadir soporte de dropsets en SetRowView: boton dropset, reduce peso automaticamente, duplica la serie

**Checkpoint**: US1 completa - puedo registrar un workout completo con sets, RIR, supersets, dropsets, timer, plate calculator

---

## Phase 4: Ranking System (US2 - Ranked LoL)

- [ ] T026 Crear RankingService.swift: calculateTier(weight, bodyweight, gender, age, exercise) -> Tier
- [ ] T027 [P] Crear Estimators.swift: estimatedMax(w, r, rir) con Epley + Brzycki + ajuste RIR
- [ ] T028 [P] Crear RankingViewModel.swift: rango general, rango por ejercicio, next milestone
- [ ] T029 [P] Crear RankingView.swift: tarjeta de rango general, lista de ejercicios rankeados
- [ ] T030 [P] Crear TierCardView.swift: visual del rango con colores (Bronze->Retador) y animacion
- [ ] T031 [P] Crear BellCurveView.swift: grafica de distribucion con posicion del usuario (Swift Charts)
- [ ] T032 Integrar RankingService en WorkoutViewModel: al completar workout, actualizar ranking

**Checkpoint**: US2 completa - veo mi rango al completar un ejercicio, se actualiza solo

---

## Phase 5: Progress + PRs (US3 - PRs inteligentes)

- [ ] T033 Crear ProgressViewModel.swift: graficas, PRs, filtro por ejercicio
- [ ] T034 [P] PR detection en ProgressionService: al completar set, comparar contra historial -> detecta 1RM/Rep/Volume PR
- [ ] T035 [P] Crear ProgressView.swift: grafica 1RM vs tiempo (Swift Charts), grafica volumen semanal
- [ ] T036 [P] Crear PRBadgeView.swift: badge animado "NUEVO PR!" en el momento
- [ ] T037 [P] Crear volumePorMusculo: "18 series de pecho esta semana"

**Checkpoint**: US3 completa - PRs se detectan solos, graficas funcionan

---

## Phase 6: Library + Routines (US4)

- [ ] T038 [P] Crear LibraryViewModel.swift: busqueda, filtro por musculo
- [ ] T039 [P] Crear LibraryView.swift: grid/busqueda de ejercicios, cada uno con su rango
- [ ] T040 [P] Crear ExerciseDetailView.swift: instrucciones, musculos, alternativos, rango actual
- [ ] T041 [P] Crear MuscleFilterView.swift: selector de grupo muscular horizontal
- [ ] T042 Crear rutinas CRUD: crear, editar, reordenar drag & drop, iniciar workout desde rutina

**Checkpoint**: US4 completa - biblioteca funcional, rutinas creadas, workout desde rutina

---

## Phase 7: Dashboard + Perfil (US5)

- [ ] T043 [P] Crear DashboardViewModel.swift: resumen semanal, ultimo workout, rango general
- [ ] T044 [P] Crear DashboardView.swift: tarjeta de rango, progreso semanal, boton nuevo workout
- [ ] T045 [P] Crear ProfileView.swift: edad, genero, peso, preferencias (timer, unidades, discos)
- [ ] T046 [P] Crear StatsView.swift: workouts totales, peso total, racha, PRs totales
- [ ] T047 Crear AppTabView.swift: 5 tabs (Dashboard, Workout, Progreso, Biblioteca, Perfil)

**Checkpoint**: US5 completa - perfil configurado, dashboard funcional

---

## Phase 8: Polish

- [ ] T048 [P] Modo oscuro: adaptar colores y tier visuals
- [ ] T049 [P] Haptic feedback al completar set, al conseguir PR
- [ ] T050 [P] Animaciones en transiciones de rango
- [ ] T051 [P] Gesture-friendly: botones grandes, swipe, tap areas amplias

---

## Dependencies & Execution Order

```
Phase 1 (Setup) -> Phase 2 (Models) -> Phase 3 (Workout Core) -> Phase 4 (Ranking)
                                                                    -> Phase 5 (Progress)
                                                                    -> Phase 6 (Library)
                                                                    -> Phase 7 (Dashboard/Profile)
                                                                    -> Phase 8 (Polish)
```

**MVP = Phase 1 + 2 + 3**: Workout funcional. Con eso ya puedes registrar entrenamientos.
