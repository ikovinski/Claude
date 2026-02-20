# Codemap Template

Template for automated architectural documentation generated from codebase.

## Freshness Metadata

Codemaps MUST be regenerated when code structure changes significantly.

| Staleness | Action |
|-----------|--------|
| < 7 days | Fresh, OK |
| 7-14 days | Warning in PR review |
| > 14 days | Must regenerate before merge |

## Template

```markdown
---
last_updated: YYYY-MM-DD
generated_from: codebase
validation_status: passed  # passed | stale | failed
component_count: N
---

# [Area] Codemap

## Overview

Brief description of this area's responsibility in the system.

## Structure

\`\`\`
src/[Area]/
├── SubDir/
│   ├── File1.php
│   └── File2.php
└── MainFile.php
\`\`\`

## Key Components

| Component | Purpose | Location | Dependencies |
|-----------|---------|----------|--------------|
| ClassName | What it does | src/path/File.php | Dep1, Dep2 |

## Data Flow

\`\`\`mermaid
flowchart LR
    A[Input] --> B[Process] --> C[Output]
\`\`\`

## External Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| vendor/package | What for | ^1.0 |

## Related Areas

- [Link to related codemap](./related.md)
```

---

## PHP/Symfony Specific Codemaps

### Controllers Codemap

```markdown
# Controllers Codemap

---
last_updated: YYYY-MM-DD
generated_from: codebase
validation_status: passed
---

## Overview

API controllers handling HTTP requests.

## Routes

| Controller | Route | Method | DTO | Auth |
|------------|-------|--------|-----|------|
| WorkoutController | /api/v1/workouts | GET | — | Bearer |
| WorkoutController | /api/v1/workouts | POST | CreateWorkoutDTO | Bearer |

## Structure

\`\`\`
src/Controller/
├── Api/
│   ├── v1/
│   │   ├── WorkoutController.php
│   │   └── UserController.php
│   └── v2/
└── Admin/
\`\`\`

## Data Flow

\`\`\`mermaid
flowchart LR
    Request --> Controller
    Controller --> Service
    Service --> Repository
    Repository --> DB[(Database)]
\`\`\`
```

### Services Codemap

```markdown
# Services Codemap

---
last_updated: YYYY-MM-DD
generated_from: codebase
validation_status: passed
---

## Overview

Business logic layer services.

## Services

| Service | Dependencies | Public Methods |
|---------|--------------|----------------|
| WorkoutService | WorkoutRepository, EventDispatcher | create(), update(), delete() |
| CalorieCalculator | — | calculate(Workout): int |

## Structure

\`\`\`
src/Service/
├── Workout/
│   ├── WorkoutService.php
│   └── CalorieCalculator.php
├── Billing/
└── Integration/
\`\`\`
```

### Entities Codemap

```markdown
# Entities Codemap

---
last_updated: YYYY-MM-DD
generated_from: codebase
validation_status: passed
---

## Overview

Doctrine ORM entities and their relationships.

## Entities

| Entity | Table | Key Relations |
|--------|-------|---------------|
| User | users | HasMany: Workout, Subscription |
| Workout | workouts | BelongsTo: User, HasMany: Exercise |
| Exercise | exercises | BelongsTo: Workout |

## ER Diagram

\`\`\`mermaid
erDiagram
    User ||--o{ Workout : has
    User ||--o| Subscription : has
    Workout ||--o{ Exercise : contains
\`\`\`

## Structure

\`\`\`
src/Entity/
├── User.php
├── Workout.php
├── Exercise.php
└── Subscription.php
\`\`\`
```

### Message Handlers Codemap

```markdown
# Message Handlers Codemap

---
last_updated: YYYY-MM-DD
generated_from: codebase
validation_status: passed
---

## Overview

Async message handlers for RabbitMQ/Symfony Messenger.

## Handlers

| Handler | Message | Async | Transport |
|---------|---------|-------|-----------|
| SyncWorkoutHandler | SyncWorkoutMessage | Yes | async |
| SendNotificationHandler | SendNotificationMessage | Yes | async |
| ProcessPaymentHandler | ProcessPaymentMessage | Yes | async_priority |

## Data Flow

\`\`\`mermaid
flowchart LR
    Producer --> Queue[(RabbitMQ)]
    Queue --> Handler
    Handler --> Service
    Service --> DB[(Database)]
\`\`\`

## Structure

\`\`\`
src/
├── Message/
│   ├── SyncWorkoutMessage.php
│   └── SendNotificationMessage.php
└── MessageHandler/
    ├── SyncWorkoutHandler.php
    └── SendNotificationHandler.php
\`\`\`
```

---

## INDEX.md Template

```markdown
# Codemaps Index

---
last_updated: YYYY-MM-DD
generated_from: codebase
validation_status: passed
total_components: N
---

## Overview

Architectural maps of the codebase, auto-generated from source code.

## Areas

| Area | Components | Last Updated | Status |
|------|------------|--------------|--------|
| [Controllers](controllers.md) | 15 | YYYY-MM-DD | Fresh |
| [Services](services.md) | 23 | YYYY-MM-DD | Fresh |
| [Entities](entities.md) | 18 | YYYY-MM-DD | Fresh |
| [Messages](messages.md) | 8 | YYYY-MM-DD | Stale |
| [Commands](commands.md) | 5 | YYYY-MM-DD | Fresh |

## Quick Stats

| Metric | Count |
|--------|-------|
| Total PHP files | 150 |
| Controllers | 15 |
| Services | 23 |
| Entities | 18 |
| Message Handlers | 8 |
| Console Commands | 5 |

## Regenerate

\`\`\`bash
/codemap                    # Regenerate all
/codemap --area services    # Regenerate specific area
/codemap --validate         # Check freshness
\`\`\`
```

---

## Validation Checklist

Before committing codemaps:

- [ ] All file paths verified to exist
- [ ] Freshness timestamps updated (`last_updated`)
- [ ] `validation_status` reflects reality
- [ ] Mermaid diagrams render correctly
- [ ] Component counts accurate
- [ ] Links to related codemaps work
- [ ] No stale references to deleted files

---

## Generation Commands

```bash
# Find all controllers
find src/Controller -name "*.php"

# Find all services
grep -r "class.*Service" src/Service/ --include="*.php" -l

# Find all entities
find src/Entity -name "*.php"

# Find message handlers
grep -rn "#\[AsMessageHandler\]" src/ --include="*.php"

# Find routes
grep -rn "#\[Route" src/Controller/ --include="*.php"
```
