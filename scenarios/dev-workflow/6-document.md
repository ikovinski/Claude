# Dev Workflow: Document Scenario

## Metadata
```yaml
name: dev-document
category: dev-workflow
trigger: Document implemented feature and review existing docs
participants:
  - Team Lead (orchestrator, technical-writer)
  - feature-writer (technical-writer)
  - delta-scanner (codebase-doc-collector)
duration: 10-25 minutes
skills:
  - auto:{project}-patterns
  - documentation/feature-spec-template
  - documentation/api-docs-template
team_execution: true
```

## Skills Usage in This Scenario

1. **{project}-patterns**: Feature-writer applies project-specific naming and structure conventions
2. **documentation/feature-spec-template**: Feature-writer uses compact version for task-scoped feature spec
3. **documentation/api-docs-template**: Feature-writer uses for OpenAPI delta generation
4. **documentation/codemap-template**: Delta-scanner uses for CODEMAPS validation and updates

## Situation

### Description
Sixth step of the `/dev` workflow. Documents the bounded context of the implemented feature and reviews existing documentation for inconsistencies caused by code changes. Two parallel tracks: Track A generates task-scoped documentation (feature spec, API delta, ADR finalization), Track B scans and incrementally updates existing project documentation. This is NOT a full documentation regeneration — it is scoped to the task context with targeted delta updates.

### Common Triggers
- Automatic progression from Review step (when REVIEW.md verdict is APPROVED)
- `/dev --step document` (standalone documentation for any code changes)
- "Document this feature"
- "Update docs for recent changes"

### Wellness/Fitness Tech Context
- **Feature spec audience**: Managers tracking wellness feature delivery, other teams integrating with health APIs
- **API docs**: Other mobile/frontend teams consuming health data endpoints
- **ADR finalization**: Documenting decisions about health data handling, sync strategies, privacy approaches
- **Delta scan scope**: Health data documentation is especially important — stale docs about PII/PHI handling create compliance risk
- **Security notes**: Feature spec includes security review summary (OWASP, PII/PHI audit results)

---

## Participants

### Required
| Role/Agent | Model | Purpose in Scenario |
|------------|-------|---------------------|
| Team Lead (orchestrator) | opus | Determines scope, compiles DOCS.md, cross-checks consistency, presents summary |
| feature-writer (technical-writer) | sonnet | Generates feature spec (compact), API delta, finalizes ADRs |
| delta-scanner (codebase-doc-collector) | sonnet | Scans existing docs for stale references, produces delta report, applies auto-fixes |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| architecture-doc-collector | When task introduces a NEW external integration (Lead checks architecture-analysis.md) |

---

## Process Flow

### Phase 1: SCOPE
**Duration**: 2-3 minutes
**Lead**: Team Lead (orchestrator)

Steps:
1. Read `.workflows/implement/PROGRESS.md` — get complete list of new/modified files
2. Read `.workflows/review/{feature-slug}/REVIEW.md` — confirm APPROVED, extract security summary
3. Read `.workflows/design/DESIGN.md` — get feature overview
4. Read `.workflows/design/api-contracts.md` — check for new/changed API endpoints
5. Read `.workflows/design/adr/*.md` — check for ADRs to finalize
6. Determine documentation scope:
   - Does the task introduce new API endpoints? → include API delta in Track A
   - Does the task have ADRs? → include ADR finalization in Track A
   - Does the task introduce a new external integration? → optionally spawn architecture-doc-collector
   - Does `docs/` directory exist in the project? → Track B enabled only if yes
7. Create task assignments for feature-writer and delta-scanner

**Output**: Scope definition, task assignments

### Phase 2: GENERATE (Parallel)
**Duration**: 5-15 minutes
**Lead**: feature-writer + delta-scanner (parallel execution)

