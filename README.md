# IronRank

App iOS de tracking de gym con sistema ranked tipo League of Legends.

## Estado
- ✅ 32 archivos Swift escritos (Modelos, Servicios, Vistas, ViewModels, Utilidades)
- ✅ Spec + Plan + Tasks documentados (570 lineas)
- ✅ 80 ejercicios precargados + thresholds de ranked poblacionales
- ✅ RIR (Reps in Reserve), Supersets, Dropsets, Plate calculator, Warmup calculator
- ✅ Haptic feedback, animaciones, PR celebration, modo oscuro
- ✅ GitHub: https://github.com/rafgana/cardo

## Compilar (necesitas Mac)

### Opcion 1: En un Mac (recomendado)
```bash
git clone git@github.com:rafgana/cardo.git
cd cardo
brew install xcodegen
xcodegen generate
open IronRank.xcodeproj
# Xcode > Product > Archive > Distribuir > Development
# El .ipa se instala con AltStore
```

### Opcion 2: GitHub Actions (CI)
El CI verifica que los archivos existen. Para build completo:
- Usar servicio externo: https://codemagic.io (free tier)
- O pedir a un amigo con Mac que compile

### Opcion 3: Alquilar Mac
- https://macstadium.com (~$20/mes)
- https://metal.dev

## Estructura
```
Sources/IronRank/
├── Models/         Workout, Set (RIR), Exercise, Routine, UserProfile
├── Services/       RankingService, ProgressionService, StandardsService
├── ViewModels/     6 ViewModels (@Observable, MVVM)
├── Views/          Dashboard, Workout, Progreso, Ranked, Perfil
├── Utilities/      Estimators (Epley+RIR), PlateCalc, Warmup, Haptics
└── Resources/      80 ejercicios + strength_standards.json

specs/001-gym-tracker/  spec.md, plan.md, tasks.md
```
