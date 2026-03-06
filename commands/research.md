---
name: research
description: Research phase — investigate codebase in context of a task. Collects facts AS IS, no proposals. Orchestrates Research Lead + Codebase Researcher team.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "TeamCreate", "TeamDelete", "SendMessage", "TodoWrite", "mcp__sentry__get_issue_details", "mcp__sentry__list_issue_events", "mcp__sentry__list_issues", "mcp__sentry__get_issue_tag_values", "mcp__context7__resolve-library-id", "mcp__context7__query-docs"]
triggers:
  - "research"
  - "досліди"
  - "проаналізуй задачу"
skills:
  - auto:{project}-patterns
requires: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
---

# /research - Feature Research

Orchestrates Research Lead + Codebase Researcher(s) as an **agent team** to investigate a task before implementation.

## Usage

```bash
/research "Add refund functionality to payments"
/research --type bug "Payment fails for amounts > 1000"
/research --type bug --sentry PROJ-123 "Payment processing error"
/research --scope src/Service/Payment "Refactor payment flow"
```

## Prerequisites

Agent Teams must be enabled:
```json
// settings.json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

## You Are the Research Lead

When this command runs, YOU (Claude) are the **Research Lead orchestrator**. You:
- Analyze the task and determine type (bug/feature)
- Decompose into 2-4 research sub-tasks
- Create the agent team and spawn scanner teammates
- Assign focused scopes to each scanner
- Collect and synthesize results into Research Report
- For bug-fix: pull Sentry context if available

## Setup

### Step 0: Prepare Workspace

1. Parse the task description and options (`--type`, `--scope`, `--sentry`)
2. Determine feature name from task (kebab-case, e.g. `payment-refund`)
3. Create workspace directory:

```bash
mkdir -p .workflows/{feature-name}/research
```

4. Detect project technology (check root files: `composer.json`, `package.json`, `go.mod`, etc.)

### Step 1: Create Team

```
TeamCreate:
  team_name: "research-{feature-name}"
  description: "Research phase for {feature-name}"
```

## Phase Execution

### Phase 1: Task Analysis

Read and analyze the task description. Determine:

1. **Type**: bug or feature
2. **Initial scope**: which parts of the codebase are likely involved
3. **Sub-tasks**: 2-4 focused research areas

For **feature** tasks, typical decomposition:
- Architecture scan — components, boundaries, dependencies
- Data scan — entities, DTOs, repositories, migrations
- Integration scan — external services, async flows (if relevant)

For **bug-fix** tasks:
- Error scan — error point, data flow, exception handling
- Component scan — involved components, their dependencies
- (Optional) Integration scan — if bug involves external service

### Phase 2: Sentry Context (bug-fix only)

If `--type bug` and Sentry MCP is available:

1. If `--sentry ISSUE-ID` provided:
   ```
   mcp__sentry__get_issue_details(issue_id: "ISSUE-ID")
   mcp__sentry__list_issue_events(issue_id: "ISSUE-ID")
   ```

2. If no specific issue but bug description available:
   ```
   mcp__sentry__list_issues(query: "{relevant search terms}")
   ```

3. Extract from Sentry data:
   - Stack trace → identifies files and lines to focus on
   - Tags → identifies environment, user segments
   - Breadcrumbs → identifies user flow leading to error
   - Frequency → determines urgency

4. Write Sentry context to pass to scanners

### Phase 3: Launch Scanners

Read agent file: `agents/engineering/codebase-researcher.md`

For each sub-task, spawn a scanner teammate with the agent file as spawn prompt, plus focused context:

#### Example: Architecture Scanner

Spawn teammate "scanner-arch" with the full agent file content, plus:

```
[RESEARCH SUB-TASK]
Type: architecture
Scope: src/Service/Payment/, src/Controller/Api/v2/PaymentController.php
Focus: How payment processing works — components, dependencies, flow
Context: Task is to add refund functionality. Need to understand current payment architecture.

