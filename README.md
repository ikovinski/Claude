# AI Agents System

Slash commands for Claude Code CLI. Each command invokes a specific agent with defined biases and output format.

## Structure

```
ai-agents-system/
├── commands/         # Slash commands (the main interface)
├── agents/           # Agent personas referenced by commands
└── scenarios/        # Multi-agent workflows
```

## Commands

| Command | Agent | Description |
|---------|-------|-------------|
| `/skill-create` | -- | Generate project skill from git history |
| `/ai-debug` | -- | System status and prompt analysis |

## Usage

```bash
/skill-create --commits 100
/ai-debug
```

## Agents

Each agent has a **bias** -- the opinionated perspective that makes it useful:

| Agent | Bias |
|-------|------|
|   |  |


## Scenarios

| Scenario | Commands | Agents |
|----------|----------|--------|
| documentation-suite | `/docs-suite` | Codebase Doc Collector, Architecture Doc Collector, Technical Writer |
