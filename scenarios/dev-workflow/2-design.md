# Dev Workflow: Design Scenario

## Metadata
```yaml
name: dev-design
category: dev-workflow
trigger: Create technical design from research
participants:
  - architecture-advisor (Team Lead, design decisions)
  - technical-writer (API contracts, diagram formatting)
duration: 30-60 minutes
skills:
  - auto:{project}-patterns
  - dev-workflow/design-template
  - architecture/architecture-decision-template
  - documentation/adr-template
team_execution: true
```

## Skills Usage in This Scenario

1. **{project}-patterns**: Both agents apply project-specific conventions for naming, patterns, structure
2. **dev-workflow/design-template**: Lead uses for structuring DESIGN.md output
3. **architecture/architecture-decision-template**: Lead uses for ADR format and decision framework
4. **documentation/adr-template**: Lead uses for individual ADR file format
5. **documentation/api-docs-template**: Contract-writer uses for api-contracts.md format (OpenAPI-compatible)

## Situation

### Description
Second step of the `/dev` workflow. Takes research artifacts and transforms them into a technical design — architecture diagrams, API contracts, ADRs, testing strategy. The Architecture Advisor leads design decisions while the Technical Writer formats contracts. This phase ends with a mandatory human approval gate.

### Common Triggers
- Automatic progression from Research phase
- `/dev --step design` (when research already exists)
- "Design the solution for [feature]"
- "Create technical design from research"

### Wellness/Fitness Tech Context
- **Integration design**: New wearable API integrations need C4 diagrams showing data flow from device to database
- **PII/PHI considerations**: Design must explicitly address where health data is stored, encrypted, transmitted
- **Message flow design**: New async operations need sequence diagrams for RabbitMQ/Kafka flows
- **Billing flow safety**: Payment-related designs require extra ADR scrutiny for idempotency and failure modes
- **Monolith boundaries**: Design must respect existing module boundaries or explicitly propose boundary changes via ADR

---

## Participants

### Required
| Role/Agent | Model | Purpose in Scenario |
|------------|-------|---------------------|
| Lead (architecture-advisor) | opus | Reads research, makes design decisions, creates DESIGN.md + diagrams + ADRs, runs quality gate |
| contract-writer (technical-writer) | sonnet | Reads research + Lead's initial design, produces api-contracts.md with request/response schemas |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| decision-challenger | When design involves risky architectural changes — challenges assumptions before approval |
| security-reviewer | When design touches PII/PHI flows — adds security constraints to design |

---

## Process Flow

### Phase 1: ANALYZE
**Duration**: 10-15 minutes
**Lead**: architecture-advisor (Team Lead)

Steps:
1. Read ALL research artifacts from `.workflows/research/`:
   - RESEARCH.md (summary + open questions)
   - code-analysis.md (classes, dependencies, patterns)
   - data-model.md (entities, relationships)
   - test-coverage.md (existing tests, gaps)
   - architecture-analysis.md (integrations, flows, infrastructure)
2. Identify architectural decisions needed (list each with context)
3. Create C4 diagrams (Mermaid): Context, Container, Component as needed
4. Create DataFlow diagrams (Mermaid) for new data paths
5. Create Sequence diagrams (Mermaid) for key interactions
6. Create ADR(s):
   - If 1-2 decisions: single ADR file covering all
   - If 3+ decisions: one ADR per decision
7. Draft initial DESIGN.md structure

