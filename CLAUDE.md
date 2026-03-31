# AI Agents System

Система AI-агентів для Claude Code CLI. Мета — зробити розробку точнішою, прогнозованою,
і дозволити одному розробнику робити більше, ніж можливо самотужки.

Кожна задача проходить через визначений флоу з чіткими фазами, артефактами та human checkpoints.

## Принципи розвитку системи

### Інтеграція перед створенням

Перед розробкою нового функціоналу:
1. Перевір чи існуючий флоу покриває потребу (розділ "Flows")
2. Перевір чи існуючий агент може бути перевикористаний (розділ "Agents")
3. Якщо ні — запропонуй новий флоу з обґрунтуванням

### Документаційна дисципліна

Кожна зміна з окремим логічним циклом виконання МУСИТЬ бути задокументована щонайменше в одній з:

| Директорія | Питання | Приклад |
|------------|---------|---------|
| `docs/how/` | Як це використовувати? | Покрокові гайди, приклади запуску |
| `docs/why/` | Чому зроблено саме так? | Обґрунтування рішень, trade-offs |
| `docs/comparisons/` | Чим відрізняється від попереднього? | Порівняння з альтернативами |

### Сценарії

Кожен сценарій у `scenarios/` МУСИТЬ мати README.md з:
- Опис проблеми, яку вирішує
- Діаграма фаз (text/mermaid)
- Перелік агентів та їх ролей
- Приклади запуску
- Артефакти, що створюються

---

## Flows

### 1. Feature Development (основний)

Повний цикл розробки від задачі до PR. Адаптивний за складністю.

**Запуск:** `/feature "опис задачі"`
**Ручний режим:** послідовно `/refine` (optional) → `/research` → `/design` → `/plan` → `/implement` → `/docs-suite` → `/pr`

| Фаза | Команда | Агенти | Артефакти |
|------|---------|--------|-----------|
| Refinement (optional) | `/refine` | Task Refiner | `.workflows/{id}/refinement/` |
| Research | `/research` | Research Lead, Codebase Researcher | `.workflows/{id}/research/` |
| Design | `/design` | Design Architect, Test Strategist, Devil's Advocate | `.workflows/{id}/design/` |
| Plan | `/plan` | Phase Planner | `.workflows/{id}/plan/` |
| Implement | `/implement` | Implement Lead, Code Writer, Security Reviewer, Quality Reviewer, Design Reviewer, Quality Gate | `.workflows/{id}/implement/` |
| Docs | `/docs-suite` | Technical Collector, Architect Collector, Swagger Collector, Technical Writer | `docs/` |
| PR | `/pr` | — (пряма команда) | GitHub PR |

**Складність** (визначається Research автоматично):
- **small** — skip Design+Plan, 1 reviewer → ~76% економія токенів
- **medium** — light Design, 2 reviewers
- **large** — повний флоу

**Сценарій:** `scenarios/delivery/feature-development.md`
**Гайд:** `docs/how/feature-flow.md`

### 2. Sentry Triage → Feature

Автоматичний збір production issues → категоризація → розробка через Feature Development.

**Запуск:** `/sentry-triage --project {name} --org {org}`
**Продовження:** `/feature --from docs/tasks/task-N/issue.md`

| Фаза | Команда | Агенти | Артефакти |
|------|---------|--------|-----------|
| Triage | `/sentry-triage` | Sentry Triager | `docs/tasks/triage-report.md`, `docs/tasks/task-{N}-{slug}/issue.md` |
| Fix | `/feature --from ...` | → Feature Development flow | `.workflows/{id}/` |

**Сценарій:** `scenarios/delivery/feature-development.md` (entry point: Sentry Triage)

### 3. Documentation Suite

Генерація повного пакету документації проекту.

**Запуск:** `/docs-suite` (повна генерація) або `/docs-suite --update` (інкрементальне оновлення)

| Command | Agent | Description |
|---------|-------|-------------|
| `/feature` | Meta-command | Full feature flow navigator with state tracking |
| `/research` | Research Lead + Codebase Researcher | Investigate codebase before implementation |
| `/design` | Design Architect + Test Strategist + Devil's Advocate | Architecture decisions, ADR, test strategy, design challenge |
| `/plan` | Phase Planner | Decompose design into implementation phases |
| `/implement` | Implement Lead + Writer + Reviewers + Gate | Execute one implementation phase |
| `/docs-suite` | Team Lead + 4 agents | Full documentation suite |
| `/pr` | Direct command | Create PR with design references |
| `/sentry-triage` | Sentry Triager | Collect & categorize Sentry issues into tasks |
| `/qa-checklist` | QA Engineer | Generate QA checklist from feature description (PDF, images, URL, text) |
| `/skill-from-git` | -- | Extract project skill from git history |
| `/ai-debug` | -- | System status and prompt analysis |

## Agents

