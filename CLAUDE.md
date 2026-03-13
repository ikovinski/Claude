# AI Agents System

Slash commands for Claude Code CLI. Each command invokes an agent with defined biases and output format.

## Structure

```
ai-agents-system/
├── commands/         # Slash commands (main interface)
├── agents/           # Agent personas referenced by commands
├── rules/            # Domain-specific rules (coding-style, security, testing, database, messaging)
├── contexts/         # Development mode contexts (dev.md — red flags, priorities)
├── scenarios/        # Multi-agent workflows referenced by commands
├── skills/           # Reusable skills (templates, project patterns)
└── templates/        # Templates for creating new agents, scenarios, skills
```

## Commands

| Command | Agent | Description |
|---------|-------|-------------|
| `/feature` | Meta-command | Full feature flow navigator with state tracking |
| `/research` | Research Lead + Codebase Researcher | Investigate codebase before implementation |
| `/design` | Design Architect + Test Strategist + Devil's Advocate | Architecture decisions, ADR, test strategy, design challenge |
| `/plan` | Phase Planner | Decompose design into implementation phases |
| `/implement` | Implement Lead + Writer + Reviewers + Gate | Execute one implementation phase |
| `/docs-suite` | Team Lead + 4 agents | Full documentation suite |
| `/pr` | Direct command | Create PR with design references |
| `/sentry-triage` | Sentry Triager | Collect & categorize Sentry issues into tasks |
| `/skill-from-git` | -- | Extract project skill from git history |
| `/ai-debug` | -- | System status and prompt analysis |

## Agents

### Engineering
| Agent | File | Purpose |
|-------|------|---------|
| Research Lead | `agents/engineering/research-lead.md` | Decompose task, orchestrate research, synthesize report |
| Codebase Researcher | `agents/engineering/codebase-researcher.md` | Scan codebase AS IS — facts only |
| Design Architect | `agents/engineering/design-architect.md` | Diagrams, architecture, ADR, API contracts (contract-first) |
| Test Strategist | `agents/engineering/test-strategist.md` | Test strategy, cases, coverage expectations |
| Phase Planner | `agents/engineering/phase-planner.md` | Decompose design into vertical-slice phases |
| Implement Lead | `agents/engineering/implement-lead.md` | Orchestrate implementation, coordinate team |
| Code Writer | `agents/engineering/code-writer.md` | Write code strictly per plan |
| TDD Guide | `agents/engineering/tdd-guide.md` | TDD coach — test-first discipline, test quality, isolation |
| Security Reviewer | `agents/engineering/security-reviewer.md` | OWASP Top 10, secrets, injection, access control (paranoid by default) |
| Quality Reviewer | `agents/engineering/quality-reviewer.md` | Complexity, SOLID, domain model, layer compliance |
| Design Reviewer | `agents/engineering/design-reviewer.md` | Verify implementation matches design artifacts |
| Quality Gate | `agents/engineering/quality-gate.md` | Run build, tests, linters, Sentry check |
| Devil's Advocate | `agents/engineering/devils-advocate.md` | Challenge architecture decisions, find weak assumptions in ADR |
| Sentry Triager | `agents/engineering/sentry-triager.md` | Collect, categorize, group Sentry issues into tasks |

### Documentation
| Agent | File | Purpose |
|-------|------|---------|
| Technical Collector | `agents/documentation/technical-collector.md` | Collect project facts as-is |
| Architect Collector | `agents/documentation/architect-collector.md` | Architecture analysis, diagrams (Mermaid, C4) |
| Swagger Collector | `agents/documentation/swagger-collector.md` | Generate OpenAPI spec from code |
| Technical Writer | `agents/documentation/technical-writer.md` | Feature articles, Swagger enrichment |

## How It Works

1. User types `/command` in Claude Code
2. Command file loads the referenced agent persona (biases, output format)
3. Agent executes the workflow defined in the command
4. Output follows the agent's structured format

## Project Skill (CRITICAL)

Every command MUST load the project skill before executing its workflow.

### How to find project skill

1. Determine `{project-name}` = **basename of the current working directory** (last segment of the path)
   - Example: CWD `/Users/ivan/repo/wellness-backend` → `{project-name}` = `wellness-backend`
2. Check for skill file at: `{CWD}/.claude/skills/{project-name}-patterns/SKILL.md`
3. If found — read `SKILL.md` and all `references/*.md` files from the same directory
4. If NOT found — continue without project skill (commands may warn the user)

### How to use project skill

1. Pass project patterns to spawned agents as `[PROJECT PATTERNS]` section in their spawn prompt
2. Project patterns are **mandatory constraints** — agents MUST follow them over generic best practices

### What project skills contain

- Naming conventions (services, controllers, exceptions, tests, YAML service IDs, ENV vars)
- Decorator chain order (e.g., `Retry → Caching → HTTP`)
- Exception patterns (factory methods, error codes, subclassing conventions)
- Cache patterns (dedicated pools, preferred API)
- Config patterns (`env(int:...)`, parameter naming)
- Test patterns (base class, fixtures, naming)

### Generate project skill

Run `/skill-from-git` in the target project to generate `.claude/skills/{project-name}-patterns/` from git history.

## Domain Rules

Rules are loaded by agents via `rules:` metadata field. Each agent declares which rules it needs.

| Rule | File | Used by |
|------|------|---------|
| Language | `rules/language.md` | All agents — Ukrainian communication |
| Git | `rules/git.md` | code-writer, implement-lead — clean commits |
| Coding Style | `rules/coding-style.md` | code-writer, quality-reviewer, design-architect, research-lead, design-reviewer, test-strategist, tdd-guide, security-reviewer — PHP 8.3/Symfony patterns |
| Security | `rules/security.md` | code-writer, security-reviewer — PII/PHI, auth, logging |
| Testing | `rules/testing.md` | code-writer, quality-reviewer, test-strategist, tdd-guide — coverage targets, test patterns |
| Database | `rules/database.md` | design-architect — Doctrine, N+1, migrations |
| Messaging | `rules/messaging.md` | design-architect — RabbitMQ/Kafka, idempotency |

## Contexts

Contexts are mode-specific priorities and guardrails injected into agent spawn prompts via `[MODE CONTEXT]` section.

| Context | File | Loaded by | Injected into |
|---------|------|-----------|---------------|
| Development | `contexts/dev.md` | `/implement` | Code Writer |
| Planning | `contexts/planning.md` | `/plan` | Phase Planner (self) |
| Research | `contexts/research.md` | `/research` | Research Lead (self) + scanners |
| Review | `contexts/review.md` | `/implement` | Security, Quality, Design Reviewers |

## Scenarios

| Scenario | Command | Agents |
|----------|---------|--------|
| feature-development | `/research` → `/design` → `/plan` → `/implement` → `/docs-suite` → `/pr` | Engineering + Documentation agents |
| sentry-triage | `/sentry-triage` → `docs/tasks/` → `/feature` per task | Sentry Triager → feature-development flow |
| documentation-suite | `/docs-suite` | Technical Collector, Architect Collector, Swagger Collector, Technical Writer |
