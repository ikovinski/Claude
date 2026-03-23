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
**Ручний режим:** послідовно `/research` → `/design` → `/plan` → `/implement` → `/docs-suite` → `/pr`

| Фаза | Команда | Агенти | Артефакти |
|------|---------|--------|-----------|
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

| Фаза | Агенти | Артефакти |
|------|--------|-----------|
| Collect | Technical Collector, Architect Collector, Swagger Collector | `docs/.artifacts/` |
| Write | Technical Writer | `docs/` |

**Сценарій:** `scenarios/delivery/documentation-suite.md`
**Гайд:** `docs/how/incremental-docs-update.md`

### 4. System Profiling

Реєстр інтеграцій проекту — use cases, актори, data flows.

**Запуск:** `/system-profile`

| Агент | Артефакти |
|-------|-----------|
| System Profiler | `docs/system-profile.md` |

### 5. Утиліти (поза флоу)

| Команда | Призначення |
|---------|-------------|
| `/skill-from-git` | Згенерувати project skill з git history |
| `/ai-debug` | Діагностика системи, аналіз промптів |

---

## Agents

### Engineering

| Agent | File | Використовується у |
|-------|------|--------------------|
| Research Lead | `agents/engineering/research-lead.md` | Feature Development → Research |
| Codebase Researcher | `agents/engineering/codebase-researcher.md` | Feature Development → Research |
| Design Architect | `agents/engineering/design-architect.md` | Feature Development → Design |
| Test Strategist | `agents/engineering/test-strategist.md` | Feature Development → Design |
| Devil's Advocate | `agents/engineering/devils-advocate.md` | Feature Development → Design |
| Phase Planner | `agents/engineering/phase-planner.md` | Feature Development → Plan |
| Implement Lead | `agents/engineering/implement-lead.md` | Feature Development → Implement |
| Code Writer | `agents/engineering/code-writer.md` | Feature Development → Implement |
| TDD Guide | `agents/engineering/tdd-guide.md` | Feature Development → Implement (опціонально) |
| Security Reviewer | `agents/engineering/security-reviewer.md` | Feature Development → Implement (medium+large) |
| Quality Reviewer | `agents/engineering/quality-reviewer.md` | Feature Development → Implement |
| Design Reviewer | `agents/engineering/design-reviewer.md` | Feature Development → Implement (large) |
| Quality Gate | `agents/engineering/quality-gate.md` | Feature Development → Implement |
| Sentry Triager | `agents/engineering/sentry-triager.md` | Sentry Triage |

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

Кожна команда МУСИТЬ завантажити project skill перед виконанням.

1. `{project-name}` = basename поточної CWD
2. Шукати: `{CWD}/.claude/skills/{project-name}-patterns/SKILL.md`
3. Якщо знайдено — прочитати SKILL.md + `references/*.md`
4. Передати агентам як `[PROJECT PATTERNS]` — мандаторні обмеження

**Генерація:** `/skill-from-git` у цільовому проекті

## Domain Rules

| Rule | File | Хто використовує |
|------|------|------------------|
| Language | `rules/language.md` | Всі — українська комунікація |
| Git | `rules/git.md` | Code Writer, Implement Lead |
| Coding Style | `rules/coding-style.md` | Code Writer, Quality Reviewer, Design Architect, та інші |
| Security | `rules/security.md` | Code Writer, Security Reviewer |
| Testing | `rules/testing.md` | Code Writer, Quality Reviewer, Test Strategist, TDD Guide |
| Database | `rules/database.md` | Design Architect |
| Messaging | `rules/messaging.md` | Design Architect |

## Contexts

| Context | File | Завантажує | Для |
|---------|------|------------|-----|
| Development | `contexts/dev.md` | `/implement` | Code Writer |
| Planning | `contexts/planning.md` | `/plan` | Phase Planner |
| Research | `contexts/research.md` | `/research` | Research Lead + scanners |
| Review | `contexts/review.md` | `/implement` | Reviewers |

## How It Works

1. Користувач вводить `/command` у Claude Code
2. Команда завантажує project skill (якщо є)
3. Команда активує агента/агентів з відповідними rules та context
4. Агенти працюють з артефактами попередньої фази (artifact chain)
5. Результат — структурований вивід у визначену директорію
