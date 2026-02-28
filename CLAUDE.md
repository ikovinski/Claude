# AI Agents System

Reusable AI agents, skills, and scenarios for engineering team lead tasks.

## Quick Start

Just describe what you need. The system routes automatically:

| You say... | System uses |
|------------|-------------|
| "Review this code" | Code Reviewer agent |
| "Security review" | Security Reviewer agent |
| "Decompose this feature" | Decomposer → Feature Decomposition scenario |
| "Architecture decision" | Staff Engineer agent |
| "Challenge this plan" | Devil's Advocate agent |
| "Write tests first" / "TDD" | TDD Guide agent |
| "Plan implementation" | Planner agent |
| "Cleanup dead code" | Refactor Cleaner agent |
| "Document this" / "API docs" / "Write docs" | Technical Writer agent |
| "Architecture docs" / "System profile" / "Integration catalog" | Architecture Doc Collector agent |
| "Full documentation" / "Documentation suite" / "Document this project" | Documentation Suite scenario (3 agents team) |
| `/dev "task description"` / "Development workflow" | Dev Workflow — 7-step pipeline (Research → Design → Plan → Implement → Review → Document → PR) |

## Structure

```
ai-agents-system/
├── agents/           # AI personas with specific biases
├── commands/         # Slash commands (/plan, /review, etc.)
├── skills/           # Reusable workflows
├── scenarios/        # Multi-step processes
├── rules/            # Always-follow guidelines
├── contexts/         # Mode-specific focus
└── hooks/            # Automated triggers
```

## Commands (Slash Commands)

Quick-invoke workflows via `/command`:

