---
name: docs-suite
description: Generate complete documentation suite — technical facts, architecture diagrams, OpenAPI spec, feature articles. Orchestrates 4 agents across 5 phases.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "TeamCreate", "TeamDelete", "SendMessage", "TodoWrite"]
triggers:
  - "generate documentation"
  - "docs suite"
  - "згенеруй документацію"
skills:
  - auto:{project}-patterns
requires: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
---

# /docs-suite - Documentation Suite

Orchestrates 4 documentation agents as an **agent team** to produce a complete project documentation set.

## Usage

```bash
/docs-suite                          # Full suite (all phases)
/docs-suite --feature payment-refund # Feature-aware mode (uses .workflows/ artifacts as context)
/docs-suite --format stoplight       # Stoplight-compatible output (SMD, toc.json, Getting Started)
/docs-suite --scope architecture     # Architecture only (Phase 1 + 2A)
/docs-suite --scope api              # API only (Phase 1 + 2B)
/docs-suite --skip-review            # Skip cross-review phase
```

## Prerequisites

Agent Teams must be enabled:
```json
// settings.json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

## You Are the Team Lead

When this command runs, YOU (Claude) are the **Team Lead orchestrator**. You:
- Create the agent team via `TeamCreate`
- Spawn teammates, each receiving their agent file as the spawn prompt
- Coordinate work via shared task list and `SendMessage`
- Pass artifacts between phases (written to `docs/.artifacts/`)
- Verify phase gates before proceeding
- Manage cross-review assignments
- Clean up team via `TeamDelete` when done

## Team Creation

At the start, create the team:
```
TeamCreate:
  team_name: "docs-suite-{project-name}"
  description: "Documentation Suite generation for {project-name}"
```

## Feature Context Resolution (--feature)

When `--feature {name}` is provided, Team Lead resolves available artifacts **before** spawning teammates:

```
feature_path = ".workflows/{feature-name}"

Resolve each artifact independently:
  research_report  = Glob("{feature_path}/research/research-report.md")  → file or null
  architecture     = Glob("{feature_path}/design/architecture.md")       → file or null
  diagrams         = Glob("{feature_path}/design/diagrams.md")           → file or null
  api_contracts    = Glob("{feature_path}/design/api-contracts.md")      → file or null
  adr_files        = Glob("{feature_path}/design/adr/*.md")              → files or []
  impl_reports     = Glob("{feature_path}/implement/phase-*-report.md")  → files or []
```

**Rule**: each artifact is optional. If a file doesn't exist — skip it silently, teammate gets standard prompt without that section. No errors, no warnings.

The resolved artifacts are injected as `[FEATURE CONTEXT]` sections into teammate spawn prompts (see phases below).

---

## Phase Execution

### Phase 1: COLLECT (blocking)

**Teammate**: scanner (Technical Collector)

1. Read agent file: `agents/documentation/technical-collector.md`
2. Spawn teammate "scanner" with the full agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}

[FEATURE CONTEXT — only if --feature and artifacts exist]
Research report: .workflows/{feature}/research/research-report.md
Implementation reports: .workflows/{feature}/implement/phase-*-report.md
→ Focus collection on components mentioned in these artifacts.
→ Still scan the full project, but prioritize affected areas.

[TASK]
Execute the full collection process as described in your Task section.
Write output to: docs/.artifacts/technical-collection-report.md
```

3. Create task in shared task list: "Collect technical facts for {project-name}"
4. Wait for scanner to go idle (automatic TeammateIdle notification)
5. **Gate**: Read `docs/.artifacts/technical-collection-report.md`, verify Components Summary table has counts > 0

---

### Phase 2: ANALYZE (parallel — 2 teammates)

**Teammates**: architect (Architect Collector) + api-spec (Swagger Collector)

Spawn both teammates simultaneously. Both read from the Technical Collection Report on disk — no write conflicts since they produce different artifacts.

