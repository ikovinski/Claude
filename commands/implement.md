---
name: implement
description: Implement phase — execute one implementation phase with Code Writer + parallel Code Reviewers (security, quality, design) + Quality Gate. Iterates until all checks pass.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "TeamCreate", "TeamDelete", "SendMessage", "TodoWrite", "mcp__sentry__list_issues", "mcp__sentry__get_issue_details", "mcp__context7__resolve-library-id", "mcp__context7__query-docs"]
triggers:
  - "implement"
  - "імплементуй"
  - "реалізуй фазу"
skills:
  - auto:{project}-patterns
requires: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
---

# /implement - Feature Implementation

Orchestrates Implementation Lead + Code Writer + Code Reviewers + Quality Gate as an **agent team** to implement one phase from the plan.

## Usage

```bash
/implement {feature-name} --phase 1                              # Implement phase 1
/implement {feature-name} --phase 2 --reviewers security,quality  # Specific reviewers only
/implement {feature-name} --phase 1 --skip-review                 # Skip code review (hotfix)
/implement {feature-name} --phase 1 --auto-fix                    # Auto-apply reviewer fixes
```

`{feature-name}` must match previous phases — reads from `.workflows/{feature-name}/`.

## Prerequisites

1. Agent Teams enabled:
```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

2. Phase 3 (Plan) completed:
```
.workflows/{feature-name}/plan/phase-{N}.md  — must exist for the requested phase
```

## You Are the Implementation Lead

When this command runs, YOU (Claude) are the **Implementation Lead orchestrator**. You:
- Read the phase plan and design artifacts
- Create agent team with writer + reviewers + gate
- Decompose phase into concrete tasks for writer
- Coordinate sequential writing → parallel review → quality gate
- Handle fix iterations (max 3)
- Generate phase implementation report

## Setup

### Step 0: Validate Prerequisites, Load Project Skill & Complexity Check

1. Check `.workflows/{feature-name}/plan/phase-{N}.md` exists
2. If missing — tell user to run `/plan` first
3. **Load project skill (MANDATORY)** — determine `{project-name}` as basename of CWD (e.g. `/repo/wellness-backend` → `wellness-backend`). Check for `.claude/skills/{project-name}-patterns/SKILL.md` in the target project root.
   - **If NOT found** — warn the user: "⚠️ Project skill not found. Implementation without project patterns risks missing conventions (cache pools, logging, DI naming, exception patterns). Run `/skill-from-git` to generate, or confirm to proceed without it."
   - **If found**:
   - Read `SKILL.md` and all files in `references/` directory (architecture.md, conventions.md, workflows.md)
   - When spawning writer — include relevant project patterns in spawn context as `[PROJECT PATTERNS]` section:
     - Decorator chain order and DI wiring naming conventions
     - Exception patterns (factory methods, error codes, subclassing vs `isType()` methods)
     - Cache patterns (dedicated pools, `$pool->get()` API vs manual PSR-6, key hashing)
     - ENV naming (`{SITE}_{DOMAIN}_{FIELD}`) and config conventions (`env(int:...)`)
     - Test patterns (base class, factories, naming)
   - When spawning reviewers — include project patterns so they can verify compliance:
     - Quality reviewer: verify code follows project conventions (not just generic SOLID)
     - Security reviewer: verify logging patterns, sensitive data handling per project standards
     - Design reviewer: verify implementation matches both design artifacts AND project patterns
4. Read phase plan to understand scope
5. Read `.workflows/{feature-name}/state.json` — check `complexity` field

**Complexity auto-defaults for reviewers** (applied when no explicit `--reviewers` or `--skip-review` flag):

| Complexity | Default reviewers | Rationale |
|-----------|------------------|-----------|
| **small** | `quality` only | No architecture decisions to verify, minimal attack surface |
| **medium** | `security,quality` | Skip design-reviewer (lighter design = less to verify) |
| **large** | `security,quality,design` | Full review — all 3 scopes |
| **null** | `security,quality,design` | Unknown complexity = full review |

Explicit `--reviewers` or `--skip-review` flags always override auto-defaults. Announce:
```
Complexity: {value} — auto-selecting reviewers: {list}
```

### Step 1: Create Team

```
TeamCreate:
  team_name: "implement-{feature-name}-phase-{N}"
  description: "Implementation of {feature-name} phase {N}"
