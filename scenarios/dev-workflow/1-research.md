# Dev Workflow: Research Scenario

## Metadata
```yaml
name: dev-research
category: dev-workflow
trigger: Analyze codebase for task implementation
participants:
  - researcher (Team Lead, orchestrator)
  - codebase-doc-collector (code scanner — research mode)
  - architecture-doc-collector (architecture scanner — research mode)
duration: 15-30 minutes
skills:
  - auto:{project}-patterns
  - dev-workflow/research-template
team_execution: true
```

## Skills Usage in This Scenario

1. **{project}-patterns**: All agents apply project-specific conventions for naming, patterns, structure
2. **dev-workflow/research-template**: Lead uses for structuring RESEARCH.md output
3. **documentation/codemap-template**: Code scanner adapts for AS-IS analysis (research mode override)
4. **documentation/system-profile-template**: Arch scanner adapts for AS-IS analysis (research mode override)

## Situation

### Description
First step of the `/dev` workflow. Before designing or implementing anything, the team gathers comprehensive AS-IS information about the system areas affected by the task. The Lead decomposes the task into research areas, spawns two scanner agents in parallel, and aggregates their findings into a unified research artifact. This phase produces NO proposals, NO solutions, NO recommendations — only descriptions of the current state.

### Common Triggers
- `/dev "Add Apple Health integration"` (auto-starts with research)
- `/dev --step research "Refactor billing module"`
- "I need to understand the codebase before implementing this feature"
- "What does the current system look like for this area?"
- "Analyze the codebase for [feature]"

### Wellness/Fitness Tech Context
- **Monolith complexity**: Research must map boundaries within a large PHP/Symfony codebase before touching code
- **Integration landscape**: Multiple wearable APIs (Garmin, Fitbit, Apple Health) — research must discover existing integration patterns
- **Health data flows**: PII/PHI handling patterns must be documented AS-IS before any changes
- **Billing complexity**: Payment provider integrations (Apple App Store, Google Play) require careful mapping before modifications
- **Message infrastructure**: RabbitMQ/Kafka topology must be understood before adding new message flows

---

## Participants

### Required
| Role/Agent | Model | Purpose in Scenario |
|------------|-------|---------------------|
| Lead (researcher) | opus | Decomposes task into research areas, orchestrates scanners, aggregates results into RESEARCH.md |
| code-scanner (codebase-doc-collector) | sonnet | Scans code structure: controllers, services, entities, handlers, tests — produces code-analysis.md, data-model.md, test-coverage.md |
| arch-scanner (architecture-doc-collector) | sonnet | Scans architecture: integrations, data flows, infrastructure patterns — produces architecture-analysis.md |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| security-reviewer | When task involves PII/PHI, authentication, or billing flows — adds security-posture.md to research output |

---

## Process Flow

### Phase 1: DECOMPOSE
**Duration**: 3-5 minutes
**Lead**: researcher (Team Lead)

Steps:
1. Read the task description provided by user
2. Identify 1-4 research areas relevant to the task (e.g., "API controllers", "data model", "message handlers", "external integrations")
3. Create structured task list for scanner agents
4. Determine which research areas map to code-scanner vs arch-scanner
5. Prepare research-mode prompt overrides for both scanners

**Output**: Task assignments for both scanner agents

### Phase 2: SCAN (Parallel)
**Duration**: 10-20 minutes
**Lead**: code-scanner + arch-scanner (parallel execution)

**Track A — Code Scanner (codebase-doc-collector in research mode)**:
1. Receive research areas from Lead
2. Scan relevant directories, classes, and configurations
3. Produce `code-analysis.md` — affected classes, methods, dependencies, coupling points
4. Produce `data-model.md` — entities, relationships, migrations history for affected area
5. Produce `test-coverage.md` — existing tests, coverage gaps, test patterns used

**Track B — Architecture Scanner (architecture-doc-collector in research mode)**:
1. Receive research areas from Lead
2. Scan integration points, infrastructure configs, message flows
3. Produce `architecture-analysis.md` — system boundaries, external dependencies, data flow diagrams (Mermaid), infrastructure constraints

**Output (Track A)**: `.workflows/research/code-analysis.md`, `.workflows/research/data-model.md`, `.workflows/research/test-coverage.md`
**Output (Track B)**: `.workflows/research/architecture-analysis.md`
**Gate**: Lead waits for both tracks to complete

### Phase 3: AGGREGATE
**Duration**: 5-10 minutes
**Lead**: researcher (Team Lead)

