# Feature Specification: IronRank - Gym Tracker con Sistema Ranked

**Status**: Draft v2

## Concept

App de tracking de gym como Hevy, con sistema **Ranked tipo League of Legends**: cada ejercicio tiene un rango segun tu fuerza relativa. Gamificacion para motivar el progreso real.

---

## User Stories

### P1 - Registrar entrenamiento como Hevy

Como usuario, quiero abrir la app, elegir o crear un workout, y registrar mis series rapido.

**Flujo Hevy-style:**
1. Abro la app > Dashboard con mi ultimo workout, proxima rutina, resumen semanal
2. Tap "Nuevo Workout" > elegir rutina guardada o "Workout Libre"
3. Anadir ejercicios: busco por nombre o grupo muscular, selecciono
4. Cada ejercicio: entro sets con peso + reps (tap rapido, numpad nativo)
5. Entre sets: temporizador de descanso automatico (configurable 30s-5min)
6. Al terminar: tap "Completar" > se guarda con fecha, duracion, volumen total

**Detalles Hevy que SI o SI:**

- **Plate calculator**: al poner peso total, muestra cuantos discos poner de cada lado
- **Warm-up calculator**: calcula series de calentamiento automaticas basadas en peso de trabajo
- **Auto-rest timer**: empieza automatico al marcar serie completada
- **Drag & drop** para reordenar ejercicios
- **Historial del ejercicio DURANTE el workout**: Al hacer Press Banca, ves arriba "Ultima vez: 80x8, 85x6, 85x5". Esto es CRITICO.
- **Sugerencia de peso inteligente**: "La ultima vez hiciste 80x8. Prueba 82.5x8 o 80x9."
- **RIR (Reps in Reserve) por set**: Al lado de reps/peso, selector rapido [0][1][2][3][4][5+]. 0 = fallo, 1-2 = series efectivas, 3+ = conservador/calentamiento. Ajusta el calculo de estimated 1RM.
- **Notas rapidas por set**: Tap: facil / dura / bomba / fallo (emojis, no texto)
- **Modo oscuro** y gesture-friendly (gym con manos sudadas)

### P1 - Sistema Ranked (LoL-style)

Como usuario, quiero ver mi rango en cada ejercicio y un rango general como en League of Legends.

**Los rangos (7, simplificado para v1):**

| Rango | Press Banca (Hombre 80kg) | Peso Muerto | Sentadilla |
|-------|--------------------------|-------------|------------|
| Bronze | <50kg | <70kg | <60kg |
| Prata | 50-70kg | 70-100kg | 60-85kg |
| Ouro | 70-85kg | 100-130kg | 85-110kg |
| Platina | 85-100kg | 130-160kg | 110-130kg |
| Esmeralda | 100-115kg | 160-190kg | 130-150kg |
| Diamante | 115-135kg | 190-220kg | 150-175kg |
| Retador | 135kg+ | 220kg+ | 175kg+ |

*(Valores exactos normalizados por peso corporal, genero y edad usando datos reales de strengthlevel.com / openpowerlifting)*

**Como funciona el ranked:**
- Cada ejercicio tiene rango individual basado en tu estimated 1RM / peso corporal
- Rango GENERAL: compuesto de tus 3 mejores levantamientos (banca + peso muerto + sentadilla)
- Barra de progreso: "Estas a 5kg de llegar a Platina en Press Banca"
- Progreso continuo (no seasons en v1)

**Pantalla de Ranked:**
- Tarjeta grande con tu rango general actual (animacion, colores)
- Debajo: tus top 3 ejercicios con sus rangos individuales
- Boton "Ver detalles" > lista completa de todos tus ejercicios rankeados
- Grafica de campana con tu posicion marcada
- "Next milestone": que necesitas levantar para subir de rango

### P1 - Personal Records (PRs) inteligentes

Como usuario, quiero saber cuando rompo mis records.

- **PR automaticos**: la app detecta y celebra cuando superas tu mejor marca
- **Tipos de PR:**
  - 1RM: mayor peso estimado para 1 repeticion
  - Rep PR: mas reps con el mismo peso (ej. antes 80x6, ahora 80x8)
  - Volume PR: mayor volumen en un ejercicio (peso x reps x series)
  - Workout PR: mayor volumen total en una sesion
