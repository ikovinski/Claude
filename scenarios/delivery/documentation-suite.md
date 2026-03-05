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
  - stoplight-docs
requires: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
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
3. **Stoplight packaging** (if Decision 2 = A):
   - Verify Technical Writer produced `docs/getting-started.md`
   - Verify `docs/toc.json` exists and references all generated files
   - Verify enriched OpenAPI in `reference/openapi.yaml` (Stoplight layout)
   - Validate SMD syntax in feature articles (callouts use `<!-- theme: -->`, not bold text)
4. Produce final statistics report

**Output**: Final documentation suite ready for use

---

## Team Setup

Team Lead створює команду через `TeamCreate`:
```
team_name: "docs-suite-{project-name}"
description: "Documentation Suite generation"
```

### Teammates

| Name | Agent File | Model | Phases |
|------|-----------|-------|--------|
| scanner | `agents/documentation/technical-collector.md` | sonnet | 1 |
| architect | `agents/documentation/architect-collector.md` | sonnet | 2A, 4 |
| api-spec | `agents/documentation/swagger-collector.md` | sonnet | 2B, 4 |
| writer | `agents/documentation/technical-writer.md` | sonnet | 3, 4 |

Кожен teammate — окрема сесія Claude Code зі своїм контекстним вікном. Teammate отримує agent file як spawn prompt + CLAUDE.md проєкту автоматично.

### Phase Execution

```
Phase 1 (COLLECT):
  Team Lead spawns "scanner" teammate
  Assigns task via shared task list
  Waits for scanner to complete (TeammateIdle notification)
  Artifact: docs/.artifacts/technical-collection-report.md

Phase 2 (ANALYZE):
  Team Lead spawns "architect" and "api-spec" IN PARALLEL
  Creates tasks with dependency on Phase 1 task (auto-unblocks)
  Both read from Technical Collection Report on disk (no write conflicts)
  Team Lead waits for BOTH to go idle

Phase 3 (WRITE):
  Team Lead spawns "writer"
  Creates tasks with dependencies on Phase 2 tasks
  Writer reads all artifacts from docs/.artifacts/
  Team Lead waits for writer to go idle

Phase 4 (CROSS-REVIEW):
  Team Lead creates cross-review tasks per review matrix
  Assigns tasks to existing teammates via shared task list
  Teammates claim and complete review tasks
  Team Lead collects findings via SendMessage, assigns corrections

Phase 5 (FINALIZE):
  Team Lead updates INDEX, verifies links
  Team Lead shuts down all teammates (shutdown request via SendMessage)
  Team Lead calls TeamDelete to clean up team resources
```

### Communication Pattern

- **Team Lead → teammates**: `SendMessage` для task assignments, artifacts handoff, shutdown requests
- **Teammates → Team Lead**: Automatic idle notifications, `SendMessage` для blockers/findings
- **Between teammates**: Не використовується — вся координація через Team Lead
- **Shared task list**: Основний механізм координації (pending → in_progress → completed)
- **Artifacts on disk**: `docs/.artifacts/` — спільна файлова система для передачі артефактів

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

### Decision 2: Output Format
**Question**: What output format to use?
**Options**:
- A: Stoplight-compatible (SMD articles, toc.json, Stoplight project structure, Getting Started guide)
- B: Plain markdown (current behavior, no SMD, no toc.json)

**Recommended**: A if project publishes docs via Stoplight; B for internal-only docs

### Decision 3: Cross-Review Depth
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

### Stoplight-Ready (when Output Format = Stoplight)
- [ ] All feature articles use SMD syntax (callouts, titled blocks)
- [ ] `docs/getting-started.md` exists and takes < 5 min
- [ ] `docs/toc.json` covers all generated files
- [ ] `reference/openapi.yaml` follows Stoplight naming conventions
- [ ] OpenAPI has standardized Error schema with `code`, `message`, `details`
- [ ] Key endpoints have HTTP Request Maker blocks in articles

---

## Anti-Patterns

1. **Bypassing artifacts chain** — agent scans codebase directly instead of using Technical Collector output. Leads to inconsistent facts
2. **Skipping cross-review** — generates docs in isolation. Naming drifts between architecture and API docs
3. **Over-generating** — documenting every internal helper class. Focus on public API and key flows
4. **Empty descriptions** — Swagger Collector generates spec, nobody enriches it. Spec exists but is unusable
5. **No diagrams** — architecture doc without Mermaid visuals is just text. Diagrams are the point
6. **Zero Open Questions** — means architect didn't look hard enough
