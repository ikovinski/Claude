# Proposal: Document Step Integration into Dev Workflow

## Context

Dev-workflow (6 steps: Research → Design → Plan → Implement → Review → PR) не має кроку документації. Documentation-suite (5 phases) — це окремий повний сценарій для проєктної документації. Потрібно об'єднати їх так, щоб dev-workflow документував обмежений контекст задачі, але при цьому ревьюїв і оновлював загальну документацію.

## Рішення: Step 6 — Document

Пайплайн стає 7-крокним:

```
Research → Design → Plan → Implement → Review → Document → PR
  (1)       (2)      (3)      (4)         (5)       (6)      (7)
```

### Чому між Review і PR

- Весь код вже написаний і затверджений — документація відображає фінальний стан
- PR включає і код, і документацію як єдиний атомарний deliverable
- Не блокує мерж — soft check замість quality gate

---

## Два треки (паралельно)

### Track A — Bounded Context Docs (нова документація задачі)

| Артефакт | Шаблон | Що генерує |
|----------|--------|------------|
| Feature spec | `feature-spec-template.md` (compact) | `docs/features/{slug}.md` |
| API delta | `api-docs-template.md` | Snippet до `docs/references/openapi.yaml` |
| ADR finalization | Існуючі ADR з Design step | Status: Proposed → Accepted |

### Track B — General Docs Delta (інкрементальний review)

| Дія | Що перевіряє |
|-----|--------------|
| STALE scan | Класи/ендпоінти змінені, але docs ще має старі посилання |
| MISSING scan | Новий код не відображений в існуючих docs |
| BROKEN_LINK scan | Посилання на файли які перемістились/перейменувались |
| Auto-fix | Оновлює CODEMAPS, INDEX.md, стейл-посилання |
| Escalation | > 10 знахідок → рекомендує `/docs-suite` замість самостійного фіксу |

---

## Агенти

| Name | Agent | Model | Track | Роль |
|------|-------|-------|-------|------|
| Lead | technical-writer | opus | All | Orchestration, compile DOCS.md |
| feature-writer | technical-writer | sonnet | A | Feature spec, API delta, ADR finalization |
| delta-scanner | codebase-doc-collector | sonnet | B | Scan existing docs, delta report, auto-fixes |

architecture-doc-collector НЕ спавниться за замовчуванням. Тільки якщо задача додає нову зовнішню інтеграцію.

---

## Process Flow (3 фази)

### Phase 1: SCOPE (Lead, 2-3 хв)
- Читає PROGRESS.md, REVIEW.md (APPROVED), DESIGN.md
- Визначає scope: чи є нові API endpoints? ADR? Інтеграції? Чи є `docs/`?
- Створює task assignments

### Phase 2: GENERATE (паралельно, 5-15 хв)
- **feature-writer**: feature spec + API delta + ADR finalization
- **delta-scanner**: scan existing docs, delta report, auto-fixes
- Timebox: якщо Track B > 10 хв — abort з partial findings

### Phase 3: COMPILE (Lead, 3-5 хв)
- Cross-check consistency між треками
- Створює `.workflows/document/DOCS.md`
- Показує summary юзеру → Continue / Fix / Skip-docs
- Shutdown teammates

---

## Input/Output артефакти

### Input (з попередніх кроків)

```
.workflows/design/DESIGN.md          → feature overview
.workflows/design/api-contracts.md   → API contracts
.workflows/design/adr/*.md           → ADRs to finalize
.workflows/implement/PROGRESS.md     → file list (scope constraint)
.workflows/review/{slug}/REVIEW.md   → verdict + security summary
docs/**                              → existing documentation baseline
```

### Output

