# Dev Workflow: Implement Scenario

## Metadata
```yaml
name: dev-implement
category: dev-workflow
trigger: Implement code phase by phase
participants:
  - tdd-guide (developer — writes tests + code)
  - code-reviewer (reviewer — security, quality, plan compliance)
duration: varies per phase
skills:
  - auto:{project}-patterns
  - tdd/tdd-workflow
  - code-quality/test-patterns
team_execution: true
```

## Skills Usage in This Scenario

1. **{project}-patterns**: Both agents apply project-specific conventions for naming, patterns, test structure
2. **tdd/tdd-workflow**: Developer follows Red-Green-Refactor cycle from this skill
3. **code-quality/test-patterns**: Developer uses test patterns for unit, integration, functional tests
4. **security/owasp-top-10**: Reviewer applies during security checks (loaded from code-reviewer rules)
5. **coding-style**: Both agents follow PHP 8.3 / Symfony 6.4 standards (loaded from rules)

## Situation

### Description
Fourth step of the `/dev` workflow. Executes the implementation plan phase by phase using a developer-reviewer pair. The developer (TDD Guide) writes tests first, then production code. After each phase, the reviewer (Code Reviewer) checks security, quality, and plan compliance. This is an internal loop — developer and reviewer iterate until the phase passes review, then move to the next phase.

### Common Triggers
- Automatic progression from Plan phase
- `/dev --step implement` (when plan already exists)
- "Implement phase 1 of the plan"
- "Start coding from the plan"

### Wellness/Fitness Tech Context
- **TDD for health data**: Tests for calorie calculations, workout metrics, and health data transformations must cover edge cases (zero, negative, null, extreme values)
- **Idempotency tests**: Every message handler must have idempotency tests — reviewer blocks if missing
- **PII/PHI in tests**: Test fixtures must not contain real health data — reviewer checks for this
- **Billing safety**: Payment-related code requires reviewer to verify idempotency and failure handling
- **Integration mocking**: External API calls (Garmin, Fitbit, Apple Health) must use MockHttpClient — reviewer blocks real API calls in tests

---

## Participants

### Required
| Role/Agent | Model | Purpose in Scenario |
|------------|-------|---------------------|
| developer (tdd-guide) | sonnet | Writes tests first (Red), then production code (Green), then refactors. Follows TDD workflow. |
| reviewer (code-reviewer) | sonnet | Reviews each phase for security, code quality, and plan compliance. Blocks or approves. |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| security-reviewer | When implementing phases that touch auth, PII/PHI, or billing — adds security-focused review layer |

---

## Process Flow

### Internal Loop (per Phase)

```
┌─────────────────────────────────────────────┐
│              PHASE N LOOP                    │
│                                              │
│  ┌──────────┐    ┌──────────┐               │
│  │developer │───>│ reviewer  │               │
│  │(TDD)     │<───│(review)   │               │
│  └──────────┘    └──────────┘               │
│       │                │                     │
│       │ writes tests   │ checks:             │
│       │ writes code    │ - security          │
│       │ refactors      │ - quality           │
│       │                │ - plan compliance   │
│       │                │ - test coverage     │
│       │                │                     │
│       ▼                ▼                     │
│   [code files]    [APPROVED / FIX NEEDED]   │
│                        │                     │
│            ┌───────────┴──────────┐          │
│            │                      │          │
│        APPROVED              FIX NEEDED      │
│            │                      │          │
│     Update PROGRESS.md    developer fixes    │
│     Move to Phase N+1    → back to review    │
│                                              │
└─────────────────────────────────────────────┘
```

### Step 1: READ PHASE (developer)
**Duration**: 2-3 minutes

Steps:
1. Read Phase N from `.workflows/plan/{name}/001-PLAN.md`
2. Read relevant sections from `.workflows/design/DESIGN.md`
3. Read relevant sections from `.workflows/design/api-contracts.md`
4. Understand: files to create/modify, TDD approach, verification criteria

**Output**: Developer understands what to build

### Step 2: RED — Write Failing Tests (developer)
**Duration**: varies

Steps:
1. Create test files as specified in PLAN.md TDD section
2. Write test methods with assertions (tests MUST fail at this point)
3. Run tests to confirm they fail (Red)
4. Commit test files (optional, depends on team preference)

**Output**: Failing test suite for Phase N

### Step 3: GREEN — Write Production Code (developer)
**Duration**: varies

