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

### Phase 1: Task Analysis + Intake

Read and analyze the task description. Determine:

1. **Type**: bug or feature
2. **Initial scope**: which parts of the codebase are likely involved

**Intake Check** — if critical context is missing, ask the user before proceeding:

| What to check | When to ask |
|---------------|-------------|
| Where is it? (path/module) | When scope can't be determined from task description |
| Related issues? (Sentry ID, GitHub) | When type = bug and no `--sentry` flag |
| Constraints? (backwards compat, deadline) | When task touches public API or shared components |
| Expected outcome? (new feature / fix / refactor) | When task type is ambiguous |

**Rule**: ask ONLY what's undefined AND critical for research. If context is sufficient — don't ask anything, proceed to Phase 2.

### Phase 2: Quick Reconnaissance

Before decomposing into sub-tasks, YOU (Lead) do a quick recon:

1. **Find entry points** — `Glob` and `Grep` by task keywords (controller, service, entity names)
2. **Read 3-5 key files** — controller, main service, entity (skim for structure, dependencies, boundaries)
3. **Git History** — check recent activity in scope:
   ```bash
   git log --oneline -10 -- {scope-paths}
   git log --oneline --since="2 weeks" -- {scope-paths}
   ```
   Look for:
   - **Hot files** — frequently changed → conflict risk, unstable code
   - **Recent changes** — someone already working on this module?
   - **For bug-fix**: when were last changes → could they have caused the bug?
   Pass findings to scanners as `Recent changes` context field.
4. **Map real scope** — which modules/directories are actually involved
5. **Assess complexity** — based on number of components and their connections

This step replaces guessing with informed decomposition. You now know what files exist, how they connect, and what changed recently.

### Phase 3: Complexity Assessment

Based on Quick Reconnaissance, determine research strategy:

| Level | Criteria | Strategy |
|-------|----------|----------|
| **Small** | 1 component, ≤ 5 files, no external deps | Lead scans alone, no team. Write Research Report directly |
| **Medium** | 2-3 components, 6-15 files | 2 scanners (architecture + data, or error + component) |
| **Large** | 4+ components, cross-boundary, external integrations | 3-4 scanners (architecture + data + integration + optional) |

**If Small** — skip to Phase 6 (Solo Scan):
- Scan files yourself following the codebase-researcher output format
- Write report directly to `.workflows/{feature-name}/research/research-report.md`
- Skip team creation, scanner launch, and synthesis phases
- Proceed to Phase 8 (Gate & Cleanup) without team cleanup

**If Medium/Large** — continue to Phase 4.

Announce your assessment to the user:
```
Complexity: {Small|Medium|Large}
Reason: {short justification}
Strategy: {Lead solo | N scanners with types}
```

### Phase 4: Sentry Context (bug-fix only)

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

### Phase 5: Launch Scanners (Medium/Large only)

Read agent file: `agents/engineering/codebase-researcher.md`

For each sub-task, spawn a scanner teammate with the agent file as spawn prompt, plus focused context.

Use your Quick Reconnaissance findings to give scanners precise scope:
- Pass specific files and directories you already discovered
- Include key dependencies you found when reading entry points
- Add Focus based on real code understanding, not guessing

#### Example: Architecture Scanner

Spawn teammate "scanner-arch" with the full agent file content, plus:

```
[RESEARCH SUB-TASK]
Type: architecture
Scope: src/Service/Payment/, src/Controller/Api/v2/PaymentController.php
Focus: How payment processing works — components, dependencies, flow
Context: Task is to add refund functionality. Need to understand current payment architecture.
Recon findings: PaymentService depends on StripeClient and OrderRepository. Main flow starts at PaymentController::process.
Recent changes: "abc123 Refactor PaymentService to use events (3 days ago)", "def456 Add retry logic to StripeClient (1 week ago)"

[TASK]
Scan the specified scope following your Process for "architecture" scan type.
If you discover a critical dependency outside your scope, send a SCOPE_EXTENSION_REQUEST to Lead.
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
Recon findings: Payment entity has 'status' field with enum values. Order has OneToMany to Payment.
Recent changes: "ghi789 Add 'refundedAt' column to payments (5 days ago)"

[TASK]
Scan the specified scope following your Process for "data" scan type.
If you discover a critical dependency outside your scope, send a SCOPE_EXTENSION_REQUEST to Lead.
Write output to: .workflows/{feature-name}/research/data-scan.md
```