[TASK]
Scan the specified scope following your Process for "architecture" scan type.
Write output to: .workflows/{feature-name}/research/architecture-scan.md
```

#### Example: Data Scanner

Spawn teammate "scanner-data" with the agent file, plus:

```
[RESEARCH SUB-TASK]
Type: data
Scope: src/Entity/Payment.php, src/Entity/Order.php, src/Repository/PaymentRepository.php, migrations/
Focus: Payment data model — fields, relations, recent schema changes
Context: Task is to add refund functionality. Need to understand payment data structure.

[TASK]
Scan the specified scope following your Process for "data" scan type.
Write output to: .workflows/{feature-name}/research/data-scan.md
```

#### Example: Integration Scanner

Spawn teammate "scanner-int" with the agent file, plus:

```
[RESEARCH SUB-TASK]
Type: integration
Scope: src/Client/StripeClient.php, src/MessageHandler/Payment/, config/packages/messenger.yaml
Focus: External payment integrations and async flows
Context: Task is to add refund functionality. Need to understand Stripe integration and async processing.

[TASK]
Scan the specified scope following your Process for "integration" scan type.
Write output to: .workflows/{feature-name}/research/integration-scan.md
```

**IMPORTANT**: Give each scanner a **narrow scope** — specific directories and files, not `src/`. The narrower the scope, the higher quality the scan.

If you don't know exact file paths yet, do a quick `Glob` or `Grep` yourself first to identify relevant files, then pass those to scanners.

### Phase 4: Synthesize

After all scanners complete (wait for TeammateIdle notifications):

1. Read all scan output files from `.workflows/{feature-name}/research/`
2. Check completeness — all sub-tasks have results
3. Identify conflicts between scan results
4. Synthesize the **Research Report** following the output format from `agents/engineering/research-lead.md`
5. Write to `.workflows/{feature-name}/research/research-report.md`

### Phase 5: Gate & Cleanup

**Gate** — verify before completing:
- [ ] Components Involved table is not empty
- [ ] Data Flow is described
- [ ] Current Behavior (AS IS) section is filled
- [ ] Open Questions section exists
- [ ] [bug] Error Analysis is filled
- [ ] All scanner sub-tasks produced output files

**Cleanup**:
1. Send shutdown to all scanner teammates via `SendMessage`
2. Call `TeamDelete` to clean up team resources
3. Report summary to user:

```markdown
## Research Complete: {feature-name}

### Files Generated
| File | Content |
|------|---------|
| .workflows/{feature-name}/research/research-report.md | Final Research Report |
| .workflows/{feature-name}/research/architecture-scan.md | Architecture scan |
| .workflows/{feature-name}/research/data-scan.md | Data scan |
| .workflows/{feature-name}/research/integration-scan.md | Integration scan |

### Summary
- Type: {bug/feature}
- Components found: {count}
- Open Questions: {count}
- Complexity: {low/medium/high}

### Next Step
Review the Research Report, then run:
/design {feature-name}
```

---

## Scope Narrowing Guide

How to narrow scope before launching scanners:

### PHP/Symfony
```bash
# Find controllers related to "payment"
Glob: src/Controller/**/*Payment*
Grep: "payment" in src/Controller/

# Find entities
Glob: src/Entity/*Payment*

# Find services
Grep: "class.*Payment.*Service" in src/Service/

# Find message handlers
Glob: src/MessageHandler/*Payment*

# Find config
Grep: "payment" in config/
```

### Node/JS
```bash
# Find routes
Grep: "payment" in src/routes/

# Find models
Glob: src/models/*payment*

# Find services
Grep: "Payment" in src/services/
```

---

## Important Notes

- Each scanner receives the **full codebase-researcher agent file** as its spawn prompt
- Scanners have read-only tools (Read, Grep, Glob) — they cannot modify code
- Artifacts are passed via **shared filesystem** (`.workflows/`), not in message body
- If a scanner fails, report the error and continue with remaining scans — partial research is better than none
- Always call `TeamDelete` at the end, even if some scanners failed
- The target project may be a **different directory** than ai-agents-system — detect or ask

---

## Related

- Agent files: `agents/engineering/research-lead.md`, `agents/engineering/codebase-researcher.md`
- Next phase: `/design {feature-name}` (Phase 2)
- Full flow: `scenarios/delivery/feature-development.md`
