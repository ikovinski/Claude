# /dev Workflow — Artifact Specification

## Directory Structure

```
.workflows/
├── state.json                          # Flow state tracking
│
├── research/                           # Step 1 output
│   ├── RESEARCH.md                     # Lead aggregation
│   ├── code-analysis.md                # Code components, dependencies
│   ├── data-model.md                   # Entities, DTOs, relations
│   ├── architecture-analysis.md        # AS-IS architecture, integrations
│   └── test-coverage.md                # Tests, coverage gaps
│
├── design/                             # Step 2 output
│   ├── DESIGN.md                       # Main design document
│   ├── diagrams.md                     # Mermaid: C4, DataFlow, Sequence
│   ├── api-contracts.md                # Endpoints, schemas, errors
│   └── adr/                            # Architecture Decision Records
│       ├── 001-{decision-slug}.md      # Auto: 1 file if 1-2 decisions
│       └── ...                         # Auto: N files if 3+ decisions
│
├── plan/{feature-slug}/                # Step 3 output
│   └── 001-PLAN.md                     # Numbered for versioning
│
├── implement/                          # Step 4 output
│   ├── PROGRESS.md                     # Phase tracking table
│   └── REPLAN-NEEDED.md               # (optional) triggers Plan re-run
│
├── review/{feature-slug}/              # Step 5 output
│   └── REVIEW.md                       # Quality + Security findings
│
├── document/                           # Step 6 output
│   ├── DOCS.md                         # Documentation summary
│   ├── feature-spec.md                 # Feature spec (working copy)
│   ├── api-changes.md                  # API delta (OpenAPI snippet)
│   ├── adr-updates.md                  # ADR status change log
│   └── delta-report.md                 # Existing docs delta scan
│
└── pr/                                 # Step 7 output
    └── PR.md                           # PR description draft
```

## Per-Step Artifact Mapping

### Step 1: Research

| Input | Output | Validation |
|-------|--------|------------|
| None (first step) | `.workflows/research/` (5 files) | All 5 files exist, RESEARCH.md links to detail files |

| File | Producer | Content |
|------|----------|---------|
| RESEARCH.md | Lead (researcher) | Aggregated summary, cross-cutting concerns, open questions |
| code-analysis.md | codebase-doc-collector | Components, dependencies, packages |
| data-model.md | codebase-doc-collector | Entities, DTOs, relations, migrations |
| architecture-analysis.md | architecture-doc-collector | AS-IS diagrams (Mermaid), integrations, boundaries |
| test-coverage.md | codebase-doc-collector | Existing tests, coverage gaps, patterns |

**Constraint**: All files AS-IS only. No proposals.

### Step 2: Design

| Input | Output | Validation |
|-------|--------|------------|
| `.workflows/research/` | `.workflows/design/` | DESIGN.md exists, diagrams valid Mermaid |

| File | Producer | Content |
|------|----------|---------|
| DESIGN.md | architecture-advisor | Overview, architecture changes, decisions summary |
| diagrams.md | architecture-advisor | C4 context, DataFlow, Sequence diagrams (Mermaid) |
| api-contracts.md | technical-writer | Endpoints, request/response schemas, errors |
| adr/*.md | architecture-advisor | ADR(s) — auto-count based on decisions |

### Step 3: Plan

| Input | Output | Validation |
|-------|--------|------------|
| `.workflows/research/` + `.workflows/design/` | `.workflows/plan/{slug}/001-PLAN.md` | PLAN.md has phases with files, TDD, verification |

### Step 4: Implement

| Input | Output | Validation |
|-------|--------|------------|
| `.workflows/plan/{slug}/001-PLAN.md` + `.workflows/design/` | Code files + `.workflows/implement/PROGRESS.md` | Tests pass, PROGRESS.md tracks all phases |

### Step 5: Review

| Input | Output | Validation |
|-------|--------|------------|
| `.workflows/design/` + code files | `.workflows/review/{slug}/REVIEW.md` | No blocking issues for PR step |

### Step 6: Document

| Input | Output | Validation |
|-------|--------|------------|
| `.workflows/design/` + `.workflows/implement/PROGRESS.md` + `.workflows/review/` + `docs/` | `.workflows/document/` (5 files) + updated `docs/` files | DOCS.md exists, feature spec created |

| File | Producer | Content |
|------|----------|---------|
| DOCS.md | Team Lead (technical-writer) | Summary of all doc changes, both tracks |
| feature-spec.md | feature-writer (technical-writer) | Compact feature spec (working copy) |
| api-changes.md | feature-writer (technical-writer) | OpenAPI delta snippet for new endpoints |
| adr-updates.md | feature-writer (technical-writer) | ADR status change log (Proposed → Accepted) |
| delta-report.md | delta-scanner (codebase-doc-collector) | Stale/missing/broken docs findings |

**Project-level outputs**: `docs/features/{slug}.md`, `docs/adr/*.md`, `docs/references/openapi.yaml`, updated CODEMAPS/INDEX.md

### Step 7: PR

| Input | Output | Validation |
|-------|--------|------------|
| All artifacts + code + docs | `.workflows/pr/PR.md` + git branch/commits | Branch exists, commits clean, docs staged |

## Feature Slug Convention

```
Task: "Add Apple Health integration"
Slug: apple-health-integration

Rules:
- lowercase
- spaces → hyphens
- remove articles (a, an, the)
- max 5 words
```

## Artifact Validation Rules

Before each step, validate prerequisites:

```
Research:  no prerequisites
Design:   .workflows/research/RESEARCH.md must exist
Plan:     .workflows/design/DESIGN.md must exist
Implement:.workflows/plan/*/001-PLAN.md must exist
Review:   .workflows/implement/PROGRESS.md must exist (or standalone mode)
Document: .workflows/review/*/REVIEW.md must exist with APPROVED verdict (or standalone mode)
PR:       .workflows/document/DOCS.md must exist (or standalone mode)
```

## REPLAN-NEEDED.md

Created by Implement step when PLAN.md is infeasible:

```markdown
# Replan Needed

## Reason
{Why the current plan doesn't work}

## Phase
Phase {N} — {phase name}

## Discovered Issue
{What was found during implementation}

## Suggestion for Replanning
{What needs to change in the plan}
```

When `/dev` detects this file, it redirects to Plan step.
