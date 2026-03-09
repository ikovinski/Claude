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
/design {feature-name}                    # Full design, standard depth
/design {feature-name} --depth light      # Lightweight: C4 Context + 1 Sequence + key decisions only
/design {feature-name} --depth detailed   # Full + rollback strategy + migration plan
/design {feature-name} --skip-adr         # Skip ADR (for simple changes)
/design {feature-name} --skip-api         # Skip API contracts (no new endpoints)
/design {feature-name} --skip-tests       # Skip test strategy
/design {feature-name} --skip-challenge   # Skip Devil's Advocate (small/obvious changes)
/design {feature-name} --security         # Add Security Reviewer for PII/auth/payment flows
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

### Step 0: Validate Prerequisites, Load Project Skill & Complexity Check

1. Check `.workflows/{feature-name}/research/research-report.md` exists
2. If missing — tell user to run `/research` first
3. **Load project skill** — check for `.claude/skills/{project}-patterns/SKILL.md` in the target project. If found:
   - Read `SKILL.md` and all files in `references/` directory (architecture.md, conventions.md, workflows.md)
   - These patterns are **mandatory constraints** for design decisions: decorator chain order, service wiring naming, exception patterns, cache pool conventions, ENV naming, interface conventions
   - When spawning architect — include the full project skill content in the spawn prompt as `[PROJECT PATTERNS]` section
   - Architect MUST NOT propose designs that contradict project patterns (e.g., breaking an interface if the project convention is to keep interfaces stable, or inverting decorator chain order)
4. Read Research Report to understand scope
5. Read `.workflows/{feature-name}/state.json` — check `complexity` field

**Complexity auto-defaults** (applied when no explicit flags override):

| Complexity | Auto-applied defaults |
|-----------|----------------------|
| **small** | Should not reach /design — `/feature` skips it. If called directly: `--depth light --skip-challenge --skip-adr --skip-api --skip-tests` |
| **medium** | `--depth light --skip-challenge` |
| **large** | `--depth standard` (or `--depth detailed` if 6+ components) |
| **null** | No auto-defaults, use explicit flags or standard |

