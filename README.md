# IronRank - Gym Tracker con Sistema Ranked

App iOS para registrar entrenamientos con sistema de rangos tipo League of Legends.

## Stack
- Swift 6 + SwiftUI + SwiftData + Swift Charts
- iOS 17+
- 100% offline-first

## Build (sin Mac)

Cada push a `main` compila automaticamente en GitHub Actions:
1. Sube a GitHub (`git push`)
2. Action compila en Mac de GitHub
3. Baja el `.ipa` de los artifacts
4. Instala con AltStore / SideStore / Sideloadly

## Estructura

```
Sources/IronRank/
├── Models/         (Workout, Set con RIR, Exercise, Routine, UserProfile)
├── Services/       (WorkoutService, RankingService, ProgressionService, StandardsService)
├── ViewModels/     (6 ViewModels)
├── Views/          (5 tabs: Dashboard, Workout, Progreso, Ranked, Perfil)
├── Utilities/      (Estimators, PlateCalculator, WarmupCalculator, Haptics)
└── Resources/      (80 ejercicios + strength_standards.json)

specs/              (spec.md, plan.md, tasks.md)
```

## Comandos

```bash
# Subir y compilar
git add . && git commit -m "mensaje" && git push

# Probar local si tienes Mac
xcodegen generate && xcodebuild
```
