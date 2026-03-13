---
name: feature
description: Meta-command — guides through the full feature development flow phase by phase. Tracks state, suggests next command, manages human checkpoints.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "TodoWrite"]
triggers:
  - "feature"
  - "нова фіча"
  - "розроби фічу"
  - "full feature flow"
skills:
  - auto:{project}-patterns
---

# /feature - Feature Development Flow

Meta-command that guides through the full feature development flow. Tracks state between phases, suggests the next command, and manages human checkpoints.

## Usage

```bash
/feature "Add refund functionality to payments"              # Start new feature
/feature {feature-name} --status                              # Check current state
/feature {feature-name} --resume                              # Continue from last phase
/feature {feature-name} --type bug --sentry PROJ-123          # Bug fix flow
/feature --from docs/tasks/task-1-amqp-transport/issue.md "Fix AMQP transport errors"  # From sentry-triage
```

## How It Works

This command does NOT run all phases automatically. It:
1. Initializes the feature workspace
2. Determines current state (which phases are done)
3. Suggests the next command to run
4. Tracks progress in `state.json`

Each phase is run separately by the user — this command is the **navigator**.

### --from (Sentry Triage Integration)

When started with `--from {path-to-issue.md}`:
1. Read the issue.md file
2. Extract Sentry issue IDs from the Issues table
3. Auto-set `--type bug` and `--sentry {PRIMARY-ISSUE-ID}`
4. Copy issue.md content into `.workflows/{feature}/research/sentry-context.md` as pre-research input
5. Continue with normal flow (Research phase will use this context)

## Execution

### Starting a New Feature

```bash
/feature "Add refund functionality to payments"
```

1. Generate feature name from description (kebab-case): `payment-refund`
2. Create workspace:
   ```bash
   mkdir -p .workflows/payment-refund
   ```
3. Initialize state:
   ```json
   // .workflows/payment-refund/state.json
   {
     "feature": "payment-refund",
     "description": "Add refund functionality to payments",
     "type": "feature",
     "created": "2026-03-06",
     "complexity": null,
     "complexity_reason": null,
     "phases": {
       "research": "pending",
       "design": "pending",
       "design-review": "pending",
       "plan": "pending",
       "implement": "pending",
       "docs": "pending",
       "pr": "pending"
     },
     "sentry_issue": null,
     "current_phase": "research",
     "implement_phases": []
   }
   ```
4. Output next step:

```markdown
## Feature Initialized: payment-refund

**Description:** Add refund functionality to payments
**Type:** feature
**Workspace:** .workflows/payment-refund/

### Flow

| # | Phase | Status | Command |
|---|-------|--------|---------|
| 1 | Research | **next** | `/research "Add refund functionality to payments"` |
| 2 | Design | pending | `/design payment-refund` |
| 3 | Design Review | pending | *human checkpoint* |
| 4 | Plan | pending | `/plan payment-refund` |
| 5 | Implement | pending | `/implement payment-refund --phase N` |
| 6 | Documentation | pending | `/docs-suite --feature payment-refund` |
| 7 | PR | pending | `/pr payment-refund` |

### Next Step
Run:
/research "Add refund functionality to payments"
```

### Checking Status

```bash
/feature payment-refund --status
```

1. Read `.workflows/payment-refund/state.json`
2. Check which artifacts exist on disk
3. Report:

```markdown
## Feature Status: payment-refund

| # | Phase | Status | Artifacts |
|---|-------|--------|-----------|
| 1 | Research | done | research-report.md, 3 scans |
| 2 | Design | done | architecture.md, adr/*.md, test-strategy.md |
| 3 | Design Review | **waiting** | *awaiting engineer approval* |
| 4 | Plan | pending | — |
| 5 | Implement | pending | — |
| 6 | Documentation | pending | — |
| 7 | PR | pending | — |

### Next Step
Review design artifacts in `.workflows/payment-refund/design/`, then run:
/plan payment-refund
```

### Resuming

```bash
/feature payment-refund --resume
```

1. Read state.json
2. Determine next phase
3. Output the exact command to run

### Updating State

After each phase command completes, the user runs `/feature {name} --status` to update. The status command detects completed phases by checking artifact existence:

| Phase | Complete When |
|-------|-------------|
| research | `research/research-report.md` exists |
| design | `design/architecture.md` exists |
| design-review | User confirms (manual) |
| plan | `plan/overview.md` exists |
| implement | `implement/phase-{N}-report.md` exists for all phases |
| docs | `docs/INDEX.md` exists in project |
| pr | PR URL recorded in state.json |

---

## State Management

### state.json Format

```json
{
  "feature": "payment-refund",
  "description": "Add refund functionality to payments",
  "type": "feature|bug",
  "created": "2026-03-06",
  "complexity": "small|medium|large|null",
  "complexity_reason": "1 component, 3 files, no external deps|null",
  "phases": {
    "research": "pending|in_progress|done",
    "design": "pending|in_progress|done|skipped",
    "design-review": "pending|approved|changes-requested|skipped",
    "plan": "pending|in_progress|done|skipped",
    "implement": "pending|in_progress|done",
    "docs": "pending|in_progress|done|skipped",
    "pr": "pending|done"
  },
  "sentry_issue": "PROJ-123|null",
  "current_phase": "research",
  "implement_phases": [
    {"number": 1, "title": "DB Schema", "status": "done"},
    {"number": 2, "title": "Domain Logic", "status": "in_progress"},
    {"number": 3, "title": "API Endpoints", "status": "pending"}
  ],
  "pr_url": "https://github.com/org/repo/pull/123|null"
}
```

---

## Complexity-Adaptive Flow

After Research completes, `/feature --resume` reads `complexity` from state.json and adapts the suggested flow. The user can always override with "I want the full flow".

### Adaptation Matrix

| Complexity | Design | Plan | Implement | Docs |
|-----------|--------|------|-----------|------|
| **Small** | **skip** | **skip** | `--reviewers quality` (1 reviewer) | skip (suggest `--skip-docs`) |
| **Medium** | `--depth light --skip-challenge` | standard | `--reviewers security,quality` (2 reviewers) | standard |
| **Large** | `--depth standard` or `--depth detailed` | standard | all 3 reviewers | standard |
| **null** (not assessed) | standard | standard | standard | standard |

### Small Task — Fast Track

When complexity = "small", `/feature --resume` after Research:

1. Set phases `design`, `design-review`, `plan` to `"skipped"` in state.json
2. Suggest direct implementation:

```markdown
### Research Complete — Small Task Detected

**Complexity:** Small — {complexity_reason}

This task is too small for a full design/plan cycle. Suggested fast track:
- ~~Design~~ skipped (no architecture decisions needed)
- ~~Plan~~ skipped (single implementation phase)
- Implement with lightweight review

**Next step:**
/implement {feature-name} --phase 1 --reviewers quality

Override: reply "full flow" to proceed with Design → Plan → Implement as usual.
```

If user replies "full flow" — reset skipped phases back to "pending" and suggest `/design`.

### Medium Task — Lighter Design

When complexity = "medium", suggest lighter design options:

```markdown
### Research Complete — Medium Task

**Complexity:** Medium — {complexity_reason}

Suggested optimizations:
- Design with `--depth light --skip-challenge` (saves ~40% design time)
- Full review in Implement phase

**Next step:**
/design {feature-name} --depth light --skip-challenge

Override: reply "full design" for standard depth with Devil's Advocate challenge.
```

### Large Task — Full Flow

No changes — full flow is the right approach for large tasks.

---

## Shortcuts

For common flows:

```bash
# Bug fix with Sentry
/feature "Fix payment error" --type bug --sentry PROJ-123

# Quick hotfix (skip design/plan)
/feature "Fix typo in error message" --type hotfix
# → Suggests: /research → /implement --skip-review → /pr

# Feature without docs update
/feature "Internal refactoring" --skip-docs

# From sentry-triage output
/feature --from docs/tasks/task-1-amqp-transport/issue.md "Fix AMQP transport errors"
# → Auto-detects: --type bug --sentry {primary issue ID from file}
```

---

## Related

- Scenario: `scenarios/delivery/feature-development.md`
- Commands: `/research`, `/design`, `/plan`, `/implement`, `/docs-suite`, `/pr`