#### Teammate: architect (Architect Collector)
1. Read agent file: `agents/documentation/architect-collector.md`
2. Spawn teammate "architect" with agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}

[INPUT — Technical Collection Report]
Read from: docs/.artifacts/technical-collection-report.md

[FEATURE CONTEXT — only if --feature and artifacts exist]
Design architecture: .workflows/{feature}/design/architecture.md
Design diagrams: .workflows/{feature}/design/diagrams.md
ADR files: .workflows/{feature}/design/adr/*.md
→ Use these as baseline. Verify against actual code, update/extend as needed.
→ Reuse diagrams that are still accurate. Update diagrams that diverged during implementation.

[TASK]
Execute architecture analysis as described in your Task section.
Write output to: docs/.artifacts/architecture-report.md
```

3. Create task with dependency on Phase 1 task

#### Teammate: api-spec (Swagger Collector)
1. Read agent file: `agents/documentation/swagger-collector.md`
2. Spawn teammate "api-spec" with agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}

[INPUT — Technical Collection Report]
Read from: docs/.artifacts/technical-collection-report.md

[FEATURE CONTEXT — only if --feature and artifacts exist]
API contracts: .workflows/{feature}/design/api-contracts.md
→ Use as starting point for endpoint extraction. Contracts define intended API shape.
→ Verify contracts against actual implemented code — implementation may differ from design.

[TASK]
Execute OpenAPI generation as described in your Task section.
Write output to: docs/.artifacts/openapi.yaml
Write coverage report to: docs/.artifacts/swagger-coverage-report.md
```

3. Create task with dependency on Phase 1 task

**Gate**: Wait for BOTH teammates to go idle. Verify:
- `docs/.artifacts/architecture-report.md` contains at least one Mermaid diagram (```mermaid block)
- `docs/.artifacts/openapi.yaml` exists and has `paths:` section

---

### Phase 3: WRITE (sequential)

**Teammate**: writer (Technical Writer)

1. Read agent file: `agents/documentation/technical-writer.md`
2. Spawn teammate "writer" with agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}

[INPUT ARTIFACTS — read from disk]
- docs/.artifacts/technical-collection-report.md
- docs/.artifacts/architecture-report.md
- docs/.artifacts/openapi.yaml
- docs/.artifacts/swagger-coverage-report.md

[TASK]
Execute all tasks as described in your Task section:
1. Write feature articles to docs/features/*.md
2. Enrich OpenAPI spec and write to docs/openapi.yaml
3. Generate docs/INDEX.md

[FORMAT: {stoplight|plain}]
If stoplight: also execute Task 4 (Stoplight Packaging):
4. Write docs/getting-started.md
5. Generate docs/toc.json
6. Place enriched OpenAPI at reference/openapi.yaml
Use SMD syntax in all articles.
```

3. Create task with dependencies on Phase 2 tasks
4. Wait for writer to go idle

**Gate**: Verify at least 1 feature article exists in `docs/features/`, `docs/INDEX.md` exists

---

### Phase 4: CROSS-REVIEW (if not --skip-review)

**Lead**: You (Team Lead) orchestrate reviews via existing teammates

Read the review matrix from `scenarios/delivery/documentation-suite.md` Phase 4 section.

For each review pair, create a task in shared task list and send review assignment via `SendMessage`:

**Example: SendMessage to architect for reviewing Swagger output**:
```
[REVIEW TASK]
You are reviewing Swagger Collector's output for consistency with your architecture documentation.

[YOUR OUTPUT — Architecture Report]
Read from: docs/.artifacts/architecture-report.md

[REVIEWING — OpenAPI Spec]
Read from: docs/.artifacts/openapi.yaml

[FOCUS]
- Endpoint naming matches architecture documentation
- Integration flows are covered in API spec
- No contradictions in system behavior descriptions

[OUTPUT FORMAT]
Write review to: docs/.artifacts/cross-review-architect-to-swagger.md

## Cross-Review: Architect Collector → Swagger Collector

### Findings
| Location | Issue | Severity | Suggested Fix |
|----------|-------|----------|--------------|
| ... | ... | high/medium/low | ... |

### Verdict: [CONSISTENT / NEEDS FIXES]
```

After all reviews complete:
- If any `high` severity issues: send fix tasks to responsible teammates via `SendMessage`
- If only `medium`/`low`: report to user, proceed

---

### Phase 5: FINALIZE

**Lead**: You (Team Lead) directly

1. Read `docs/INDEX.md`
2. Verify all file links are valid (Glob for referenced files)
3. Update INDEX if needed
4. **If `--format stoplight`**: verify Stoplight artifacts:
   - `docs/getting-started.md` exists
   - `docs/toc.json` exists and references all files
   - `reference/openapi.yaml` exists
   - Feature articles contain SMD callouts (`<!-- theme:`)
5. Shut down all teammates (send shutdown request via `SendMessage`)
6. Call `TeamDelete` to clean up team resources
7. Report final statistics:

```
## Documentation Suite Complete

### Generated Files
| File | Type | Agent |
|------|------|-------|
| docs/.artifacts/technical-collection-report.md | Artifact | Technical Collector |
| docs/.artifacts/architecture-report.md | Artifact | Architect Collector |
| docs/.artifacts/openapi.yaml | Artifact | Swagger Collector |
| docs/.artifacts/swagger-coverage-report.md | Artifact | Swagger Collector |
| docs/openapi.yaml | Final | Technical Writer |
| docs/features/*.md | Final | Technical Writer |
| docs/INDEX.md | Final | Technical Writer |
| docs/getting-started.md | Final (Stoplight) | Technical Writer |
| docs/toc.json | Final (Stoplight) | Technical Writer |
| reference/openapi.yaml | Final (Stoplight) | Technical Writer |

### Statistics
| Metric | Value |
|--------|-------|
| Phases completed | N/5 |
| Teammates spawned | N |
| Feature articles | N |
| API endpoints documented | N |
| Mermaid diagrams | N |
| Cross-review issues found | N |
| Cross-review issues fixed | N |

### Entry Point
docs/INDEX.md
```

---

## Scope Options

| Flag | Phases | Teammates | Notes |
|------|--------|-----------|-------|
| (default) | 1 → 2 → 3 → 4 → 5 | All 4 | Plain markdown output |
| `--feature {name}` | 1 → 2 → 3 → 4 → 5 | All 4 | Injects `.workflows/{name}/` artifacts as context per teammate |
| `--format stoplight` | 1 → 2 → 3 → 4 → 5 | All 4 | SMD articles, toc.json, Getting Started, Stoplight layout |
| `--scope architecture` | 1 → 2A | scanner, architect | |
| `--scope api` | 1 → 2B → 3 (swagger enrichment only) | scanner, api-spec, writer | |
| `--skip-review` | 1 → 2 → 3 → 5 | All 4, skip Phase 4 | |

---

## Important Notes

- Each teammate receives the **full agent file** as its spawn prompt — identity, biases, output format
- Teammates load CLAUDE.md and project context automatically (standard Claude Code behavior)
- Artifacts are passed via **shared filesystem** (`docs/.artifacts/`), not in message body
- `SendMessage` is for task coordination and status updates, not large data transfer
- If a teammate fails, report the error and ask the user whether to retry or skip
- The target project may be a **different directory** than ai-agents-system — always ask or detect
- Always call `TeamDelete` at the end, even if some phases were skipped
- **`--feature` is a hint, not a hard dependency** — if `.workflows/{name}/` doesn't exist or has no artifacts, all teammates work as usual (scan code from scratch). Each artifact is checked independently; missing ones are silently skipped

---

## Related

- Scenario details: `scenarios/delivery/documentation-suite.md`
- Agent files: `agents/documentation/*.md`
