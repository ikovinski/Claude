---
name: design
description: Design phase — architecture decisions, diagrams (C4/DataFlow/Sequence), ADR, test strategy, API contracts, design challenge. Produces design artifacts for human review before implementation.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "TeamCreate", "TeamDelete", "SendMessage", "TodoWrite", "mcp__context7__resolve-library-id", "mcp__context7__query-docs"]
triggers:
  - "design"
  - "спроектуй"
  - "архітектура фічі"
skills:
  - auto:{project}-patterns
requires: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
---

# /design - Feature Design

Orchestrates Design Architect + Test Strategist + Devil's Advocate as an **agent team** to produce architecture decisions, test strategy, and design challenge based on Research Report.

## Usage

```bash
/design {feature-name}                    # Full design (architecture + ADR + tests + API)
/design {feature-name} --skip-adr         # Skip ADR (for simple changes)
/design {feature-name} --skip-api         # Skip API contracts (no new endpoints)
/design {feature-name} --skip-tests       # Skip test strategy
```

`{feature-name}` must match the name used in `/research` — artifacts are read from `.workflows/{feature-name}/research/`.

## Prerequisites

1. Agent Teams enabled:
```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

2. Phase 1 (Research) completed:
```
.workflows/{feature-name}/research/research-report.md  — must exist
```

## You Are the Design Lead

When this command runs, YOU (Claude) are the **Design Lead orchestrator**. You:
- Verify Research Report exists and is valid
- Create the agent team
- Spawn Design Architect + Test Strategist (Stage A) in parallel
- After Architect completes — spawn Devil's Advocate + Test Strategist (Stage B) in parallel
- Process challenge results — Architect addresses CRITICAL/SIGNIFICANT issues
- Verify design quality (gate checks)
- Report results and prompt for human review

## Setup

### Step 0: Validate Prerequisites

1. Check `.workflows/{feature-name}/research/research-report.md` exists
2. If missing — tell user to run `/research` first
3. Read Research Report to understand scope

### Step 1: Create Team

```
TeamCreate:
  team_name: "design-{feature-name}"
  description: "Design phase for {feature-name}"
```

## Phase Execution

### Phase 1: Architecture + Test Pattern Analysis (parallel)

Two teammates run in parallel:

#### 1a: Design Architect (blocking)

**Teammate**: architect

1. Read agent file: `agents/engineering/design-architect.md`
2. Spawn teammate "architect" with the full agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}
Feature: {feature-name}

[INPUT — Research Report]
Read from: .workflows/{feature-name}/research/research-report.md
Additional scans available in: .workflows/{feature-name}/research/

[TASK]
Execute the full design process as described in your Task section:
1. Read Research Report
2. Determine approach: Contract-first (if new endpoints) or Architecture-first
3. Create Architecture Design → .workflows/{feature-name}/design/architecture.md
4. Create ADR → .workflows/{feature-name}/design/adr.md
5. Create API Contracts (if new endpoints) → .workflows/{feature-name}/design/api-contracts.md
6. Run Self-Review (Step 5) — fix inconsistencies before completing

[SKIP OPTIONS]
Skip ADR: {yes/no based on --skip-adr}
Skip API Contracts: {yes/no based on --skip-api}
```

3. Create task: "Design architecture for {feature-name}"

#### 1b: Test Strategist Stage A (parallel with architect)

**Teammate**: tester

Skip if `--skip-tests` is set.

1. Read agent file: `agents/engineering/test-strategist.md`
2. Spawn teammate "tester" with agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}
Feature: {feature-name}

[TASK — STAGE A ONLY]
Execute Stage A (Steps 1-2) from your Task section:
1. Analyze existing test patterns in the project
2. Pre-analyze Research Report (.workflows/{feature-name}/research/research-report.md)

Write intermediate results to: .workflows/{feature-name}/design/test-patterns.md
Do NOT proceed to Stage B yet — architecture.md is not ready.
Wait for further instructions.
```

3. Create task: "Analyze test patterns for {feature-name}"

**Wait**: Both teammates finish Phase 1.

**Gate for architect**: Verify:
- `architecture.md` contains at least one Mermaid diagram
- `architecture.md` has New/Changed Components table
- `adr.md` has at least 2 alternatives (unless --skip-adr)
- API contracts exist if architecture mentions new endpoints (unless --skip-api)

---

### Phase 2: Devil's Advocate + Test Strategy Stage B (parallel)

After architect completes, two tasks run in parallel:

#### 2a: Devil's Advocate

**Teammate**: challenger

1. Read agent file: `agents/engineering/devils-advocate.md`
2. Spawn teammate "challenger" with agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}
Feature: {feature-name}

[INPUT ARTIFACTS — read from disk]
- .workflows/{feature-name}/design/architecture.md
- .workflows/{feature-name}/design/adr.md
- .workflows/{feature-name}/research/research-report.md

[TASK]
Execute the full challenge process as described in your Task section.
Write output to: .workflows/{feature-name}/design/challenge-report.md
```

