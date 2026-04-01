# AMO Claude Workflows

Система AI-агентів для Claude Code CLI. Дозволяє одному розробнику виконувати повний цикл розробки — від уточнення задачі до Pull Request — з якістю, порівнянною з роботою команди (дослідження, архітектура, код-рев'ю, документація).

## Установка

Prerequisite: [Claude Code](https://claude.ai/code) має бути встановлений (`~/.claude/` існує).

```bash
./install.sh
```

Скрипт створює **symlinks** з цього репозиторію в `~/.claude/`:

```
amo-claude-workflows/commands/*    →  ~/.claude/commands/*
amo-claude-workflows/agents/*      →  ~/.claude/agents/*
amo-claude-workflows/rules/*       →  ~/.claude/rules/*
amo-claude-workflows/scenarios/*   →  ~/.claude/scenarios/*
amo-claude-workflows/skills/*      →  ~/.claude/skills/*
amo-claude-workflows/contexts/*    →  ~/.claude/contexts/*
amo-claude-workflows/templates/*   →  ~/.claude/templates/*
```

Кожен файл/піддиректорія лінкується **окремо** (не вся директорія). Існуючі файли не перезаписуються — symlinks, що вказують на інші місця, та звичайні файли пропускаються.

## Деінсталяція

```bash
./uninstall.sh
```

Видаляє **тільки** symlinks, які вказують на цей репозиторій. Чужі файли та symlinks на інші джерела не зачіпає. Пусті директорії прибирає автоматично.

## Сценарії

Основні multi-step workflows, кожен складається з послідовності команд.

### Feature Development

```bash
/feature "опис задачі"
```

Повний цикл розробки фічі. Мета-команда, яка навігує через фази та відстежує стан у `.workflows/{feature-id}/state.json`. Адаптується за складністю — прості задачі пропускають Design/Plan, складні проходять повний цикл.

**Фази:** `/refine` (optional) → `/research` → `/design` → HUMAN REVIEW → `/plan` → `/implement` → `/docs-suite` → `/pr`

**Результат:** готовий Pull Request з кодом, тестами, документацією та ревʼю-звітами.

| Фаза | Агенти | Rules | Skills |
|------|--------|-------|--------|
| Refine (optional) | task-refiner | language | task-refinement |
| Research | research-lead, codebase-researcher | language, coding-style | — |
| Design | design-architect, test-strategist, devils-advocate | language, coding-style, database, messaging, testing | design-template, adr-template, api-contracts-template |
| Plan | phase-planner | language | tdd-approach |
| Implement | implement-lead, code-writer, security-reviewer, quality-reviewer, design-reviewer, quality-gate | language, git, coding-style, security, testing | owasp-top-10, security-audit-checklist |
| Docs | technical-collector, architect-collector, swagger-collector, technical-writer | — | stoplight-docs (if applicable) |
| PR | — (пряма команда) | language, git | — |

**Сценарій:** `scenarios/delivery/feature-development.md`

```
.workflows/{feature-id}/
├── state.json
├── refinement/
│   └── refined-task.md
├── research/
│   ├── research-report.md
│   ├── architecture-scan.md
│   ├── data-scan.md
│   └── integration-scan.md
├── design/
│   ├── architecture.md
│   ├── diagrams.md
│   ├── adr/*.md
│   ├── api-contracts.md
│   ├── test-strategy.md
│   ├── challenge-report.md
│   └── security-review.md (optional)
├── plan/
│   ├── overview.md
│   └── phase-{N}.md
└── implement/
    ├── phase-{N}-report.md
    ├── phase-{N}-security-review.md
    ├── phase-{N}-quality-review.md
    ├── phase-{N}-design-review.md
    └── phase-{N}-quality-gate-report.md
```

### Sentry Triage → Fix

```bash
/sentry-triage --project {name} --org {org}
```

Збирає production issues з Sentry, категоризує за критичністю (CRITICAL/HIGH/MEDIUM), групує за кореневою причиною. Кожен task потім можна передати у Feature Development:

```bash
/feature --from docs/tasks/{issue-id}/issue.md "Fix description"
```

**Результат:** `docs/tasks/triage-report.md` + окремі `issue.md` для кожного task.

| Компонент | Значення |
|-----------|----------|
| Агент | sentry-triager (opus) |
| Rules | language |
| Skills | auto:{project}-patterns |
| MCP | Sentry (list_issues, get_issue_details, analyze_issue_with_seer) |
| Сценарій | `scenarios/delivery/feature-development.md` (entry point) |

```
docs/tasks/
├── triage-report.md
├── {ISSUE-ID-1}-{slug}/
│   └── issue.md
├── {ISSUE-ID-2}-{slug}/
│   └── issue.md
└── ...
```

### Documentation Suite

```bash
/docs-suite
```

Генерація повного пакету документації проекту. Оркеструє 4 агенти: збирач технічних фактів, архітектурних діаграм, OpenAPI spec та технічний писар.

**Результат:** `docs/` з технічною документацією, діаграмами та API reference.

| Фаза | Агент | Що робить |
|------|-------|-----------|
| Collect | technical-collector | Збирає технічні факти з коду |
| Collect | architect-collector | Генерує архітектурні діаграми |
| Collect | swagger-collector | Генерує/валідує OpenAPI spec |
| Write | technical-writer | Пише документацію з артефактів |

**Сценарій:** `scenarios/delivery/documentation-suite.md`

```
docs/
├── .artifacts/                    # Проміжні артефакти
│   ├── technical-collection-report.md
│   ├── architecture-report.md
│   ├── openapi.yaml
│   ├── swagger-coverage-report.md
│   └── .meta.json
├── features/
│   └── *.md                       # Статті по фічах
├── openapi.yaml
├── INDEX.md
├── getting-started.md             # (stoplight format)
├── toc.json                       # (stoplight format)
└── reference/
    └── openapi.yaml               # (stoplight format)
```

## Команди

Окремі команди, які можна запускати незалежно або як частину сценарію.

### `/refine "опис"`

Уточнює нечітку задачу від PM через інтерактивний діалог. Автоматично збирає технічний контекст з кодової бази, попередніх артефактів та Sentry. Задає 2-3 уточнюючі питання за раунд (до 3 раундів), оцінює scope.

**Результат:** `refined-task.md` з user stories, acceptance criteria, T-shirt estimation, risk flags.

| Компонент | Значення |
|-----------|----------|
| Агент | task-refiner (opus) |
| Rules | language |
| Skills | task-refinement, auto:{project}-patterns |
| MCP | Sentry (optional), Context7 (optional) |

```
.workflows/{feature-id}/refinement/
├── refined-task.md
└── source.md                      # (якщо --from)
```

### `/research "опис"`

AS-IS аналіз кодової бази в контексті задачі. Оркеструє Research Lead + Codebase Researchers для сканування архітектури, даних, інтеграцій. Збирає факти — не пропонує рішення.

**Результат:** research report з компонентами, data flows, залежностями та open questions.

| Компонент | Значення |
|-----------|----------|
| Агенти | research-lead (opus), codebase-researcher ×1-4 (sonnet) |
| Rules | language, coding-style |
| Skills | auto:{project}-patterns |
| MCP | Sentry (для bug-fix), Context7 |
| Context | `contexts/research.md` |

```
.workflows/{feature-id}/research/
├── research-report.md
├── architecture-scan.md
├── data-scan.md
└── integration-scan.md
```

### `/design "опис"`

Архітектурні рішення для задачі. Оркеструє Design Architect + Test Strategist + Devil's Advocate (challenge). Генерує C4/DataFlow/Sequence діаграми, ADR, тест-стратегію, API контракти.

**Результат:** design artifacts для human review.

| Компонент | Значення |
|-----------|----------|
| Агенти | design-architect (opus), test-strategist (sonnet), devils-advocate (opus), security-reviewer (optional, sonnet) |
| Rules | language, coding-style, database, messaging, testing |
| Skills | design-template, adr-template, api-contracts-template, auto:{project}-patterns |
| Context | `contexts/review.md` |

```
.workflows/{feature-id}/design/
├── architecture.md
├── diagrams.md
├── adr/
│   └── *.md                       # Одне рішення — один файл
├── api-contracts.md
├── test-strategy.md
├── challenge-report.md
└── security-review.md             # (optional)
```

### `/plan "опис"`

Декомпозиція дизайну на вертикальні фази реалізації. Кожна фаза — незалежний deliverable з тестами. Визначає порядок, залежності, TDD підхід.

**Результат:** overview.md + phase-{N}.md з acceptance criteria та чітким scope.

| Компонент | Значення |
|-----------|----------|
| Агент | phase-planner (opus) |
| Rules | language |
| Skills | tdd-approach, auto:{project}-patterns |
| Context | `contexts/planning.md` |

```
.workflows/{feature-id}/plan/
├── overview.md
├── phase-1.md
├── phase-2.md
└── phase-{N}.md
```

### `/implement`

Виконання однієї фази імплементації. Оркеструє Code Writer + паралельні Code Reviewers (security, quality, design) + Quality Gate. Ітерує до проходження всіх перевірок.

**Результат:** код + review-звіти + quality gate report.

| Компонент | Значення |
|-----------|----------|
| Агенти | implement-lead (opus), code-writer (sonnet), security-reviewer (sonnet), quality-reviewer (sonnet), design-reviewer (sonnet), quality-gate (sonnet) |
| Rules | language, git, coding-style, security, testing |
| Skills | owasp-top-10, security-audit-checklist, auto:{project}-patterns |
| Context | `contexts/dev.md` (writer), `contexts/review.md` (reviewers) |

```
.workflows/{feature-id}/implement/
├── phase-{N}-report.md
├── phase-{N}-security-review.md
├── phase-{N}-quality-review.md
├── phase-{N}-design-review.md
└── phase-{N}-quality-gate-report.md
```

### `/pr`

Створення Pull Request з посиланнями на дизайн-артефакти, тест-планом та CI verification.

| Компонент | Значення |
|-----------|----------|
| Тип | Пряма команда (без агентів) |
| Rules | language, git |

### `/qa-checklist "опис фічі"`

Генерує QA чеклист з опису фічі. Приймає будь-який формат: PDF, зображення, текст, URL.

**Результат:** структурований тест-чеклист у чаті.

| Компонент | Значення |
|-----------|----------|
| Агент | qa-engineer (sonnet) |
| Rules | qa-checklist-selection |
| Skills | test-design-techniques |

### `/system-profile`

Генерує реєстр інтеграцій проекту — use cases, актори, data flows, open questions.

**Результат:** `docs/system-profile.md`.

| Компонент | Значення |
|-----------|----------|
| Агент | system-profiler (opus) |
| Rules | language |
| Skills | auto:{project}-patterns |

### `/skill-from-git`

Аналізує git history проекту та генерує project skill з реальними патернами команди (PHP/Symfony). Skill потім використовується агентами для дотримання conventions проекту.

**Результат:**

```
.claude/skills/{project}-patterns/
├── SKILL.md
└── references/
    ├── architecture.md
    ├── workflows.md
    └── conventions.md
```

### `/ai-debug`

Статус системи, аналіз промптів, пояснення workflows. Показує всі доступні агенти, команди, skills та їх стан.

```bash
/ai-debug                           # Статус системи
/ai-debug --prompt "your request"   # Аналіз що буде запущено
/ai-debug --agents                  # Список агентів
/ai-debug --commands                # Список команд
```