| Command | What It Does | Agent | Skills Applied |
|---------|--------------|-------|----------------|
| `/plan` | Create implementation plan | Planner | planning/* |
| `/review` | Code review | Code Reviewer | code-quality/* |
| `/tdd` | Start TDD workflow | TDD Guide | tdd/* |
| `/security-check` | Security review | Security Reviewer | security/* |
| `/docs` | Generate documentation (Stoplight-compatible) | Technical Writer | documentation/* |
| `/architecture-docs` | System profiles, integration catalogs | Architecture Doc Collector | documentation/* |
| `/docs-suite` | Complete documentation suite (team-based) | Team (3 agents) | documentation/* |
| `/dev` | Development workflow pipeline (7 steps) | Team (varies per step) | dev-workflow/*, planning/*, tdd/* |
| `/skill-create` | Generate skill from git history | — | — |

### Usage Examples

```bash
/plan "Add workout sharing to social feed"
/review src/MessageHandler/SyncHandler.php
/tdd "CalorieCalculator service"
/security-check src/Controller/Api/
/docs --api /api/v1/workouts
/docs --feature "Workout Sharing"
/architecture-docs
/architecture-docs --integration "Apple App Store"
/docs-suite
/docs-suite --scope architecture
/dev "Add Apple Health integration"
/dev --step review
/dev --step document
/dev --status
/skill-create --commits 100
```

## Agent Routing

### All Agents

| Request Pattern | Agent | File |
|-----------------|-------|------|
| Code review, PR review | `code-reviewer` | [agents/code-reviewer.md](agents/code-reviewer.md) |
| Decompose, break down tasks | `feature-decomposer` | [agents/feature-decomposer.md](agents/feature-decomposer.md) |
| Architecture, technical decision | `architecture-advisor` | [agents/architecture-advisor.md](agents/architecture-advisor.md) |
| Challenge, what could go wrong | `decision-challenger` | [agents/decision-challenger.md](agents/decision-challenger.md) |
| Security review, vulnerabilities, OWASP | `security-reviewer` | [agents/security-reviewer.md](agents/security-reviewer.md) |
| TDD, write tests, coverage | `tdd-guide` | [agents/tdd-guide.md](agents/tdd-guide.md) |
| Implementation plan, how to build | `planner` | [agents/planner.md](agents/planner.md) |
| Dead code, cleanup, refactor | `refactor-cleaner` | [agents/refactor-cleaner.md](agents/refactor-cleaner.md) |
| Document, API docs, feature spec, ADR | `technical-writer` | [agents/technical-writer.md](agents/technical-writer.md) |
| Architecture docs, system profile, integrations | `architecture-doc-collector` | [agents/architecture-doc-collector.md](agents/architecture-doc-collector.md) |
| Codemap generation, code-driven docs | `codebase-doc-collector` | [agents/codebase-doc-collector.md](agents/codebase-doc-collector.md) |
| Research, AS-IS analysis, codebase exploration | `researcher` | [agents/researcher.md](agents/researcher.md) |

## Scenario Routing

| Request Pattern | Scenario | File |
|-----------------|----------|------|
| Feature decomposition, epic breakdown | Feature Decomposition | [scenarios/delivery/feature-decomposition.md](scenarios/delivery/feature-decomposition.md) |
| Should we rewrite, rebuild vs refactor | Rewrite Decision | [scenarios/technical-decisions/rewrite-decision.md](scenarios/technical-decisions/rewrite-decision.md) |
| Full documentation, documentation suite, document project | Documentation Suite | [scenarios/delivery/documentation-suite.md](scenarios/delivery/documentation-suite.md) |
| `/dev`, development workflow, research→design→plan→implement→review→document→PR | Dev Workflow (7 steps) | [scenarios/dev-workflow/](scenarios/dev-workflow/) |

## Rules (Always Applied)

| Rule | Purpose | File |
|------|---------|------|
| Security | PII/PHI protection, auth, encryption | [rules/security.md](rules/security.md) |
| Testing | Coverage requirements, patterns | [rules/testing.md](rules/testing.md) |
| Coding Style | PHP 8.3, Symfony 6.4 standards | [rules/coding-style.md](rules/coding-style.md) |
| Messaging | RabbitMQ/Kafka patterns, idempotency | [rules/messaging.md](rules/messaging.md) |
| Database | Doctrine, N+1, migrations | [rules/database.md](rules/database.md) |

## Contexts (Modes)

| Mode | Focus | File |
|------|-------|------|
| `dev` | Implementation, write code | [contexts/dev.md](contexts/dev.md) |
| `review` | Quality, security, find issues | [contexts/review.md](contexts/review.md) |
| `research` | Understanding, exploration | [contexts/research.md](contexts/research.md) |
| `planning` | Decomposition, strategy | [contexts/planning.md](contexts/planning.md) |

## Domain Context

**Wellness/Fitness Tech (PHP/Symfony Backend)**

- **Tech Stack**: PHP 8.3, Symfony 6.4, Doctrine ORM, MySQL, RabbitMQ, Kafka, Redis, Elasticsearch, Docker, Kubernetes
- **Data Sensitivity**: Health data (PII/PHI) — workouts, nutrition, subscriptions, billing
- **Key Challenges**: Monolith split, DB performance, message idempotency
- **Load**: 30-65 RPS

## Key Agent Biases

| Agent | Core Bias |
|-------|-----------|
| Code Reviewer | Maintainability > cleverness |
| Security Reviewer | Paranoid by default, health data = high stakes |
| Decomposer | Vertical slices > horizontal layers |
| Staff Engineer | Boring technology wins |
| Devil's Advocate | Assume nothing works |
| TDD Guide | Test first, always |
| Planner | Clarity over speed |
| Refactor Cleaner | Less code = less bugs |
| Technical Writer | Audience first, examples > explanations |
| Architecture Doc Collector | Diagram first, tables over prose |
| Researcher | Describe, don't prescribe (AS-IS only) |

## Agent Selection Guide

### When to Use Each Agent

| Situation | Best Agent |
|-----------|------------|
| PR готовий до merge | Code Reviewer |
| Новий API endpoint з user input | Security Reviewer |
| Нова фіча, потрібен план | Planner → Decomposer |
| Пишу новий код | TDD Guide (tests first!) |
| Architectural decision | Staff Engineer |
| Сумніваюсь у рішенні | Devil's Advocate |
| Codebase захаращений | Refactor Cleaner |
| Потрібна документація для інших команд | Technical Writer |
| Feature spec для менеджерів | Technical Writer |
| System overview для onboarding | Architecture Doc Collector |
| Integration catalog | Architecture Doc Collector |
| Повна документація проєкту | `/docs-suite` (Documentation Suite) |
| Onboarding documentation | `/docs-suite` (Documentation Suite) |
| Нова фіча від research до PR | `/dev "task"` (Dev Workflow) |
| Code review всього scope | `/dev --step review` (standalone) |
| Документація фічі + delta scan | `/dev --step document` (standalone) |

### Recommended Sequences

```
Feature Development:
Planner → Decomposer → TDD Guide → Code Reviewer → Security Reviewer → Technical Writer (docs)

Refactoring:
Refactor Cleaner → Code Reviewer → TDD Guide (add missing tests)

Architecture Decision:
Staff Engineer → Devil's Advocate → Decomposer (if approved) → Technical Writer (ADR)

Cross-Team Feature:
Planner → Technical Writer (feature spec for stakeholders) → Decomposer → Implementation

Full Feature Development Pipeline:
/dev "task" → Research → Design (quality gate) → Plan → Implement (TDD + review loop) → Review → Document → PR

System Documentation:
/docs-suite (orchestrates: Codebase Doc Collector → Architecture Doc Collector + Technical Writer → Cross-Review → Index)
  OR manually: Architecture Doc Collector (system profile) → Technical Writer (API docs) → Staff Engineer (review)
```

## Skills System

Skills поділяються на **Universal** (для всіх проєктів) та **Project-specific** (автогенеровані).

### Universal Skills (Categories)

```
skills/
├── architecture/        # ADR templates, decision matrices
├── planning/            # Epic breakdown, vertical slicing
├── code-quality/        # Refactoring patterns, test patterns
├── security/            # OWASP checks, security audit
├── tdd/                 # TDD workflow
├── documentation/       # API docs, feature specs, runbooks (Stoplight-compatible)
├── dev-workflow/        # /dev pipeline templates (research, design)
└── risk-management/     # Risk assessment
```

**Used by agents:**
- Decomposer → planning/*
- Staff Engineer → architecture/*
- Security Reviewer → security/*
- TDD Guide → tdd/*
- Code Reviewer → code-quality/*
- Devil's Advocate → risk-management/*
- Technical Writer → documentation/*
- Architecture Doc Collector → documentation/*

### Project Skills (Auto-generated)

```
skills/
├── wellness-backend-patterns/    # Generated from wellness-backend repo
│   └── SKILL.md
└── billing-service-patterns/     # Generated from billing-service repo
    └── SKILL.md
```

Generated via `/skill-create --commits 100`

### How Skills Are Loaded

**Automatic loading sequence:**

1. **Universal skills** — based on agent type (planning/, security/, etc.)
2. **Project skill** — based on current directory (auto-detected)
3. **Rules** — always applied (security, testing, coding-style, etc.)

### Example: Feature Decomposition

```
User is in: ~/wellness-backend
Says: "Decompose feature: Add Apple Health integration"

System loads:
1. agents/feature-decomposer.md (persona + biases)
2. skills/planning/epic-breakdown.md (universal skill)
3. skills/planning/vertical-slicing.md (universal skill)
4. skills/wellness-backend-patterns/SKILL.md (project conventions) ✓
5. rules/security.md, rules/testing.md (always applied)

Output:
→ Slices follow wellness-backend naming conventions
→ Tests match project patterns
→ Estimates based on historical velocity
```

### Example: Security Review

```
User: "/security-check src/Controller/Api/PaymentController.php"

System loads:
1. agents/security-reviewer.md (persona + biases)
2. skills/security/owasp-top-10.md (universal skill)
3. skills/security/security-audit-checklist.md (universal skill)
4. rules/security.md (PII/PHI protection rules)

Output:
→ OWASP Top 10 checks
→ PII/PHI leak detection
→ Input validation review
→ Auth/authorization checks
```

## How Agents Work

1. **Load the agent file** — get persona, biases, output format
2. **Check for project skill** — load `skills/{project}-patterns/` if exists
3. **Apply biases** — this is what makes each agent valuable
4. **Follow output structure** — consistent, actionable results
5. **Announce which agent** — "Applying [Agent] with bias: [main bias]"

## For Complex Tasks

Multi-step scenarios:

1. Announce current phase
2. Switch agent personas between phases
3. Show output of each phase
4. Ask for input at decision points
5. Wait for approval before proceeding

---

## Documentation

### Core Guides

- **[README.md](README.md)** — System overview, installation, quick start
- **[How Scenarios Work](docs/how-it-works/how-scenarios-work.md)** — Multi-agent workflows explained
- **[Documentation Suite vs Individual Commands](docs/how-it-works/docs-suite-vs-individual-commands.md)** — /docs-suite comparison
- **[Skills Index](skills/skills-index.md)** — Complete skills catalog
- **[Dev Workflow](docs/dev-workflow/README.md)** — /dev pipeline documentation

### By Component

- **[agents/README.md](agents/README.md)** — Agent biases and use cases
- **[skills/README.md](skills/README.md)** — Skills system overview
- **[scenarios/README.md](scenarios/README.md)** — Multi-step workflows
- **[commands/README.md](commands/README.md)** — Slash commands reference
- **[rules/README.md](rules/README.md)** — Always-apply guidelines

---

See [HOW-TO-USE.md](HOW-TO-USE.md) for detailed instructions.
