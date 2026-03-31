# Commands

## What is it
Slash-команди для Claude Code CLI. Швидкий виклик workflows, які активують конкретних агентів або багатокрокові процеси.

## How to use
Введіть `/command` в Claude Code:

```
/feature "Add Apple Health integration"
/research "Investigate billing flow"
/design
/plan
/implement
/ai-debug
```

## Expected result
- Негайна активація відповідного workflow
- Оголошення агента та структурований вивід
- Покрокове керівництво через процес

## Available commands

| Command | Agent | Output | Description |
|---------|-------|--------|-------------|
| `/feature` | Meta-command | `.workflows/` | Навігатор повного flow: refine → research → design → plan → implement → docs → pr |
| `/refine` | Task Refiner | `.workflows/{feature-id}/refinement/` | Уточнення нечіткої задачі через діалог |
| `/research` | Research Lead + Codebase Researcher | `.workflows/{feature-id}/research/` | AS-IS аналіз кодової бази |
| `/design` | Design Architect + Test Strategist + Devil's Advocate | `.workflows/{feature-id}/design/` | Архітектура, ADR, тест-стратегія |
| `/plan` | Phase Planner | `.workflows/{feature-id}/plan/` | Декомпозиція дизайну на фази імплементації |
| `/implement` | Implement Lead + Writer + Reviewers + Gate | `.workflows/{feature-id}/implement/` | Виконання однієї фази імплементації |
| `/docs-suite` | Team (4 agents) | `docs/` | Повна документація (technical, architecture, OpenAPI, articles) |
| `/pr` | Direct command | GitHub PR | Створення PR з артефактами та тест-планом |
| `/sentry-triage` | Sentry Triager | `docs/tasks/` | Збір і категоризація issues з Sentry |
| `/qa-checklist` | QA Engineer | Chat | Генерація QA чеклісту з опису фічі (PDF, images, URL, text) |
| `/system-profile` | System Profiler | `docs/` | Integration Profile — реєстр інтеграцій |
| `/skill-from-git` | — | `.claude/skills/` | Генерація project skill з git history |
| `/ai-debug` | — | Chat | Статус системи, аналіз промптів |

## Feature Development Flow

Основний workflow — послідовне виконання команд:

```
/feature "Task description"     # Ініціалізація
/refine                         # Уточнення задачі (optional)
/research                       # AS-IS аналіз кодової бази
/design                         # Архітектура + ADR
  → Human Review                # Перевірка дизайну
/plan                           # Декомпозиція на фази
/implement                      # Виконання фази (повторити per phase)
/docs-suite                     # Документація
/pr                             # Pull Request
```

**Output:**
```
.workflows/{feature-id}/
├── state.json
├── research/
├── design/
├── plan/
└── implement/
```

Детальний опис: `docs/how/feature-flow.md`
