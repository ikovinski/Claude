# Skills Index

Цей файл показує всі доступні skills та їх використання в системі.

## Структура Skills

```
skills/
├── architecture/              # Architecture & decisions
│   ├── architecture-decision-template.md
│   └── decision-matrix.md
├── code-quality/              # Code quality & refactoring
│   ├── refactoring-patterns.md
│   ├── test-patterns.md
│   └── dead-code-detection.md
├── documentation/             # Cross-team docs (Stoplight-compatible)
│   ├── api-docs-template.md
│   ├── feature-spec-template.md
│   ├── adr-template.md
│   ├── runbook-template.md
│   ├── readme-template.md
│   ├── system-profile-template.md
│   ├── integration-template.md
│   └── codemap-template.md
├── planning/                  # Planning & decomposition
│   ├── planning-template.md
│   ├── vertical-slicing.md
│   └── epic-breakdown.md
├── risk-management/           # Risk assessment
│   └── risk-assessment.md
├── security/                  # Security practices
│   ├── security-audit-checklist.md
│   └── owasp-top-10.md
├── tdd/                       # Test-Driven Development
│   └── tdd-workflow.md
├── dev-workflow/              # /dev pipeline templates
│   ├── research-template.md
│   └── design-template.md
├── engineering/               # Legacy/general skills
│   ├── code-review.md
│   └── task-decomposition.md
└── {project}-patterns/        # Auto-generated project skills
    └── SKILL.md
```

## Skills by Category

### Architecture

| Skill | Use for | Used by |
|-------|---------|---------|
| `architecture-decision-template.md` | ADR template, decision documentation | architecture-advisor, rewrite-decision |
| `decision-matrix.md` | Weighted decisions, trade-off analysis | architecture-advisor, decision-challenger, rewrite-decision |

### Code Quality

| Skill | Use for | Used by |
|-------|---------|---------|
| `refactoring-patterns.md` | Extract Method, Replace Conditional, etc. | refactor-cleaner |
| `test-patterns.md` | AAA, Mocks, Data Providers, PHPUnit | tdd-guide |
| `dead-code-detection.md` | PHPStan, Psalm, coverage analysis | refactor-cleaner |

### Planning

| Skill | Use for | Used by |
|-------|---------|---------|
| `planning-template.md` | Implementation plan structure | planner, feature-decomposition |
| `vertical-slicing.md` | Deliverable increments (1-3 days) | feature-decomposer, feature-decomposition |
| `epic-breakdown.md` | Epic → Feature → Story decomposition | feature-decomposer, feature-decomposition |

### Risk Management

| Skill | Use for | Used by |
|-------|---------|---------|
| `risk-assessment.md` | Risk matrix, mitigation strategies | planner, decision-challenger, rewrite-decision |

### Security

| Skill | Use for | Used by |
|-------|---------|---------|
| `security-audit-checklist.md` | Auth, Input, Data, API security checks | security-reviewer |
| `owasp-top-10.md` | OWASP Top 10 with PHP/Symfony examples | security-reviewer |

### TDD

| Skill | Use for | Used by |
|-------|---------|---------|
| `tdd-workflow.md` | Red-Green-Refactor cycle, TDD rules | tdd-guide |

### Documentation (Stoplight-compatible)

| Skill | Use for | Used by |
|-------|---------|---------|
| `api-docs-template.md` | OpenAPI 3.x endpoint documentation | technical-writer |
| `feature-spec-template.md` | Feature specs for managers/stakeholders | technical-writer |
| `adr-template.md` | Architecture Decision Records | technical-writer, architecture-advisor |
| `runbook-template.md` | Operational runbooks for Ops/SRE | technical-writer |
| `readme-template.md` | Service README structure | technical-writer |
| `system-profile-template.md` | System context, integrations overview | architecture-doc-collector |
| `integration-template.md` | Single integration documentation | architecture-doc-collector |
| `codemap-template.md` | Auto-generated architectural maps | codebase-doc-collector |

### Dev Workflow

| Skill | Use for | Used by |
|-------|---------|---------|
| `research-template.md` | Templates for research output (5 files: RESEARCH.md, code-analysis, data-model, architecture-analysis, test-coverage) | researcher (dev-workflow/1-research) |
| `design-template.md` | Templates for design output (DESIGN.md, diagrams, api-contracts, ADR auto-count) | architecture-advisor (dev-workflow/2-design) |

### Engineering (Legacy)

| Skill | Use for | Used by |
|-------|---------|---------|
| `code-review.md` | Code review workflow | (consider deprecating) |
| `task-decomposition.md` | Task breakdown methodology | (consider deprecating) |

## Agent → Skills Mapping

| Agent | Category | Skills |
|-------|----------|--------|
| **code-reviewer** | — | `{project}-patterns` |
| **security-reviewer** | Security | `{project}-patterns`, `security/security-audit-checklist`, `security/owasp-top-10` |
| **planner** | Planning | `{project}-patterns`, `planning/planning-template`, `risk-management/risk-assessment` |
| **feature-decomposer** | Planning | `{project}-patterns`, `planning/vertical-slicing`, `planning/epic-breakdown` |
| **tdd-guide** | TDD + Quality | `{project}-patterns`, `tdd/tdd-workflow`, `code-quality/test-patterns` |
| **refactor-cleaner** | Code Quality | `{project}-patterns`, `code-quality/refactoring-patterns`, `code-quality/dead-code-detection` |
| **architecture-advisor** | Architecture | `{project}-patterns`, `architecture/architecture-decision-template`, `architecture/decision-matrix` |
| **decision-challenger** | Risk + Arch | `risk-management/risk-assessment`, `architecture/decision-matrix` |
| **technical-writer** | Documentation | `{project}-patterns`, `documentation/api-docs-template`, `documentation/feature-spec-template`, `documentation/adr-template`, `documentation/runbook-template`, `documentation/readme-template` |
| **architecture-doc-collector** | Documentation | `{project}-patterns`, `documentation/system-profile-template`, `documentation/integration-template` |
| **codebase-doc-collector** | Documentation | `{project}-patterns`, `documentation/codemap-template` |
| **researcher** | Dev Workflow | `{project}-patterns`, `dev-workflow/research-template` |

## Scenario → Skills Mapping

| Scenario | Skills Used |
|----------|-------------|
| **feature-decomposition** | `planning/epic-breakdown`, `planning/vertical-slicing`, `planning/planning-template` |
| **rewrite-decision** | `architecture/architecture-decision-template`, `architecture/decision-matrix`, `risk-management/risk-assessment` |
| **dev-workflow/1-research** | `dev-workflow/research-template`, `{project}-patterns` |
| **dev-workflow/2-design** | `dev-workflow/design-template`, `architecture/architecture-decision-template`, `documentation/adr-template` |
| **dev-workflow/3-plan** | `planning/planning-template`, `planning/vertical-slicing`, `planning/epic-breakdown`, `risk-management/risk-assessment` |
| **dev-workflow/4-implement** | `tdd/tdd-workflow`, `code-quality/test-patterns`, `{project}-patterns` |
| **dev-workflow/5-review** | `code-quality/refactoring-patterns`, `security/owasp-top-10`, `security/security-audit-checklist` |

## How to Use

### For Agents
Skills автоматично завантажуються через frontmatter:
```yaml
skills:
  - auto:{project}-patterns
  - security/owasp-top-10
```

### For Manual Reference
Агенти можуть посилатися на skills-index.md щоб дізнатись які skills доступні.

### For Project Skills
```bash
cd ~/your-project
/skill-create --commits 100
# Creates ~/.claude/skills/your-project-patterns/SKILL.md
```