```

### Step 2: Spawn Teammates

Read agent files and spawn all teammates:

| Teammate | Agent File | When |
|----------|-----------|------|
| writer | `agents/engineering/code-writer.md` | Always |
| reviewer-security | `agents/engineering/security-reviewer.md` | Unless --skip-review or not in --reviewers |
| reviewer-quality | `agents/engineering/quality-reviewer.md` | Unless --skip-review or not in --reviewers |
| reviewer-design | `agents/engineering/design-reviewer.md` | Unless --skip-review or not in --reviewers |
| gate | `agents/engineering/quality-gate.md` | Always |

Each reviewer is a dedicated agent with its own identity, biases, and review workflow.

## Phase Execution

### Phase 1: Write Code (sequential tasks)

Decompose `phase-{N}.md` into ordered writer tasks.

**TDD Approach (priority):** if `phase-{N}.md` contains a `TDD Approach` section — follow its order. It defines the tests-first sequence for this phase.

**Fallback (if TDD Approach is absent):**
1. **Migrations** (if any)
2. **Entities/Models**
3. **Services** (business logic)
4. **Controllers/Routes**
5. **Config changes**

Each task includes both tests and production code — Writer applies Red-Green-Refactor per task (tests are written first within each task, not as a separate step at the end).

For each task, send to writer via `SendMessage`:

```
[IMPLEMENTATION TASK {n}/{total}]
Phase: {N}
Feature: {feature-name}

[FILES TO CREATE/MODIFY]
- {path} — {description}

[CONTEXT]
- Architecture: .workflows/{feature-name}/design/architecture.md
- Phase plan: .workflows/{feature-name}/plan/phase-{N}.md

[IMPLEMENTATION NOTES]
{from phase-{N}.md Implementation Notes section}

[TDD CYCLE]
- RED: write tests first, run them — they MUST fail
- GREEN: write minimum production code, run tests — they MUST pass
- REFACTOR: clean up, run tests — they MUST still pass
- Skip RED for non-testable tasks (migrations, config)

[CONSTRAINTS]
- Follow existing code patterns
- Do not modify files outside scope
```

Wait for writer to complete each task before sending the next.

After all tasks complete, collect list of all created/modified files.

---

### Phase 2: Smoke Check (build + tests)

Before sending code to reviewers, verify it compiles and tests pass:

1. Run build + tests via `Bash` (same commands as Quality Gate for the project's tech stack)
2. If **PASS** — proceed to Phase 3 (reviewers)
3. If **FAIL** — send errors back to writer as fix task. After fix — re-run smoke check
4. Max 3 iterations. If still FAIL — escalate to user

This prevents wasting reviewer turns on fundamentally broken code.

---

### Phase 3: Code Review (parallel reviewers)

Skip if `--skip-review` is set.

Spawn reviewers. Each reviewer is a dedicated agent — send context via `SendMessage`:

**To reviewer-security (`security-reviewer.md`):**
```
[SECURITY REVIEW]
Feature: {feature-name}, Phase: {N}

[DESIGN SECURITY CONTEXT]
- Read .workflows/{feature-name}/design/security-review.md (if exists) for Phase 2 security concerns

[FILES TO REVIEW]
{list all new/modified files from Phase 1}

[OUTPUT]
Write to: .workflows/{feature-name}/implement/phase-{N}-security-review.md
```

The agent has its own 4-phase workflow (automated scan, OWASP analysis, code pattern review, audit checklist) and references `owasp-top-10` and `security-audit-checklist` skills.

**To reviewer-quality (`quality-reviewer.md`):**
```
[QUALITY REVIEW]
Feature: {feature-name}, Phase: {N}

[FILES TO REVIEW]
{list all new/modified files}

[OUTPUT]
Write to: .workflows/{feature-name}/implement/phase-{N}-quality-review.md
```

The agent runs complexity analysis, SOLID checks, domain model quality, layer compliance, and error handling review.

**To reviewer-design (`design-reviewer.md`):**
```
[DESIGN COMPLIANCE REVIEW]
Feature: {feature-name}, Phase: {N}

[DESIGN ARTIFACTS]
- .workflows/{feature-name}/design/architecture.md
- .workflows/{feature-name}/design/diagrams.md
- .workflows/{feature-name}/design/api-contracts.md
- .workflows/{feature-name}/design/test-strategy.md

[FILES TO REVIEW]
{list all new/modified files}