- Notificacion cuando consigues un nuevo PR
- Timeline de PRs en la pantalla de progreso

### P1 - Supersets y Dropsets

Como usuario que entrena de verdad, necesito poder hacer supersets y dropsets.

**Supersets:**
- Agrupar 2 ejercicios en un superset
- La UI muestra ambos ejercicios intercalados
- El temporizador cuenta entre el FIN del superset (no entre ejercicios)
- Reordenar dentro del superset

**Dropsets:**
- Al marcar una serie como "dropset", se duplica con peso reducido
- Default: baja 20% del peso, misma cantidad de reps objetivo
- Configurable el porcentaje de drop

### P2 - Progresion y sobrecarga progresiva

Como usuario, quiero que la app me ayude a progresar, no solo registrar.

- **Sugerencia de peso**: basado en tu ultimo workout del mismo ejercicio, sugiere +2.5kg o +1 rep
- **Deteccion de estancamiento**: si llevas 3+ sesiones sin progresar en un ejercicio, alerta y sugiere deload
- **Regla de doble progresion**: "Si haces 3x8 con 80kg, la proxima sube a 82.5kg" - la app lo sabe
- **Rest timer inteligente**: sugiere descanso segun el tipo de ejercicio (fuerza: 3min, hipertrofia: 90s, acceso: 60s)
- **Deload tracking**: flag de "deload week" manual, no penaliza en el ranked

### P2 - Biblioteca de Ejercicios (80-100 ejercicios v1)

- Biblioteca curada con los ejercicios MAS comunes:
  - Compuestos: Press Banca, Sentadilla, Peso Muerto, Press Militar, Remo Barra, Dominadas, Fondos
  - Pecho: Press Inclinado, Aperturas, Cable Cross, Press Banca Declinado
  - Espalda: Remo Mancuerna, Jalones, Face Pull, Pullover, Hiperextensiones
  - Hombros: Elevaciones Laterales, Frontales, Pajaro, Press Arnold
  - Biceps: Curl Barra, Curl Mancuerna, Curl Martillo, Curl Polea, Curl Concentrado
  - Triceps: Extensiones, Patada Triceps, Press Frances, Cuerda
  - Piernas: Prensa, Extensiones, Curl Femoral, Sentadilla Bulgara, Peso Muerto Rumano
  - Pantorrillas: Elevaciones de Gemelos Sentado, De Pie
  - Accesorios: Abdominales, Russian Twist, Plancha, L-Sit

- Cada ejercicio: nombre, grupo muscular, equipo, instrucciones, musculos primarios/secundarios, ejercicios alternativos

### P2 - Rutinas

- CRUD de rutinas
- Ordenar ejercicios drag & drop
- Iniciar workout desde rutina
- Nota: NO programas pre-armados en v1 (5/3/1, StrongLifts, etc.)

### P2 - Body Tracking (basico)

- Peso corporal con grafica simple
- Solo peso, sin medidas ni fotos en v1

---

## Ranking System - Detalle Tecnico

### Calculo de Estimated 1RM

| Metodo | Formula | Cuando usarlo |
|--------|---------|---------------|
| Epley | RM = w x (1 + r/30) | Reps 1-10 |
| Brzycki | RM = w x (36/(37-r)) | Reps 10-15 |
| Epley modificado | RM = w x (1 + r/30) x 0.95 | Reps 15-20 |

**Ajuste por RIR**: Si el usuario registra RIR, se ajusta el RM estimado:
- RIR 0 (fallo real) -> formula exacta
- RIR 1 -> se anade 1 rep teorica antes de calcular: RM = w x (1 + (r+RIR)/30)
- RIR 2+ -> mismo ajuste, pero se marca como "estimado con baja precision" en la UI
- Sin RIR -> se asume RIR 1 por defecto (conservador)

### Ranking por Ejercicio

1. Se toma el mejor set de las ultimas 8 semanas (maximo estimated 1RM)
2. Se normaliza: RM_rel = RM / bodyweight^0.67
3. Se ajusta por genero y edad usando coeficientes de referencia
4. Se mapea al rango correspondiente (Bronze -> Retador)

### Ranking General (Ranked Score)