Steps:
1. Create/modify production files as specified in PLAN.md
2. Write minimum code to make all tests pass
3. Run tests to confirm they pass (Green)
4. Run verification criteria from PLAN.md

**Output**: Passing test suite + production code for Phase N

### Step 4: REFACTOR (developer)
**Duration**: 5-10 minutes

Steps:
1. Review code for duplication, naming, structure
2. Apply coding-style rules (PHP 8.3, Symfony 6.4 standards)
3. Ensure readonly classes, enums, attributes used where appropriate
4. Run tests again to confirm they still pass
5. Signal to reviewer: "Phase N ready for review"

**Output**: Refactored, clean code + passing tests

### Step 5: REVIEW (reviewer)
**Duration**: 5-10 minutes

Steps:
1. Read all code changes for Phase N
2. Check security:
   - No hardcoded credentials
   - Input validation on user data
   - PII/PHI not in logs or error messages
   - Parameterized queries (no SQL injection)
3. Check quality:
   - Coding style compliance (PHP 8.3 standards)
   - Error handling (Recoverable vs Unrecoverable exceptions for handlers)
   - Type safety (full type declarations)
   - No N+1 queries
4. Check plan compliance:
   - All files from PLAN.md Phase N created/modified
   - All test methods from PLAN.md written
   - Verification criteria met
5. Check test coverage:
   - Happy path tested
   - Edge cases tested
   - Error cases tested
   - Idempotency tested (for message handlers)
6. Produce review verdict:
   - **APPROVED**: Phase passes all checks
   - **FIX NEEDED**: List specific issues to fix

**Output**: Review verdict (APPROVED or FIX NEEDED with issue list)

### Step 6: FIX (developer, only if FIX NEEDED)
**Duration**: varies

Steps:
1. Read reviewer feedback
2. Fix each issue
3. Run tests to confirm they still pass
4. Signal to reviewer: "Fixes applied, ready for re-review"
5. Return to Step 5

**Output**: Fixed code

### Step 7: UPDATE PROGRESS (developer, after APPROVED)
**Duration**: 1-2 minutes

Steps:
1. Update `.workflows/implement/PROGRESS.md`:
   - Mark Phase N as complete
   - Record files created/modified
   - Record test results
   - Note any deviations from plan
2. If deviation is significant: create `.workflows/implement/REPLAN-NEEDED.md` (triggers return to Plan step)
3. Move to Phase N+1 (back to Step 1)

**Output**: Updated PROGRESS.md

---

## PROGRESS.md Format

```markdown
# Implementation Progress: {Feature Name}

## Status
- **Current Phase**: {N} of {total}
- **Started**: {date}
- **Last Updated**: {date}

---

## Phase 1: {Phase Name} — COMPLETED
**Duration**: {actual time}
**Review Rounds**: {count}

### Files Created/Modified
| File | Action | Status |
|------|--------|--------|
| src/Service/{Name}.php | CREATE | Done |
| tests/Unit/Service/{Name}Test.php | CREATE | Done |

### Test Results
```
Tests: {N} passed, {N} failed
Coverage: {N}% for affected classes
```

### Deviations from Plan
- {deviation description, or "None"}

---

## Phase 2: {Phase Name} — IN PROGRESS
...

---

## Phase 3: {Phase Name} — PENDING
...
```

## REPLAN-NEEDED.md Format

```markdown
# Replan Needed: {Feature Name}

## Trigger
Phase {N} revealed: {what was discovered}

## Impact
- Plan assumption: {what was assumed}
- Reality: {what was found}
- Affected phases: {which phases need adjustment}

## Suggested Changes
- {change 1}
- {change 2}

## Action
Return to Plan step (3-plan.md) with this file as input.
```

---

## Team-Based Execution

### Team Setup

```
Team Lead creates team:
  team_name: "dev-implement-{feature-slug}"
  description: "Implementation phase for {task description}"
```

### Teammates

| Name | Agent File | subagent_type | Model | Role |
|------|-----------|---------------|-------|------|
| developer | tdd-guide | tdd-guide | sonnet | TDD: tests -> code -> refactor |
| reviewer | code-reviewer | code-reviewer | sonnet | Security + Quality + Plan compliance |

### Phase Execution