[OUTPUT]
Write to: .workflows/{feature-name}/implement/phase-{N}-design-review.md
```

The agent compares implementation against design artifacts: component existence, data flow, API contracts, test strategy, and ADR compliance.

Wait for ALL reviewers to complete.

---

### Phase 4: Fix Iteration (if needed)

Read all review outputs. For each finding with severity high or medium:

1. Send fix task to writer:
```
[FIX TASK]
Reviewer: {scope}
Issue: {description}
File: {path:line}
Severity: {high/medium}
Suggested Fix: {from reviewer}
```

2. After writer fixes — re-run ONLY affected reviewer (not all)
3. Track iteration count
4. **Max 3 iterations** — if still failing, escalate to user

---

### Phase 5: Quality Gate

After reviews pass (or are skipped), run Quality Gate:

Send to gate teammate:
```
[QUALITY GATE]
Feature: {feature-name}
Phase: {N}
Technology: {detected}
Files changed: {list}

Run all checks and write report to:
.workflows/{feature-name}/implement/phase-{N}-quality-gate-report.md
```

If gate FAILS:
1. Send failure details to writer as fix task
2. Re-run gate after fixes
3. Max 3 iterations

### Plan Blocker — Replan Needed

If during any phase the writer or lead discovers that the plan is **fundamentally unworkable** (not a simple fix, but a structural problem):

1. **Stop implementation** — do not continue with broken assumptions
2. **Create replan file**: `.workflows/{feature-name}/plan/replan-needed.md`

```markdown
# Replan Needed: {feature-name}

## Blocked Phase
Phase {N}: {title}

## Problem
{What makes the plan unworkable — be specific}

## Root Cause
{Why the plan is wrong — e.g., missing dependency, wrong assumption, API changed}

## Affected Phases
- Phase {N}: {how it's affected}
- Phase {M}: {how it's affected}

## Suggestion
{What the planner should consider when re-planning}
```

3. **Report to user**: "Implementation blocked — plan needs revision. Created replan-needed.md. Run `/plan {feature-name}` to re-plan."
4. **Cleanup**: send shutdown to teammates, call TeamDelete

This is for **structural blockers only** — not for code bugs or review findings. Examples:
- Plan assumes a service exists but it was removed
- Phase 2 depends on Phase 3 output (dependency cycle)
- API contract from design doesn't match actual external API
- Migration is incompatible with existing data

---

### Phase 6: Cleanup & Report

1. Generate phase report: `.workflows/{feature-name}/implement/phase-{N}-report.md`
   (Follow output format from `agents/engineering/implement-lead.md`)

2. Send shutdown to all teammates
3. Call `TeamDelete`
4. Report to user:

```markdown
## Implementation Complete: {feature-name} Phase {N}

### Status: COMPLETE / FAILED

### Changes Made
| File | Action | Type |
|------|--------|------|
| {path} | Created/Modified | Entity/Service/Controller/Test |

### Review Results
| Reviewer | Findings | Fixed | Verdict |
|----------|---------|-------|---------|
| Security | {N} | {N} | PASS |
| Quality | {N} | {N} | PASS |
| Design | {N} | {N} | PASS |

### Quality Gate
| Check | Result |
|-------|--------|
| Build | PASS |
| Tests | PASS ({N} total, {N} new) |
| Linters | PASS |
| Coverage | {N}% |

### Iterations: {N}/3

### Next Step
Continue with next phase:
/implement {feature-name} --phase {N+1}

Or if all phases complete:
/docs-suite
```

---

## Reviewer Configuration

Default reviewers: `security,quality,design`

Use `--reviewers` to select specific ones:
```bash
--reviewers security           # Security only
--reviewers security,quality   # Security + Quality
--reviewers design             # Design compliance only
```

---

## Important Notes

- Code Writer uses **sonnet** with `acceptEdits` — can create and modify files
- Security Reviewer uses **sonnet** with read + Bash — runs automated scans, reads code
- Quality Reviewer uses **sonnet** with read-only tools — cannot modify code
- Design Reviewer uses **sonnet** with read-only tools — cannot modify code
- Quality Gate uses **sonnet** with `Bash` — runs build/test/lint commands
- Writer tasks are **sequential** (avoid file conflicts)
- Reviewer scopes are **parallel** (independent analysis)
- Fix iterations are capped at **3** — then escalate
- Context7 MCP is available to writer for framework docs
- Sentry MCP is available to gate for post-implementation verification

---

## Related

- Agent files: `agents/engineering/implement-lead.md`, `agents/engineering/code-writer.md`, `agents/engineering/security-reviewer.md`, `agents/engineering/quality-reviewer.md`, `agents/engineering/design-reviewer.md`, `agents/engineering/quality-gate.md`
- Security skills: `skills/owasp-top-10/SKILL.md`, `skills/security-audit-checklist/SKILL.md`
- Previous phase: `/plan {feature-name}` (Phase 3)
- Next phase: `/docs-suite` (Phase 5) or `/pr {feature-name}` (Phase 6)
- Full flow: `scenarios/delivery/feature-development.md`
