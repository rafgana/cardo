# MiAppiOS - Spec-Driven iOS App with AI

Eres un agente de IA construyendo una app iOS con Swift/SwiftUI usando Spec-Driven Development.

## Stack
- **Lenguaje**: Swift 6
- **UI**: SwiftUI
- **Arquitectura**: MVVM + Coordinator
- **Persistencia**: SwiftData o CoreData
- **AI/ML**: MLX (Apple Silicon) o CoreML
- **Testing**: Swift Testing

## Workflow (Spec-Driven)

Usa este flujo siempre, supervisado por el humano:

1. **Spec** — `/speckit.specify` o crea `specs/<feature>/spec.md`
2. **Plan** — `/speckit.plan` o crea `specs/<feature>/plan.md`
3. **Tasks** — `/speckit.tasks` o crea `specs/<feature>/tasks.md`
4. **Implement** — `/speckit.implement` (con checkpoints)
5. **Review** — validar, iterar, archivar spec en `specs/completed/`

Para tareas pequeñas usa `sdd-riper-one-light`:
- Restate goal → minimal spec → approval → execute → validate → reverse sync

## Harness Rules
- Sin spec aprobada, no codees
- Sin approval humano, no ejecutes
- Cada task necesita un "Done Contract" (qué prueba que está hecho)
- Reverse-sync: después de implementar, actualiza specs/memory

## Skills disponibles
- `sdd-riper-one-light` — daily coding harness
- `sdd-riper-one` — high-risk/multi-file harness
- `codemap` — indexa codebase para cambios
- `new-chat-ready` — handoff/resume pack
- `speckit-*` — spec-kit workflow skills
