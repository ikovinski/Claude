# AI Agents System for Team Leads

> Система AI-агентів для управління технічними командами. Працює з Claude Code CLI.

## Installation

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Git

### Quick Install

```bash
# Clone the repository
git clone https://github.com/your-username/ai-agents-system.git
cd ai-agents-system

# Run setup script
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Create `~/.claude/` directory if it doesn't exist
2. Create symlink `~/.claude/ai-agents/` → your cloned directory
3. Backup existing `~/.claude/CLAUDE.md` (if any)
4. Create new `~/.claude/CLAUDE.md` with agent routing instructions

### Verify Installation

```bash
# Check symlink exists
ls -la ~/.claude/ai-agents

# Should show: ai-agents -> /path/to/your/ai-agents-system
```

### Uninstall

```bash
cd /path/to/ai-agents-system
./uninstall.sh
```

This will remove the symlink and optionally restore your previous CLAUDE.md.

---

## Quick Start

1. Обери **agent** для specific expertise (Code Reviewer, Staff Engineer, etc.)
2. Скопіюй **prompt template** з файлу агента
3. Заповни `{{variables}}` своїм контекстом
4. Paste у Claude.ai або використовуй slash commands

## Structure

```
ai-agents-system/
├── agents/                    # AI персонажі з унікальними biases
│   ├── technical/
│   │   ├── code-reviewer.md   # Code quality, production-readiness
│   │   ├── staff-engineer.md  # Architecture, tech strategy
│   │   └── decomposer.md      # Task breakdown, delivery
│   ├── facilitation/
│   │   └── devils-advocate.md # Challenge assumptions, find risks
│   └── management/            # [Wave 2]
│
├── skills/                    # Reusable prompts для конкретних tasks
│   ├── engineering/
│   │   ├── code-review.md     # PR review process
│   │   └── task-decomposition.md
│   ├── core/                  # [Wave 2]
│   ├── management/            # [Wave 2]
│   └── product/               # [Wave 2]
│
├── scenarios/                 # Multi-agent workflows
│   ├── technical-decisions/
│   │   └── rewrite-decision.md
│   ├── delivery/
│   │   └── feature-decomposition.md
│   ├── quality/               # [Wave 2]
│   └── people/                # [Wave 2]
│
├── templates/                 # Шаблони для створення нових items
│   ├── agent-template.md
│   ├── skill-template.md
│   └── scenario-template.md
│
├── docs/                      # [Wave 2] Confluence documentation
└── examples/                  # [Wave 2] Real-world examples
```

## Core Concepts

### Agents
AI персонажі з **унікальними biases**. Biases — це те що робить agent корисним:
- Code Reviewer bias: "Maintainability > cleverness"
- Staff Engineer bias: "Boring technology wins"
- Devil's Advocate bias: "Assume nothing works"

### Skills
Reusable prompts для конкретних tasks з **Quality Bar**:
- Must Have — без цього результат невалідний
- Should Have — значно покращує якість
- Nice to Have — бонус

### Scenarios
Multi-agent workflows для складних ситуацій:
- Кілька agents у sequence
- Decision points
- Copy-paste prompts для кожного кроку

## Slash Commands

After installation, these commands work in any project:

| Command | Description |
|---------|-------------|
| `/plan <task>` | Create implementation plan for a task |
| `/review` | Code review (staged changes or specific file) |
| `/tdd <feature>` | Start TDD workflow - tests first |
| `/security-check` | Security-focused review |
| `/skill-create` | Generate project skill from git history |

### Example Usage

```bash
# In Claude Code CLI
/plan "Add user authentication with JWT"
/review src/Service/PaymentService.php
/tdd "CalorieCalculator service"
/skill-create --commits 100
```

---

## Available Agents

| Type | Item | Use Case |
|------|------|----------|
| Agent | [code-reviewer.md](agents/technical/code-reviewer.md) | PR review, code quality |
| Agent | [staff-engineer.md](agents/technical/staff-engineer.md) | Architecture decisions |
| Agent | [decomposer.md](agents/technical/decomposer.md) | Task breakdown |
| Agent | [security-reviewer.md](agents/technical/security-reviewer.md) | Security audit |
| Agent | [tdd-guide.md](agents/technical/tdd-guide.md) | TDD workflow |
| Agent | [planner.md](agents/technical/planner.md) | Implementation planning |
| Agent | [devils-advocate.md](agents/facilitation/devils-advocate.md) | Challenge decisions |
| Skill | [code-review.md](skills/engineering/code-review.md) | Structured PR review |
| Skill | [task-decomposition.md](skills/engineering/task-decomposition.md) | Feature breakdown |
| Scenario | [rewrite-decision.md](scenarios/technical-decisions/rewrite-decision.md) | "Should we rewrite?" |
| Scenario | [feature-decomposition.md](scenarios/delivery/feature-decomposition.md) | Epic → sprints |

## Usage Example

### Quick Code Review

1. Open [code-review.md](skills/engineering/code-review.md)
2. Copy the prompt template
3. Replace:
   - `{{paste_code_or_diff}}` — your code
   - `{{what_this_code_does}}` — context
   - `{{full | security | performance | quick}}` — scope
4. Paste to Claude.ai

### Architecture Decision

1. Open [staff-engineer.md](agents/technical/staff-engineer.md)
2. Copy the prompt template
3. Fill in your context
4. Get structured analysis with trade-offs

### Challenge a Decision

1. Got a decision everyone agrees on too quickly?
2. Open [devils-advocate.md](agents/facilitation/devils-advocate.md)
3. Feed the decision to the Devil's Advocate
4. Get back assumptions to validate, risks to mitigate

## Project-Specific Skills

Generate a skill from your project's git history:

```bash
cd ~/your-project
# In Claude Code:
/skill-create
```

This creates `skills/{project-name}-patterns/SKILL.md` with:
- Commit conventions
- Code architecture patterns
- Naming conventions
- Common workflows
- Testing patterns

Agents automatically load matching project skills.

---

## Domain Context

Agents are calibrated for **PHP/Symfony backend** with:
- **Tech stack**: PHP 8.3, Symfony 6.4, Doctrine, RabbitMQ
- **Patterns**: DDD, CQRS, Event Sourcing
- **Integrations**: External APIs, webhooks
- **Data sensitivity**: PII/PHI awareness

## Creating New Items

Use templates:
- [agent-template.md](templates/agent-template.md) — new agent
- [skill-template.md](templates/skill-template.md) — new skill
- [scenario-template.md](templates/scenario-template.md) — new scenario

**Key rules**:
1. Every agent MUST have Biases (without them, agent is useless)
2. Every skill MUST have Quality Bar (must/should/nice)
3. Format for Claude.ai (copy-paste prompts)

## Wave 2 Roadmap

### Additional Agents
- [ ] tech-lead.md — team coordination, delivery
- [ ] mentor.md — 1:1, growth plans
- [ ] incident-commander.md — crisis management
- [ ] interviewer.md — technical interviews

### Additional Skills
- [ ] estimation.md — task estimation
- [ ] 1-on-1.md — 1:1 meeting prep
- [ ] feedback.md — giving feedback
- [ ] adr-writing.md — architecture decision records

### Additional Scenarios
- [ ] incident-response.md
- [ ] tech-debt-prioritization.md
- [ ] hiring-decision.md
- [ ] performance-review.md

### Documentation
- [ ] docs/quick-start.md
- [ ] docs/agents-overview.md
- [ ] docs/skills-catalog.md
- [ ] docs/scenarios-playbook.md
- [ ] docs/customization-guide.md
- [ ] docs/best-practices.md

---

*Built for wellness/fitness tech team leads. Calibrate to your domain as needed.*
