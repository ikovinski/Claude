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
  - tdd-approach
---

# /plan - Implementation Planning

Runs Phase Planner agent to decompose Design artifacts into implementation phases. Single agent — no team needed.

## Usage

```bash
/plan {feature-id}                          # Standard decomposition
/plan {feature-id} --max-phases 5           # Limit number of phases
/plan {feature-id} --granularity fine        # More smaller phases
/plan {feature-id} --granularity coarse      # Fewer larger phases (default)
```

`{feature-id}` must match previous phases — reads from `.workflows/{feature-id}/`.

## Prerequisites

Phase 2 (Design) completed and **approved by engineers**:
```
.workflows/{feature-id}/design/architecture.md   — must exist
.workflows/{feature-id}/design/adr/*.md            — must exist (unless --skip-adr was used)
.workflows/{feature-id}/design/test-strategy.md   — must exist (unless --skip-tests was used)
```

## You Are the Phase Planner

When this command runs, YOU (Claude) become the **Phase Planner**. This is a single-agent command — no team orchestration needed. The task is linear: read inputs → analyze → produce plan files.

1. Read agent file: `agents/engineering/phase-planner.md`
2. Load the agent's identity, biases, and output format
3. Execute the full planning process

## Execution

### Step 0: Validate Prerequisites, Load Project Skill & Complexity Check

1. **Load project skill** — determine `{project-name}` as basename of CWD (e.g. `/repo/wellness-backend` → `wellness-backend`). Check for `.claude/skills/{project-name}-patterns/SKILL.md` in the target project root. If found, read it and `references/` files. Use these patterns when planning phases — e.g., knowing decorator chain order helps define the correct implementation sequence.
2. Read `.workflows/{feature-id}/state.json` — check `complexity` field
2. **If complexity = "small"**: Plan is unnecessary for single-phase tasks. Report:
   ```
   Complexity: small — skipping /plan (single implementation phase, no decomposition needed).
   Proceed directly with: /implement {feature-id} --phase 1 --reviewers quality
   ```
   Create a minimal plan file for artifact chain consistency:
   ```bash
   mkdir -p .workflows/{feature-id}/plan
   ```
   Write `.workflows/{feature-id}/plan/overview.md` with a single phase derived from the research report. Write `.workflows/{feature-id}/plan/phase-1.md` with file list from research. Mark plan as "done" in state.json. **Stop here — do not proceed to full planning.**
3. Check `.workflows/{feature-id}/design/architecture.md` exists
4. If missing — tell user to run `/design` first
5. Verify design was reviewed (ask user: "Has the design been reviewed and approved?")
6. Check if `.workflows/{feature-id}/plan/replan-needed.md` exists:
   - **If exists** — this is a **replan**. Read the file to understand what went wrong. Inform user: "Replan requested by /implement: {summary of issues}". Delete existing `plan/phase-*.md` and `plan/overview.md`. Proceed with full re-planning from scratch, using replan-needed.md as additional context
   - **If not exists** — normal planning flow

### Step 1: Prepare Workspace

```bash
mkdir -p .workflows/{feature-id}/plan
```

### Step 2: Read All Inputs

Read all design and research artifacts:
- `.workflows/{feature-id}/research/research-report.md`
- `.workflows/{feature-id}/design/architecture.md`
- `.workflows/{feature-id}/design/adr/*.md` (if exists)
- `.workflows/{feature-id}/design/test-strategy.md` (if exists)
- `.workflows/{feature-id}/plan/replan-needed.md` (if exists — replan context from /implement)

### Step 3: Plan

Follow the Phase Planner agent process:

1. **Inventory** — list all New/Changed Components from architecture.md
2. **Dependencies** — build dependency graph between components
3. **Group** — organize into vertical-slice phases
4. **Detect parallel phases** — analyze dependency graph for independent phases, group into execution waves, identify critical path
5. **Assign tests** — distribute test cases from test-strategy.md
6. **Write files** — generate overview.md (with execution strategy) + phase-{N}.md files

Apply options:
- `--max-phases N` → merge smallest phases until count ≤ N
- `--granularity fine` → prefer more smaller phases (3-5 files each)
- `--granularity coarse` → prefer fewer larger phases (5-10 files each)

### Step 4: Gate Check

Verify before completing:
- [ ] Every component from architecture.md is covered
- [ ] No dependency cycles in phase graph
- [ ] Execution waves correctly reflect dependency graph
- [ ] Each phase is self-contained
- [ ] Each phase has acceptance criteria
- [ ] Each phase has TDD Approach (tests-first order, strategy references)
- [ ] Each phase has Verification section (runnable checks + smoke test)
- [ ] Tests are distributed (not a separate phase)
- [ ] Risk Mitigation in overview.md for med/high-risk phases
- [ ] If replan: replan-needed.md issues addressed and file deleted

### Step 5: Report

```markdown
## Plan Complete: {feature-id}

### Phases

| # | Phase | Size | Risk | Wave | Command |
|---|-------|------|------|------|---------|
| 1 | {title} | S | low | 1 | `/implement {feature-id} --phase 1` |
| 2 | {title} | M | med | 2 | `/implement {feature-id} --phase 2` |
| N | {title} | M | low | 2 | `/implement {feature-id} --phase N` |

### Execution Strategy
- **Waves:** {N} (phases within same wave can run in parallel)
- **Critical path:** Phase 1 → Phase 2 → ...
- **Parallelism gain:** {N} waves instead of {M} sequential phases

### Files Generated
| File | Content |
|------|---------|
| .workflows/{feature-id}/plan/overview.md | Phases overview + dependency graph |
| .workflows/{feature-id}/plan/phase-1.md | Phase 1 details |
| .workflows/{feature-id}/plan/phase-N.md | Phase N details |

### Next Step
Start implementation phase by phase:
/implement {feature-id} --phase 1
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
- Previous phase: `/design {feature-id}` (Phase 2)
- Next phase: `/implement {feature-id} --phase {N}` (Phase 4)
- Full flow: `scenarios/delivery/feature-development.md`
