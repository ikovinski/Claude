# AI Agents System

Система AI-агентів для Claude Code CLI. Дозволяє одному розробнику виконувати повний цикл розробки — від уточнення задачі до Pull Request — з якістю, порівнянною з роботою команди (дослідження, архітектура, код-рев'ю, документація).

## Установка

Prerequisite: [Claude Code](https://claude.ai/code) має бути встановлений (`~/.claude/` існує).

```bash
./install.sh
```

Скрипт створює **symlinks** з цього репозиторію в `~/.claude/`:

```
ai-agents-system/commands/*    →  ~/.claude/commands/*
ai-agents-system/agents/*      →  ~/.claude/agents/*
ai-agents-system/rules/*       →  ~/.claude/rules/*
ai-agents-system/scenarios/*   →  ~/.claude/scenarios/*
ai-agents-system/skills/*      →  ~/.claude/skills/*
ai-agents-system/contexts/*    →  ~/.claude/contexts/*
ai-agents-system/templates/*   →  ~/.claude/templates/*
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

### Sentry Triage → Fix

```bash
/sentry-triage --project {name} --org {org}
```

Збирає production issues з Sentry, категоризує за критичністю (CRITICAL/HIGH/MEDIUM), групує за кореневою причиною. Кожен task потім можна передати у Feature Development:

```bash
/feature --from docs/tasks/{issue-id}/issue.md "Fix description"
```

**Результат:** `docs/tasks/triage-report.md` + окремі `issue.md` для кожного task.

### Documentation Suite

```bash
/docs-suite
```

Генерація повного пакету документації проекту. Оркеструє 4 агенти: збирач технічних фактів, архітектурних діаграм, OpenAPI spec та технічний писар.

**Результат:** `docs/` з технічною документацією, діаграмами та API reference.

## Команди

Окремі команди, які можна запускати незалежно або як частину сценарію.

### `/refine "опис"`

Уточнює нечітку задачу від PM через інтерактивний діалог. Автоматично збирає технічний контекст з кодової бази, попередніх артефактів та Sentry. Задає 2-3 уточнюючі питання за раунд (до 3 раундів), оцінює scope.

**Результат:** `refined-task.md` з user stories, acceptance criteria, T-shirt estimation, risk flags.

### `/research "опис"`

AS-IS аналіз кодової бази в контексті задачі. Оркеструє Research Lead + Codebase Researchers для сканування архітектури, даних, інтеграцій. Збирає факти — не пропонує рішення.

**Результат:** research report з компонентами, data flows, залежностями та open questions.

### `/design "опис"`

Архітектурні рішення для задачі. Оркеструє Design Architect + Test Strategist + Devil's Advocate (challenge). Генерує C4/DataFlow/Sequence діаграми, ADR, тест-стратегію, API контракти.

**Результат:** design artifacts (architecture.md, diagrams.md, adr/*.md, test-strategy.md) для human review.

### `/plan "опис"`

Декомпозиція дизайну на вертикальні фази реалізації. Кожна фаза — незалежний deliverable з тестами. Визначає порядок, залежності, TDD підхід.

**Результат:** overview.md + phase-{N}.md з acceptance criteria та чітким scope.

### `/system-profile`

Генерує реєстр інтеграцій проекту — use cases, актори, data flows, open questions.

**Результат:** `docs/system-profile.md`.

### `/skill-from-git`

Аналізує git history проекту та генерує project skill з реальними патернами команди (PHP/Symfony). Skill потім використовується агентами для дотримання conventions проекту.

**Результат:** `.claude/skills/{project}-patterns/SKILL.md`.