```
For each Phase N in PLAN.md:

  1. developer reads Phase N from PLAN.md + DESIGN.md
  2. developer writes tests (Red)
  3. developer writes code (Green)
  4. developer refactors
  5. developer → reviewer: "Phase N ready for review"
  6. reviewer checks: security, quality, plan compliance, test coverage
  7. If FIX NEEDED:
       reviewer → developer: "Fix: [issues]"
       developer fixes
       → back to step 6
  8. If APPROVED:
       developer updates PROGRESS.md
       → next Phase (step 1)

After all phases complete:
  developer sends final PROGRESS.md summary
  Team lead sends shutdown_request to both
  Calls TeamDelete to clean up
```

### Task List Structure

```
1. [developer] Implement Phase 1: {name}
2. [reviewer] Review Phase 1
3. [developer] Implement Phase 2: {name}
4. [reviewer] Review Phase 2
...
N. [developer] Update final PROGRESS.md
```

### Communication Pattern

- **developer -> reviewer**: "Phase N ready for review" + list of changed files
- **reviewer -> developer**: "APPROVED" or "FIX NEEDED: [specific issues]"
- **developer -> team lead**: PROGRESS.md updates, REPLAN-NEEDED.md if triggered
- **team lead -> Plan step**: REPLAN-NEEDED.md (if significant deviation found)

---

## Feedback Loops

### Internal Loop: developer <-> reviewer
Within each phase, developer and reviewer iterate until approval. This is the primary quality gate for code.

### External Loop: Implement <-> Plan
If the developer discovers that the plan has incorrect assumptions (e.g., an entity does not exist, an API behaves differently than documented), they create `REPLAN-NEEDED.md` and control returns to the Plan step. The Planner re-reads research + design + REPLAN-NEEDED.md and produces an updated plan.

```
Implement discovers issue
  → creates .workflows/implement/REPLAN-NEEDED.md
  → pauses implementation
  → control returns to 3-plan.md
  → Planner creates updated plan (002-PLAN.md)
  → Implement resumes with new plan
```

---

## Decision Points

### Decision 1: Review Depth per Phase
**Question**: How thorough should the per-phase review be?
**Options**:
- A: Quick check (security + plan compliance only) — for low-risk phases
- B: Standard (security + quality + plan compliance + coverage) — default
- C: Deep (all above + performance + architecture) — for critical phases (billing, auth)

**Recommended approach**: B for most phases. C for phases touching billing, PII/PHI, or authentication.

### Decision 2: Replan Threshold
**Question**: When should implementation trigger a replan?
**Options**:
- A: Minor deviation — handle in current phase, note in PROGRESS.md
- B: Moderate deviation — complete current phase, replan remaining phases
- C: Major deviation — stop immediately, replan everything

**Recommended approach**: A for naming differences, B for missing dependencies, C for incorrect architecture assumptions.

### Decision 3: Test Granularity
**Question**: How many tests per phase?
**Options**:
- A: Minimum (happy path only) — for simple utility phases
- B: Standard (happy path + edge cases + error cases) — default
- C: Comprehensive (all above + idempotency + performance) — for message handlers and billing

**Recommended approach**: B for most phases. C for message handlers, billing code, and health data processing.

---

## Prompts Sequence

### Developer Prompt (per Phase)
**Use Agent**: tdd-guide
**Prompt**:
```
[IDENTITY]
You are the TDD Guide implementing Phase {N} of the /dev workflow.

[CONTEXT]
Plan: .workflows/plan/{slug}/001-PLAN.md (read Phase {N})
Design: .workflows/design/DESIGN.md
Contracts: .workflows/design/api-contracts.md

[TASK]
Implement Phase {N} using strict TDD:

1. RED: Write failing tests first
   - Create test files from PLAN.md TDD section
   - Run tests: they MUST fail
   - If tests pass without production code → tests are wrong

2. GREEN: Write minimum production code
   - Create/modify files from PLAN.md Files section
   - Make ALL tests pass
   - No extra code beyond what tests require

3. REFACTOR: Clean up
   - Apply PHP 8.3 standards (readonly, enums, attributes)
   - Remove duplication
   - Run tests again — they MUST still pass

4. VERIFY: Run PLAN.md verification criteria
   - Execute verification commands
   - Confirm expected output

5. SIGNAL: Tell reviewer "Phase {N} ready for review"

[CONSTRAINTS]
- NO production code before tests
- NO skipping test methods listed in PLAN.md
- NO real API calls in tests (use MockHttpClient)
- NO PII/PHI in test fixtures
- Follow coding-style rules (type safety, readonly, enums)
```

