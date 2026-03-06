---
name: design
description: Design phase — architecture decisions, diagrams (C4/DataFlow/Sequence), ADR, test strategy, API contracts. Produces design artifacts for human review before implementation.
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

Orchestrates Design Architect + Test Strategist as an **agent team** to produce architecture decisions and test strategy based on Research Report.

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
- Spawn Design Architect to produce architecture + ADR + API contracts
- Spawn Test Strategist after architecture is ready
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

### Phase 1: Architecture Design (blocking)

**Teammate**: architect (Design Architect)

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
2. Create Architecture Design → .workflows/{feature-name}/design/architecture.md
3. Create ADR → .workflows/{feature-name}/design/adr.md
4. Create API Contracts (if new endpoints) → .workflows/{feature-name}/design/api-contracts.md

[SKIP OPTIONS]
Skip ADR: {yes/no based on --skip-adr}
Skip API Contracts: {yes/no based on --skip-api}
```

3. Create task in shared task list: "Design architecture for {feature-name}"
4. Wait for architect to go idle

**Gate**: Verify:
- `architecture.md` contains at least one Mermaid diagram
- `architecture.md` has New/Changed Components table
- `adr.md` has at least 2 alternatives (unless --skip-adr)
- API contracts exist if architecture mentions new endpoints (unless --skip-api)

---

### Phase 2: Test Strategy (sequential, depends on Phase 1)

**Teammate**: tester (Test Strategist)

Skip this phase if `--skip-tests` is set.

1. Read agent file: `agents/engineering/test-strategist.md`
2. Spawn teammate "tester" with agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}
Feature: {feature-name}

[INPUT ARTIFACTS — read from disk]
- .workflows/{feature-name}/research/research-report.md
- .workflows/{feature-name}/design/architecture.md
- .workflows/{feature-name}/design/adr.md

[TASK]
Execute the full test strategy process as described in your Task section.
Write output to: .workflows/{feature-name}/design/test-strategy.md
```

3. Create task with dependency on Phase 1 task
4. Wait for tester to go idle

**Gate**: Verify:
- `test-strategy.md` has concrete test cases (Given/When/Then)
- Test levels are appropriate for the components
- "What NOT to Test" section exists

---

### Phase 3: Quality Check

Design Lead (you) performs final consistency check:

1. Read all design artifacts
2. Verify consistency:
   - Components in architecture.md match those in test-strategy.md
   - API contracts match sequence diagrams
   - ADR risks are covered by test cases
3. If inconsistencies found — send fix request to responsible teammate via `SendMessage`

---

### Phase 4: Cleanup & Report

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

### Design Summary
- New components: {count}
- Modified components: {count}
- New API endpoints: {count}
- Test cases defined: {count}
- Risks identified: {count}
- Open questions: {resolved}/{total}

### HUMAN REVIEW REQUIRED

Review the design artifacts before proceeding:
1. Architecture: `.workflows/{feature-name}/design/architecture.md`
2. ADR: `.workflows/{feature-name}/design/adr.md`
3. Test Strategy: `.workflows/{feature-name}/design/test-strategy.md`

After review and approval, run:
/plan {feature-name}
```

---

## Important Notes

- Design Architect uses **opus** model for complex architectural reasoning
- Test Strategist uses **sonnet** — task is more structured, doesn't need deep reasoning
- Test Strategist runs AFTER architect — needs architecture.md as input
- Each teammate receives the **full agent file** as spawn prompt
- Artifacts are passed via **shared filesystem** (`.workflows/`)
- Context7 MCP is available to architect for framework best practices
- After this phase — **full stop** for human review before `/plan`

---

## Related

- Agent files: `agents/engineering/design-architect.md`, `agents/engineering/test-strategist.md`
- Previous phase: `/research {feature-name}` (Phase 1)
- Next phase: `/plan {feature-name}` (Phase 3)
- Full flow: `scenarios/delivery/feature-development.md`
