# Documentation Suite Scenario

---
name: documentation-suite
description: Generate complete documentation suite from codebase — technical facts, architecture diagrams, OpenAPI spec, feature articles.
category: delivery
triggers:
  - "Generate full documentation"
  - "Document this project completely"
  - "We need docs for onboarding"
  - "Згенеруй повну документацію"
  - "Підготуй документацію для нової команди"
  - "Create architecture and API docs from code"
participants:
  - Team Lead (orchestrator)
  - Technical Collector (scanner)
  - Architect Collector (architect)
  - Swagger Collector (api-spec)
  - Technical Writer (writer)
duration: 60-120 minutes
skills:
  - auto:{project}-patterns
team_execution: true
---

## Situation

### Description
Проект потребує повної документації: технічний збір фактів, архітектурний аналіз з діаграмами, OpenAPI специфікація, feature-статті. Типові випадки: onboarding нових інженерів, pre-release документація, аудит, або система виросла без відповідної документації.

---

## Participants

### Required
| Role/Agent | Agent File | Model | Purpose |
|------------|-----------|-------|---------|
| Team Lead (Claude) | — | opus | Orchestrates phases, manages gates, generates INDEX |
| Technical Collector | `agents/documentation/technical-collector.md` | sonnet | Scans codebase, collects facts as-is |
| Architect Collector | `agents/documentation/architect-collector.md` | sonnet | Architecture analysis, diagrams, interactions |
| Swagger Collector | `agents/documentation/swagger-collector.md` | sonnet | Generates OpenAPI spec from code |
| Technical Writer | `agents/documentation/technical-writer.md` | sonnet | Feature articles, Swagger enrichment, INDEX |

---

## Process Flow

### Phase 1: COLLECT (blocking)
**Lead**: Technical Collector

**Input**: Project root path
**Task**:
1. Detect technology (PHP/Symfony, Node/JS, etc.)
2. Scan project structure
3. Collect all components: controllers, entities, services, handlers, integrations
4. Collect configuration, migrations, async flows
5. Produce structured Technical Collection Report

**Output**: Technical Collection Report (markdown with tables)
**Gate**: Team Lead verifies report is complete — all component types scanned, stats make sense

---

### Phase 2: ANALYZE (parallel — 2 tracks)

**Input**: Technical Collection Report from Phase 1

#### Track A: Architect Collector
1. Read Technical Collection Report
2. Identify system boundaries and external integrations
3. Produce C4 Context Diagram (Mermaid)
4. Produce Component Diagram (Mermaid)
5. Document key flows with sequence/flow diagrams
6. Map async flows (messages, events, cron)
7. Create ER diagram for key entities
8. Document integration catalog
9. Collect Open Questions

**Output (Track A)**: Architecture Documentation with diagrams

#### Track B: Swagger Collector
1. Read Technical Collection Report
2. Extract endpoints from controllers/routes
3. Build request/response schemas from entities/DTOs
4. Map authentication and error responses
5. Generate `openapi.yaml` (descriptions left empty for Technical Writer)
6. Produce coverage report with gaps

**Output (Track B)**: `openapi.yaml` + Coverage Report

**Gate**: Team Lead waits for BOTH tracks, verifies:
- Architecture doc has at least C4 Context + 1 flow diagram
- `openapi.yaml` is valid and covers all discovered endpoints

---

### Phase 3: WRITE (sequential, depends on Phase 2)
**Lead**: Technical Writer

**Input**: All previous artifacts (Technical Collection + Architecture + Swagger)

**Task**:
1. Identify major features from controller groupings and entity clusters
2. Write feature articles (`docs/features/*.md`) with:
   - Flow diagrams (reuse from Architect Collector)
   - API endpoint references (link to Swagger)
   - Data model references
   - Async behavior description
3. Enrich `openapi.yaml`:
   - Add endpoint descriptions and summaries
   - Add parameter and schema descriptions
   - Add example values
   - Add links to relevant feature articles
4. Generate `docs/INDEX.md` — unified documentation entry point

**Output**: Feature articles + enriched `openapi.yaml` + `docs/INDEX.md`
**Gate**: Team Lead verifies all features have articles, Swagger has descriptions

---

### Phase 4: CROSS-REVIEW (rotated)
**Lead**: Team Lead orchestrates

This is a **scenario phase**, not an agent responsibility. Each agent reviews others' output for consistency.

#### Review Matrix

| Reviewer | Reviews Output Of | Focus |
|----------|------------------|-------|
| Architect Collector | Swagger Collector | Endpoint naming matches architecture; integration flows covered in API |
| Architect Collector | Technical Writer | Diagrams in articles consistent with architecture docs; no contradictions |
| Swagger Collector | Technical Writer | Descriptions match actual endpoint behavior; no invented parameters |
| Technical Writer | Architect Collector | Diagrams readable and scannable; Mermaid syntax valid; Open Questions actionable |
| Technical Writer | Swagger Collector | Schema structure logical; naming consistent; gaps justified |