#### Example: Integration Scanner (Large only)

Spawn teammate "scanner-int" with the agent file, plus:

```
[RESEARCH SUB-TASK]
Type: integration
Scope: src/Client/StripeClient.php, src/MessageHandler/Payment/, config/packages/messenger.yaml
Focus: External payment integrations and async flows
Context: Task is to add refund functionality. Need to understand Stripe integration and async processing.
Recon findings: StripeClient wraps stripe/stripe-php SDK. PaymentCreatedMessage dispatched async via messenger.
Recent changes: no recent changes

[TASK]
Scan the specified scope following your Process for "integration" scan type.
If you discover a critical dependency outside your scope, send a SCOPE_EXTENSION_REQUEST to Lead.
Write output to: .workflows/{feature-name}/research/integration-scan.md
```

**IMPORTANT**: Give each scanner a **narrow scope** — specific directories and files, not `src/`. Quick Reconnaissance should have already identified the relevant paths.

### Phase 5b: Handle Scope Extension Requests

During scanning, scanners may discover critical dependencies outside their assigned scope. They will send `SCOPE_EXTENSION_REQUEST` messages back to you (Lead).

**Protocol**:
1. Scanner sends request with reason, specific files (max 3), and impact
2. You evaluate: is this truly critical for the task?
3. **Approve** — send back `SCOPE_EXTENSION_APPROVED` with allowed files
4. **Deny** — send back `SCOPE_EXTENSION_DENIED` with reason (scanner adds to "Out of Scope" in report)

**Guardrails**:
- Max **2 extensions** per scanner (prevents scope creep)
- Only **specific files**, not directories
- If scanner requests > 5 files → initial scope was wrong. Log as Open Question
- Don't block on requests — continue processing other scanner results while deciding

### Phase 6: Solo Scan (Small only)

For Small complexity tasks, Lead performs the scan directly:

1. Read all files in scope (≤ 5 files)
2. Document components, dependencies, data flow
3. Follow the output format from `agents/engineering/codebase-researcher.md` for consistency
4. Write combined Research Report (scan results + synthesis) to `.workflows/{feature-name}/research/research-report.md`

No team creation needed. No scanner agents spawned.

### Phase 7: Synthesize (Medium/Large only)

After all scanners complete (wait for TeammateIdle notifications):

1. Read all scan output files from `.workflows/{feature-name}/research/`
2. Check completeness — all sub-tasks have results
3. Identify conflicts between scan results
4. Synthesize the **Research Report** following the output format from `agents/engineering/research-lead.md`
5. Write to `.workflows/{feature-name}/research/research-report.md`

### Phase 8: Gate & Cleanup

**Gate** — verify before completing:
- [ ] Components Involved table is not empty
- [ ] Data Flow is described
- [ ] Current Behavior (AS IS) section is filled
- [ ] Open Questions section exists
- [ ] [bug] Error Analysis is filled
- [ ] [Medium/Large] All scanner sub-tasks produced output files
- [ ] [Small] Lead completed scan and report directly

**Cleanup** (Medium/Large only):
1. Send shutdown to all scanner teammates via `SendMessage`
2. Call `TeamDelete` to clean up team resources

**Cleanup** (Small):
1. No team cleanup needed

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
- Scanners have read-only tools (Read, Grep, Glob) + SendMessage for scope extension requests — they cannot modify code
- Artifacts are passed via **shared filesystem** (`.workflows/`), not in message body
- If a scanner fails, report the error and continue with remaining scans — partial research is better than none
- Always call `TeamDelete` at the end, even if some scanners failed
- The target project may be a **different directory** than ai-agents-system — detect or ask

---

## Related

- Agent files: `agents/engineering/research-lead.md`, `agents/engineering/codebase-researcher.md`
- Next phase: `/design {feature-name}` (Phase 2)
- Full flow: `scenarios/delivery/feature-development.md`
