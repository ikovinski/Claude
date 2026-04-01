# AMO Claude Workflows

Автономна система розробки під Claude Code CLI. Один розробник + AI-агенти = повноцінна команда.

Репозиторій містить **тільки промпти та конфігурацію** — жодного runtime-коду. Інсталюється через symlinks у `~/.claude/`.

## Як працює

1. Користувач вводить `/command` у Claude Code
2. Команда завантажує project skill цільового проекту (якщо є)
3. Команда спавнить агентів з відповідними rules та context
4. Агенти працюють з артефактами попередньої фази (artifact chain)
5. Результат записується у `.workflows/{feature-id}/` або `docs/`

## Головний флоу: Feature Development

```
/feature "опис задачі"
```

Фази (адаптується за складністю — small/medium/large):

```
/refine (optional) → /research → /design → HUMAN REVIEW → /plan → /implement → /docs-suite → /pr
```

- **small** — skip Design+Plan, 1 reviewer
- **medium** — light Design, 2 reviewers
- **large** — повний флоу з усіма агентами

Артефакти: `.workflows/{feature-id}/` (research/, design/, plan/, implement/)

## Команди

| Команда | Що робить |
|---------|-----------|
| `/feature` | Мета-навігатор повного циклу |
| `/refine` | Уточнення задачі через діалог → `refined-task.md` |
| `/research` | AS-IS аналіз кодової бази → research report |
| `/design` | Архітектура, ADR, діаграми, тест-стратегія |
| `/plan` | Декомпозиція на вертикальні фази |
| `/implement` | Виконання однієї фази + review + quality gate |
| `/pr` | Створення Pull Request |
| `/docs-suite` | Повна документація проекту |
| `/sentry-triage` | Збір та категоризація issues з Sentry |
| `/system-profile` | Реєстр інтеграцій проекту |
| `/qa-checklist` | QA чеклист з опису фічі (PDF, image, text, URL) |
| `/skill-from-git` | Генерація project skill з git history |
| `/ai-debug` | Статус системи, аналіз промптів |

## Агенти

### Моделі

- **Opus** (reasoning): research-lead, design-architect, phase-planner, implement-lead, devils-advocate, sentry-triager, task-refiner, system-profiler
- **Sonnet** (execution): codebase-researcher, test-strategist, code-writer, tdd-guide, security-reviewer, quality-reviewer, design-reviewer, quality-gate, qa-engineer, technical-collector, architect-collector, swagger-collector, technical-writer

### Файли

Агенти — markdown з YAML frontmatter (`consumes`, `produces`, `model`, `depends_on`).

- `agents/engineering/` — 16 агентів розробки
- `agents/documentation/` — 5 агентів документації

## Rules

Domain-правила, які агенти завантажують за потребою. Визначають стандарти цільового проекту.

| Rule | Файл | Хто використовує |
|------|------|------------------|
| Language | `rules/language.md` | Всі — українська комунікація |
| Git | `rules/git.md` | code-writer, implement-lead |
| Coding Style | `rules/coding-style.md` | code-writer, quality-reviewer, design-architect та інші |
| Security | `rules/security.md` | code-writer, security-reviewer |
| Testing | `rules/testing.md` | code-writer, quality-reviewer, test-strategist, tdd-guide |
| Database | `rules/database.md` | design-architect |
| Messaging | `rules/messaging.md` | design-architect |
| QA Checklist | `rules/qa-checklist-selection.md` | qa-engineer |

## Contexts

Mode-specific guardrails, інжектяться в промпти агентів через `[MODE CONTEXT]`.

| Context | Файл | Де використовується |
|---------|------|---------------------|
| Development | `contexts/dev.md` | Code Writer |
| Review | `contexts/review.md` | Security, Quality, Design Reviewers |
| Research | `contexts/research.md` | Research Lead + scanners |
| Planning | `contexts/planning.md` | Phase Planner |

## Skills

Reusable knowledge packages у `skills/`:

- `design-template/` — формат architecture.md + diagrams.md
- `adr-template/` — Architecture Decision Records
- `api-contracts-template/` — REST + async контракти
- `tdd-approach/` — TDD секції для планів
- `owasp-top-10/` — вразливості та code patterns
- `security-audit-checklist/` — чеклист безпеки
- `test-design-techniques/` — EP, BVA, Decision Table та інші техніки
- `task-refinement/` — story formats, INVEST criteria
- `stoplight-docs/` — Stoplight API docs

## Принципи розвитку

### Інтеграція перед створенням

Перед розробкою нового компонента:
1. Перевір чи існуючий флоу/агент покриває потребу
2. Якщо ні — запропонуй з обґрунтуванням

### Документаційна дисципліна

Кожна зміна з окремим логічним циклом **мусить** бути задокументована:

| Директорія | Питання |
|------------|---------|
| `docs/how/` | Як використовувати? |
| `docs/why/` | Чому саме так? |
| `docs/comparisons/` | Чим відрізняється? |

### Сценарії

Кожен сценарій у `scenarios/` мусить мати README.md з описом проблеми, діаграмою фаз, переліком агентів, прикладами запуску та артефактами.

## Структура

```
amo-claude-workflows/
├── commands/          # Slash-команди (точки входу)
├── agents/
│   ├── engineering/   # 16 агентів розробки
│   └── documentation/ # 5 агентів документації
├── scenarios/delivery/# Multi-agent workflows
├── rules/             # Domain rules
├── contexts/          # Mode contexts
├── skills/            # Knowledge packages та templates
├── templates/         # Шаблони для нових компонентів
├── docs/              # how/, why/, comparisons/
├── plans/             # Плани розвитку
├── install.sh         # Symlink installer → ~/.claude/
└── uninstall.sh       # Symlink remover
```
