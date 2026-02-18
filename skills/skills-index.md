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
| `architecture-decision-template.md` | ADR template, decision documentation | staff-engineer, rewrite-decision |
| `decision-matrix.md` | Weighted decisions, trade-off analysis | staff-engineer, devils-advocate, rewrite-decision |

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
| `vertical-slicing.md` | Deliverable increments (1-3 days) | decomposer, feature-decomposition |
| `epic-breakdown.md` | Epic → Feature → Story decomposition | decomposer, feature-decomposition |

### Risk Management

| Skill | Use for | Used by |
|-------|---------|---------|
| `risk-assessment.md` | Risk matrix, mitigation strategies | planner, devils-advocate, rewrite-decision |

### Security

| Skill | Use for | Used by |
|-------|---------|---------|
| `security-audit-checklist.md` | Auth, Input, Data, API security checks | security-reviewer |
| `owasp-top-10.md` | OWASP Top 10 with PHP/Symfony examples | security-reviewer |

### TDD

| Skill | Use for | Used by |
|-------|---------|---------|
| `tdd-workflow.md` | Red-Green-Refactor cycle, TDD rules | tdd-guide |

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
| **decomposer** | Planning | `{project}-patterns`, `planning/vertical-slicing`, `planning/epic-breakdown` |
| **tdd-guide** | TDD + Quality | `{project}-patterns`, `tdd/tdd-workflow`, `code-quality/test-patterns` |
| **refactor-cleaner** | Code Quality | `{project}-patterns`, `code-quality/refactoring-patterns`, `code-quality/dead-code-detection` |
| **staff-engineer** | Architecture | `{project}-patterns`, `architecture/architecture-decision-template`, `architecture/decision-matrix` |
| **devils-advocate** | Risk + Arch | `risk-management/risk-assessment`, `architecture/decision-matrix` |

## Scenario → Skills Mapping

| Scenario | Skills Used |
|----------|-------------|
| **feature-decomposition** | `planning/epic-breakdown`, `planning/vertical-slicing`, `planning/planning-template` |
| **rewrite-decision** | `architecture/architecture-decision-template`, `architecture/decision-matrix`, `risk-management/risk-assessment` |

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
cd ~/repo/your-project
/skill-create --commits 100
# Creates ~/.claude/skills/your-project-patterns/SKILL.md
```