### Engineering
| Agent | File | Purpose |
|-------|------|---------|
| Research Lead | `agents/engineering/research-lead.md` | Decompose task, orchestrate research, synthesize report |
| Codebase Researcher | `agents/engineering/codebase-researcher.md` | Scan codebase AS IS — facts only |
| Design Architect | `agents/engineering/design-architect.md` | Diagrams, architecture, ADR, API contracts (contract-first) |
| Test Strategist | `agents/engineering/test-strategist.md` | Test strategy, cases, coverage expectations |
| Phase Planner | `agents/engineering/phase-planner.md` | Decompose design into vertical-slice phases |
| Implement Lead | `agents/engineering/implement-lead.md` | Orchestrate implementation, coordinate team |
| Code Writer | `agents/engineering/code-writer.md` | Write code strictly per plan |
| TDD Guide | `agents/engineering/tdd-guide.md` | TDD coach — test-first discipline, test quality, isolation |
| Security Reviewer | `agents/engineering/security-reviewer.md` | OWASP Top 10, secrets, injection, access control (paranoid by default) |
| Quality Reviewer | `agents/engineering/quality-reviewer.md` | Complexity, SOLID, domain model, layer compliance |
| Design Reviewer | `agents/engineering/design-reviewer.md` | Verify implementation matches design artifacts |
| Quality Gate | `agents/engineering/quality-gate.md` | Run build, tests, linters, Sentry check |
| Devil's Advocate | `agents/engineering/devils-advocate.md` | Challenge architecture decisions, find weak assumptions in ADR |
| Sentry Triager | `agents/engineering/sentry-triager.md` | Collect, categorize, group Sentry issues into tasks |
| QA Engineer | `agents/engineering/qa-engineer.md` | Generate QA checklist from feature description (any format) |

### Documentation

| Agent | File | Використовується у |
|-------|------|--------------------|
| Technical Collector | `agents/documentation/technical-collector.md` | Documentation Suite, Feature Development → Docs |
| Architect Collector | `agents/documentation/architect-collector.md` | Documentation Suite, Feature Development → Docs |
| Swagger Collector | `agents/documentation/swagger-collector.md` | Documentation Suite, Feature Development → Docs |
| Technical Writer | `agents/documentation/technical-writer.md` | Documentation Suite, Feature Development → Docs |
| System Profiler | `agents/documentation/system-profiler.md` | System Profiling |

---

## Commands

Кожна команда — точка входу. Згруповані за флоу.

### Feature Development flow

| Команда | Опис | Агенти |
|---------|------|--------|
| `/feature` | Мета-навігатор повного циклу | — |
| `/refine` | Уточнення задачі від PM через діалог (optional Phase 0) | Task Refiner |
| `/research` | AS-IS аналіз кодової бази | Research Lead + Codebase Researcher |
| `/design` | Архітектура, ADR, тест-стратегія | Design Architect + Test Strategist + Devil's Advocate |
| `/plan` | Декомпозиція дизайну на фази | Phase Planner |
| `/implement` | Виконання однієї фази | Implement Lead + Code Writer + Reviewers + Quality Gate |
| `/pr` | Створення Pull Request | — (пряма команда) |

### Documentation flow

| Команда | Опис | Агенти |
|---------|------|--------|
| `/docs-suite` | Повна документація | 4 Documentation agents |

### Operations flow

| Команда | Опис | Агенти |
|---------|------|--------|
| `/sentry-triage` | Збір issues з Sentry | Sentry Triager |
| `/system-profile` | Реєстр інтеграцій | System Profiler |

### Utilities

| Команда | Опис |
|---------|------|
| `/skill-from-git` | Генерація project skill з git history |
| `/ai-debug` | Статус системи, аналіз промптів |

---

## Structure

```
ai-agents-system/
├── commands/         # Slash commands — точки входу
├── agents/           # Agent personas (engineering/, documentation/)
│   ├── engineering/  # 14 агентів для розробки
│   └── documentation/# 5 агентів для документації
├── scenarios/        # Multi-agent workflows з README
│   └── delivery/     # feature-development, documentation-suite
├── rules/            # Domain rules, завантажуються агентами
├── contexts/         # Mode contexts (dev, planning, research, review)
├── skills/           # Reusable skills та templates
├── templates/        # Шаблони для нових агентів/сценаріїв
└── docs/             # Документація системи
    ├── how/          # Як це використовувати
    ├── why/          # Чому саме так
    └── comparisons/  # Порівняння з альтернативами
```

## Project Skill (CRITICAL)

| Rule | File | Used by |
|------|------|---------|
| Language | `rules/language.md` | All agents — Ukrainian communication |
| Git | `rules/git.md` | code-writer, implement-lead — clean commits |
| Coding Style | `rules/coding-style.md` | code-writer, quality-reviewer, design-architect, research-lead, design-reviewer, test-strategist, tdd-guide, security-reviewer — PHP 8.3/Symfony patterns |
| Security | `rules/security.md` | code-writer, security-reviewer — PII/PHI, auth, logging |
| Testing | `rules/testing.md` | code-writer, quality-reviewer, test-strategist, tdd-guide — coverage targets, test patterns |
| Database | `rules/database.md` | design-architect — Doctrine, N+1, migrations |
| Messaging | `rules/messaging.md` | design-architect — RabbitMQ/Kafka, idempotency |
| Checklist | `rules/qa-checklist-selection.md` | qa-engineer — pre-defined checklists applied |

## Contexts

Contexts are mode-specific priorities and guardrails injected into agent spawn prompts via `[MODE CONTEXT]` section.

| Context | File | Loaded by | Injected into |
|---------|------|-----------|---------------|
| Development | `contexts/dev.md` | `/implement` | Code Writer |
| Planning | `contexts/planning.md` | `/plan` | Phase Planner (self) |
| Research | `contexts/research.md` | `/research` | Research Lead (self) + scanners |
| Review | `contexts/review.md` | `/implement` | Security, Quality, Design Reviewers |

## How It Works

1. Користувач вводить `/command` у Claude Code
2. Команда завантажує project skill (якщо є)
3. Команда активує агента/агентів з відповідними rules та context
4. Агенти працюють з артефактами попередньої фази (artifact chain)
5. Результат — структурований вивід у визначену директорію