Explicit flags always override auto-defaults. Announce applied defaults:
```
Complexity: {value} — auto-applying: {list of defaults}
```

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
3. Create Diagrams → .workflows/{feature-name}/design/diagrams.md
4. Create Architecture Design → .workflows/{feature-name}/design/architecture.md
5. Create ADR(s) → .workflows/{feature-name}/design/adr/*.md (one file per decision)
6. Create API Contracts (if new endpoints) → .workflows/{feature-name}/design/api-contracts.md
7. Run Self-Review (Step 5) — fix inconsistencies before completing

[DEPTH]
Design depth: {light/standard/detailed based on --depth, default: standard}

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
- `diagrams.md` contains at least one Mermaid diagram (` ```mermaid ` code block)
- `diagrams.md` contains NO ASCII art diagrams — all diagrams must use Mermaid syntax. If you find box-drawing characters (─│┌┐└┘├┤) or text-art layouts instead of ` ```mermaid ` blocks, send the architect a fix request: "All diagrams must use Mermaid syntax in ```mermaid code blocks. Rewrite ASCII diagrams as Mermaid."
- `architecture.md` has New/Changed Components table and references diagrams.md
- ADR exists in adr/*.md with at least 2 alternatives per decision (unless --skip-adr)
- API contracts exist if architecture mentions new endpoints (unless --skip-api)

---

### Phase 2: Challenge + Test Strategy Stage B + Security (parallel)

After architect completes, up to three tasks run in parallel:

#### 2a: Devil's Advocate

Skip if `--skip-challenge` is set.

**Teammate**: challenger

1. Read agent file: `agents/engineering/devils-advocate.md`
2. Spawn teammate "challenger" with agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}
Feature: {feature-name}

[INPUT ARTIFACTS — read from disk]
- .workflows/{feature-name}/design/architecture.md
- .workflows/{feature-name}/design/adr/*.md
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
2. Read .workflows/{feature-name}/design/adr/*.md
3. Define test strategy and write test cases
Write final output to: .workflows/{feature-name}/design/test-strategy.md
(you may delete test-patterns.md or merge its content)
```

#### 2c: Security Reviewer (optional)

Only if `--security` is set OR Research Report mentions PII, authentication, payments, encryption, or sensitive data.

**Teammate**: security-reviewer

1. Read agent file: `agents/engineering/security-reviewer.md`
2. Spawn teammate "security-reviewer" with security-reviewer agent file, plus:

```
[CONTEXT]
Project path: {target_project_path}
Feature: {feature-name}

[SCOPE]
security

[INPUT ARTIFACTS — read from disk]
- .workflows/{feature-name}/design/architecture.md
- .workflows/{feature-name}/design/diagrams.md
- .workflows/{feature-name}/design/api-contracts.md (if exists)

[TASK]
Review the DESIGN (not code) for security concerns:
1. Data flow security — where is sensitive data stored, transmitted, logged?
2. Auth/authz gaps — are all endpoints properly protected?
3. Input validation — are all external inputs validated at system boundary?
4. Secrets management — are API keys, tokens handled securely?
5. OWASP Top 10 applicability to this design

Write output to: .workflows/{feature-name}/design/security-review.md
```

3. Create task: "Security review design for {feature-name}"

**Wait**: All Phase 2 teammates finish.

**Gate for challenger** (if not skipped): Verify:
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
1. Address each challenge — update architecture.md and/or adr/*.md
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
| .workflows/{feature-name}/design/diagrams.md | C4, DataFlow, Sequence diagrams (Mermaid) |
| .workflows/{feature-name}/design/architecture.md | Component changes, async flows, open questions |
| .workflows/{feature-name}/design/adr/*.md | Decision(s), alternatives, risks |
| .workflows/{feature-name}/design/api-contracts.md | New/changed API endpoints |
| .workflows/{feature-name}/design/test-strategy.md | Test cases and strategy |
| .workflows/{feature-name}/design/challenge-report.md | Devil's Advocate challenges + verdict |
| .workflows/{feature-name}/design/security-review.md | Security concerns (if --security) |

### Design Summary
- Design depth: {light/standard/detailed}
- New components: {count}
- Modified components: {count}
- New API endpoints: {count}
- ADR decisions: {count} (adr/*.md)
- Test cases defined: {count}
- Risks identified: {count}
- Challenges raised: {total} (critical: {n}, significant: {n}, minor: {n})
- Challenge verdict: {PASS / PASS WITH CONDITIONS / NEEDS REVISION}
- Security issues: {count or "not reviewed"}
- Open questions: {resolved}/{total}
```

4. **HUMAN REVIEW GATE** — present structured options:

```markdown
### HUMAN REVIEW REQUIRED

Please review the design artifacts:
1. Diagrams: `.workflows/{feature-name}/design/diagrams.md`
2. Architecture: `.workflows/{feature-name}/design/architecture.md`
3. ADR: `.workflows/{feature-name}/design/adr/`
4. Challenge Report: `.workflows/{feature-name}/design/challenge-report.md`
5. Test Strategy: `.workflows/{feature-name}/design/test-strategy.md`

**Your decision:**
- **approve** — design is good, proceed to `/plan {feature-name}`
- **change {description}** — I want to adjust specific parts (Lead will coordinate changes)
- **reject {reason}** — start over with different direction

Reply with your decision.
```

5. Handle response:
   - **approve** → print "Approved. Run `/plan {feature-name}` when ready."
   - **change** → send change request to relevant teammate, iterate, re-present
   - **reject** → print "Design rejected. Artifacts preserved in `.workflows/{feature-name}/design/` for reference."

---

## Important Notes

- Design Architect uses **opus** model for complex architectural reasoning
- Devil's Advocate uses **opus** — needs deep reasoning to challenge effectively
- Test Strategist uses **sonnet** — task is more structured, doesn't need deep reasoning
- Security Reviewer uses **sonnet** with dedicated `security-reviewer.md` agent (OWASP, secrets, access control)
- **Parallelism strategy:**
  - Phase 1: Architect + Test Strategist (Stage A) run in parallel
  - Phase 2: Devil's Advocate + Test Strategist (Stage B) + Security Reviewer run in parallel
  - Phase 3: Architect addresses challenges (only if needed)
- **Contract-first:** Architect determines approach based on Research Report — if new endpoints exist, API Contracts are created BEFORE architecture
- **Design depth:** light / standard / detailed — controls diagram and documentation detail level
- **ADR always in adr/*.md** — one file per decision, always in directory
- **Diagrams separate:** all Mermaid diagrams in `diagrams.md`, architecture.md references them
- Each teammate receives the **full agent file** as spawn prompt
- Artifacts are passed via **shared filesystem** (`.workflows/`)
- Context7 MCP is available to architect for framework best practices
- After this phase — **full stop** for human review before `/plan`

---

## Example Walkthrough

### Context
Task: "Add Stripe webhook endpoint for handling payment refunds"
Research completed: `.workflows/stripe-refunds/research/` has research-report.md documenting existing Stripe integration, PaymentService, and webhook patterns.

### How It Plays Out

**Phase 1 (parallel):**

*Architect (Wave 1):*
```
Reads research-report.md:
  - Existing: StripeWebhookController handles charge.succeeded
  - Existing: PaymentService with processPayment()
  - Pattern: one handler per event type, dispatches domain event
  - New endpoints needed → Contract-first approach

Creates api-contracts.md FIRST:
  - POST /webhooks/stripe (existing, but add refund handling)
  - No new endpoints, but new event type: charge.refunded

Creates diagrams.md:
  - C4 Component: StripeWebhookController → RefundHandler → PaymentService → DB
  - Sequence: Stripe → webhook → validate signature → RefundHandler → update payment → dispatch event
  - DataFlow: charge.refunded event → handler → DB update → notification

Creates architecture.md:
  - New: RefundHandler service
  - Modify: StripeWebhookController (add refund event routing)
  - Modify: PaymentService (add processRefund method)

Creates adr/:
  adr/001-refund-handler-pattern.md:
    Decision: Separate RefundHandler (CHOSEN) — SRP, testable
    Alternative: Add to PaymentService — simpler but grows the god-service
  adr/002-idempotency-strategy.md:
    Decision: DB unique on stripe_event_id (CHOSEN) — no new infra
    Alternative: Redis with TTL — faster but adds dependency

Self-Review: ✅ all consistent
```

*Test Strategist (Wave 1 — Stage A):*
```
Analyzes existing tests:
  - PHPUnit, tests/Unit + tests/Functional structure
  - WebTestCase for API tests
  - Fixtures via Alice
  - Found: StripeWebhookControllerTest.php — 3 existing tests
  - Gap: no refund scenarios tested
```

**Phase 2 (parallel):**

*Devil's Advocate (Wave 2):*
```
Challenge ALT-1 (SIGNIFICANT): "Separate RefundHandler" alternative B
  dismissed too quickly. PaymentService already handles charge.succeeded —
  adding refund there follows existing pattern. Why break consistency?

Challenge R-1 (MINOR): Missing risk — Stripe webhook retry behavior.
  What happens if refund handler fails? Stripe retries up to 3 days.
  Is idempotency sufficient?

Challenge A-1 (MINOR): Sequence diagram doesn't show error path
  for invalid Stripe signature.

Verdict: PASS WITH CONDITIONS
Required Actions:
  1. Strengthen ADR Alternative B justification
  2. Add Stripe retry risk to ADR risks table
```

*Test Strategist (Wave 2 — Stage B):*
```
Creates test-strategy.md:
  Unit: RefundHandler — 4 cases (happy path, already refunded, partial refund, payment not found)
  Functional: StripeWebhookController — 3 cases (valid refund event, invalid signature, duplicate event)
  What NOT to Test: Stripe API behavior, existing charge.succeeded flow
```

**Phase 3 (Address Challenges):**
```
Architect updates:
  - ADR: adds stronger justification for why RefundHandler separate
    (PaymentService already 300 lines, adding refund = 400+)
  - ADR risks: adds "Stripe webhook retries" with mitigation (idempotency key)
  - diagrams.md: adds error flow for invalid signature
```

**Phase 4 (Quality Check):**
```
Lead verifies:
  - Components in architecture.md ↔ test-strategy.md: ✅ match
  - diagrams.md sequences ↔ api-contracts.md: ✅ consistent
  - ADR risks covered by tests: ✅ duplicate event test covers idempotency
```

**Phase 5 (Report + Human Gate):**
```
Design Summary:
  - Depth: standard
  - New components: 1 (RefundHandler)
  - Modified: 2 (StripeWebhookController, PaymentService)
  - ADR decisions: 2 (adr/*.md)
  - Test cases: 7
  - Challenges: 3 (0 critical, 1 significant, 2 minor)
  - Verdict: PASS WITH CONDITIONS → addressed

User: "approve"
→ "Approved. Run /plan stripe-refunds when ready."
```

### Outcome
- Contract-first identified no new endpoints early (just new event handling)
- Devil's Advocate caught weak ADR alternative and missing retry risk
- Self-Review caught diagram/contract consistency before challenge phase
- Test Strategist Stage A ran in parallel — saved ~5 minutes
- Total team time: ~20 minutes (parallel execution)

---

## Related

- Agent files: `agents/engineering/design-architect.md`, `agents/engineering/test-strategist.md`, `agents/engineering/devils-advocate.md`, `agents/engineering/security-reviewer.md`
- Template skills: `skills/design-template/`, `skills/adr-template/`, `skills/api-contracts-template/` (if exist)
- Previous phase: `/research {feature-name}` (Phase 1)
- Next phase: `/plan {feature-name}` (Phase 3)
- Full flow: `scenarios/delivery/feature-development.md`
