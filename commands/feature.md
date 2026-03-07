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
```

## How It Works

This command does NOT run all phases automatically. It:
1. Initializes the feature workspace
2. Determines current state (which phases are done)
3. Suggests the next command to run
4. Tracks progress in `state.json`

Each phase is run separately by the user — this command is the **navigator**.

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
  "phases": {
    "research": "pending|in_progress|done",
    "design": "pending|in_progress|done",
    "design-review": "pending|approved|changes-requested",
    "plan": "pending|in_progress|done",
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
```

---

## Related

- Scenario: `scenarios/delivery/feature-development.md`
- Commands: `/research`, `/design`, `/plan`, `/implement`, `/docs-suite`, `/pr`
