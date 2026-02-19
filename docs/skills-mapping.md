# Skills Mapping

Визначення які skills потрібні для кожного агента, команди та сценарію.

## Agents

### Technical Agents

| Agent | Auto-Generated Skills | Manual Skills | Опис |
|-------|----------------------|---------------|------|
| `code-reviewer` | `{project}-patterns` | `code-review-checklist` | Перевірки для review коду |
| `security-reviewer` | `{project}-patterns` | `security-audit-checklist`, `owasp-top-10` | Security перевірки |
| `planner` | `{project}-patterns` | `planning-template`, `estimation-guide` | Шаблони планування |
| `feature-decomposer` | `{project}-patterns` | `task-decomposition`, `vertical-slicing` | Методики декомпозиції |
| `tdd-guide` | `{project}-patterns` | `tdd-workflow`, `test-patterns` | TDD практики |
| `refactor-cleaner` | `{project}-patterns` | `refactoring-patterns`, `dead-code-detection` | Рефакторинг техніки |
| `architecture-advisor` | `{project}-patterns` | `architecture-decision-template`, `tech-evaluation` | ADR шаблони |

### Facilitation Agents

| Agent | Auto-Generated Skills | Manual Skills | Опис |
|-------|----------------------|---------------|------|
| `decision-challenger` | — | `risk-assessment`, `challenge-questions` | Питання для челенджу |

## Commands

| Command | Uses Agent | Additional Skills |
|---------|-----------|-------------------|
| `/plan` | `planner` | — (використовує agent skills) |
| `/code-review` | `code-reviewer` | — (використовує agent skills) |
| `/tdd` | `tdd-guide` | — (використовує agent skills) |
| `/security-check` | `security-reviewer` | — (використовує agent skills) |
| `/skill-create` | — | `skill-extraction-prompts` |
| `/ai-debug` | — | — |

## Scenarios

| Scenario | Agents Used | Additional Skills |
|----------|-------------|-------------------|
| `feature-decomposition` | `feature-decomposer`, `planner` | `epic-breakdown`, `story-mapping` |
| `rewrite-decision` | `architecture-advisor`, `decision-challenger` | `decision-matrix`, `migration-checklist` |

## Skills Classification

### Auto-Generated (Project-Specific)
- `{project}-patterns/SKILL.md` — генеруються через `/skill-create`
- Містять: commit conventions, architecture, naming standards

### Manual (Universal)

#### Code Quality
- ✅ `code-review-checklist` — чеклист для code review
- 🆕 `refactoring-patterns` — каталог рефакторингів
- 🆕 `test-patterns` — патерни тестування

#### Security
- 🆕 `security-audit-checklist` — security перевірки
- 🆕 `owasp-top-10` — OWASP топ 10 вразливостей

#### Planning & Decomposition
- ✅ `task-decomposition` — методики декомпозиції
- 🆕 `planning-template` — шаблони планів
- 🆕 `estimation-guide` — гайд по оцінці задач
- 🆕 `vertical-slicing` — vertical slice практики
- 🆕 `epic-breakdown` — декомпозиція епіків
- 🆕 `story-mapping` — user story mapping

#### TDD
- 🆕 `tdd-workflow` — TDD робочий процес
- 🆕 `test-first-checklist` — чеклист test-first

#### Architecture
- 🆕 `architecture-decision-template` — ADR template
- 🆕 `tech-evaluation` — оцінка технологій
- 🆕 `decision-matrix` — матриця рішень
- 🆕 `migration-checklist` — чеклист міграції

#### Risk Management
- 🆕 `risk-assessment` — оцінка ризиків
- 🆕 `challenge-questions` — питання для челенджу

#### Meta
- 🆕 `skill-extraction-prompts` — промпти для skill extraction
- 🆕 `dead-code-detection` — пошук мертвого коду

---

✅ — вже існує
🆕 — потрібно створити
