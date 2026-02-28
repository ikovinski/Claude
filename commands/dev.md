---
name: dev
description: Development workflow pipeline. 6 atomic steps from Research to PR with Agent Teams.
allowed_tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
agent: null
scenario: dev-workflow
---

# /dev - Development Workflow Pipeline

6-step development pipeline: Research → Design → Plan → Implement → Review → PR. Кожен крок атомарний, запускається окремо або автоматично. Комунікація між кроками через артефакти в `.workflows/`.

## Usage

```bash
/dev "Add Apple Health integration"     # New workflow → starts with Research
/dev                                    # Auto-continue next step
/dev --step research                    # Run specific step
/dev --step design
/dev --step plan
/dev --step implement                   # All remaining phases
/dev --step implement --phase 2         # Specific phase
/dev --step review                      # Standalone review (works outside pipeline too)
/dev --step pr
/dev --status                           # Show workflow state
/dev --reset                            # Reset workflow
/dev --auto                             # All steps, pause at quality gates
```

## Output

### Artifact Structure

```
.workflows/
├── state.json                     # Flow state tracking
├── research/                      # Step 1: AS-IS analysis (5 files)
│   ├── RESEARCH.md                # Lead aggregation
│   ├── code-analysis.md           # Components, dependencies
│   ├── data-model.md              # Entities, DTOs, relations
│   ├── architecture-analysis.md   # AS-IS diagrams, integrations
│   └── test-coverage.md           # Tests, coverage gaps
├── design/                        # Step 2: Technical design
│   ├── DESIGN.md                  # Main design document
│   ├── diagrams.md                # Mermaid: C4, DataFlow, Sequence
│   ├── api-contracts.md           # Endpoints, schemas, errors
│   └── adr/                       # Architecture Decision Records
│       └── 001-*.md
├── plan/{feature-name}/           # Step 3: Implementation phases
│   └── 001-PLAN.md
├── implement/                     # Step 4: Code + progress
│   └── PROGRESS.md
├── review/{feature-name}/         # Step 5: Review findings
│   └── REVIEW.md
└── pr/                            # Step 6: PR preparation
    └── PR.md                      # PR description draft
```

## What Each Step Does

### Step 1: Research — "Що є зараз?"

**Agent Team**: Lead (researcher) + code-scanner (codebase-doc-collector) + arch-scanner (architecture-doc-collector)

Збирає повну картину поточного стану системи. Тільки AS-IS — жодних пропозицій.

1. Lead декомпозує задачу на 1-4 research areas
2. code-scanner і arch-scanner сканують код паралельно
3. Lead агрегує результати в RESEARCH.md

### Step 2: Design — "Як це має працювати?"

**Agent Team**: Lead (architecture-advisor) + contract-writer (technical-writer)

Розробляє технічний дизайн: C4/DataFlow/Sequence діаграми (Mermaid), ADR, API контракти.

1. Lead створює діаграми + ADR
2. contract-writer пише API контракти
3. **Quality gate**: дизайн показується для ревю з командою

### Step 3: Plan — "В якому порядку робити?"

**Single agent**: planner

Розбиває дизайн на фази реалізації, кожна незалежно deployable.

### Step 4: Implement — "Пишемо код"

**Agent Team**: developer (tdd-guide) + reviewer (code-reviewer)

Реалізація з вбудованим code review loop:
1. developer пише тести (Red) → код (Green) → рефакторинг
2. reviewer перевіряє security + quality + plan compliance
3. Якщо проблеми → developer виправляє → reviewer перевіряє знову

### Step 5: Review — "Фінальна перевірка"

**Agent Team**: quality (code-reviewer) + security (security-reviewer)

Комплексне ревю всього scope. Може запускатися окремо через `/dev --step review`.

### Step 6: PR — "Готово"

**Single**: bash/gh

Створює гілку + коміти. Генерує PR description draft.

**IMPORTANT**:
- НЕ створює PR автоматично — тільки після явного дозволу
- НЕ додає Co-Authored-By в коміти

## State Management

### state.json

