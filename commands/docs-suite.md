---
name: docs-suite
description: Generate complete documentation suite — technical facts, architecture diagrams, OpenAPI spec, feature articles. Orchestrates 4 agents across 5 phases.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "TeamCreate", "TeamDelete", "SendMessage", "TodoWrite"]
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
/docs-suite                          # First run — full suite (all phases)
/docs-suite --update                 # Re-run — incremental, only changed parts
/docs-suite --full                   # Force full overwrite (explicit)
/docs-suite --feature payment-refund # Feature-aware mode (uses .workflows/ artifacts as context)
/docs-suite --format stoplight       # Stoplight-compatible output (SMD, toc.json, Getting Started)
/docs-suite --scope architecture     # Architecture only (Phase 1 + 2A)
/docs-suite --scope api              # API only (Phase 1 + 2B)
/docs-suite --skip-review            # Skip cross-review phase
/docs-suite --update --skip-review   # Incremental update, skip user confirmation
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

When `--feature {feature-id}` is provided, Team Lead resolves available artifacts **before** spawning teammates:

```
feature_path = ".workflows/{feature-id}"

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

### Phase 0: DETECT (--update mode only)

**Lead**: You (Team Lead) directly — no teammates spawned yet.

When `--update` flag is present, execute change detection before creating the team.
When `--full` flag is present or no flag specified (first run), skip Phase 0 entirely.

#### Step 1: Read metadata

Read `docs/.artifacts/.meta.json`.

**If missing or invalid JSON:**
```
⚠️ No metadata from previous run found (docs/.artifacts/.meta.json).
Falling back to full mode.
```
→ Proceed to Phase 1 as full run.

**If `last_sha` not in git history** (verify via Bash: `git cat-file -t {last_sha}`):
```
⚠️ Previous run SHA ({last_sha}) not found in git history. Falling back to full mode.
```
→ Proceed to Phase 1 as full run.

#### Step 2: Detect source changes

Run via Bash:
```bash
git diff {last_sha}..HEAD --name-only
```

Filter results — **exclude**: `tests/`, `spec/`, `docs/`, `.github/`, `README.md`, `CHANGELOG.md`, `*.md` in root.
**Include**: source code (`src/`), config (`config/`), migrations (`migrations/`).

**If no relevant source changes:**
```
## Documentation Up To Date

No source changes since last run ({last_run}).
Last SHA: {last_sha} | Current HEAD: {current_sha}

To force regeneration: /docs-suite --full
```
→ EXIT without creating team.

#### Step 3: Map changes to features

Using `feature_mapping` from `.meta.json`:

```
For each changed file:
  For each feature in feature_mapping:
    If changed_file path starts with any source_dir of this feature:
      → add to affected_features[]
  If no feature matched:
    → add to unmapped_files[]
    → extract domain directory (e.g., src/NewThing/Controller/X.php → src/NewThing/)
    → add to new_scan_dirs[]
```

#### Step 4: Check for manual edits

For each artifact in `.meta.json` that belongs to an affected feature:

Run via Bash: `shasum -a 256 {artifact_path}`

Compare with stored `sha256`. If different → mark as "manually edited".

If manually edited files exist AND are in affected scope:
```
## Manual Edits Detected

| File | Status |
|------|--------|
| docs/features/workouts.md | Manually edited since last run |

Options:
- **proceed** — update anyway (manual edits in changed sections may be lost)
- **skip {file}** — skip specific files, update the rest
- **abort** — cancel update entirely
```
Wait for user response.

#### Step 5: Check flag compatibility

- If `meta.flags.format` != current `--format` → fall back to `--full` with explanation
- If `meta.flags.scope` was limited and now running full → fall back to `--full`

#### Step 6: Determine affected artifacts

| Changed Component Type | Triggers Re-run Of |
|------------------------|-------------------|
| Controller | scanner (scoped), api-spec (scoped), writer (affected articles) |
| Entity | scanner (scoped), architect (data model + ER), api-spec (schemas), writer (affected articles) |
| Service | scanner (scoped), writer (affected articles) |
| MessageHandler / Message | scanner (scoped), architect (async flows), writer (affected articles) |
| Config (`config/packages/`) | scanner (config section only) |
| Migration | scanner (migration section), architect (ER diagram) |
| New directory (unmapped) | scanner (full for new dir), potentially all downstream |

#### Step 7: Output scope summary

```
## Update Scope

