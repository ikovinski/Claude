---
name: refine
description: Task refinement — приймає нечітку задачу від PM, збирає контекст з кодової бази та артефактів, задає уточнюючі питання, генерує structured task document з estimation та acceptance criteria.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "AskUserQuestion", "mcp__sentry__list_issues", "mcp__sentry__get_issue_details", "mcp__context7__resolve-library-id", "mcp__context7__query-docs"]
triggers:
  - "refine"
  - "уточни задачу"
  - "опиши задачу"
  - "refined task"
  - "refine task"
skills:
  - auto:{project}-patterns
  - task-refinement
---

# /refine - Task Refinement

Приймає нечітку задачу від PM, через інтерактивний діалог уточнює вимоги, автоматично збирає технічний контекст, і генерує structured task document з user stories, acceptance criteria та estimation.

## Usage

```bash
/refine "додай експорт в PDF"                              # Нечіткий вхід від PM
/refine "JIRA-123: Implement caching for API tokens"       # Формальний тікет
/refine --from docs/tasks/BODYFIT-9H9/issue.md             # З sentry-triage output
/refine --workflow payment-refund                           # Для існуючого workflow
```

## You Are the Task Refiner

When this command runs, YOU (Claude) become the **Task Refiner** agent. Read the full agent persona from:

```
agents/engineering/task-refiner.md
```

Apply the agent's identity, biases, process, and output format.

## Setup

### Step 0: Prepare Workspace

1. Parse the task description and options (`--from`, `--workflow`)
2. Determine feature name from task (kebab-case, e.g. `export-to-pdf`)
3. Create workspace directory:

```bash
mkdir -p .workflows/{feature-id}/refinement
```

4. Detect project technology (check root files: `composer.json`, `package.json`, `go.mod`, etc.)
5. **Load project skill** — determine `{project-name}` as basename of CWD. Check for `.claude/skills/{project-name}-patterns/SKILL.md`. If found — read and use as project context for estimation and technical discovery.

### Input Modes

#### Default: Raw Text

```bash
/refine "додай можливість експорту звітів в PDF"
```

PM's text is the starting point. Proceed to Step 1.

#### --from: File Input

```bash
/refine --from docs/tasks/BODYFIT-9H9/issue.md
/refine --from requirements/feature-request.md
```

1. Read the specified file
2. Extract available context (Sentry data, requirements, description)
3. Use as seed — but still ask clarifying questions if gaps exist
4. Copy original file to `.workflows/{feature-id}/refinement/source.md`

#### --workflow: Existing Workflow

```bash
/refine --workflow payment-refund
```

1. Read `.workflows/{workflow-id}/state.json` if exists
2. Check for existing artifacts:
   - `research/research-report.md` — use as technical context
   - `refinement/refined-task.md` — update mode (re-refine)
3. Use existing context to ask more focused questions

## Execution

Follow the 3-phase process defined in `agents/engineering/task-refiner.md`.

PM бачить прогрес через фазові індикатори:
```
[1/3] 📋 Збираю контекст проекту...
[2/3] 💬 Уточнюючі питання
[3/3] ✅ Генерую refined task
```

### Phase [1/3] 📋 Збираю контекст проекту

**Silent phase** — gather context without PM interaction:

1. Read project documentation (`README.md`, `docs/`, `docs/system-profile.md`)
2. Scan codebase structure (Glob/Grep by task keywords)
3. Check prior artifacts (`.workflows/*/research/`, `.workflows/*/refinement/`)
4. Sentry correlation (optional, if task mentions error/bug)

After gathering, output brief summary of findings to PM.

### Phase [2/3] 💬 Уточнюючі питання

Ask questions **one at a time** via `AskUserQuestion` tool.

**Обов'язковий формат:** кожне питання МУСИТЬ містити варіанти відповіді з коротким обґрунтуванням:

```
[2/3] 💬 Питання 1 з ~5

{Текст питання}

Варіанти:
  а) {Опція} — {чому це важливо}
  б) {Опція} — {чому це важливо}
  в) {Опція} — {чому це важливо}
  г) Інше — розкажіть своїми словами
```

| Rule | Value |
|------|-------|
| Questions per round | 2-3, кожне через AskUserQuestion |
| Total rounds | 3 max |
| Total questions | ~9 max |
| Language | Ukrainian, PM-friendly, no tech jargon |
| "Не знаю" handling | Record as Open Question, move on |
| Options | MANDATORY — кожне питання з варіантами |

Between rounds — confirm understanding via AskUserQuestion (summary + "Все вірно? а) Так б) Потрібно виправити").

### Phase [3/3] ✅ Генерую refined task

1. **Tech Context Discovery** (silent) — Grep/Glob for affected components, DB/API impact
2. **Synthesize** — choose story format, write AC, estimate T-shirt size, flag risks
3. **Write** `refined-task.md` to `.workflows/{feature-id}/refinement/`
4. **Present** summary to PM
5. **Ask** PM for final action via AskUserQuestion (передати в розробку / уточнити / зберегти)

## Output Location

| Mode | Path |
|------|------|
| `--workflow {id}` | `.workflows/{id}/refinement/refined-task.md` |
| Default | `.workflows/{feature-id}/refinement/refined-task.md` |

## Integration with Feature Development Flow

`refined-task.md` integrates with the flow:

```bash
# After /refine:
/feature --from .workflows/{feature-id}/refinement/refined-task.md "{title}"

# Or start research directly:
/research "{title}"
# → Research Lead will find and use refined-task.md automatically
```

When `/feature` picks up a refined task:
- Acceptance criteria from refined-task become feature success criteria
- Technical context hints narrow Research scope
- Estimation provides initial complexity signal
- Open Questions guide Research focus areas

## Checklist

Before completing refinement, verify:

- [ ] Description is PM-readable (no technical jargon)
- [ ] At least one story (User Story / Job Story / WWA) is written
- [ ] 3-6 acceptance criteria are testable without reading code
- [ ] T-shirt size has evidence-based reasoning
- [ ] Risk flags are identified (or explicitly "none")
- [ ] Open Questions capture unresolved items
- [ ] Next step command is suggested
