# AI Agents System

Slash commands for Claude Code CLI. Each command invokes a specific agent with defined biases and output format.

## Structure

```
ai-agents-system/
├── commands/         # Slash commands (main interface)
├── agents/           # Agent personas referenced by commands
│   ├── engineering/  # 14 engineering agents
│   └── documentation/ # 5 documentation agents
├── scenarios/        # Multi-agent workflows
├── rules/            # Domain-specific rules (coding-style, security, testing, database, messaging)
├── contexts/         # Development mode contexts (dev, review, research, planning)
├── skills/           # Reusable skills (templates, project patterns)
├── templates/        # Templates for creating new agents, scenarios, skills
└── plans/            # Feature flow design plans and roadmap
```

## Commands

| Command | Agent | Description |
|---------|-------|-------------|
| `/feature` | Meta-command | Full feature flow navigator with state tracking |
| `/research` | Research Lead + Codebase Researcher | Investigate codebase before implementation |
| `/design` | Design Architect + Test Strategist + Devil's Advocate | Architecture decisions, ADR, test strategy |
| `/plan` | Phase Planner | Decompose design into implementation phases |
| `/implement` | Implement Lead + Writer + Reviewers + Gate | Execute one implementation phase |
| `/docs-suite` | Team (4 agents) | Full documentation suite |
| `/pr` | Direct command | Create PR with design references and test plan |
| `/system-profile` | System Profiler | Integration Profile — business-technical registry |
| `/sentry-triage` | Sentry Triager | Collect and categorize Sentry issues into tasks |
| `/skill-from-git` | — | Generate project skill from git history |
| `/ai-debug` | — | System status and prompt analysis |

## Agents

### Engineering

| Agent | Bias |
|-------|------|
| `research-lead` | Describe, don't prescribe |
| `codebase-researcher` | Facts only, no proposals |
| `design-architect` | Contract-first, boring technology wins |
| `test-strategist` | Test strategy before implementation |
| `phase-planner` | Vertical slices > horizontal layers |
| `implement-lead` | Orchestrate, don't implement |
| `code-writer` | Working code > clever code |
| `tdd-guide` | Test first, always |
| `security-reviewer` | Paranoid by default |
| `quality-reviewer` | Complexity, SOLID, domain model |
| `design-reviewer` | Implementation must match design |
| `quality-gate` | Build, tests, linters — all green |
| `devils-advocate` | Assume nothing works |
| `sentry-triager` | Categorize and group by root cause |

### Documentation

| Agent | Bias |
|-------|------|
| `technical-collector` | Generate, don't write |
| `architect-collector` | Diagram first, tables over prose |
| `swagger-collector` | Code is the source of truth |
| `technical-writer` | Audience first, examples > explanations |
| `system-profiler` | Use cases and integrations registry |

## Scenarios

| Scenario | Commands | Agents |
|----------|----------|--------|
| `feature-development` | `/research` → `/design` → `/plan` → `/implement` → `/docs-suite` → `/pr` | Research Lead, Design Architect, Test Strategist, Devil's Advocate, Phase Planner, Implement Lead, Code Writer, Reviewers |
| `documentation-suite` | `/docs-suite` | Technical Collector, Architect Collector, Swagger Collector, Technical Writer |