Steps:
1. Read all scanner outputs (4 files)
2. Identify cross-cutting concerns (patterns that span code + architecture)
3. Identify open questions that require human input
4. Create `RESEARCH.md` with:
   - Summary of findings per research area
   - Cross-cutting concerns section
   - Open questions for the user
   - Cross-references to detailed files
5. Shutdown scanner teammates

**Output**: `.workflows/research/RESEARCH.md`

---

## Research Mode Prompt Overrides

### Code Scanner — Research Mode
```
[MODE OVERRIDE: RESEARCH]
You are operating in RESEARCH mode, NOT documentation mode.

CRITICAL CONSTRAINTS:
- Describe ONLY what exists (AS-IS). No proposals, no improvements, no suggestions.
- Output format: factual inventory with code references
- Do NOT generate codemaps or cache files
- Do NOT create docs/ directory artifacts
- Write findings to .workflows/research/ directory

[FOCUS AREAS]
For each research area assigned by Lead:
1. List all relevant classes with file paths
2. Map dependencies (what calls what)
3. Identify patterns used (Repository, Service, Handler, etc.)
4. Note coupling points (shared dependencies, circular refs)
5. Document existing test coverage for affected code

[OUTPUT FILES]
- code-analysis.md: Classes, dependencies, patterns, coupling
- data-model.md: Entities, relationships, field types, indexes
- test-coverage.md: Existing tests, patterns, gaps (factual, not prescriptive)

[FORMAT]
Use tables and code references. No prose. Every claim must have a file:line reference.
```

### Architecture Scanner — Research Mode
```
[MODE OVERRIDE: RESEARCH]
You are operating in RESEARCH mode, NOT documentation mode.

CRITICAL CONSTRAINTS:
- Describe ONLY what exists (AS-IS). No proposals, no improvements, no suggestions.
- Output format: diagrams + tables with references
- Do NOT generate system profiles or integration catalogs
- Write findings to .workflows/research/ directory

[FOCUS AREAS]
For each research area assigned by Lead:
1. Map external integration points (APIs, webhooks, callbacks)
2. Document message flows (RabbitMQ queues, Kafka topics)
3. Identify infrastructure constraints (config, env vars, Docker)
4. Trace data flow end-to-end for the affected area (Mermaid diagrams)
5. Note authentication/authorization patterns in the area

[OUTPUT FILE]
- architecture-analysis.md: Integrations, message flows, infra constraints, data flow diagrams

[FORMAT]
Mermaid diagrams for flows. Tables for inventories. No prose. Reference config files and env vars.
```

---

## Team-Based Execution

### Team Setup

```
Team Lead creates team:
  team_name: "dev-research-{feature-slug}"
  description: "Research phase for {task description}"
```

### Teammates

| Name | Agent File | subagent_type | Model | Output |
|------|-----------|---------------|-------|--------|
| lead | researcher | general-purpose | opus | RESEARCH.md |
| code-scanner | codebase-doc-collector | codebase-doc-collector | sonnet | code-analysis.md, data-model.md, test-coverage.md |
| arch-scanner | architecture-doc-collector | architecture-doc-collector | sonnet | architecture-analysis.md |

### Phase Execution

```
Phase 1 (DECOMPOSE):
  Lead reads task, identifies research areas
  Creates task assignments for scanners

Phase 2 (SCAN):
  Lead spawns "code-scanner" and "arch-scanner" IN PARALLEL
  Both receive research-mode prompt overrides
  Both write to .workflows/research/ (no write conflicts — different files)
  Lead waits for BOTH to complete

Phase 3 (AGGREGATE):
  Lead reads all scanner outputs
  Lead creates RESEARCH.md with cross-references
  Lead sends shutdown_request to both scanners
  Calls TeamDelete to clean up
```

### Task List Structure

```
1. [lead] Decompose task into research areas
2. [code-scanner] Scan code: classes, dependencies, tests
3. [arch-scanner] Scan architecture: integrations, flows, infra
4. [lead] Aggregate findings into RESEARCH.md
```

### Communication Pattern

- **Lead -> scanners**: Research area assignments with mode overrides
- **Scanners -> Lead**: Completion reports with file paths
- **code-scanner <-> arch-scanner**: No direct communication; all coordination through Lead

---

## Decision Points

### Decision 1: Research Scope
**Question**: How many research areas to investigate?
**Options**:
- A: Narrow (1-2 areas) — for well-understood tasks with clear scope
- B: Medium (3-4 areas) — default for most features
- C: Wide (5+ areas) — for cross-cutting changes or unfamiliar codebase