**Output**: Draft DESIGN.md, diagrams.md, adr/*.md

### Phase 2: CONTRACTS (Parallel)
**Duration**: 10-20 minutes
**Lead**: architecture-advisor + contract-writer (parallel)

**Track A — Lead (architecture-advisor)**:
1. Complete DESIGN.md with full design specification
2. Finalize diagrams.md with all Mermaid diagrams
3. Complete ADR(s) with decision rationale and consequences

**Track B — Contract Writer (technical-writer)**:
1. Read research artifacts + Lead's draft DESIGN.md
2. Produce `api-contracts.md` with:
   - New/modified API endpoints (method, path, description)
   - Request/response JSON schemas
   - Error response schemas
   - Authentication requirements
   - Async message contracts (if applicable)

**Output (Track A)**: `.workflows/design/DESIGN.md`, `.workflows/design/diagrams.md`, `.workflows/design/adr/*.md`
**Output (Track B)**: `.workflows/design/api-contracts.md`
**Gate**: Lead waits for contract-writer to complete

### Phase 3: COMPILE
**Duration**: 5-10 minutes
**Lead**: architecture-advisor (Team Lead)

Steps:
1. Read contract-writer's api-contracts.md
2. Verify consistency between DESIGN.md and api-contracts.md
3. Add testing strategy section to DESIGN.md:
   - Unit test approach per component
   - Integration test approach for external APIs
   - Test data strategy
4. Add risks section to DESIGN.md:
   - Technical risks (from research open questions)
   - Integration risks
   - Data migration risks (if applicable)
5. Consolidate all files into final state
6. Shutdown contract-writer teammate

**Output**: Finalized `.workflows/design/` directory

### Phase 4: QUALITY GATE
**Duration**: User-dependent
**Lead**: architecture-advisor (Team Lead)

Steps:
1. Display design summary to user:
   - Key decisions (from ADRs)
   - Architecture diagrams (from diagrams.md)
   - API contracts summary
   - Risks and testing strategy
2. **PAUSE for human approval**
3. User can:
   - Approve: proceed to Plan phase
   - Request changes: Lead modifies design and re-presents
   - Reject: scenario ends, user provides new direction

**Output**: Human approval (or rejection with feedback)
**Gate**: BLOCKING — cannot proceed to Plan without explicit approval

---

## ADR Auto-Count Logic

```
decisions = identify_decisions(research_artifacts)

if len(decisions) <= 2:
    # Single ADR covering all decisions
    create_file("adr/001-{feature-slug}.md")
else:
    # Separate ADR per decision
    for i, decision in enumerate(decisions):
        create_file(f"adr/{i+1:03d}-{decision-slug}.md")
```

### ADR Format
```markdown
# ADR-{NNN}: {Title}

## Status
Proposed

## Context
[What is the issue? Reference research artifacts]

## Decision
[What was decided and why]

## Alternatives Considered
| Option | Pros | Cons |
|--------|------|------|
| A | ... | ... |
| B | ... | ... |

## Consequences
### Positive
- [consequence]

### Negative
- [consequence]

### Risks
- [risk with mitigation]
```

---

## Team-Based Execution

### Team Setup

```
Team Lead creates team:
  team_name: "dev-design-{feature-slug}"
  description: "Design phase for {task description}"
```

### Teammates

| Name | Agent File | subagent_type | Model | Phases |
|------|-----------|---------------|-------|--------|
| lead | architecture-advisor | general-purpose | opus | 1, 2A, 3, 4 |
| contract-writer | technical-writer | technical-writer | sonnet | 2B |

### Phase Execution

```
Phase 1 (ANALYZE):
  Lead reads all research artifacts
  Lead creates draft design, diagrams, ADRs

Phase 2 (CONTRACTS):
  Lead spawns "contract-writer" teammate
  Lead continues finalizing DESIGN.md (Track A)
  contract-writer writes api-contracts.md (Track B) IN PARALLEL
  Lead waits for contract-writer to complete

Phase 3 (COMPILE):
  Lead reads contract-writer output
  Lead consolidates, adds testing strategy + risks
  Lead sends shutdown_request to contract-writer
  Calls TeamDelete to clean up

Phase 4 (QUALITY GATE):
  Lead presents design to user
  PAUSES and waits for approval
```

### Task List Structure

```
1. [lead] Analyze research artifacts and identify decisions
2. [lead] Create architecture diagrams (Mermaid)
3. [lead] Write ADR(s)
4. [contract-writer] Write API contracts
5. [lead] Compile final design with testing strategy and risks
6. [lead] Present design for human approval
```

### Communication Pattern

- **Lead -> contract-writer**: Draft DESIGN.md + research artifacts for context
- **Contract-writer -> Lead**: Completed api-contracts.md
- **Lead -> User**: Quality gate presentation + approval request

---

## Decision Points

### Decision 1: Design Depth
**Question**: How detailed should the design be?
**Options**:
- A: High-level (C4 Context + key decisions only) — for small, well-understood features
- B: Standard (C4 Context + Component + Sequence + ADRs + contracts) — default
- C: Detailed (all above + data migration plan + rollback strategy) — for high-risk changes

**Recommended approach**: B for most features. C when touching billing, PII/PHI, or data migrations.

### Decision 2: ADR Granularity
**Question**: How many ADR files to create?
**Options**:
- A: Single ADR for 1-2 decisions — keeps it simple
- B: One ADR per decision for 3+ decisions — better traceability
- C: Always one per decision regardless of count — maximum documentation

**Recommended approach**: Auto-count logic (A for 1-2, B for 3+)

### Decision 3: Contract Format
**Question**: What format for API contracts?
**Options**:
- A: Markdown tables with JSON examples — readable, lightweight
- B: OpenAPI YAML snippets — machine-readable, Stoplight-compatible
- C: Both — Markdown for review, OpenAPI for tooling

**Recommended approach**: A for internal review. C if API will be consumed by external teams.

---

## Prompts Sequence

### Step 1: Research Analysis (Lead)
**Use Agent**: architecture-advisor
**Prompt**:
```
[IDENTITY]
You are the Architecture Advisor leading the Design phase of /dev workflow.

[CONTEXT]
Task: {{task_description}}
Research artifacts: .workflows/research/

[TASK]
1. Read ALL files in .workflows/research/
2. Identify every architectural decision needed
3. For each decision, note: context, options, trade-offs
4. Create Mermaid diagrams:
   - C4 Context diagram (system + external actors)
   - C4 Component diagram (affected modules)
   - Sequence diagram (key interaction flows)
   - Data flow diagram (new data paths)
5. Create ADR(s) — auto-count: 1-2 decisions = single ADR, 3+ = per decision
6. Write DESIGN.md with all sections

[OUTPUT]
Write to .workflows/design/:
- DESIGN.md
- diagrams.md
- adr/001-{slug}.md (or multiple)
```

### Step 2: API Contracts (Contract Writer)
**Use Agent**: technical-writer
**Prompt**:
```
[IDENTITY]
You are the Technical Writer producing API contracts for the Design phase.

[CONTEXT]
Task: {{task_description}}
Research: .workflows/research/
Design draft: .workflows/design/DESIGN.md

[TASK]
Read research artifacts and design draft. Produce api-contracts.md:
1. List all new/modified API endpoints
2. For each endpoint: method, path, auth, request schema, response schema, errors
3. For async operations: message contract (topic/queue, payload schema, idempotency key)
4. Use JSON examples for schemas
5. Note breaking changes if any

[OUTPUT FORMAT]
# API Contracts: {{feature_name}}

## REST Endpoints

### POST /api/v1/{resource}
**Auth**: Bearer token (ROLE_USER)
**Request**:
```json
{ ... }
```
**Response 201**:
```json
{ ... }
```
**Errors**: 400 (validation), 401 (unauthorized), 409 (conflict)

## Async Messages

### {queue/topic}.{action}
**Transport**: RabbitMQ|Kafka
**Payload**:
```json
{ ... }
```
**Idempotency**: {key field}
```

### Step 3: Quality Gate (Lead)
**Use Agent**: architecture-advisor
**Prompt**:
```
[TASK]
Present design summary for human approval.

Display:
1. Key Decisions (from ADRs) — one-line each
2. Architecture Diagrams (render Mermaid)
3. API Contracts Summary (endpoints list)
4. Testing Strategy (bullet points)
5. Risks (bullet points)

Then ASK: "Approve this design to proceed to Planning? (approve/change/reject)"

WAIT for user response. Do NOT proceed automatically.
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] DESIGN.md exists with architecture overview and component design
- [ ] At least one Mermaid diagram in diagrams.md
- [ ] At least one ADR in adr/ directory
- [ ] api-contracts.md exists with endpoint specifications

### Good Outcome
- [ ] Multiple diagram types (C4, Sequence, DataFlow)
- [ ] ADRs include alternatives considered with trade-offs
- [ ] API contracts include request/response schemas with examples
- [ ] Testing strategy covers unit, integration, and functional levels
- [ ] Risk section identifies at least 2 risks with mitigations

### Excellent Outcome
- [ ] Diagrams reference specific classes from research
- [ ] ADR consequences map to specific implementation phases
- [ ] Contracts are OpenAPI-compatible
- [ ] Design explicitly addresses research open questions
- [ ] Human approval obtained on first presentation (no revisions needed)

---

## Anti-Patterns

### What to Avoid

1. **Design Without Research**: Jumping to design without reading research artifacts. Research exists to constrain the design space — ignoring it leads to solutions that conflict with existing architecture.

2. **Over-Engineering**: Creating C4 diagrams down to class level for a feature that adds one endpoint. Match design depth to feature complexity.

3. **Skipping Quality Gate**: Auto-approving design because "it looks good." Human approval is the checkpoint between design and implementation — it catches business misunderstandings that code review cannot.

4. **Contract Without Design**: Writing API contracts before the architecture is decided. Contracts should flow from design decisions, not drive them.

5. **Vague ADRs**: ADRs that say "we decided to use X" without documenting alternatives or consequences. The value of ADRs is the reasoning, not the conclusion.

6. **Monolithic DESIGN.md**: A single 500-line file instead of structured artifacts. Use separate files for diagrams, contracts, and ADRs.

### Warning Signs
- DESIGN.md has no references to research artifacts — design is disconnected from analysis
- Zero Mermaid diagrams — architecture not visualized
- ADR "Alternatives Considered" section is empty — decision not justified
- API contracts have no error schemas — happy-path-only thinking
- No testing strategy — implementation will lack test guidance
- Quality gate skipped or auto-approved — defeats the purpose

---

## Example Walkthrough

### Context
Task: "Add Apple Health integration to the wellness-backend"
Research completed: `.workflows/research/` has 5 files documenting existing Garmin/Fitbit patterns.

### How It Played Out

**Phase 1 (ANALYZE)**:
```
Lead reads research artifacts:
  - Existing pattern: Client + Mapper + SyncHandler per provider
  - OAuth2 token flow for Garmin/Fitbit
  - Separate RabbitMQ queues per provider
  - Open question: Apple Health uses device-level auth, not OAuth2

Decisions identified:
  1. Auth strategy: device-token vs OAuth2 (differs from existing pattern)
  2. Sync approach: push (HealthKit background delivery) vs pull (periodic)
  3. Data mapping: Apple Health data types → existing entities

Diagrams created:
  - C4 Context: iOS App → Apple HealthKit → Backend → Database
  - Sequence: HealthKit background delivery → webhook → handler → DB
  - Data Flow: HealthKit workout → AppleHealthMapper → Workout entity
```

**Phase 2 (CONTRACTS — parallel)**:
```
Track A (Lead):
  DESIGN.md:
    - Component: AppleHealthClient, AppleHealthMapper, AppleHealthSyncHandler
    - Auth: device-level token (stored in IntegrationToken, type=APPLE_HEALTH)
    - Sync: push-based via HealthKit background delivery
    - Queue: apple-health.sync (follows existing convention)

  ADRs (3 decisions → 3 files):
    - adr/001-apple-health-auth-strategy.md
    - adr/002-apple-health-sync-approach.md
    - adr/003-apple-health-data-mapping.md

Track B (contract-writer):
  api-contracts.md:
    - POST /api/v1/integrations/apple-health/connect
    - POST /api/v1/integrations/apple-health/webhook
    - GET /api/v1/integrations/apple-health/status
    - Message: apple-health.sync payload schema
```

**Phase 3 (COMPILE)**:
```
Lead consolidates:
  - Contracts consistent with DESIGN.md ✅
  - Added testing strategy:
    - Unit: AppleHealthMapper with fixture data
    - Integration: MockHttpClient for HealthKit API
    - Functional: webhook endpoint with signed payloads
  - Added risks:
    - Apple HealthKit API changes without notice (mitigation: version pinning)
    - Background delivery unreliable on some iOS versions (mitigation: manual sync fallback)
```

**Phase 4 (QUALITY GATE)**:
```
Lead presents to user:
  Key Decisions:
    1. Device-token auth (not OAuth2) — Apple Health is device-level
    2. Push-based sync via HealthKit background delivery
    3. Map to existing Workout/HealthMetric entities (no new tables)

  User response: "Approve, but add manual sync endpoint as fallback"
  Lead updates DESIGN.md + api-contracts.md → approved
```

### Outcome
- Clear architecture with 3 documented decisions
- API contracts ready for implementation planning
- Risks identified early (background delivery reliability)
- User input captured before implementation starts
- Total time: ~45 minutes

---

## Related

- **Previous step**: [1-research.md](./1-research.md) — Gather AS-IS information
- **Next step**: [3-plan.md](./3-plan.md) — Break design into implementation phases
- **Agent files**: [architecture-advisor](../../agents/architecture-advisor.md), [technical-writer](../../agents/technical-writer.md)
- **Skills**: [architecture-decision-template](../../skills/architecture/architecture-decision-template.md), [adr-template](../../skills/documentation/adr-template.md)
- **Input**: `.workflows/research/` directory
- **Output**: `.workflows/design/` directory (DESIGN.md, diagrams.md, api-contracts.md, adr/*.md)