#### Review Process
1. Team Lead assigns reviews per matrix above
2. Each reviewer produces a findings table:

```markdown
## Cross-Review: [Reviewer] → [Author]

### Findings
| Location | Issue | Severity | Suggested Fix |
|----------|-------|----------|--------------|
| [file/section] | [description] | high/medium/low | [fix] |

### Verdict: [CONSISTENT / NEEDS FIXES]
```

3. Team Lead collects all findings
4. Team Lead assigns fix tasks to responsible agents (only `high` and `medium` severity)
5. Agents apply fixes
6. Team Lead verifies fixes applied

**Output**: Corrected documentation across all agents
**Gate**: All `high` severity issues resolved; `medium` addressed or justified

---

### Phase 5: FINALIZE
**Lead**: Team Lead

1. Update `docs/INDEX.md` with final file list
2. Verify all cross-references are valid (links between docs, swagger refs)
3. Produce final statistics report

**Output**: Final documentation suite ready for use

---

## Team Setup

```
Team Lead creates team:
  team_name: "docs-suite-{project-name}"
  description: "Documentation Suite generation"
```

### Teammates

| Name | Agent File | subagent_type | Model | Phases |
|------|-----------|---------------|-------|--------|
| scanner | technical-collector | technical-collector | sonnet | 1 |
| architect | architect-collector | architect-collector | sonnet | 2A, 4 |
| api-spec | swagger-collector | swagger-collector | sonnet | 2B, 4 |
| writer | technical-writer | technical-writer | sonnet | 3, 4 |

### Phase Execution

```
Phase 1 (COLLECT):
  Team lead spawns "scanner" teammate
  Assigns collection task
  Waits for Technical Collection Report
  scanner goes idle

Phase 2 (ANALYZE):
  Team lead spawns "architect" and "api-spec" IN PARALLEL
  Both read from Technical Collection Report (no write conflicts)
  Team lead waits for BOTH to complete

Phase 3 (WRITE):
  Team lead spawns "writer"
  Provides all artifacts from Phase 1 + Phase 2
  writer produces feature articles + enriched swagger + INDEX
  Team lead waits for completion

Phase 4 (CROSS-REVIEW):
  Team lead creates cross-review tasks per review matrix
  Each agent reviews assigned outputs
  Team lead collects findings, assigns corrections
  Agents apply fixes

Phase 5 (FINALIZE):
  Team lead updates INDEX, verifies links
  Sends shutdown_request to all teammates
  Calls TeamDelete to clean up
```

### Communication Pattern

- **Team lead → teammates**: Task assignments, phase gates, artifacts handoff
- **Teammates → team lead**: Completion reports, blockers, review findings
- **Between teammates**: No direct communication; all coordination through Team Lead

---

## Decision Points

### Decision 1: Documentation Scope
**Question**: What types of documentation to generate?
**Options**:
- A: Full (Collection + Architecture + Swagger + Features) — default
- B: Architecture only (skip API docs and features)
- C: API only (skip architecture)
- D: Custom selection

**Recommended**: A for first run, then targeted updates

### Decision 2: Cross-Review Depth
**Question**: How deep should cross-review be?
**Options**:
- A: Full review (consistency + quality + completeness)
- B: Consistency check only (naming, linking)
- C: Skip cross-review

**Recommended**: A for first generation, B for updates

---

## Success Criteria

### Minimum Viable
- [ ] Technical Collection Report complete with all component types
- [ ] Architecture doc with C4 Context Diagram
- [ ] `openapi.yaml` with all endpoints
- [ ] At least 1 feature article

### Good
- [ ] Architecture doc with C4 Context + Component + key flow diagrams
- [ ] `openapi.yaml` with descriptions and examples
- [ ] Feature articles for all major domains
- [ ] Cross-references between docs are valid

### Excellent
- [ ] Cross-review completed, all high issues resolved
- [ ] ER diagram for data model
- [ ] Integration catalog complete
- [ ] `docs/INDEX.md` with full catalog
- [ ] Open Questions documented
- [ ] Zero TODO gaps in Swagger

---

## Anti-Patterns

1. **Bypassing artifacts chain** — agent scans codebase directly instead of using Technical Collector output. Leads to inconsistent facts
2. **Skipping cross-review** — generates docs in isolation. Naming drifts between architecture and API docs
3. **Over-generating** — documenting every internal helper class. Focus on public API and key flows
4. **Empty descriptions** — Swagger Collector generates spec, nobody enriches it. Spec exists but is unusable
5. **No diagrams** — architecture doc without Mermaid visuals is just text. Diagrams are the point
6. **Zero Open Questions** — means architect didn't look hard enough