**Recommended approach**: B for most tasks. A only when developer has strong existing knowledge.

### Decision 2: Scanner Depth
**Question**: How deep should scanners go?
**Options**:
- A: Surface scan — list classes and relationships only
- B: Standard scan — classes, dependencies, patterns, coverage (default)
- C: Deep scan — include git history, change frequency, complexity metrics

**Recommended approach**: B for standard features, C for high-risk refactoring

---

## Prompts Sequence

### Step 1: Task Decomposition (Lead)
**Use Agent**: researcher
**Prompt**:
```
[IDENTITY]
You are the Research Lead for the /dev workflow.

[TASK]
Task: {{task_description}}
Project: {{project_path}}

Decompose this task into 1-4 research areas. For each area, specify:
1. Area name (e.g., "Workout API Controllers", "Subscription Data Model")
2. What to look for (specific classes, patterns, configs)
3. Assignment: code-scanner or arch-scanner

[OUTPUT]
## Research Plan

### Task Understanding
[1-2 sentences: what this task is about]

### Research Areas
| # | Area | Scanner | What to Look For |
|---|------|---------|-----------------|
| 1 | [name] | [code/arch] | [specifics] |

### Scanner Assignments
**code-scanner**: Areas [list], focus on [specifics]
**arch-scanner**: Areas [list], focus on [specifics]
```

### Step 2: Parallel Scanning (code-scanner + arch-scanner)
**Use Agents**: codebase-doc-collector (research mode), architecture-doc-collector (research mode)
**Prompts**: See Research Mode Prompt Overrides section above

### Step 3: Aggregation (Lead)
**Use Agent**: researcher
**Prompt**:
```
[TASK]
Read all research outputs from .workflows/research/:
- code-analysis.md
- data-model.md
- test-coverage.md
- architecture-analysis.md

Create RESEARCH.md that:
1. Summarizes findings per research area (with cross-references to detail files)
2. Identifies cross-cutting concerns
3. Lists open questions requiring human input
4. Does NOT propose solutions

[OUTPUT FORMAT]
# Research: {{task_description}}

## Summary
[2-3 bullet points: key findings]

## Research Areas
### [Area 1 Name]
**Code**: [summary, ref: code-analysis.md#section]
**Architecture**: [summary, ref: architecture-analysis.md#section]
**Tests**: [summary, ref: test-coverage.md#section]

### [Area N Name]
...

## Cross-Cutting Concerns
| Concern | Affected Areas | Details |
|---------|---------------|---------|
| [concern] | [areas] | [details] |

## Open Questions
| # | Question | Context | Needs Input From |
|---|----------|---------|-----------------|
| 1 | [question] | [why it matters] | [role/person] |

## Artifacts
| File | Contents |
|------|----------|
| code-analysis.md | [summary] |
| data-model.md | [summary] |
| test-coverage.md | [summary] |
| architecture-analysis.md | [summary] |
```

---

## Validation

Research phase is complete when:
- [ ] `.workflows/research/` directory exists
- [ ] `code-analysis.md` exists with file:line references
- [ ] `data-model.md` exists with entity/relationship inventory
- [ ] `test-coverage.md` exists with coverage assessment
- [ ] `architecture-analysis.md` exists with Mermaid diagrams
- [ ] `RESEARCH.md` exists with cross-references to all detail files
- [ ] RESEARCH.md has Open Questions section (even if empty with explanation)
- [ ] No proposals or solution suggestions in any file

---

## Success Criteria

### Minimum Viable Outcome
- [ ] All 5 research files generated in `.workflows/research/`
- [ ] RESEARCH.md summarizes findings from all detail files
- [ ] Each finding has a code/config file reference

### Good Outcome
- [ ] Cross-cutting concerns identified
- [ ] Open questions are specific and actionable
- [ ] Data model documented with entity relationships
- [ ] Architecture analysis includes Mermaid flow diagrams

### Excellent Outcome
- [ ] Test coverage gaps mapped to specific classes
- [ ] Dependency graph reveals coupling hotspots
- [ ] Integration patterns cataloged with auth/error handling details
- [ ] Research enables next step (Design) without returning to codebase

---

## Anti-Patterns

### What to Avoid

1. **Proposing Solutions During Research**: Research must describe AS-IS. Any "we should", "consider", "recommend" violates the research contract and biases the Design phase.

