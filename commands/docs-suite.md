---
name: docs-suite
description: Generate complete documentation suite — technical facts, architecture diagrams, OpenAPI spec, feature articles. Orchestrates 4 agents across 5 phases.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Agent", "TodoWrite"]
triggers:
  - "generate documentation"
  - "docs suite"
  - "згенеруй документацію"
skills:
  - auto:{project}-patterns
---

# /docs-suite - Documentation Suite

Orchestrates 4 documentation agents to produce a complete project documentation set.

## Usage

```bash
/docs-suite                          # Full suite (all phases)
/docs-suite --scope architecture     # Architecture only (Phase 1 + 2A)
/docs-suite --scope api              # API only (Phase 1 + 2B)
/docs-suite --skip-review            # Skip cross-review phase
```

## You Are the Team Lead

When this command runs, YOU (Claude) are the **Team Lead orchestrator**. You:
- Read agent files to understand each agent's identity, biases, and output format
- Spawn agents as subagents via the Agent tool
- Pass artifacts between phases
- Verify phase gates before proceeding
- Manage cross-review assignments

## Phase Execution

### Phase 1: COLLECT (blocking)

**Agent**: Technical Collector

1. Read agent file: `agents/documentation/technical-collector.md`
2. Spawn subagent with the agent's identity, biases, task, and output format as the prompt
3. Provide the **target project path** (ask user if unclear)
4. Wait for Technical Collection Report
5. **Gate**: Verify report has Components Summary table with counts > 0

**Subagent prompt structure**:
```
[Read full contents of agents/documentation/technical-collector.md]

[CONTEXT]
Project path: {target_project_path}

[TASK]
Execute the full collection process as described in your Task section.
Write output to: docs/.artifacts/technical-collection-report.md
```

**Save artifact**: `docs/.artifacts/technical-collection-report.md`

---

### Phase 2: ANALYZE (parallel — 2 subagents)

**Agents**: Architect Collector + Swagger Collector (run in parallel)

#### Subagent A: Architect Collector
1. Read agent file: `agents/documentation/architect-collector.md`
2. Spawn subagent, provide Technical Collection Report as context
3. Wait for Architecture Report with diagrams

**Subagent prompt**:
```
[Read full contents of agents/documentation/architect-collector.md]

[CONTEXT]
Project path: {target_project_path}

[INPUT — Technical Collection Report]
{contents of docs/.artifacts/technical-collection-report.md}

[TASK]
Execute architecture analysis as described in your Task section.
Write output to: docs/.artifacts/architecture-report.md
```

#### Subagent B: Swagger Collector
1. Read agent file: `agents/documentation/swagger-collector.md`
2. Spawn subagent, provide Technical Collection Report as context
3. Wait for OpenAPI spec + coverage report

**Subagent prompt**:
```
[Read full contents of agents/documentation/swagger-collector.md]

[CONTEXT]
Project path: {target_project_path}

[INPUT — Technical Collection Report]
{contents of docs/.artifacts/technical-collection-report.md}

[TASK]
Execute OpenAPI generation as described in your Task section.
Write output to: docs/.artifacts/openapi.yaml
Write coverage report to: docs/.artifacts/swagger-coverage-report.md
```

**Gate**: Both subagents complete. Verify:
- Architecture report contains at least one Mermaid diagram
- `openapi.yaml` exists and has `paths:` section

---

### Phase 3: WRITE (sequential)

**Agent**: Technical Writer

1. Read agent file: `agents/documentation/technical-writer.md`
2. Spawn subagent, provide ALL previous artifacts as context
3. Wait for feature articles + enriched swagger + INDEX

**Subagent prompt**:
```
[Read full contents of agents/documentation/technical-writer.md]

[CONTEXT]
Project path: {target_project_path}

[INPUT — Technical Collection Report]
{contents of docs/.artifacts/technical-collection-report.md}

[INPUT — Architecture Report]
{contents of docs/.artifacts/architecture-report.md}

[INPUT — OpenAPI Spec]
{contents of docs/.artifacts/openapi.yaml}

[INPUT — Swagger Coverage Report]
{contents of docs/.artifacts/swagger-coverage-report.md}

[TASK]
Execute all 3 tasks as described in your Task section:
1. Write feature articles to docs/features/*.md
2. Enrich OpenAPI spec and write to docs/openapi.yaml
3. Generate docs/INDEX.md
```

**Gate**: Verify at least 1 feature article exists, `docs/INDEX.md` exists

---

### Phase 4: CROSS-REVIEW (if not --skip-review)

**Lead**: You (Team Lead) orchestrate reviews

Read the review matrix from `scenarios/delivery/documentation-suite.md` Phase 4 section.

For each review pair:
1. Spawn reviewer agent with their agent file as identity
2. Provide the output they need to review as context
3. Collect findings table

**Subagent prompt (example: Architect reviews Swagger)**:
```
[Read full contents of agents/documentation/architect-collector.md]

[REVIEW TASK]
You are reviewing Swagger Collector's output for consistency with your architecture documentation.

[YOUR OUTPUT — Architecture Report]
{contents of docs/.artifacts/architecture-report.md}

[REVIEWING — OpenAPI Spec]
{contents of docs/.artifacts/openapi.yaml}

[FOCUS]
- Endpoint naming matches architecture documentation
- Integration flows are covered in API spec
- No contradictions in system behavior descriptions

[OUTPUT FORMAT]
## Cross-Review: Architect Collector → Swagger Collector

### Findings
| Location | Issue | Severity | Suggested Fix |
|----------|-------|----------|--------------|
| ... | ... | high/medium/low | ... |

### Verdict: [CONSISTENT / NEEDS FIXES]
```

After collecting all reviews:
- If any `high` severity issues: spawn responsible agent to fix
- If only `medium`/`low`: report to user, proceed

---

### Phase 5: FINALIZE

**Lead**: You (Team Lead) directly

1. Read `docs/INDEX.md`
2. Verify all file links are valid (Glob for referenced files)
3. Update INDEX if needed
4. Report final statistics:

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

### Statistics
| Metric | Value |
|--------|-------|
| Phases completed | N/5 |
| Agents invoked | N |
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

| Flag | Phases | Agents |
|------|--------|--------|
| (default) | 1 → 2 → 3 → 4 → 5 | All 4 |
| `--scope architecture` | 1 → 2A | Technical Collector, Architect Collector |
| `--scope api` | 1 → 2B → 3 (swagger enrichment only) | Technical Collector, Swagger Collector, Technical Writer |
| `--skip-review` | 1 → 2 → 3 → 5 | All 4, skip Phase 4 |

---

## Important Notes

- Each subagent receives the **full agent file** as its system prompt — identity, biases, output format
- Artifacts are passed as text in the subagent prompt, AND written to `docs/.artifacts/`
- Subagents use `subagent_type: "coder"` to get file read/write access
- If a phase fails, report the error and ask the user whether to retry or skip
- The target project may be a **different directory** than ai-agents-system — always ask or detect

---

## Related

- Scenario details: `scenarios/delivery/documentation-suite.md`
- Agent files: `agents/documentation/*.md`