3. Create task: "Challenge design for {feature-name}"

#### 2b: Test Strategist Stage B

Resume "tester" teammate via `SendMessage`:

```
[STAGE B — architecture.md is ready]
Continue with Steps 3-5 from your Task section:
1. Read .workflows/{feature-name}/design/architecture.md
2. Read .workflows/{feature-name}/design/adr.md
3. Define test strategy and write test cases
Write final output to: .workflows/{feature-name}/design/test-strategy.md
(you may delete test-patterns.md or merge its content)
```

**Wait**: Both teammates finish Phase 2.

**Gate for challenger**: Verify:
- `challenge-report.md` exists and has a Verdict
- At least 1 challenge per section

**Gate for tester**: Verify:
- `test-strategy.md` has concrete test cases (Given/When/Then)
- Test levels are appropriate for the components
- "What NOT to Test" section exists

---

### Phase 3: Address Challenges (conditional)

**Skip** if Devil's Advocate verdict is **PASS** (no CRITICAL or SIGNIFICANT issues).

If verdict is **PASS WITH CONDITIONS** or **NEEDS REVISION**:

1. Read `challenge-report.md` — extract CRITICAL and SIGNIFICANT challenges
2. Send to "architect" teammate via `SendMessage`:

```
[CHALLENGE RESPONSE REQUIRED]
Devil's Advocate has raised the following issues:

{list CRITICAL and SIGNIFICANT challenges with their questions}

Please:
1. Address each challenge — update architecture.md and/or adr.md
2. For each challenge, briefly explain your response
3. If you disagree with a challenge — explain why with evidence
```

3. Wait for architect to go idle
4. Verify changes were made to relevant files

---

### Phase 4: Quality Check

Design Lead (you) performs final consistency check:

1. Read all design artifacts
2. Verify consistency:
   - Components in architecture.md match those in test-strategy.md
   - API contracts match sequence diagrams
   - ADR risks are covered by test cases
   - Challenge responses are reflected in updated artifacts
3. If inconsistencies found — send fix request to responsible teammate via `SendMessage`

---

### Phase 5: Cleanup & Report

1. Send shutdown to all teammates via `SendMessage`
2. Call `TeamDelete`
3. Report to user:

```markdown
## Design Complete: {feature-name}

### Files Generated
| File | Content |
|------|---------|
| .workflows/{feature-name}/design/architecture.md | C4, DataFlow, Sequence diagrams + component changes |
| .workflows/{feature-name}/design/adr.md | Decision, alternatives, risks |
| .workflows/{feature-name}/design/api-contracts.md | New/changed API endpoints |
| .workflows/{feature-name}/design/test-strategy.md | Test cases and strategy |
| .workflows/{feature-name}/design/challenge-report.md | Devil's Advocate challenges + verdict |

### Design Summary
- New components: {count}
- Modified components: {count}
- New API endpoints: {count}
- Test cases defined: {count}
- Risks identified: {count}
- Challenges raised: {total} (critical: {n}, significant: {n}, minor: {n})
- Challenge verdict: {PASS / PASS WITH CONDITIONS / NEEDS REVISION}
- Open questions: {resolved}/{total}

### HUMAN REVIEW REQUIRED

Review the design artifacts before proceeding:
1. Architecture: `.workflows/{feature-name}/design/architecture.md`
2. ADR: `.workflows/{feature-name}/design/adr.md`
3. Challenge Report: `.workflows/{feature-name}/design/challenge-report.md`
4. Test Strategy: `.workflows/{feature-name}/design/test-strategy.md`

After review and approval, run:
/plan {feature-name}
```

---

## Important Notes

- Design Architect uses **opus** model for complex architectural reasoning
- Devil's Advocate uses **opus** — needs deep reasoning to challenge effectively
- Test Strategist uses **sonnet** — task is more structured, doesn't need deep reasoning
- **Parallelism strategy:**
  - Phase 1: Architect + Test Strategist (Stage A) run in parallel
  - Phase 2: Devil's Advocate + Test Strategist (Stage B) run in parallel
  - Phase 3: Architect addresses challenges (only if needed)
- **Contract-first:** Architect determines approach based on Research Report — if new endpoints exist, API Contracts are created BEFORE architecture
- Each teammate receives the **full agent file** as spawn prompt
- Artifacts are passed via **shared filesystem** (`.workflows/`)
- Context7 MCP is available to architect for framework best practices
- After this phase — **full stop** for human review before `/plan`

---

## Related

- Agent files: `agents/engineering/design-architect.md`, `agents/engineering/test-strategist.md`, `agents/engineering/devils-advocate.md`
- Previous phase: `/research {feature-name}` (Phase 1)
- Next phase: `/plan {feature-name}` (Phase 3)
- Full flow: `scenarios/delivery/feature-development.md`