```
.workflows/document/
├── DOCS.md              # Summary всіх doc змін
├── feature-spec.md      # Згенерований feature spec
├── api-changes.md       # API delta (OpenAPI snippet)
├── adr-updates.md       # ADR status change log
└── delta-report.md      # Delta scan findings

docs/ (project-level updates):
├── features/{slug}.md        # CREATE — feature spec
├── references/openapi.yaml   # UPDATE — new endpoints
├── adr/*.md                  # UPDATE — status changes
├── CODEMAPS/*.md             # UPDATE — stale entries
└── INDEX.md                  # UPDATE — new entries
```

---

## Scope Control (запобігання full regeneration)

1. Обидва треки працюють ТІЛЬКИ з файлами із PROGRESS.md
2. НЕ генерує `.codemap-cache/` — тільки читає якщо є
3. НЕ створює system-profile — це territory docs-suite
4. НЕ регенерує CODEMAPS повністю — тільки delta updates
5. Feature spec ТІЛЬКИ compact template
6. \> 10 stale findings → рекомендує `/docs-suite`

---

## Зміни до PR step (Step 7)

PR step (раніше Step 6) потребує:
- Stage `docs/` файли разом з кодом
- Додати окремий docs commit: `docs: add documentation for {slug}`
- Додати "Documentation" секцію в PR.md template

---

## Feedback Loop

Якщо Document step знаходить code issues:
- **Doc-only issue**: fix в docs
- **Minor mismatch**: fix в docs (code is truth)
- **Significant code issue**: створити `.workflows/document/CODE-ISSUE.md` → user вирішує: back to Implement або proceed

---

## Standalone Mode

```bash
/dev --step document
```

| Aspect | Pipeline Mode | Standalone Mode |
|--------|---------------|-----------------|
| File discovery | PROGRESS.md | `git diff` |
| Feature spec | Full (from DESIGN.md) | Compact (from code only) |
| ADR finalization | Yes | Only if design artifacts exist |
| Delta scan | Yes | Yes |

---

## Success Criteria

**Minimum**: Feature spec created + DOCS.md exists + Delta report produced
**Good**: API docs updated + existing docs fixed + INDEX.md updated + ADRs finalized
**Excellent**: Zero stale refs + publication-ready feature spec + < 10 minutes

---

## Файли для створення/зміни

### Створити

| File | Опис |
|------|------|
| `scenarios/dev-workflow/6-document.md` | Головний сценарій Document step |
| `skills/dev-workflow/document-template.md` | DOCS.md template |

### Перейменувати

| Від | До |
|-----|---|
| `scenarios/dev-workflow/6-pr.md` | `scenarios/dev-workflow/7-pr.md` |

### Оновити

| File | Що змінити |
|------|------------|
| `scenarios/dev-workflow/7-pr.md` | Stage docs/, docs commit, Documentation секція в PR.md |
| `commands/dev.md` | Додати Step 6 Document, оновити нумерацію |
| `docs/dev-workflow/README.md` | Додати Document step |
| `docs/dev-workflow/artifacts.md` | Додати `.workflows/document/` |
| `docs/dev-workflow/state-management.md` | Додати "document" в state.json schema |
| `docs/dev-workflow/diagrams.md` | Оновити всі pipeline діаграми |
| `CLAUDE.md` | "6-step" → "7-step", додати Document |

---

## Reuse від Documentation Suite

| Компонент | Джерело | Адаптація |
|-----------|---------|-----------|
| Feature spec template | `skills/documentation/feature-spec-template.md` | Тільки compact version |
| API docs template | `skills/documentation/api-docs-template.md` | Additive only — append нових paths |
| ADR template | `skills/documentation/adr-template.md` | Status update only |
| Codemap validation | `agents/codebase-doc-collector.md` | Targeted validation (тільки affected areas) |
| Cache concept | Documentation-suite `.codemap-cache/` | Read-only — ніколи не регенерує |
| Cross-review pattern | Documentation-suite Phase 4 | Не реюзається — занадто heavyweight |
| INDEX generation | Documentation-suite Phase 5 | Append-only, не регенерувати |
