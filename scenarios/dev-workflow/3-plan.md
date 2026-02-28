# Dev Workflow: Plan Scenario

## Metadata
```yaml
name: dev-plan
category: dev-workflow
trigger: Break design into implementation phases
participants:
  - planner (single agent)
duration: 15-30 minutes
skills:
  - auto:{project}-patterns
  - planning/planning-template
  - planning/vertical-slicing
  - planning/epic-breakdown
  - risk-management/risk-assessment
team_execution: false
```

## Skills Usage in This Scenario

1. **{project}-patterns**: Planner applies project-specific conventions for file structure, naming, patterns
2. **planning/planning-template**: Core template for PLAN.md structure
3. **planning/vertical-slicing**: Ensures each phase is independently deployable and testable
4. **planning/epic-breakdown**: Breaks complex features into manageable implementation units
5. **risk-management/risk-assessment**: Adds risk assessment per phase and overall

## Situation

### Description
Third step of the `/dev` workflow. Takes research + design artifacts and breaks them into ordered, independently deployable implementation phases. Each phase includes specific files to create/modify, TDD approach (what tests to write first), dependencies on prior phases, and verification criteria. This is a single-agent scenario — the Planner works alone, synthesizing all prior artifacts.

### Common Triggers
- Automatic progression from Design phase (after human approval)
- `/dev --step plan` (when research + design already exist)
- "Break this design into implementation phases"
- "Plan the implementation for [feature]"

### Wellness/Fitness Tech Context
- **Vertical slicing for integrations**: Each integration phase should deliver a working (if partial) integration — e.g., Phase 1: auth + token storage, Phase 2: data sync, Phase 3: webhook handling
- **Health data incrementality**: Phases that touch health data entities should be deployable without breaking existing Garmin/Fitbit flows
- **Billing safety**: Payment-related phases require explicit rollback verification criteria
- **Message handler isolation**: New RabbitMQ/Kafka handlers should be deployable independently from the controllers that trigger them
- **Test-first planning**: Each phase explicitly defines which tests to write before code

---

## Participants

### Required
| Role/Agent | Model | Purpose in Scenario |
|------------|-------|---------------------|
| Planner | opus | Reads research + design, creates phased implementation plan with vertical slicing |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| None | This is a single-agent scenario. Planner works alone. |

---

## Process Flow

### Phase 1: VALIDATE
**Duration**: 2-3 minutes
**Lead**: planner

Steps:
1. Verify `.workflows/research/RESEARCH.md` exists
2. Verify `.workflows/design/DESIGN.md` exists
3. Verify `.workflows/design/api-contracts.md` exists
4. Verify at least one ADR exists in `.workflows/design/adr/`
5. If any missing: report which artifacts are absent, suggest running prior steps

**Output**: Validation pass/fail

### Phase 2: SYNTHESIZE
**Duration**: 5-10 minutes
**Lead**: planner

Steps:
1. Read ALL artifacts from `.workflows/research/`:
   - RESEARCH.md, code-analysis.md, data-model.md, test-coverage.md, architecture-analysis.md