2. **Scanning Everything**: Resist the urge to scan the entire codebase. Focus on areas relevant to the task. A 30-controller scan when only 2 are affected wastes time and adds noise.

3. **Skipping Open Questions**: Pretending everything is clear when business context is missing. Research should surface unknowns, not hide them.

4. **Prose-Heavy Output**: Research artifacts should be tables, code references, and diagrams — not essays. Scanners produce inventories, not narratives.

5. **Conflating Research with Documentation**: This is NOT the documentation-suite scenario. Research produces internal working artifacts, not polished docs for stakeholders.

6. **Sequential Scanning**: Running code-scanner then arch-scanner sequentially when they produce independent files. Always run in parallel.

### Warning Signs
- Research files contain words like "should", "recommend", "suggest", "improve"
- RESEARCH.md has no Open Questions — not looking hard enough
- Scanner outputs lack file:line references — too abstract
- Research takes longer than 30 minutes — scope too wide
- Lead does not read scanner outputs before writing RESEARCH.md — copy-paste without synthesis

---

## Example Walkthrough

### Context
Task: "Add Apple Health integration to the wellness-backend"

### How It Played Out

**Phase 1 (DECOMPOSE)**:
```
Lead identifies 3 research areas:
1. "Existing Integration Patterns" (arch-scanner) — how Garmin/Fitbit are integrated
2. "Health Data Model" (code-scanner) — entities for workouts, health metrics
3. "Webhook/Callback Infrastructure" (arch-scanner) — how external callbacks are handled
4. "Test Patterns for Integrations" (code-scanner) — how integration tests are structured

Scanner assignments:
  code-scanner: Areas 2, 4 — entities, services, existing test suites
  arch-scanner: Areas 1, 3 — integration clients, webhook controllers, message flows
```

**Phase 2 (SCAN — parallel)**:
```
Track A (code-scanner):
  code-analysis.md:
    - Found: GarminSyncService, FitbitSyncService (src/Service/Integration/)
    - Pattern: each has Client, Mapper, SyncHandler
    - Dependencies: WorkoutRepository, HealthMetricRepository
    - Coupling: shared IntegrationTokenManager
  data-model.md:
    - Entities: Workout (15 fields), HealthMetric (8 fields), IntegrationToken (6 fields)
    - Relations: User -> Workout (1:N), Workout -> HealthMetric (1:N)
    - Missing: no HealthKit-specific entity exists
  test-coverage.md:
    - GarminSyncServiceTest: 85% coverage, 12 test methods
    - FitbitSyncServiceTest: 78% coverage, 9 test methods
    - Pattern: MockHttpClient for API calls, in-memory DB for entities

Track B (arch-scanner):
  architecture-analysis.md:
    - Integration pattern: OAuth2 token flow → periodic sync via RabbitMQ
    - Queues: garmin.sync, fitbit.sync (separate queues per provider)
    - Webhook: /api/webhook/{provider} → dispatches to handler
    - Mermaid: data flow diagram showing sync cycle
    - Config: GARMIN_CLIENT_ID, FITBIT_CLIENT_ID in .env
```

**Phase 3 (AGGREGATE)**:
```
RESEARCH.md created:
  Summary:
    - Established integration pattern: Client + Mapper + SyncHandler per provider
    - Data model supports generic workout/health metric storage
    - Test patterns well-established with MockHttpClient

  Cross-Cutting Concerns:
    | IntegrationTokenManager shared | All integrations | Single class manages OAuth for all providers |
    | Queue naming convention | Message infra | Pattern: {provider}.sync |

  Open Questions:
    | 1 | Does Apple Health use OAuth2 or device-level auth? | Affects token management | @backend-team |
    | 2 | Real-time sync or periodic batch? | Determines queue vs webhook approach | @product |
    | 3 | Which HealthKit data types to support? | Scopes data model changes | @product |

  Artifacts: 5 files in .workflows/research/
```

### Outcome
- Design phase can start with clear understanding of existing patterns
- Open questions surfaced early — product team consulted before design
- No time wasted proposing solutions that conflict with existing architecture
- Total time: ~20 minutes

---

## Related

- **Next step**: [2-design.md](./2-design.md) — Create technical design from research
- **Alternative**: [documentation-suite.md](../delivery/documentation-suite.md) — If the goal is documentation, not implementation
- **Agent files**: [codebase-doc-collector](../../agents/codebase-doc-collector.md), [architecture-doc-collector](../../agents/architecture-doc-collector.md)
- **Input to**: Design phase consumes `.workflows/research/` directory
