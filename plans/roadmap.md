# Implementation Roadmap

## Порядок реалізації

Кожен крок — окрема задача. Залежності вказані.

---

## Milestone 1: Foundation (agents + template)

### 1.1 Створити директорію agents/engineering/
```bash
mkdir -p agents/engineering
```

### 1.2 Створити агентів Phase 1 (Research)

| Файл | Пріоритет | Залежності |
|------|-----------|------------|
| `agents/engineering/research-lead.md` | P0 | template |
| `agents/engineering/codebase-researcher.md` | P0 | template |

**Spec:** [new-agents-spec.md](new-agents-spec.md) — sections 1, 2

### 1.3 Створити команду /research

| Файл | Залежності |
|------|------------|
| `commands/research.md` | agents 1.2 |

**Референс:** `commands/docs-suite.md` — аналогічна структура team orchestration

### 1.4 Тестувати Phase 1 на реальному проєкті

```bash
# В bodyfit-engine-mobile або harna-backend-mobile:
/research "Add refund functionality to payments"
```

**Критерій:** Research Report створюється в `.workflows/`, містить facts without opinions

---

## Milestone 2: Design Phase

### 2.1 Створити агентів Phase 2

| Файл | Пріоритет | Залежності |
|------|-----------|------------|
| `agents/engineering/design-architect.md` | P0 | template |
| `agents/engineering/test-strategist.md` | P0 | template |

**Spec:** [new-agents-spec.md](new-agents-spec.md) — sections 3, 4

### 2.2 Створити команду /design

| Файл | Залежності |
|------|------------|
| `commands/design.md` | agents 2.1 |

### 2.3 Тестувати Phase 1 → Phase 2 flow

```bash
/research "Add refund functionality"
# review research report
/design payment-refund
# review design artifacts
```

**Критерій:** Design артефакти консистентні з Research Report, діаграми валідні

---

## Milestone 3: Plan Phase

### 3.1 Створити агент Phase 3

| Файл | Пріоритет | Залежності |
|------|-----------|------------|
| `agents/engineering/phase-planner.md` | P0 | template |

**Spec:** [new-agents-spec.md](new-agents-spec.md) — section 5

### 3.2 Створити команду /plan

| Файл | Залежності |
|------|------------|
| `commands/plan.md` | agent 3.1 |

### 3.3 Тестувати Research → Design → Plan flow

```bash
/research "Add refund functionality"
/design payment-refund
/plan payment-refund
```

**Критерій:** Фази мають vertical slices, acceptance criteria, dependency graph

---

## Milestone 4: Implement Phase

### 4.1 Створити агентів Phase 4

| Файл | Пріоритет | Залежності |
|------|-----------|------------|
| `agents/engineering/implement-lead.md` | P0 | template |
| `agents/engineering/code-writer.md` | P0 | template |
| `agents/engineering/code-reviewer.md` | P0 | template |
| `agents/engineering/quality-gate.md` | P1 | template |

**Spec:** [new-agents-spec.md](new-agents-spec.md) — sections 6, 7, 8, 9

### 4.2 Створити команду /implement

| Файл | Залежності |
|------|------------|
| `commands/implement.md` | agents 4.1 |

### 4.3 Тестувати повний flow через всі фази

```bash
/research "Add refund functionality"
/design payment-refund
/plan payment-refund
/implement payment-refund --phase 1
```

**Критерій:** Code changes pass quality gate, reviews мають actionable findings

---

## Milestone 5: PR + Integration

### 5.1 Створити команду /pr

| Файл | Залежності |
|------|------------|
| `commands/pr.md` | Milestone 4 |

### 5.2 Створити сценарій feature-development

| Файл | Залежності |
|------|------------|
| `scenarios/delivery/feature-development.md` | Milestones 1-4 |

### 5.3 Створити мета-команду /feature

| Файл | Залежності |
|------|------------|
| `commands/feature.md` | scenario 5.2 |

Мета-команда що послідовно запускає фази з human checkpoints між ними.

### 5.4 Оновити CLAUDE.md

Додати нові команди і агенти в Quick Reference.

### 5.5 Оновити README.md

Додати документацію нового флоу.

---

## Milestone 6: Polish

### 6.1 Створити rules для engineering

| Файл | Опис |
|------|------|
| `rules/security.md` | OWASP checklist для code-reviewer security scope |
| `rules/testing.md` | Test conventions для test-strategist |
| `rules/coding-style.md` | Code style для code-writer |

**Примітка:** Ці файли вже referenced в CLAUDE.md але не створені в цьому проєкті. Можливо вони існують глобально в `~/.claude/rules/`.

### 6.2 Додати MCP інструкції

Додати в README або окремий doc:
- Як налаштувати Context7 MCP
- Як налаштувати Sentry MCP
- Які endpoints кожен агент використовує

### 6.3 Запропонувати нові MCP

| MCP | Де | Навіщо |
|-----|----|--------|
| **GitHub** | Phase 6 (PR) | Створення PR, перевірка CI, коментарі |
| **Linear/Jira** | Phase 1 (Research) | Підтягувати issue details, оновлювати status |
| **Figma** | Phase 2 (Design) | Якщо є UI — підтягувати дизайн для API contracts |

---

## Повний перелік файлів для створення

### Агенти (9 файлів)
```
agents/engineering/
├── research-lead.md
├── codebase-researcher.md
├── design-architect.md
├── test-strategist.md
├── phase-planner.md
├── implement-lead.md
├── code-writer.md
├── code-reviewer.md
└── quality-gate.md
```

### Команди (5 нових файлів)
```
commands/
├── research.md          # NEW
├── design.md            # NEW
├── plan.md              # NEW
├── implement.md         # NEW
├── pr.md                # NEW
├── feature.md           # NEW (meta-command)
├── docs-suite.md        # EXISTS
├── skill-from-git.md    # EXISTS
└── ai-debug.md          # EXISTS
```

### Сценарії (1 новий файл)
```
scenarios/delivery/
├── feature-development.md    # NEW
└── documentation-suite.md    # EXISTS
```

### Rules (3 файли — перевірити чи існують глобально)
```
rules/
├── security.md          # NEW або reference
├── testing.md           # NEW або reference
├── coding-style.md      # NEW або reference
├── language.md          # EXISTS
└── git.md               # EXISTS
```

---

## Оцінка обсягу

| Milestone | Файлів | Складність |
|-----------|--------|------------|
| 1: Foundation | 3 | Medium |
| 2: Design | 3 | Medium |
| 3: Plan | 2 | Low |
| 4: Implement | 5 | High |
| 5: Integration | 4 | Medium |
| 6: Polish | 3-6 | Low |
| **Total** | **20-23** | — |

---

## Рекомендований підхід

1. **Build and test incrementally** — кожен milestone тестується на реальному проєкті перед наступним
2. **Start with Research** — це найпростіша фаза і дає найбільше розуміння паттернів
3. **Use /skill-from-git** — перед тестуванням на проєкті, згенерувати project skill
4. **Iterate agents** — перший варіант агента рідко ідеальний, потрібно тюнити biases і output format
5. **Use /docs-suite as reference** — структура команди і сценарію docs-suite — перевірений паттерн