Ranked Score = (Banca_rel x 0.4 + Sentadilla_rel x 0.35 + PesoMuerto_rel x 0.25) / maximo teorico

### Datos de Referencia

Los thresholds de rangos se basan en:
- Referencia principal: Datos de strengthlevel.com
- Powerlifting: OpenPowerlifting database
- Ajuste dinamico: opt-in para datos anonimos de comunidad

---

## Pantallas (UI)

### Tab 1: Dashboard
[Rango general, ultimo workout, progreso semanal, boton nuevo workout]

### Tab 2: Workout (EL CORE - la pantalla mas importante)
[Lista de ejercicios con historial "ultima vez" en cada uno, sets con peso/reps, selector RIR [0][1][2][3][4][5+] por set, timer entre sets, plate calculator, boton dropset/superset, sugerencia de peso basada en RIR (si RIR>2 sube peso, si RIR<1 baja), barra de progreso del workout]

### Tab 3: Progreso + Ranked
[Selector de ejercicio, grafica 1RM vs tiempo, rango actual con barra de progreso, PRs destacados, grafica de campana]

### Tab 4: Biblioteca + Rutinas
[Busqueda, filtrar por musculo, cada ejercicio muestra su rango, pestaña de rutinas]

### Tab 5: Perfil
[Edad, genero, peso corporal, estadisticas totales, preferencias (timer, unidades kg/lbs, discos disponibles)]

---

## Technical Stack

| Capa | Tecnologia |
|------|-----------|
| Lenguaje | Swift 6 |
| UI | SwiftUI + Charts |
| Arquitectura | MVVM + Coordinator |
| Persistencia | SwiftData (offline-first, 100% offline) |
| Graficas | Swift Charts (iOS 17+) |
| Ranking data | JSON embebido con thresholds |
| Testing | Swift Testing |
| Target | iOS 17+, Xcode 16+ |

---

## Archivos del proyecto (v1)

```
MiAppiOS/
├── Models/
│   ├── Workout.swift
│   ├── Exercise.swift
│   ├── Set.swift              (dropSet, supersetGroupId, rir, note)
│   ├── Routine.swift
│   ├── UserProfile.swift
│   └── StrengthStandard.swift
├── Services/
│   ├── WorkoutService.swift   (SwiftData CRUD)
│   ├── RankingService.swift   (calculo de rangos)
│   ├── ProgressionService.swift (sugerencia peso, deteccion PR)
│   └── StandardsService.swift (carga thresholds JSON)
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── WorkoutViewModel.swift  (EL mas importante)
│   ├── ProgressViewModel.swift
│   ├── RankingViewModel.swift
│   ├── LibraryViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── Dashboard/
│   ├── Workout/
│   │   ├── WorkoutView.swift
│   │   ├── ExerciseSectionView.swift
│   │   ├── SetRowView.swift
│   │   ├── RestTimerView.swift
│   │   └── PlateCalculatorView.swift
│   ├── Progress/
│   ├── Ranking/
│   ├── Library/
│   └── Profile/
├── Utilities/
│   ├── Estimators.swift       (Epley, Brzycki)
│   ├── PlateCalculator.swift
│   ├── WarmupCalculator.swift
│   └── Extensions.swift
└── Resources/
    └── strength_standards.json
```

---

## Lo que NO entra en v1

- Apple Watch
- Export/Import Hevy
- Programas pre-armados (5/3/1, etc.)
- Fotos de progreso
- Mesociclo tracking completo
- Seasons/quincenas
- Subdivisiones IV-I dentro de rangos (solo rango base)
- Compartir rutinas por link
- RIR detallado (v1 tiene [0]...[5+], simplificado)

---

## Edge Cases

- Peso corporal = 0 -> no ranking hasta que el usuario ponga su peso
- Nuevo usuario sin datos -> "Completa 3 workouts para ver tu rango inicial"
- Bodyweight exercises -> dominadas, flexiones: solo reps, peso = 0
- Lastre -> dominadas con peso anadido: peso+reps
- Barra de 20kg vs 15kg vs EZ-bar -> el usuario configura la barra, afecta plate calculator
- Plates disponibles -> el usuario configura que discos tiene disponibles
- Workout a medianoche -> la fecha se asigna al dia correcto
- Telefono sin bateria -> estado guardado localmente, no se pierde nada
