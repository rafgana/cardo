# Specs - MiAppiOS

## Workflow
1. Crea `features/<nombre-feature>/spec.md` con requirements
2. Haz `/speckit.plan` o crea `plan.md` con tech details
3. Haz `/speckit.tasks` o crea `tasks.md`
4. Implementa con `/speckit.implement`
5. Archiva en `completed/` cuando termine

## Template para spec.md
```markdown
# Feature: [Nombre]

## User Story
Como [rol], quiero [acción] para [beneficio].

## Acceptance Criteria
- [ ] Criterio 1
- [ ] Criterio 2

## UI/UX
- Pantallas, flujos, mockups

## Technical Notes
- SwiftUI views, MVVM, data flow
```
