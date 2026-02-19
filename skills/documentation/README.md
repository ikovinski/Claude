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

## Used By

- **Technical Writer** agent (primary)
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
    ├── features/
    │   └── feature-name.md   # Feature specs
    ├── adr/
    │   └── 0001-decision.md  # ADRs
    └── runbooks/
        └── service-name.md   # Runbooks
```
