# AI Agents System

Slash commands for Claude Code CLI. Each command invokes an agent with defined biases and output format.

## Structure

```
ai-agents-system/
├── commands/         # Slash commands (main interface)
├── agents/           # Agent personas referenced by commands
├── scenarios/        # Multi-agent workflows referenced by commands
└── templates/        # Templates for creating new agents, scenarios, skills
```

## Commands

| Command | Agent | Description |
|---------|-------|-------------|
| `/research` | Research Lead + Codebase Researcher | Investigate codebase before implementation |
| `/design` | Design Architect + Test Strategist | Architecture decisions, ADR, test strategy |
| `/plan` | Phase Planner | Decompose design into implementation phases |
| `/docs-suite` | Team Lead + 4 agents | Full documentation suite |
| `/skill-from-git` | -- | Extract project skill from git history |
| `/ai-debug` | -- | System status and prompt analysis |

## Agents

### Engineering
| Agent | File | Purpose |
|-------|------|---------|
| Research Lead | `agents/engineering/research-lead.md` | Decompose task, orchestrate research, synthesize report |
| Codebase Researcher | `agents/engineering/codebase-researcher.md` | Scan codebase AS IS — facts only |
| Design Architect | `agents/engineering/design-architect.md` | C4, DataFlow, Sequence diagrams, ADR |
| Test Strategist | `agents/engineering/test-strategist.md` | Test strategy, cases, coverage expectations |
| Phase Planner | `agents/engineering/phase-planner.md` | Decompose design into vertical-slice phases |

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

## Scenarios

| Scenario | Command | Agents |
|----------|---------|--------|
| feature-development | `/research` → `/design` → `/plan` → `/implement` → `/docs-suite` → `/pr` | Engineering + Documentation agents |
| documentation-suite | `/docs-suite` | Technical Collector, Architect Collector, Swagger Collector, Technical Writer |
