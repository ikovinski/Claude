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

## Structure

```
ai-agents-system/
├── agents/           # AI personas with specific biases
│   ├── technical/    # Code-focused agents
│   └── facilitation/ # Process-focused agents
├── commands/         # Slash commands (/plan, /review, etc.)
├── skills/           # Reusable workflows
├── scenarios/        # Multi-step processes
├── rules/            # Always-follow guidelines
├── contexts/         # Mode-specific focus
└── hooks/            # Automated triggers
```

## Commands (Slash Commands)

Quick-invoke workflows via `/command`:

| Command | What It Does | Agent |
|---------|--------------|-------|
| `/plan` | Create implementation plan | Planner |
| `/review` | Code review | Code Reviewer |
| `/tdd` | Start TDD workflow | TDD Guide |
| `/security-check` | Security review | Security Reviewer |
| `/skill-create` | Generate skill from git history | — |

### Usage Examples

```bash
/plan "Add workout sharing to social feed"
/review src/MessageHandler/SyncHandler.php
/tdd "CalorieCalculator service"
/security-check src/Controller/Api/
/skill-create --commits 100
```

## Agent Routing

### Core Agents (Original)

| Request Pattern | Agent | File |
|-----------------|-------|------|
| Code review, PR review | `code-reviewer` | [agents/technical/code-reviewer.md](agents/technical/code-reviewer.md) |
| Decompose, break down tasks | `decomposer` | [agents/technical/decomposer.md](agents/technical/decomposer.md) |
| Architecture, technical decision | `staff-engineer` | [agents/technical/staff-engineer.md](agents/technical/staff-engineer.md) |
| Challenge, what could go wrong | `devils-advocate` | [agents/facilitation/devils-advocate.md](agents/facilitation/devils-advocate.md) |

### New Agents (From everything-claude-code)

| Request Pattern | Agent | File |
|-----------------|-------|------|
| Security review, vulnerabilities, OWASP | `security-reviewer` | [agents/technical/security-reviewer.md](agents/technical/security-reviewer.md) |
| TDD, write tests, coverage | `tdd-guide` | [agents/technical/tdd-guide.md](agents/technical/tdd-guide.md) |
| Implementation plan, how to build | `planner` | [agents/technical/planner.md](agents/technical/planner.md) |
| Dead code, cleanup, refactor | `refactor-cleaner` | [agents/technical/refactor-cleaner.md](agents/technical/refactor-cleaner.md) |

## Scenario Routing

| Request Pattern | Scenario | File |
|-----------------|----------|------|
| Feature decomposition, epic breakdown | Feature Decomposition | [scenarios/delivery/feature-decomposition.md](scenarios/delivery/feature-decomposition.md) |
| Should we rewrite, rebuild vs refactor | Rewrite Decision | [scenarios/technical-decisions/rewrite-decision.md](scenarios/technical-decisions/rewrite-decision.md) |

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

### Recommended Sequences

```
Feature Development:
Planner → Decomposer → TDD Guide → Code Reviewer → Security Reviewer

Refactoring:
Refactor Cleaner → Code Reviewer → TDD Guide (add missing tests)

Architecture Decision:
Staff Engineer → Devil's Advocate → Decomposer (if approved)
```

## Project Skills (Auto-generated)

Skills generated via `/skill-create` contain project-specific patterns:

```
skills/
├── wellness-backend-patterns/    # Generated from wellness-backend repo
│   └── SKILL.md
├── billing-service-patterns/     # Generated from billing-service repo
│   └── SKILL.md
└── engineering/                  # Manual skills
    ├── code-review.md
    └── task-decomposition.md
```

### How Skills Are Used

When agent is activated:
1. **Check for project skill** — look for `skills/{project-name}-patterns/SKILL.md`
2. **If exists, load it** — apply project conventions
3. **Merge with agent rules** — project patterns + general rules

### Example

```
User is in: ~/repo/wellness-backend
Calls: /review src/Service/WorkoutService.php

Agent loads:
1. agents/technical/code-reviewer.md (persona + biases)
2. rules/security.md, rules/testing.md (general rules)
3. skills/wellness-backend-patterns/SKILL.md (project conventions) ← 🆕
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

See [HOW-TO-USE.md](HOW-TO-USE.md) for detailed instructions.