```json
{
  "version": "1.0",
  "task": "Add Apple Health integration",
  "created_at": "2026-02-27T10:00:00Z",
  "current_step": "implement",
  "steps": {
    "research":  { "status": "completed", "completed_at": "..." },
    "design":    { "status": "completed", "quality_gate": "approved" },
    "plan":      { "status": "completed" },
    "implement": { "status": "in_progress", "phases_total": 4, "phases_completed": 2 },
    "review":    { "status": "pending" },
    "pr":        { "status": "pending" }
  }
}
```

### Auto-continue Algorithm

```
1. Read .workflows/state.json
2. If no state → error "Run /dev <task> first"
3. Check for REPLAN-NEEDED.md → redirect to plan if exists
4. Find first step where status != "completed"
5. Validate input artifacts exist
6. Run step's scenario
7. If --auto: continue to next unless quality gate (design)
```

### Quality Gates

| Gate | Where | Behavior |
|------|-------|----------|
| Design approval | After Step 2 | **PAUSE** — requires human `/dev` or `/dev --step plan` to continue |
| Review blocking | After Step 5 | If blocking issues → redirect to Implement |
| PR creation | Step 6 | **ASK** — requires explicit approval (default: no) |

## Examples

### New Feature

```
> /dev "Add Apple Health integration"

Starting /dev workflow...
Task: Add Apple Health integration

Step 1: Research
  Spawning research team...
  [code-scanner] Scanning affected code...
  [arch-scanner] Analyzing architecture...
  [lead] Aggregating results...
  ✅ Research complete: .workflows/research/ (5 files)

> /dev

Step 2: Design
  Spawning design team...
  [lead] Creating C4 + DataFlow + Sequence diagrams...
  [contract-writer] Writing API contracts...
  [lead] Creating ADR...
  ✅ Design complete: .workflows/design/

  ⏸️ Quality Gate: Review design with team before continuing.
  Run /dev or /dev --step plan when approved.

> /dev --step plan

Step 3: Plan
  Planner reading research + design...
  ✅ Plan complete: .workflows/plan/apple-health-integration/001-PLAN.md
  4 phases identified

> /dev --step implement

Step 4: Implement
  Phase 1/4: Data Layer
  [developer] Writing tests...
  [developer] Implementing code...
  [reviewer] Reviewing...
  [reviewer] ✅ Approved
  Phase 2/4: Message Handling
  ...
```

### Standalone Review

```
> /dev --step review

Step 5: Review (standalone)
  [quality] Reviewing code quality + design compliance...
  [security] Reviewing OWASP + PII/PHI...
  ✅ Review complete: .workflows/review/apple-health-integration/REVIEW.md
  Blocking: 0 | Suggestions: 3 | Security: PASS
```

### Check Status

```
> /dev --status

/dev Workflow Status
════════════════════
Task: Add Apple Health integration
Started: 2026-02-27

  research   ✅ completed
  design     ✅ completed (approved)
  plan       ✅ completed
  implement  🔄 in_progress (phase 3/4)
  review     ⏳ pending
  pr         ⏳ pending
```

## When to Use

| Situation | Command |
|-----------|---------|
| Нова фіча від початку до PR | `/dev "feature description"` |
| Продовжити де зупинився | `/dev` |
| Тільки дослідити codebase | `/dev --step research` |
| Тільки зробити дизайн | `/dev --step design` |
| Тільки code review | `/dev --step review` |
| Побачити прогрес | `/dev --status` |
| Почати з нуля | `/dev --reset` |

## Decision Points

| # | Question | Default |
|---|----------|---------|
| 1 | Design approved? | Pause and wait |
| 2 | Blocking review issues? | Redirect to Implement |
| 3 | Create PR? | No (ask first) |

---

*Scenarios: [scenarios/dev-workflow/](../scenarios/dev-workflow/)*
*Agent: [researcher](../agents/researcher.md)*
*Reused Agents: architecture-advisor, technical-writer, planner, tdd-guide, code-reviewer, security-reviewer, codebase-doc-collector, architecture-doc-collector*
