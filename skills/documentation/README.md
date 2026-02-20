# Documentation Skills

Skills for creating high-level documentation targeting cross-team communication and manager visibility.

## Target Platform

**Stoplight.io** — All templates are compatible with Stoplight's documentation platform:
- OpenAPI 3.x specifications
- Markdown with frontmatter
- Proper file structure for Stoplight projects

## Available Skills

| Skill | Purpose | Audience |
|-------|---------|----------|
| [api-docs-template](api-docs-template.md) | OpenAPI endpoint documentation | External team devs |
| [feature-spec-template](feature-spec-template.md) | Feature status and scope | Managers, PMs |
| [adr-template](adr-template.md) | Architecture Decision Records | Architects, future maintainers |
| [runbook-template](runbook-template.md) | Operational procedures | Ops, SRE, on-call |
| [readme-template](readme-template.md) | Service/project overview | All technical audiences |
| [system-profile-template](system-profile-template.md) | System context, integrations overview | New team members, architects |
| [integration-template](integration-template.md) | Single integration documentation | Devs, Ops/SRE |
| [codemap-template](codemap-template.md) | Auto-generated architectural maps | Devs, new team members |

## Used By

- **Technical Writer** agent — API docs, feature specs, ADRs, runbooks
- **Architecture Documenter** agent — System profiles, integration catalogs
- **Doc-Updater** agent — Codemaps, automated documentation
- **Planner** agent (feature specs after planning)
- **Code Reviewer** agent (suggests docs for undocumented code)

## Documentation Principles

1. **Audience-first** — Know who reads before writing
2. **Scannable** — Headers, tables, bullets over prose
3. **Examples** — Working code > abstract descriptions
4. **Living** — Only document stable interfaces

## File Structure for Stoplight

```
project/
├── openapi.yaml              # Main API spec
├── README.md                 # Project overview
└── docs/
    ├── getting-started.md
    ├── authentication.md
    ├── references/           # Generated API specs
    │   └── openapi.yaml
    ├── architecture/         # System-level docs
    │   ├── system-profile.md
    │   ├── context-diagram.md
    │   └── integrations/
    │       ├── README.md     # Integration catalog
    │       └── {category}/
    │           └── {integration}.md
    ├── features/
    │   └── feature-name.md   # Feature specs
    ├── adr/
    │   └── 0001-decision.md  # ADRs
    └── runbooks/
        └── service-name.md   # Runbooks
```

## Agent Responsibilities

| Level | Agent | Focus |
|-------|-------|-------|
| System | Architecture Documenter | Context diagrams, integrations, system boundaries |
| Detail | Technical Writer | API endpoints, features, decisions, operations |
| Automated | Doc-Updater | Codemaps, validation, freshness tracking |

---

## Freshness Policy

All documentation MUST include freshness metadata for validation.

### Required Fields

```yaml
---
last_updated: YYYY-MM-DD
validation_status: current  # current | needs-review | outdated
---
```

### Staleness Thresholds

| Doc Type | Fresh | Stale | Outdated |
|----------|-------|-------|----------|
| API Docs | < 7 days | 7-14 days | > 14 days |
| Feature Specs | < 14 days | 14-30 days | > 30 days |
| Runbooks | < 30 days | 30-60 days | > 60 days |
| ADRs | N/A (historical) | Review annually | — |
| Integrations | < 30 days | 30-90 days | > 90 days |
| System Profiles | < 90 days | 90-180 days | > 180 days |

### Validation

Run documentation validation:

```bash
/codemap --validate      # Check codemaps vs code
/docs --validate         # Check all docs freshness
```

### Automation

- **Pre-PR check**: Warn if docs older than threshold
- **Weekly**: Scan for stale documentation
- **Post-release**: Trigger full docs review