Changes: {N} source files since {last_sha}

### Affected Features ({M} of {total})
| Feature | Changed Files | Article |
|---------|--------------|---------|
| workouts | CalorieCalculator.php, Workout.php | docs/features/workouts.md |

### Artifacts to Update
| Artifact | Agent | Reason |
|----------|-------|--------|
| technical-collection-report | scanner | Entity changes in src/Workout/ |
| architecture-report | architect | Data model changes |
| openapi.yaml | api-spec | Controller changes |
| workouts.md | writer | Source changes |

### Unmapped Changes (will be discovered by scanner)
| File |
|------|
| src/NewFeature/Controller/NewController.php |

Proceeding with scoped update...
```

Store `affected_features`, `affected_artifacts`, `changed_source_dirs`, `unmapped_files` in memory for subsequent phases.

**If >60% of features affected:**
```
## Large Change Detected

{N} of {M} features affected ({percentage}%).
Incremental update may be slower than full run due to per-feature overhead.

Recommendation: /docs-suite --full
Proceed with --update anyway? (yes/no)
```

---

### Phase 1: COLLECT (blocking)

**Teammate**: scanner (Technical Collector)

1. Read agent file: `agents/documentation/technical-collector.md`
2. Spawn teammate "scanner" with the full agent file as spawn prompt, plus:

```
[CONTEXT]
Project path: {target_project_path}

[FEATURE CONTEXT — only if --feature and artifacts exist]
Research report: .workflows/{feature-id}/research/research-report.md
Implementation reports: .workflows/{feature-id}/implement/phase-*-report.md
→ Focus collection on components mentioned in these artifacts.
→ Still scan the full project, but prioritize affected areas.

[TASK]
Execute the full collection process as described in your Task section.
Write output to: docs/.artifacts/technical-collection-report.md
```

3. Create task in shared task list: "Collect technical facts for {project-name}"
4. Wait for scanner to go idle (automatic TeammateIdle notification)
5. **Gate**: Read `docs/.artifacts/technical-collection-report.md`, verify Components Summary table has counts > 0

#### Phase 1 — Update Mode

When `--update` and Phase 0 determined scope, replace the `[TASK]` section in the scanner spawn prompt:

```
[UPDATE MODE — INCREMENTAL SCAN]
This is an incremental update, NOT a full scan.

[EXISTING REPORT]
Read from: docs/.artifacts/technical-collection-report.md
→ This is the full report from the previous run. It is your BASELINE.

[SCOPE — Changed directories only]
Only scan these directories for changes:
{list of changed_source_dirs and new_scan_dirs from Phase 0}

[TASK — INCREMENTAL]
1. Read the existing technical-collection-report.md
2. For each directory in SCOPE:
   - Re-scan components (controllers, entities, services, handlers)
   - Compare with existing report entries for this directory
   - Update changed entries, add new entries, mark removed entries
3. For directories NOT in SCOPE: keep existing report entries unchanged
4. If new directories found (unmapped): scan them fully and add to report
5. Update the Raw Statistics section
6. Write the COMPLETE updated report to: docs/.artifacts/technical-collection-report.md
   (full report with all sections, not just a delta)

CRITICAL: Preserve all unchanged sections exactly. Only modify rows in tables
that correspond to changed/new/removed files in SCOPE directories.
```

**Gate**: same as full mode (Components Summary counts > 0).

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
Design architecture: .workflows/{feature-id}/design/architecture.md
Design diagrams: .workflows/{feature-id}/design/diagrams.md
ADR files: .workflows/{feature-id}/design/adr/*.md
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
API contracts: .workflows/{feature-id}/design/api-contracts.md
→ Use as starting point for endpoint extraction. Contracts define intended API shape.
→ Verify contracts against actual implemented code — implementation may differ from design.

[TASK]
Execute OpenAPI generation as described in your Task section.
Write output to: docs/.artifacts/openapi.yaml
Write coverage report to: docs/.artifacts/swagger-coverage-report.md
```