2. Read ALL artifacts from `.workflows/design/`:
   - DESIGN.md, diagrams.md, api-contracts.md, adr/*.md
3. Identify all components to implement (from DESIGN.md)
4. Map dependencies between components
5. Identify which components can be implemented independently
6. Apply vertical slicing: group components into phases where each phase delivers a deployable increment

**Output**: Component dependency graph + phase grouping

### Phase 3: PLAN
**Duration**: 10-15 minutes
**Lead**: planner

Steps:
1. Create `.workflows/plan/{feature-slug}/001-PLAN.md` with:
   - Overview (feature summary, total phases, estimated effort)
   - Phase-by-phase breakdown
   - Execution notes
   - Risk assessment
2. For each phase, specify:
   - **Files**: exact files to create or modify (with paths)
   - **TDD**: which tests to write first (test class, test methods, assertions)
   - **Verification**: how to confirm the phase works (run commands, expected output)
   - **Dependencies**: which prior phases must be complete
   - **Estimated effort**: time range
3. Ensure each phase is independently deployable:
   - Phase N works even if Phase N+1 is never implemented
   - No phase leaves the system in a broken state
4. Add execution notes:
   - Suggested review points (which phases benefit from early review)
   - Parallelization opportunities (which phases can run concurrently)
   - Feature flag recommendations (if applicable)
5. Add risk assessment:
   - Per-phase risks
   - Overall risks
   - Mitigation strategies

**Output**: `.workflows/plan/{feature-slug}/001-PLAN.md`

---

## PLAN.md Format

```markdown
# Implementation Plan: {Feature Name}

## Overview
- **Feature**: {description}
- **Phases**: {N} phases
- **Estimated Total**: {time range}
- **Design**: .workflows/design/DESIGN.md
- **Research**: .workflows/research/RESEARCH.md

---

## Phase 1: {Phase Name}
**Estimated**: {time}
**Dependencies**: None (first phase)

### Files
| Action | File Path | Description |
|--------|-----------|-------------|
| CREATE | src/Service/{Name}.php | {what it does} |
| MODIFY | src/Entity/{Name}.php | {what changes} |
| CREATE | migrations/Version{N}.php | {schema change} |

### TDD Approach
**Test First**:
```php
// tests/Unit/Service/{Name}Test.php
public function testMethodName(): void
{
    // Arrange: {setup}
    // Act: {action}
    // Assert: {expected outcome}
}
```

**Tests to Write**:
1. `test{HappyPath}` — {description}
2. `test{EdgeCase}` — {description}
3. `test{ErrorCase}` — {description}

### Verification
```bash
# Run tests
php bin/phpunit tests/Unit/Service/{Name}Test.php

# Verify migration
php bin/console doctrine:schema:validate

# Expected: all tests pass, schema valid
```

### Notes
- {important implementation detail}
- {gotcha from research}

---

## Phase 2: {Phase Name}
**Estimated**: {time}
**Dependencies**: Phase 1 (requires {specific artifact})

### Files
...

### TDD Approach
...

### Verification
...

---

## Execution Notes

### Review Points
- After Phase {N}: review {what} because {why}
- After Phase {N}: review {what} because {why}

### Parallelization
- Phases {X} and {Y} can run in parallel (no shared dependencies)

### Feature Flags
- {flag name}: controls {what}, remove after {when}

---

## Risk Assessment

### Per-Phase Risks
| Phase | Risk | Impact | Mitigation |
|-------|------|--------|------------|
| 1 | {risk} | {impact} | {mitigation} |

### Overall Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {risk} | Low/Medium/High | {impact} | {mitigation} |
```

---

## Decision Points

### Decision 1: Phase Granularity
**Question**: How fine-grained should phases be?
**Options**:
- A: Coarse (2-3 large phases) — less overhead, but harder to verify incrementally
- B: Standard (4-6 phases) — good balance of incrementality and overhead (default)
- C: Fine (7+ phases) — maximum incrementality, but more coordination overhead

**Recommended approach**: B for most features. C for high-risk changes touching billing or health data.

### Decision 2: TDD Depth
**Question**: How detailed should the TDD section be?
**Options**:
- A: Test class names + method names only — leaves details to implementer
- B: Test names + assertion descriptions — guides the implementation (default)
- C: Full test skeletons with arrange/act/assert — maximum guidance

**Recommended approach**: B for experienced teams. C for new team members or unfamiliar areas.

### Decision 3: Dependency Strategy
**Question**: How to handle cross-phase dependencies?
**Options**:
- A: Strict linear — each phase depends on the previous
- B: DAG — phases form a dependency graph with parallelization opportunities (default)
- C: Independent — each phase works in complete isolation

**Recommended approach**: B for most features. A when phases are naturally sequential.

---

## Prompts Sequence

### Step 1: Validation
**Use Agent**: planner
**Prompt**:
```
[IDENTITY]
You are the Planner for the /dev workflow.

[TASK]
Validate that required artifacts exist for planning:

Required:
- .workflows/research/RESEARCH.md
- .workflows/design/DESIGN.md
- .workflows/design/api-contracts.md
- .workflows/design/adr/*.md (at least one)

Check each file. Report status.

If all exist: proceed to planning.
If any missing: report which are missing and suggest running the prior step.
```

### Step 2: Synthesis + Plan Creation
**Use Agent**: planner
**Prompt**:
```
[IDENTITY]
You are the Planner creating an implementation plan for the /dev workflow.

[CONTEXT]
Task: {{task_description}}
Research: .workflows/research/ (all files)
Design: .workflows/design/ (all files)

[SKILLS]
Apply:
- planning/vertical-slicing: each phase independently deployable
- planning/epic-breakdown: manageable implementation units
- risk-management/risk-assessment: per-phase and overall risks

[TASK]
1. Read ALL artifacts from research/ and design/
2. Identify all components from DESIGN.md
3. Map dependencies between components
4. Apply vertical slicing to create phases
5. For each phase specify: files, TDD approach, verification, dependencies
6. Add execution notes (review points, parallelization, feature flags)
7. Add risk assessment

Write to: .workflows/plan/{feature-slug}/001-PLAN.md

[CONSTRAINTS]
- Each phase MUST be independently deployable
- Each phase MUST have TDD approach (tests before code)
- Each phase MUST have verification criteria (runnable commands)
- File paths MUST be exact (src/Service/..., not "the service file")
- Phases MUST reference specific design decisions from ADRs
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] PLAN.md exists in `.workflows/plan/{feature-slug}/`
- [ ] At least 3 phases defined
- [ ] Each phase has files, TDD approach, and verification sections
- [ ] Dependencies between phases are explicit

### Good Outcome
- [ ] Each phase is independently deployable (vertical slicing applied)
- [ ] TDD sections include test method names and assertion descriptions
- [ ] Verification sections include runnable commands
- [ ] Risk assessment includes per-phase and overall risks
- [ ] Execution notes include review points

### Excellent Outcome
- [ ] Parallelization opportunities identified
- [ ] Feature flag recommendations included where appropriate
- [ ] Time estimates per phase based on complexity
- [ ] Plan references specific research findings and design decisions
- [ ] Phases ordered to deliver highest-value functionality first

---

## Anti-Patterns

### What to Avoid

1. **Horizontal Slicing**: Creating phases like "Phase 1: Database layer", "Phase 2: Service layer", "Phase 3: Controller layer." Each phase should deliver a vertical slice — from endpoint to database for one piece of functionality.

2. **Missing TDD Section**: Leaving "tests" as an afterthought. Every phase MUST specify which tests to write FIRST. This is the TDD guide's contract for the Implement step.

3. **Vague File References**: Writing "update the service" instead of `src/Service/AppleHealthSyncService.php`. The Implement step needs exact file paths.

4. **All-or-Nothing Phases**: Phases that only work if ALL subsequent phases are also complete. Each phase must leave the system in a working state.

5. **Ignoring Research Findings**: Creating a plan that contradicts research artifacts (e.g., planning OAuth2 when research showed Apple Health uses device tokens).

6. **No Verification Criteria**: Phases without runnable verification commands. The implementer needs to know "how do I know Phase N is done?"

### Warning Signs
- Phase 1 is "set up the database" and Phase 2 is "write the services" — horizontal slicing detected
- No `php bin/phpunit` commands in verification sections — tests not planned
- File paths are relative or generic ("the controller") — not actionable
- Zero reference to research or design artifacts — plan is disconnected
- All phases are estimated at the same duration — not thinking about complexity
- Risk assessment is empty or says "no risks" — not looking hard enough

---

## Example Walkthrough

### Context
Task: "Add Apple Health integration to the wellness-backend"
Research and Design completed. Design approved with 3 ADRs: device-token auth, push-based sync, existing entity mapping.

### How It Played Out

**Phase 1 (VALIDATE)**:
```
Checking artifacts:
  .workflows/research/RESEARCH.md ✅
  .workflows/design/DESIGN.md ✅
  .workflows/design/api-contracts.md ✅
  .workflows/design/adr/001-apple-health-auth-strategy.md ✅
  .workflows/design/adr/002-apple-health-sync-approach.md ✅
  .workflows/design/adr/003-apple-health-data-mapping.md ✅
All artifacts present. Proceeding to planning.
```

**Phase 2 (SYNTHESIZE)**:
```
Components identified from DESIGN.md:
  1. AppleHealthClient (API communication)
  2. AppleHealthMapper (data transformation)
  3. AppleHealthSyncHandler (message handler)
  4. IntegrationToken extension (auth storage)
  5. Webhook controller (incoming data)
  6. Connect endpoint (initial setup)
  7. Status endpoint (health check)

Dependency graph:
  IntegrationToken extension → AppleHealthClient → AppleHealthMapper
  AppleHealthMapper → AppleHealthSyncHandler
  AppleHealthClient → Connect endpoint
  AppleHealthSyncHandler → Webhook controller
  Connect endpoint, Status endpoint (independent)

Vertical slices:
  Phase 1: Auth foundation (token + client + connect endpoint)
  Phase 2: Data mapping (mapper + entity handling)
  Phase 3: Sync pipeline (handler + queue + webhook)
  Phase 4: Status + monitoring (status endpoint + health checks)
```

**Phase 3 (PLAN)**:
```
Created: .workflows/plan/apple-health-integration/001-PLAN.md

Phase 1: Auth Foundation (2-3 hours)
  Files:
    CREATE src/Service/Integration/AppleHealth/AppleHealthClient.php
    MODIFY src/Entity/IntegrationToken.php (add APPLE_HEALTH type)
    CREATE migrations/Version20240115_AddAppleHealthTokenType.php
    CREATE src/Controller/Api/V1/Integration/AppleHealthConnectController.php
  TDD:
    - testAppleHealthClientAuthenticatesWithDeviceToken
    - testIntegrationTokenSupportsAppleHealthType
    - testConnectEndpointStoresToken
    - testConnectEndpointRejectsInvalidToken
  Verification:
    php bin/phpunit tests/Unit/Service/Integration/AppleHealth/
    php bin/console doctrine:schema:validate
    curl -X POST /api/v1/integrations/apple-health/connect

Phase 2: Data Mapping (2-3 hours)
  Dependencies: Phase 1
  Files:
    CREATE src/Service/Integration/AppleHealth/AppleHealthMapper.php
    CREATE src/DTO/AppleHealth/AppleHealthWorkoutData.php
  TDD:
    - testMapperConvertsHealthKitWorkoutToEntity
    - testMapperHandlesUnknownWorkoutType
    - testMapperPreservesHealthMetricPrecision
  Verification:
    php bin/phpunit tests/Unit/Service/Integration/AppleHealth/AppleHealthMapperTest.php

Phase 3: Sync Pipeline (3-4 hours)
  Dependencies: Phase 1, Phase 2
  Files:
    CREATE src/Message/AppleHealthSyncMessage.php
    CREATE src/MessageHandler/AppleHealthSyncHandler.php
    CREATE src/Controller/Api/V1/Integration/AppleHealthWebhookController.php
    MODIFY config/packages/messenger.yaml (add apple-health.sync queue)
  TDD:
    - testSyncHandlerIsIdempotent
    - testSyncHandlerProcessesWorkoutData
    - testSyncHandlerRetriesOnTransientError
    - testWebhookRejectsUnsignedPayload
  Verification:
    php bin/phpunit tests/Unit/MessageHandler/AppleHealthSyncHandlerTest.php
    php bin/console messenger:consume apple-health.sync --limit=1

Phase 4: Status & Monitoring (1-2 hours)
  Dependencies: Phase 1
  Files:
    CREATE src/Controller/Api/V1/Integration/AppleHealthStatusController.php
  TDD:
    - testStatusEndpointReturnsConnectedWhenTokenValid
    - testStatusEndpointReturnsDisconnectedWhenNoToken
  Verification:
    php bin/phpunit tests/Functional/Controller/Api/V1/Integration/AppleHealthStatusControllerTest.php

Execution Notes:
  - Review after Phase 1: verify auth approach with team
  - Phases 2 and 4 can run in parallel (no shared dependencies)
  - Feature flag: APPLE_HEALTH_ENABLED, remove after stable release

Risk Assessment:
  | Phase 3 | HealthKit background delivery unreliable | Medium | Manual sync fallback endpoint |
  | Phase 1 | Apple token format changes | Low | Version-pin HealthKit API |
  | Overall | No Apple developer account for testing | High | Set up sandbox environment first |
```

### Outcome
- 4 phases, each independently deployable
- TDD approach specified for every phase (16 test methods total)
- Verification criteria with runnable commands
- Parallelization identified: Phases 2 and 4 concurrent
- High-risk item surfaced: need Apple developer sandbox
- Total planning time: ~20 minutes

---

## Related

- **Previous step**: [2-design.md](./2-design.md) — Create technical design
- **Next step**: [4-implement.md](./4-implement.md) — Implement code phase by phase
- **Agent file**: [planner](../../agents/planner.md)
- **Skills**: [planning-template](../../skills/planning/planning-template.md), [vertical-slicing](../../skills/planning/vertical-slicing.md), [epic-breakdown](../../skills/planning/epic-breakdown.md), [risk-assessment](../../skills/risk-management/risk-assessment.md)
- **Input**: `.workflows/research/`, `.workflows/design/`
- **Output**: `.workflows/plan/{feature-slug}/001-PLAN.md`
- **Feedback loop**: If Implement step discovers plan issues, it creates `REPLAN-NEEDED.md` and control returns here
