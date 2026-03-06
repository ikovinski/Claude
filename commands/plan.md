---
name: plan
description: Plan phase — decompose Design into implementation phases. Each phase is a vertical slice with tests, deliverable independently. Single agent, no team needed.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "TodoWrite"]
triggers:
  - "plan"
  - "розбий на фази"
  - "implementation plan"
skills:
  - auto:{project}-patterns
---

# /plan - Implementation Planning

Runs Phase Planner agent to decompose Design artifacts into implementation phases. Single agent — no team needed.

## Usage

```bash
/plan {feature-name}                          # Standard decomposition
/plan {feature-name} --max-phases 5           # Limit number of phases
/plan {feature-name} --granularity fine        # More smaller phases
/plan {feature-name} --granularity coarse      # Fewer larger phases (default)
```

`{feature-name}` must match previous phases — reads from `.workflows/{feature-name}/`.

## Prerequisites

Phase 2 (Design) completed and **approved by engineers**:
```
.workflows/{feature-name}/design/architecture.md   — must exist
.workflows/{feature-name}/design/adr.md             — must exist (unless --skip-adr was used)
.workflows/{feature-name}/design/test-strategy.md   — must exist (unless --skip-tests was used)
```

## You Are the Phase Planner

When this command runs, YOU (Claude) become the **Phase Planner**. This is a single-agent command — no team orchestration needed. The task is linear: read inputs → analyze → produce plan files.

1. Read agent file: `agents/engineering/phase-planner.md`
2. Load the agent's identity, biases, and output format
3. Execute the full planning process

## Execution

### Step 0: Validate Prerequisites

1. Check `.workflows/{feature-name}/design/architecture.md` exists
2. If missing — tell user to run `/design` first
3. Verify design was reviewed (ask user: "Has the design been reviewed and approved?")

### Step 1: Prepare Workspace

```bash
mkdir -p .workflows/{feature-name}/plan
```

### Step 2: Read All Inputs

Read all design and research artifacts:
- `.workflows/{feature-name}/research/research-report.md`
- `.workflows/{feature-name}/design/architecture.md`
- `.workflows/{feature-name}/design/adr.md` (if exists)
- `.workflows/{feature-name}/design/test-strategy.md` (if exists)

### Step 3: Plan

Follow the Phase Planner agent process:

1. **Inventory** — list all New/Changed Components from architecture.md
2. **Dependencies** — build dependency graph between components
3. **Group** — organize into vertical-slice phases
4. **Assign tests** — distribute test cases from test-strategy.md
5. **Write files** — generate overview.md + phase-{N}.md files

Apply options:
- `--max-phases N` → merge smallest phases until count ≤ N
- `--granularity fine` → prefer more smaller phases (3-5 files each)
- `--granularity coarse` → prefer fewer larger phases (5-10 files each)

### Step 4: Gate Check

Verify before completing:
- [ ] Every component from architecture.md is covered
- [ ] No dependency cycles in phase graph
- [ ] Each phase is self-contained
- [ ] Each phase has acceptance criteria
- [ ] Tests are distributed (not a separate phase)

### Step 5: Report

```markdown
## Plan Complete: {feature-name}

### Phases

| # | Phase | Size | Risk | Command |
|---|-------|------|------|---------|
| 1 | {title} | S | low | `/implement {feature-name} --phase 1` |
| 2 | {title} | M | med | `/implement {feature-name} --phase 2` |
| N | {title} | M | low | `/implement {feature-name} --phase N` |

### Files Generated
| File | Content |
|------|---------|
| .workflows/{feature-name}/plan/overview.md | Phases overview + dependency graph |
| .workflows/{feature-name}/plan/phase-1.md | Phase 1 details |
| .workflows/{feature-name}/plan/phase-N.md | Phase N details |

### Next Step
Start implementation phase by phase:
/implement {feature-name} --phase 1
```

---

## Important Notes

- This is a **single agent** command — no Agent Teams required
- Uses **opus** model — decomposition requires deep reasoning about dependencies
- Design must be **reviewed and approved** before planning
- Each phase file includes the `/implement` command to run it
- Phases are designed for **independent deployment** — each can be merged separately

---

## Related

- Agent file: `agents/engineering/phase-planner.md`
- Previous phase: `/design {feature-name}` (Phase 2)
- Next phase: `/implement {feature-name} --phase {N}` (Phase 4)
- Full flow: `scenarios/delivery/feature-development.md`