**Track A — feature-writer (technical-writer)**:
1. Read DESIGN.md, api-contracts.md, diagrams.md, adr/*.md, REVIEW.md
2. Generate `docs/features/{feature-slug}.md` using compact feature-spec template:
   - Status: In Development / Released
   - Overview from DESIGN.md (2-3 sentences)
   - API Changes table from api-contracts.md
   - Architecture diagram (simplified from diagrams.md)
   - Security notes from REVIEW.md security section
   - Integration points (if applicable)
3. Generate API delta documentation (`api-changes.md`):
   - If project has `docs/references/openapi.yaml`: generate additive YAML snippet for new endpoints
   - If no existing OpenAPI: generate standalone API reference section in feature spec
4. Finalize ADRs:
   - Read each `design/adr/*.md`
   - Compare with actual implementation (read code files from PROGRESS.md)
   - If implementation matches design: set Status to "Accepted"
   - If implementation deviated: add "Implementation Notes" section documenting deviation
   - Copy updated ADRs to `docs/adr/` (project-level ADR directory)
   - Log changes in `adr-updates.md`

**Track B — delta-scanner (codebase-doc-collector in delta mode)**:
1. Read PROGRESS.md for the list of all new/modified files
2. Scan existing `docs/` directory for references to affected areas:
   - Search for class names, endpoint paths, entity names from PROGRESS.md in existing docs
   - Check `docs/CODEMAPS/*.md` if they exist — flag stale references
   - Check `docs/architecture/*.md` if they exist — flag inconsistencies
   - Check `docs/references/openapi.yaml` if exists — flag missing new endpoints
   - Check `docs/INDEX.md` if exists — flag missing entries
3. For each finding, categorize:
   - **STALE**: Documentation references code that changed (renamed class, modified behavior)
   - **MISSING**: New code not reflected in existing docs
   - **BROKEN_LINK**: Documentation links to files that moved or were renamed
4. Produce `delta-report.md` with summary and per-file changes
5. Apply auto-fixes:
   - Update stale class/method references
   - Add new entries to INDEX.md
   - Update CODEMAPS with new components (if CODEMAPS exist)
6. **Scope escalation**: If more than 10 stale entries found, report: "Consider running `/docs-suite` for a full documentation refresh" — do NOT attempt to fix everything

**Timebox**: If Track B exceeds 10 minutes, abort with partial findings

**Output (Track A)**: `docs/features/{slug}.md`, `api-changes.md`, updated ADRs in `docs/adr/`, `adr-updates.md`
**Output (Track B)**: `delta-report.md`, updated existing docs
**Gate**: Team Lead waits for both tracks to complete

### Phase 3: COMPILE
**Duration**: 3-5 minutes
**Lead**: Team Lead (orchestrator)

Steps:
1. Read both track outputs
2. Cross-check consistency:
   - Feature spec endpoint names match api-changes.md
   - ADR references in feature spec link to correct adr/ files
   - Delta report findings do not conflict with feature-writer output
3. Produce `.workflows/document/DOCS.md` (see format below)
4. Present summary to user:
   - Show DOCS.md summary
   - Ask: "Documentation looks good. Proceed to PR? (yes/fix/skip-docs)"
   - Default: yes
5. Shutdown teammates

**Output**: `.workflows/document/DOCS.md`

---

## DOCS.md Format

```markdown
# Documentation: {Feature Name}

## Summary
- **Feature Spec**: Created / Skipped
- **API Docs**: Updated / No changes / N/A
- **ADRs Finalized**: {count}
- **Existing Docs Updated**: {count} files
- **Stale References Found**: {count}
- **Total Doc Files Changed**: {count}

---

## Track A: Bounded Context Documentation

### Feature Spec
- **Created**: `docs/features/{slug}.md`
- **Audience**: Managers, other team leads
- **Includes**: Overview, API changes, architecture diagram, security notes

### API Documentation
- **Updated**: `docs/references/openapi.yaml`
- **New Endpoints**: {count}
- **Modified Endpoints**: {count}

### ADR Finalization
| ADR | Original Status | New Status | Notes |
|-----|-----------------|------------|-------|
| {ADR-001} | Proposed | Accepted | Implementation matches design |

---

## Track B: General Documentation Delta

### Delta Report Summary
| Category | Count | Auto-Fixed | Manual Review |
|----------|-------|------------|---------------|
| Stale references | {N} | {N} | {N} |
| Missing entries | {N} | {N} | {N} |
| Broken links | {N} | {N} | {N} |

### Files Updated
| File | Changes | Category |
|------|---------|----------|
| {docs/path} | {description} | {STALE/MISSING/BROKEN_LINK} |

### Deferred Items
{Items not auto-fixed that require manual review, if any}

---

## Code Issues Found
{Reference to .workflows/document/CODE-ISSUE.md if created, otherwise "None"}
```

---

## Team-Based Execution

### Team Setup

```
Team Lead creates team:
  team_name: "dev-document-{feature-slug}"
  description: "Documentation phase for {task description}"
```

### Teammates

| Name | Agent File | subagent_type | Model | Track |
|------|-----------|---------------|-------|-------|
| feature-writer | technical-writer | technical-writer | sonnet | A |
| delta-scanner | codebase-doc-collector | codebase-doc-collector | sonnet | B |

### Phase Execution

```
Phase 1 (SCOPE):
  Lead reads PROGRESS.md, REVIEW.md, DESIGN.md
  Lead determines scope (what to generate, what to scan)
  Lead creates task assignments

Phase 2 (GENERATE):
  Lead spawns "feature-writer" and "delta-scanner" IN PARALLEL
  feature-writer produces feature spec + API delta + ADR updates
  delta-scanner scans existing docs, produces delta report + fixes
  Lead waits for BOTH to complete

Phase 3 (COMPILE):
  Lead reads both outputs
  Lead cross-checks consistency
  Lead creates .workflows/document/DOCS.md
  Lead presents summary to user
  Lead sends shutdown_request to both teammates
  Calls TeamDelete to clean up

User interaction:
  Lead shows DOCS.md summary
  Asks: "Documentation looks good. Proceed to PR? (yes/fix/skip-docs)"
  Default: yes
```

### Task List Structure

```
1. [lead] Determine documentation scope from pipeline artifacts
2. [feature-writer] Generate feature spec + API delta + ADR finalization
3. [delta-scanner] Scan existing docs for stale references and missing entries
4. [lead] Compile DOCS.md and present to user
```

### Communication Pattern

- **Team Lead -> feature-writer**: Design artifacts, REVIEW.md security section, output expectations
- **Team Lead -> delta-scanner**: PROGRESS.md file list, existing docs/ location, delta scan instructions
- **feature-writer -> Team Lead**: Feature spec + API delta + ADR updates
- **delta-scanner -> Team Lead**: Delta report + list of auto-fixed files
- **Team Lead -> PR step**: DOCS.md + list of all created/updated doc files

---

## Standalone Mode

This step can run independently via `/dev --step document`:

```
/dev --step document

Behavior in standalone mode:
- File discovery: uses git diff instead of PROGRESS.md
- Design artifacts: only if .workflows/design/ exists (Track A limited)
- Review summary: only if .workflows/review/ exists (skips security notes)
- Track B still works: scans docs/ against git diff
- Output: .workflows/document/DOCS.md + updated docs files
```

| Aspect | Pipeline Mode | Standalone Mode |
|--------|---------------|-----------------|
| File discovery | PROGRESS.md | git diff |
| Feature spec | Full (from DESIGN.md) | Compact (from code only) |
| ADR finalization | Yes | Only if design artifacts exist |
| Delta scan | Yes | Yes |
| Output location | .workflows/document/ | .workflows/document/ |

---

## Scope Control Mechanisms

Hard boundaries preventing this step from becoming a full docs-suite regeneration:

1. **File list constraint**: Both tracks operate ONLY on files listed in PROGRESS.md. They do not scan the entire `src/` directory.
2. **No cache generation**: Delta-scanner NEVER generates `.codemap-cache/`. Reads existing cache if present; works from PROGRESS.md file list otherwise.
3. **No system profile**: Architecture-doc-collector NOT spawned by default. System profile is docs-suite territory.
4. **No CODEMAPS regeneration**: Delta-scanner may update existing CODEMAPS entries but never regenerates the entire set.
5. **Feature spec uses compact template**: Compact version only — no rollout plan, no success metrics, no lengthy business context.
6. **Escalation threshold**: If delta-scanner finds > 10 stale documentation entries, recommend `/docs-suite` instead of attempting to fix everything.
7. **Timebox**: Track B aborts at 10 minutes with partial findings.

---

## Feedback Loop: Code Issues

If the documentation process reveals code issues:

- **Documentation-only issue** (stale text, wrong description): Fix in docs, note in DOCS.md
- **Minor code-doc mismatch** (slightly different parameter name): Fix in docs to match code (code is truth)
- **Significant code issue** (API endpoint missing, ADR decision not followed): Create `.workflows/document/CODE-ISSUE.md`:

```markdown
# Code Issue Found During Documentation

## Source
Document step, Phase 2

## Issue
{Description of what was found}

## Impact
- Design assumption: {what was assumed}
- Reality: {what was found}
- Affected documentation: {which docs}

## Recommendation
- [ ] Return to Implement step to fix
- [ ] Proceed and track as tech debt
```

The user decides whether to loop back to Implement or proceed.

---

## Decision Points

### Decision 1: Architecture Doc Collector Inclusion
**Question**: Should architecture-doc-collector be spawned as a third teammate?
**Options**:
- A: Never — feature-writer handles all documentation (default)
- B: When task introduces a new external integration (from RESEARCH.md)
- C: Always — for consistency with documentation-suite

**Recommended approach**: A for most features. B when Research phase identified new integrations.

### Decision 2: Delta Scan Depth
**Question**: How deep should delta-scanner scan existing docs?
**Options**:
- A: Surface — check INDEX.md and CODEMAPS only (fast, 2-3 min)
- B: Standard — check all docs/ for references to affected code (default, 5-10 min)
- C: Deep — also validate `.codemap-cache/` and check cross-references (10-15 min)

**Recommended approach**: B for most features. A when no `docs/` directory exists.

### Decision 3: Documentation Blocking
**Question**: Should documentation block the PR?
**Options**:
- A: Never block — documentation is advisory (default)
- B: Block if feature spec is missing
- C: Block if delta scan finds critical stale references

**Recommended approach**: A for velocity. Code is already reviewed and approved — doc issues should not prevent merge.

---

## Prompts Sequence

### Feature Writer Prompt
**Use Agent**: technical-writer
**Prompt**:
```
[IDENTITY]
You are the Feature Writer generating bounded-context documentation for the /dev workflow.
You produce task-scoped docs: feature spec, API delta, ADR finalization.

[CONTEXT]
Task: {{task_description}}
Design: .workflows/design/DESIGN.md
API Contracts: .workflows/design/api-contracts.md
ADRs: .workflows/design/adr/*.md
Diagrams: .workflows/design/diagrams.md
Review: .workflows/review/{{feature_slug}}/REVIEW.md
Progress: .workflows/implement/PROGRESS.md

[SKILLS]
- documentation/feature-spec-template (compact version)
- documentation/api-docs-template

[TASK]
1. Generate COMPACT feature spec at docs/features/{{feature_slug}}.md:
   - Status, Overview (2-3 sentences from DESIGN.md)
   - API Changes table (from api-contracts.md)
   - Architecture diagram (simplified from diagrams.md)
   - Security notes (from REVIEW.md security section)
   - No rollout plan, no success metrics, no lengthy business context

2. Generate API delta (api-changes.md):
   - If docs/references/openapi.yaml exists: additive YAML snippet
   - If not: standalone API section in feature spec

3. Finalize ADRs:
   - Read each design/adr/*.md
   - If implementation matches: Status → Accepted
   - If deviated: add Implementation Notes section
   - Copy to docs/adr/
   - Log in adr-updates.md

[OUTPUT]
- docs/features/{{feature_slug}}.md (feature spec)
- .workflows/document/api-changes.md (API delta)
- .workflows/document/adr-updates.md (ADR change log)
- docs/adr/*.md (updated ADRs)
```

### Delta Scanner Prompt
**Use Agent**: codebase-doc-collector
**Prompt**:
```
[IDENTITY]
You are the Delta Scanner checking existing documentation for inconsistencies
caused by new code changes. You are NOT regenerating docs — you are doing
a targeted delta scan.

[CONTEXT]
Changed files: .workflows/implement/PROGRESS.md
Existing docs: docs/ directory
Existing cache: .codemap-cache/ (if present, read-only)

[TASK]
1. Read PROGRESS.md — get list of all new/modified files
2. Extract class names, endpoint paths, entity names from changed files
3. Scan docs/ for references to these:
   - docs/CODEMAPS/*.md — check for stale/missing entries
   - docs/architecture/*.md — check for inconsistencies
   - docs/references/openapi.yaml — check for missing endpoints
   - docs/INDEX.md — check for missing entries
4. Categorize each finding:
   - STALE: docs reference changed code
   - MISSING: new code not in docs
   - BROKEN_LINK: docs link to moved/renamed files
5. Auto-fix what you can:
   - Update stale class/method references
   - Add entries to INDEX.md
   - Update CODEMAPS entries
6. If > 10 stale entries: STOP fixing and recommend /docs-suite

[CONSTRAINTS]
- NEVER generate .codemap-cache/ — read only
- NEVER regenerate full CODEMAPS — only delta updates
- NEVER create system-profile.md — that's /docs-suite territory
- Work ONLY with files from PROGRESS.md (no full src/ scan)
- Timebox: 10 minutes max

[OUTPUT]
.workflows/document/delta-report.md:
  - Summary of findings
  - Per-file changes (what was found, what was fixed)
  - Deferred items (what needs manual review)
```

### Compile Prompt (Team Lead)
**Prompt**:
```
[TASK]
Compile documentation outputs from both tracks into DOCS.md.

1. Read feature-writer output (feature spec, API delta, ADR updates)
2. Read delta-scanner output (delta report, auto-fixed files)
3. Cross-check consistency:
   - Feature spec endpoints match api-changes.md
   - ADR references in feature spec link correctly
   - Delta fixes don't conflict with feature-writer output
4. Create .workflows/document/DOCS.md using the format above
5. Present summary to user
6. Ask: "Documentation looks good. Proceed to PR? (yes/fix/skip-docs)"
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] Feature spec created at `docs/features/{slug}.md`
- [ ] DOCS.md exists with summary of all doc changes
- [ ] Delta report produced (even if zero findings)
- [ ] ADRs finalized (status updated)

### Good Outcome
- [ ] API documentation updated (openapi.yaml additions)
- [ ] Existing docs updated with stale reference fixes
- [ ] INDEX.md updated (if exists)
- [ ] Feature spec includes architecture diagram from design phase
- [ ] Security notes from review included in feature spec

### Excellent Outcome
- [ ] Zero stale documentation references after delta scan
- [ ] Feature spec is publication-ready for stakeholders without edits
- [ ] ADRs include "Implementation Notes" for any design deviations
- [ ] Step completes in under 10 minutes
- [ ] CODEMAPS updated with new components (if CODEMAPS exist)

---

## Anti-Patterns

### What to Avoid

1. **Full Regeneration**: Attempting to regenerate all project docs. This step is incremental. If full regeneration is needed, use `/docs-suite` separately.

2. **Blocking on Docs**: Making documentation a hard gate. Code is already reviewed and approved — doc issues should not prevent merge.

3. **Generating System Profile**: Creating or updating `docs/architecture/system-profile.md`. That is documentation-suite territory.

4. **Cache Regeneration**: Running a full codebase scan and regenerating `.codemap-cache/`. This step reads existing cache, never writes it.

5. **Skipping Track B**: Only generating new docs without checking existing ones. The incremental update is what prevents documentation drift.

6. **Prose-Heavy Feature Specs**: Writing long narrative feature specs. Use the compact template with tables, bullets, and diagrams.

7. **Documenting Before Review**: Running this step before Review approval. The documented code must be the final reviewed code.

### Warning Signs
- Step takes more than 20 minutes — scope too wide, use `/docs-suite`
- Delta scanner finds > 10 issues — existing docs significantly stale
- Feature spec is longer than 2 pages — not compact enough
- No delta report produced — Track B was skipped
- ADRs still in "Proposed" status — finalization not performed

---

## Example Walkthrough

### Context
Task: "Add Apple Health integration to the wellness-backend"
Review passed: APPROVED, Quality 9/10, Security 9/10.
PROGRESS.md shows: 10 new files, 2 modified files, 15 tests.
Project has existing `docs/` with INDEX.md, CODEMAPS/, features/, references/openapi.yaml.

### How It Played Out

**Phase 1 (SCOPE)**:
```
Lead reads:
  PROGRESS.md: 10 new files in src/Service/Integration/AppleHealth/,
               src/Controller/Api/V1/Integration/, src/MessageHandler/
  REVIEW.md: APPROVED, 0 blocking issues
  DESIGN.md: 3 ADRs, 3 new endpoints, 1 new RabbitMQ queue

Scope determined:
  Track A: feature spec (yes), API delta (yes, 3 endpoints), ADR finalization (3 ADRs)
  Track B: docs/ exists (yes), CODEMAPS exist (yes), INDEX.md exists (yes)
  Architecture-doc-collector: NOT needed (follows existing integration pattern)
```

**Phase 2 (GENERATE — parallel)**:
```
Track A (feature-writer):
  docs/features/apple-health-integration.md:
    Status: In Development
    Overview: Apple Health wearable integration using device-token auth
    API Changes:
      | POST /api/v1/integrations/apple-health/connect | Connect device |
      | POST /api/v1/integrations/apple-health/webhook | Receive sync data |
      | GET  /api/v1/integrations/apple-health/status  | Check connection |
    Architecture: simplified sequence diagram from design
    Security: OWASP PASS, PII/PHI PASS, webhook HMAC+timestamp

  api-changes.md:
    OpenAPI YAML snippet for 3 new endpoints
    (appended to docs/references/openapi.yaml)

  adr-updates.md:
    ADR-001 (auth strategy): Proposed -> Accepted
    ADR-002 (sync approach): Proposed -> Accepted
    ADR-003 (data mapping): Proposed -> Accepted (with note: added
      AppleHealthWorkoutType enum not in original design)

Track B (delta-scanner):
  Scanned docs/ against PROGRESS.md file list:
    STALE: docs/CODEMAPS/services.md — no entry for AppleHealthClient
    STALE: docs/CODEMAPS/messages.md — no entry for AppleHealthSyncHandler
    MISSING: docs/INDEX.md — no entry for apple-health-integration feature
    MISSING: docs/CODEMAPS/integrations.md — no Apple Health entry

  Auto-fixed:
    - Added AppleHealthClient to services.md
    - Added AppleHealthSyncHandler to messages.md
    - Added feature spec link to INDEX.md
    - Added Apple Health to integrations.md

  delta-report.md: 4 findings, 4 auto-fixed, 0 manual review
```

**Phase 3 (COMPILE)**:
```
Lead cross-checks:
  Feature spec endpoints match api-changes.md — consistent
  ADR references in feature spec link correctly — consistent
  Delta fixes do not conflict with feature-writer output — no conflicts

DOCS.md:
  Feature Spec: Created (docs/features/apple-health-integration.md)
  API Docs: Updated (3 endpoints added to openapi.yaml)
  ADRs Finalized: 3 (all Accepted)
  Existing Docs Updated: 4 files
  Code Issues: None

Presented to user:
  "Documentation complete. 1 feature spec created, 3 ADRs finalized,
   4 existing doc entries updated. Proceed to PR? (yes/fix/skip-docs)"
  User: "yes"

Proceed to PR step.
```

### Outcome
- Feature spec ready for stakeholders
- API docs updated for external teams
- ADRs promoted to permanent project documentation
- No documentation drift — existing docs updated incrementally
- Total time: ~8 minutes

---

## Related

- **Previous step**: [5-review.md](./5-review.md) — Full-scope code review
- **Next step**: [7-pr.md](./7-pr.md) — Create branch and PR
- **Redirect from**: [5-review.md](./5-review.md) — When review APPROVED
- **Agent files**: [technical-writer](../../agents/technical-writer.md), [codebase-doc-collector](../../agents/codebase-doc-collector.md)
- **Skills**: [feature-spec-template](../../skills/documentation/feature-spec-template.md), [api-docs-template](../../skills/documentation/api-docs-template.md), [codemap-template](../../skills/documentation/codemap-template.md)
- **Input**: `.workflows/design/`, `.workflows/implement/PROGRESS.md`, `.workflows/review/`, `docs/`
- **Output**: `.workflows/document/DOCS.md`, `docs/features/`, `docs/adr/`, updated existing docs
- **Feedback loop**: If significant code issues found → `.workflows/document/CODE-ISSUE.md` → user decides
