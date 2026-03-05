# Header Format Standard

## Проблема

В проекті було 3 різних формати header для різних типів файлів:
- Agents: `# Title` + inline `---` блок
- Skills/Commands: YAML frontmatter `---...---` на початку файлу
- Scenarios: `## Metadata` + ` ```yaml ``` ` code block

Поля теж не були уніфіковані: `triggers` vs `trigger`, різний набір метаданих.

## Рішення

Єдиний стандарт на базі формату agents, з адаптацією для Claude Code requirements.

### Два варіанти одного стандарту

**Варіант A — Agents, Scenarios** (Claude Code не парсить ці файли):

```markdown
# {Title}

---
name: {kebab-case-name}
description: {One-line description}
tools: [...]
model: sonnet
triggers: [...]
...
---
```

`# Title` йде першим, потім `---` блок з метаданими. Claude читає ці файли через `Read` tool як звичайний текст — формат не впливає на працездатність.

**Варіант B — Commands, Skills** (Claude Code парсить frontmatter):

```markdown
---
name: {kebab-case-name}
description: {One-line description}
allowed_tools: [...]
triggers: [...]
...
---

# {Title}
```

YAML frontmatter `---...---` **мусить** бути на самому початку файлу. Claude Code парсить:
- `name` — ідентифікатор команди/скіла
- `description` — використовується для auto-triggering та автокомпліту
- `allowed_tools` — дозволені інструменти (тільки commands)

### Чому не можна все на Варіант A?

Commands і Skills вимагають YAML frontmatter на початку файлу — це парсить система Claude Code, а не LLM. Без frontmatter:
- Команда не з'явиться як `/slash-command`
- Skill не буде auto-triggered по description

### Чому не можна все на Варіант B?

Можна. Але agents і scenarios не потребують парсингу системою — їх завантажує LLM через `Read` tool. Формат з `# Title` першим краще читається людиною і дає LLM одразу контекст: "це агент Technical Collector".

## Стандартні поля

### Обов'язкові (всі типи)

| Поле | Тип | Опис |
|------|-----|------|
| `name` | string | Kebab-case ідентифікатор |
| `description` | string | Один рядок — що робить |

### Agents

| Поле | Тип | Опис |
|------|-----|------|
| `tools` | list | Доступні інструменти |
| `model` | string | Рекомендована модель (sonnet/opus) |
| `triggers` | list | Фрази для активації |
| `rules` | list | Правила з `rules/` |
| `skills` | list | Залежні скіли |
| `consumes` | list | Вхідні артефакти (шляхи) |
| `produces` | list | Вихідні артефакти (шляхи) |
| `depends_on` | list | Залежності від інших агентів |

### Commands

| Поле | Тип | Опис |
|------|-----|------|
| `allowed_tools` | list | Дозволені інструменти (парсить Claude Code) |
| `triggers` | list | Фрази для активації |
| `skills` | list | Залежні скіли |

### Skills

Skills мають обмежений набір дозволених атрибутів у frontmatter. Підтримуються: `name`, `description`, `version`, `user-invokable`, `metadata`, `compatibility`, `license`, `argument-hint`, `disable-model-invocation`. Довільні поля (як `triggers`) **не підтримуються** і викликають warning. Тригерінг для skills працює виключно через `description`.

| Поле | Тип | Опис |
|------|-----|------|
| `version` | string | Версія скіла |

### Scenarios

| Поле | Тип | Опис |
|------|-----|------|
| `category` | string | Категорія (delivery, technical-decisions) |
| `triggers` | list | Фрази для активації |
| `participants` | list | Учасники (агенти) |
| `duration` | string | Орієнтовний час |
| `skills` | list | Залежні скіли |

## Що критично для Claude Code

Тільки два місця де система парсить header:

1. **Commands** (`~/.claude/commands/*.md`) — frontmatter з `name`, `description`, `allowed_tools`
2. **Skills** (`~/.claude/skills/*/SKILL.md`) — frontmatter з `name`, `description`

Все інше (agents, scenarios) — це контент для LLM, формат header не впливає на працездатність системи.