3. Create task with dependency on Phase 1 task

**Gate**: Wait for BOTH teammates to go idle. Verify:
- `docs/.artifacts/architecture-report.md` contains at least one Mermaid diagram (` ```mermaid ` code block)
- `docs/.artifacts/architecture-report.md` contains NO ASCII art diagrams — if box-drawing characters (─│┌┐└┘├┤) found instead of ` ```mermaid ` blocks, send architect a fix request
- `docs/.artifacts/openapi.yaml` exists and has `paths:` section

#### Phase 2 — Update Mode

Spawn only the teammates whose artifacts are affected (determined in Phase 0 Step 6).
If architecture-report is not affected — skip architect. If openapi.yaml is not affected — skip api-spec.

**Architect update mode** — replace `[TASK]` section:

```
[UPDATE MODE — INCREMENTAL ANALYSIS]
This is an incremental update, NOT a full analysis.

[EXISTING REPORT]
Read from: docs/.artifacts/architecture-report.md
→ This is your BASELINE. Preserve all unchanged sections exactly.

[CHANGES SINCE LAST RUN]
Changed areas: {changed_source_dirs from Phase 0}
Affected sections: {list — e.g., Key Flows, Data Model, Component Diagram}

[TASK — INCREMENTAL]
1. Read the existing architecture-report.md
2. Read the UPDATED technical-collection-report.md
3. For changed areas:
   - Update affected diagrams (Component Diagram if new components, ER if entities changed)
   - Update affected Key Flows if flow logic changed
   - Update Integration Catalog only if integrations changed
4. For new components (unmapped): add new flows/diagrams as needed
5. Preserve all unchanged sections exactly — do NOT rewrite the entire document
6. Update Open Questions if any new unknowns discovered
7. Write complete updated report to: docs/.artifacts/architecture-report.md

CRITICAL: Do NOT regenerate diagrams unaffected by the changes.
Preserve existing Mermaid blocks for unchanged flows.
```

**API-spec update mode** — replace `[TASK]` section:

```
[UPDATE MODE — INCREMENTAL GENERATION]
This is an incremental update, NOT a full generation.

[EXISTING SPEC]
Read from: docs/.artifacts/openapi.yaml

[EXISTING COVERAGE REPORT]
Read from: docs/.artifacts/swagger-coverage-report.md

[CHANGES SINCE LAST RUN]
Changed controllers: {list of changed controller paths from Phase 0}

[TASK — INCREMENTAL]
1. Read the existing openapi.yaml and swagger-coverage-report.md
2. Read the UPDATED technical-collection-report.md
3. For changed controllers:
   - Re-extract endpoints, parameters, request/response schemas
   - Update existing paths or add new paths
   - Update affected component schemas
4. For unchanged controllers: keep existing paths and schemas exactly
5. If controllers were removed: remove their paths (verify file no longer exists)
6. Update coverage report with new/changed endpoint info
7. Write complete updated spec to: docs/.artifacts/openapi.yaml
8. Write complete updated report to: docs/.artifacts/swagger-coverage-report.md

CRITICAL: Preserve descriptions already filled by Technical Writer in previous runs.
Do NOT reset enriched descriptions to empty strings.
```

**Gate**: same as full mode.

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
6. Place enriched OpenAPI at docs/reference/openapi.yaml
Use SMD syntax in all articles.
```

3. Create task with dependencies on Phase 2 tasks
4. Wait for writer to go idle

**Gate**: Verify at least 1 feature article exists in `docs/features/`, `docs/INDEX.md` exists

#### Phase 3 — Update Mode

Replace the `[TASK]` section in the writer spawn prompt:

```
[UPDATE MODE — INCREMENTAL WRITING]
This is an incremental update, NOT a full rewrite.

[AFFECTED FEATURES]
Only update these feature articles:
{for each affected feature from Phase 0:}
- {feature-name} → docs/features/{feature}.md (EXISTS — update, do not rewrite)
{for each new/unmapped feature:}
- {feature-name} → docs/features/{feature}.md (NEW — create from scratch)

[EXISTING ARTICLES — read before updating]
For each existing article listed above: read the current file from disk first.

[TASK — INCREMENTAL]
1. For each AFFECTED feature with an EXISTING article:
   - Read the existing article from disk
   - Read the updated input artifacts (collection report, architecture, openapi)
   - Identify what changed (new endpoints, changed flows, new entities)
   - UPDATE only the changed sections of the article
   - Preserve: Overview (unless fundamentally changed), manual edits
     (look for non-standard sections not in the template)
   - Add new sections if new components/endpoints discovered
2. For each AFFECTED feature WITHOUT an existing article:
   - Create new article from scratch (standard template)
3. For UNAFFECTED features: do NOT touch their articles at all
4. Update docs/openapi.yaml (enriched):
   - Merge existing descriptions with updated spec from Swagger Collector
   - Add descriptions for new endpoints only
   - Preserve existing descriptions for unchanged endpoints
5. Update docs/INDEX.md:
   - Add entries for new articles if any
   - Keep existing entries unchanged

CRITICAL: The goal is MINIMAL DIFF. The user will review git diff after you finish.
Cosmetic rewrites of unchanged content will be rejected.
```

**Gate**: same as full mode (feature articles exist, INDEX.md exists).

---

### Phase 4: CROSS-REVIEW / USER CONFIRMATION

#### Full Mode (default, --full): CROSS-REVIEW

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

#### Update Mode (--update): USER CONFIRMATION

Cross-review is skipped in update mode (base content was already cross-reviewed in the first full run).
Instead, show the user what changed and ask for confirmation.

If `--skip-review` is present in update mode: skip this phase entirely, proceed to Phase 5.

1. Run via Bash: `git diff --stat docs/` — show change summary
2. Run via Bash: `git diff docs/` — show full diff
3. Present to user:

```
## Update Preview

### Changes Made
| File | Status | Lines Changed |
|------|--------|---------------|
| docs/features/workouts.md | modified | +12 -5 |
| docs/features/new-feature.md | new | +85 |
| docs/.artifacts/technical-collection-report.md | modified | +8 -3 |
| docs/.artifacts/architecture-report.md | modified | +15 -10 |
| docs/.artifacts/openapi.yaml | modified | +22 -4 |
| docs/openapi.yaml | modified | +22 -4 |
| docs/INDEX.md | modified | +1 |

### Actions
- **approve** — keep all changes, update .meta.json
- **reject** — revert all doc changes (`git checkout docs/`)
- **edit** — pause for manual edits, then confirm
```

4. Based on user response:
   - **approve** → proceed to Phase 5 (FINALIZE with .meta.json update)
   - **reject** → run via Bash: `git checkout docs/` → output "Changes reverted. docs/ restored to previous state." → EXIT without updating .meta.json
   - **edit** → output "Make your edits to docs/ files. When done, reply 'done' to continue." → wait for user → proceed to Phase 5

---

### Phase 5: FINALIZE

**Lead**: You (Team Lead) directly

1. Read `docs/INDEX.md`
2. Verify all file links are valid (Glob for referenced files)
3. Update INDEX if needed
4. **If `--format stoplight`**: verify Stoplight artifacts:
   - `docs/getting-started.md` exists
   - `docs/toc.json` exists and references all files
   - `docs/reference/openapi.yaml` exists
   - Feature articles contain SMD callouts (`<!-- theme:`)
5. **Create/update `docs/.artifacts/.meta.json`** (all modes):
   ```
   a. Get current HEAD SHA: run `git rev-parse HEAD` via Bash
   b. For each artifact file, compute SHA256: run `shasum -a 256 {file}` via Bash
   c. Build feature_mapping by parsing technical-collection-report.md:
      - Read Controllers table → extract Name, Path columns
      - Read Entities table → extract Name, Path columns
      - Read Services table → extract Name, Path columns
      - Group paths by top-level domain directory (e.g., src/Workout/ → "workouts")
      - Map each group to the corresponding feature article in docs/features/
   d. Write .meta.json:
   ```
   ```json
   {
     "version": 1,
     "last_run": "{ISO 8601 datetime}",
     "last_sha": "{git HEAD SHA}",
     "mode": "{full|update}",
     "project_path": "{target_project_path}",
     "flags": {
       "format": "{plain|stoplight}",
       "feature": "{feature-id|null}",
       "scope": "{null|architecture|api}"
     },
     "artifacts": {
       "{relative-path}": {
         "sha256": "{hash}",
         "agent": "{agent-name}",
         "phase": "{phase-number}"
       }
     },
     "feature_mapping": {
       "{feature-name}": {
         "article": "docs/features/{feature}.md",
         "source_dirs": ["src/{Domain}/", "src/Controller/{Domain}Controller.php"]
       }
     }
   }
   ```
6. Shut down all teammates (send shutdown request via `SendMessage`)
7. Call `TeamDelete` to clean up team resources
8. Report final statistics:

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
| docs/reference/openapi.yaml | Final (Stoplight) | Technical Writer |

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
| (default, first run) | 1 → 2 → 3 → 4 → 5 | All 4 | Full run, creates `.meta.json` |
| `--update` | 0 → 1* → 2* → 3* → 4-confirm → 5 | Scoped subset | Incremental, minimal diff |
| `--full` | 1 → 2 → 3 → 4 → 5 | All 4 | Force full overwrite, updates `.meta.json` |
| `--feature {feature-id}` | 1 → 2 → 3 → 4 → 5 | All 4 | Compatible with `--update` |
| `--format stoplight` | 1 → 2 → 3 → 4 → 5 | All 4 | NOT compatible with `--update` if format changed since last run |
| `--scope architecture` | 1 → 2A | scanner, architect | |
| `--scope api` | 1 → 2B → 3 (swagger enrichment only) | scanner, api-spec, writer | |
| `--skip-review` | 1 → 2 → 3 → 5 | All 4, skip Phase 4 | In `--update` mode: skip user confirmation |

\* Phases marked with * run in scoped/incremental mode — only affected features/artifacts are processed.

### Flag Combinations

| Combination | Behavior |
|-------------|----------|
| `--update --feature X` | Incremental + feature context for affected areas |
| `--update --skip-review` | Incremental without user confirmation gate |
| `--update --format stoplight` | Only if previous run was also stoplight; otherwise falls back to `--full` |
| `--update --scope architecture` | Incremental architecture only (skips API and feature articles) |
| `--full --skip-review` | Full overwrite without cross-review |

---

## Important Notes

- Each teammate receives the **full agent file** as its spawn prompt — identity, biases, output format
- Teammates load CLAUDE.md and project context automatically (standard Claude Code behavior)
- Artifacts are passed via **shared filesystem** (`docs/.artifacts/`), not in message body
- `SendMessage` is for task coordination and status updates, not large data transfer
- If a teammate fails, report the error and ask the user whether to retry or skip
- The target project may be a **different directory** than amo-claude-workflows — always ask or detect
- Always call `TeamDelete` at the end, even if some phases were skipped
- **`--feature` is a hint, not a hard dependency** — if `.workflows/{feature-id}/` doesn't exist or has no artifacts, all teammates work as usual (scan code from scratch). Each artifact is checked independently; missing ones are silently skipped

### Update Mode Notes

- **`--update` requires a previous full run** — if `.meta.json` is missing, falls back to full mode automatically
- **`--update` preserves manual edits** in unaffected files — only touched features are updated
- **`--update` detects manual edits** in affected files and warns before overwriting
- **`feature_mapping`** in `.meta.json` is the source of truth for change detection — if mapping seems wrong, run `--full` to rebuild
- **`.meta.json` should be committed to git** — it tracks the documentation state for the team
- **First run** (no flags) behaves identically to `--full` — creates `.meta.json` for future `--update` runs

---

## Related

- Scenario details: `scenarios/delivery/documentation-suite.md`
- Agent files: `agents/documentation/*.md`
