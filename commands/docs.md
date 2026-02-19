---
name: docs
description: Generate documentation for cross-team communication. Creates Stoplight.io compatible docs (OpenAPI, Markdown).
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit"]
agent: technical-writer
---

# /docs - Documentation Generator

Створює high-level документацію для cross-team communication та manager visibility. Вивід сумісний зі Stoplight.io.

## Usage

```bash
/docs <file>                    # Document specific file/service
/docs --api <endpoint>          # Generate OpenAPI docs for endpoint
/docs --feature <name>          # Create feature specification
/docs --adr <decision>          # Create Architecture Decision Record
/docs --runbook <service>       # Create operational runbook
/docs --readme                  # Generate service README
```

## What It Does

1. **Визначає audience** — технічні спеціалісти інших команд? менеджери?
2. **Сканує код** — Controllers, DTOs, validation rules, routes
3. **Генерує OpenAPI** — у `docs/references/openapi.yaml`
4. **Додає Mermaid діаграми** — sequence diagrams, flowcharts
5. **Створює документацію** — Stoplight-compatible format
6. **Пропонує next steps** — review, publish, notify teams

## Documentation Types

| Type | Audience | Output |
|------|----------|--------|
| API Docs | Other team devs | `docs/references/openapi.yaml` + Mermaid diagrams |
| Feature Spec | Managers, PMs | `docs/features/{name}.md` |
| ADR | Architects, maintainers | `docs/adr/{number}-{slug}.md` |
| Runbook | Ops, SRE, on-call | `docs/runbooks/{service}.md` |
| README | All technical audiences | `README.md` |

## Key Features

### Code-Driven Swagger
При `--api` сканує код і генерує OpenAPI:
- Знаходить `#[Route]` атрибути в Controllers
- Витягує типи з DTOs
- Додає validation rules з `#[Assert\*]`
- Генерує у `docs/references/`

### Mermaid Diagrams (автоматично)
Додає візуалізацію:
- **Sequence diagrams** — для API flows
- **Flowcharts** — для бізнес-логіки
- **State diagrams** — для entity lifecycle
- **ER diagrams** — для data models

## Output Format

```markdown
## Documentation Type: [API Docs | Feature Spec | ADR | Runbook]

### Target Audience
[Who will read this and what they need]

### File Location
`docs/path/to/file.md`

---

[DOCUMENTATION CONTENT]

---

### Next Steps
- [ ] Review with [stakeholder]
- [ ] Add to Stoplight project
- [ ] Notify dependent teams
```

## Examples

### API Documentation

```
> /docs --api /api/v1/workouts

## Documentation Type: API Docs

### Target Audience
Developers from Social team who need to display workout data in feed.

### File Location
`openapi.yaml` (paths section) + `docs/api/workouts.md`

---

# Workouts API

## Endpoints

### GET /api/v1/workouts/{id}

Retrieves a single workout with exercises.

**Permissions**: `workout:read` scope
**Rate limit**: 100 req/min

#### Request

\`\`\`http
GET /api/v1/workouts/wkt_abc123 HTTP/1.1
Host: api.example.com
Authorization: Bearer {token}
\`\`\`

#### Response (200 OK)

\`\`\`json
{
  "id": "wkt_abc123",
  "name": "Morning Run",
  "duration": 3600,
  "calories": 450
}
\`\`\`

---

### Next Steps
- [ ] Review with @social-team
- [ ] Add to Stoplight project
- [ ] Update API changelog
```

### Feature Specification

```
> /docs --feature "Workout Sharing"

## Documentation Type: Feature Spec

### Target Audience
Managers tracking Q1 deliverables, Social team for integration planning.

### File Location
`docs/features/workout-sharing.md`

---

# Feature: Workout Sharing

## Status

| Aspect | Value |
|--------|-------|
| **Status** | In Development |
| **Target** | 2024-Q1 |
| **Owner** | @team-wellness |

## Overview

Users can share completed workouts to their social feed.

## Scope

**Included**: Share to feed, privacy controls, basic reactions

**Not Included**: External platforms, challenges, comments

## Integration Points

| Team | What They Need | Status |
|------|----------------|--------|
| Social | POST to /feed/items | Ready |
| Notifications | workout.shared event | Spec shared |

---

### Next Steps
- [ ] Review with PM
- [ ] Share with Social team lead
- [ ] Update roadmap
```

### Architecture Decision Record

```
> /docs --adr "Switch from MySQL to PostgreSQL for analytics"

## Documentation Type: ADR

### Target Audience
Future maintainers, architects reviewing past decisions.

### File Location
`docs/adr/0005-postgresql-for-analytics.md`

---

# ADR-0005: Use PostgreSQL for Analytics Database

**Status**: Proposed | **Date**: 2024-01-20

## Context

MySQL struggling with complex analytical queries.
P95 for dashboard queries > 5 seconds.

## Decision

Use PostgreSQL 15 for analytics workloads.

## Consequences

**Positive**: Better query performance, native JSON support
**Negative**: Additional database to maintain

---

### Next Steps
- [ ] Review with staff engineer
- [ ] Present at architecture meeting
- [ ] Schedule migration if approved
```

## Integration with Other Agents

### Automatic Suggestions

| After | Technical Writer Suggests |
|-------|--------------------------|
| Code Review finds undocumented API | `/docs --api <endpoint>` |
| Planner creates implementation plan | `/docs --feature <name>` for stakeholders |
| Security Review approves auth changes | Update authentication docs |
| New service deployed | `/docs --runbook <service>` |

## Stoplight.io Integration

Generated docs follow Stoplight structure:

```
project/
├── openapi.yaml          # API specification
├── README.md             # Project overview
└── docs/
    ├── features/         # Feature specs
    ├── adr/              # Architecture decisions
    └── runbooks/         # Operational docs
```

All Markdown files include `stoplight-id` frontmatter for proper rendering.

## Checklist Applied

During documentation:

### Content
- [ ] Audience clearly identified
- [ ] Examples included (not just descriptions)
- [ ] No internal jargon without definition
- [ ] Status and dates current

### Format
- [ ] Stoplight-compatible structure
- [ ] Proper frontmatter
- [ ] Tables for scannable data
- [ ] Code blocks for examples

### Quality
- [ ] Working curl/code examples
- [ ] Error responses documented
- [ ] No implementation details leaked
- [ ] Links to related docs

---

*Uses [Technical Writer Agent](../agents/technical/technical-writer.md)*
