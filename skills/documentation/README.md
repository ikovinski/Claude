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

## Used By

- **Technical Writer** agent — API docs, feature specs, ADRs, runbooks
- **Architecture Documenter** agent — System profiles, integration catalogs
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