### Reviewer Prompt (per Phase)
**Use Agent**: code-reviewer
**Prompt**:
```
[IDENTITY]
You are the Code Reviewer for Phase {N} of the /dev workflow.

[CONTEXT]
Plan: .workflows/plan/{slug}/001-PLAN.md (Phase {N})
Design: .workflows/design/DESIGN.md

[TASK]
Review Phase {N} implementation:

1. SECURITY CHECK:
   - No hardcoded credentials or API keys
   - Input validation on all user data
   - PII/PHI not in logs or error messages
   - Parameterized queries (no SQL injection)
   - Proper auth checks on endpoints

2. QUALITY CHECK:
   - PHP 8.3 standards (type declarations, readonly, enums, attributes)
   - Error handling (Recoverable vs Unrecoverable for handlers)
   - No N+1 queries (eager loading where needed)
   - Single flush per handler/request

3. PLAN COMPLIANCE:
   - All files from Phase {N} created/modified
   - All test methods from Phase {N} TDD section written
   - Verification criteria met
   - No unauthorized scope creep

4. TEST COVERAGE:
   - Happy path tested
   - Edge cases tested (null, zero, negative, boundary)
   - Error cases tested
   - Idempotency tested (for message handlers)
   - No real API calls (MockHttpClient used)

[OUTPUT]
## Phase {N} Review

### Verdict: APPROVED | FIX NEEDED

### Security
| Check | Status | Notes |
|-------|--------|-------|
| No hardcoded credentials | PASS/FAIL | ... |
| Input validation | PASS/FAIL | ... |
| PII/PHI protection | PASS/FAIL | ... |

### Quality
| Check | Status | Notes |
|-------|--------|-------|
| Type safety | PASS/FAIL | ... |
| Error handling | PASS/FAIL | ... |
| No N+1 queries | PASS/FAIL | ... |

### Plan Compliance
| Requirement | Status |
|-------------|--------|
| {file 1} | Created/Modified/Missing |
| {test 1} | Written/Missing |

### Issues to Fix (if FIX NEEDED)
1. [BLOCKING] {issue} — {file:line} — {fix suggestion}
2. [SUGGESTION] {issue} — {file:line} — {fix suggestion}
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] All plan phases implemented with tests
- [ ] All tests passing
- [ ] PROGRESS.md exists with status for each phase
- [ ] Each phase passed reviewer approval

### Good Outcome
- [ ] Zero REPLAN-NEEDED triggered (plan was accurate)
- [ ] Each phase approved in first review round (no FIX NEEDED)
- [ ] Test coverage above 80% for new code
- [ ] All verification criteria from PLAN.md pass

### Excellent Outcome
- [ ] Code follows all coding-style rules without reviewer corrections
- [ ] Idempotency tests present for every message handler
- [ ] Edge cases covered (null, zero, negative, boundary values)
- [ ] No security issues found during review
- [ ] PROGRESS.md shows no deviations from plan

---

## Anti-Patterns

### What to Avoid

1. **Code Before Tests**: Writing production code first, then tests to cover it. This violates the TDD contract and produces tests that verify the implementation rather than the requirements.

2. **Skipping Review**: Moving to next phase without reviewer approval. Per-phase review catches issues early when they are cheap to fix.

3. **Ignoring Plan**: Implementing something different from what PLAN.md specifies without creating REPLAN-NEEDED.md. The plan is the contract — deviations must be documented.

4. **Rubber-Stamp Reviews**: Reviewer approving without actually checking security, quality, and plan compliance. Review checklist exists for a reason.

5. **Fixing Without Re-Review**: Developer fixes issues but does not send back for re-review. The reviewer must verify that fixes are correct and do not introduce new issues.

6. **Scope Creep**: Developer adding features or improvements not in the current phase. Each phase has a defined scope — additional work goes into future phases or separate tasks.

7. **Monolithic Phases**: Implementing multiple plan phases as one large change. Each phase should be a separate implementation-review cycle.

### Warning Signs
- Tests written after production code — TDD violated
- Reviewer always approves in round 1 — reviews not thorough
- PROGRESS.md shows many deviations — plan was inaccurate, should have replanned
- No test failures during Red phase — tests are not asserting correctly
- Review only checks formatting — missing security and logic checks
- Developer and reviewer are the same agent instance — no independent perspective

---

## Example Walkthrough

### Context
Task: "Add Apple Health integration to the wellness-backend"
Plan: 4 phases in `.workflows/plan/apple-health-integration/001-PLAN.md`

### How It Played Out

**Phase 1: Auth Foundation**
```
developer (RED):
  Created: tests/Unit/Service/Integration/AppleHealth/AppleHealthClientTest.php
    - testAuthenticatesWithDeviceToken()
    - testRejectsExpiredToken()
    - testRefreshesTokenBeforeExpiry()
  Created: tests/Functional/Controller/Api/V1/Integration/AppleHealthConnectControllerTest.php
    - testConnectEndpointStoresToken()
    - testConnectEndpointRejectsInvalidToken()
    - testConnectEndpointRequiresAuthentication()
  Run tests: 6 FAILED ✅ (Red confirmed)

developer (GREEN):
  Created: src/Service/Integration/AppleHealth/AppleHealthClient.php
  Modified: src/Entity/IntegrationToken.php (added APPLE_HEALTH type to enum)
  Created: migrations/Version20240115_AddAppleHealthTokenType.php
  Created: src/Controller/Api/V1/Integration/AppleHealthConnectController.php
  Run tests: 6 PASSED ✅ (Green confirmed)

developer (REFACTOR):
  Applied: readonly class for AppleHealthClient
  Applied: PHP 8 attributes for route
  Run tests: 6 PASSED ✅

reviewer (REVIEW):
  Security: PASS (no hardcoded creds, input validated, auth required)
  Quality: PASS (readonly, typed, attributes used)
  Plan compliance: PASS (all files created, all tests written)
  Test coverage: PASS (happy path + error cases)
  Verdict: APPROVED ✅

PROGRESS.md updated: Phase 1 COMPLETED, 0 deviations
```

**Phase 2: Data Mapping**
```
developer (RED): 3 tests written, all FAIL ✅
developer (GREEN): AppleHealthMapper created, tests PASS ✅
developer (REFACTOR): readonly DTO applied ✅

reviewer (REVIEW):
  Quality: FIX NEEDED
    - [BLOCKING] AppleHealthMapper::mapWorkout() missing null check for optional fields
    - [SUGGESTION] Consider backed enum for workout types instead of string constants

developer (FIX): Added null checks + created AppleHealthWorkoutType enum
reviewer (RE-REVIEW): APPROVED ✅

PROGRESS.md updated: Phase 2 COMPLETED, 1 review round with fixes
```

**Phase 3: Sync Pipeline**
```
developer (RED): 4 tests written, all FAIL ✅
developer (GREEN): Handler + webhook created, tests PASS ✅
developer (REFACTOR): Applied RecoverableMessageHandlingException ✅

reviewer (REVIEW):
  Security: FIX NEEDED
    - [BLOCKING] Webhook controller does not validate payload signature
  Test coverage: FIX NEEDED
    - [BLOCKING] Missing idempotency test for AppleHealthSyncHandler

developer (FIX): Added signature validation + idempotency test
reviewer (RE-REVIEW): APPROVED ✅

PROGRESS.md updated: Phase 3 COMPLETED, 1 review round with fixes
```

**Phase 4: Status & Monitoring**
```
developer: 2 tests → code → refactor
reviewer: APPROVED ✅ (first round)

PROGRESS.md updated: Phase 4 COMPLETED, 0 deviations

Final PROGRESS.md:
  Phase 1: COMPLETED (1 review round)
  Phase 2: COMPLETED (2 review rounds)
  Phase 3: COMPLETED (2 review rounds)
  Phase 4: COMPLETED (1 review round)
  Total tests: 15 passed
  Total files: 10 created, 2 modified
  REPLAN-NEEDED: not triggered
```

### Outcome
- All 4 phases implemented with TDD
- Reviewer caught 3 real issues (null check, signature validation, missing idempotency test)
- No replan needed — plan was accurate
- PROGRESS.md provides full audit trail
- Total time: ~8 hours across all phases

---

## Related

- **Previous step**: [3-plan.md](./3-plan.md) — Break design into phases
- **Next step**: [5-review.md](./5-review.md) — Full-scope review of all implemented code
- **Feedback to**: [3-plan.md](./3-plan.md) — via REPLAN-NEEDED.md if significant deviation found
- **Agent files**: [tdd-guide](../../agents/tdd-guide.md), [code-reviewer](../../agents/code-reviewer.md)
- **Skills**: [tdd-workflow](../../skills/tdd/tdd-workflow.md), [test-patterns](../../skills/code-quality/test-patterns.md)
- **Input**: `.workflows/plan/{name}/001-PLAN.md`, `.workflows/design/`
- **Output**: Code files, `.workflows/implement/PROGRESS.md`, optionally `.workflows/implement/REPLAN-NEEDED.md`
