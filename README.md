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
│   │   ├── security-reviewer.md # Security audit, OWASP
│   │   ├── staff-engineer.md  # Architecture, tech strategy
│   │   ├── decomposer.md      # Task breakdown, delivery
│   │   ├── planner.md         # Implementation planning
│   │   ├── tdd-guide.md       # Test-Driven Development
│   │   └── refactor-cleaner.md # Dead code cleanup
│   └── facilitation/
│       └── devils-advocate.md # Challenge assumptions, find risks
│
├── skills/                    # Reusable workflows & patterns
│   ├── architecture/          # ADR templates, decision matrices
│   ├── planning/              # Epic breakdown, vertical slicing
│   ├── code-quality/          # Refactoring, test patterns
│   ├── security/              # Security checklists, OWASP
│   ├── tdd/                   # TDD workflow
│   ├── risk-management/       # Risk assessment
│   └── {project}-patterns/    # Auto-generated from git history
│
├── scenarios/                 # Multi-agent workflows
│   ├── technical-decisions/
│   │   └── rewrite-decision.md
│   └── delivery/
│       └── feature-decomposition.md
│
├── rules/                     # Always-follow guidelines
│   ├── security.md            # PII/PHI protection
│   ├── testing.md             # Coverage requirements
│   ├── coding-style.md        # PHP 8.3, Symfony 6.4
│   ├── messaging.md           # RabbitMQ/Kafka patterns
│   └── database.md            # Doctrine, migrations
│
├── commands/                  # Slash commands (/plan, /review, etc)
├── contexts/                  # Mode-specific focus (dev, review, etc)
├── templates/                 # Templates for creating new items
├── docs/                      # Documentation & how-to guides
└── examples/                  # Real-world usage examples
```

## Core Concepts

### Agents
AI персонажі з **унікальними biases**. Biases — це те що робить agent корисним:
- Code Reviewer bias: "Maintainability > cleverness"
- Staff Engineer bias: "Boring technology wins"
- Devil's Advocate bias: "Assume nothing works"

### Skills
Reusable workflows та patterns, організовані по категоріям:
- **Universal Skills** — для всіх проєктів (architecture, security, planning, etc.)
- **Project Skills** — автогенеровані з git history конкретного проєкту
- **Auto-loading** — агенти та scenarios автоматично завантажують потрібні skills

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

## How Skills Work

### Автоматичне Завантаження

Skills автоматично завантажуються агентами та scenarios:

```yaml
# Example: scenarios/delivery/feature-decomposition.md
skills:
  - auto:{project}-patterns        # ← Project-specific conventions
  - planning/epic-breakdown         # ← Universal skill
  - planning/vertical-slicing       # ← Universal skill
  - planning/planning-template      # ← Universal skill
```

Коли scenario запускається:
1. **Перевіряє поточну директорію** → знаходить project skill
2. **Завантажує universal skills** зі списку
3. **Застосовує всі patterns** до процесу

### Приклади Використання

#### Приклад 1: Feature Decomposition з Project Skills

```
You: "Decompose feature: Add Apple Health integration"

System:
├─ Loads: agents/technical/decomposer.md
├─ Checks: ~/.claude/skills/wellness-backend-patterns/SKILL.md ✓ Found
├─ Loads: skills/planning/epic-breakdown.md
├─ Loads: skills/planning/vertical-slicing.md
└─ Applies: Project patterns + Planning skills

Output:
✓ Slices follow project naming conventions
✓ Estimates based on historical velocity
✓ Tests follow project test patterns
✓ Vertical slices per project architecture
```

#### Приклад 2: Security Review з Universal Skills

```
You: "/security-check src/Controller/Api/PaymentController.php"

System:
├─ Loads: agents/technical/security-reviewer.md
├─ Loads: skills/security/owasp-top-10.md
├─ Loads: skills/security/security-audit-checklist.md
└─ Applies: OWASP checks + Security audit

Output:
✓ Checks OWASP Top 10 vulnerabilities
✓ Validates input sanitization
✓ Reviews authentication/authorization
✓ Checks for PII/PHI leaks
```

#### Приклад 3: Rewrite Decision з Risk Management

```
You: "Should we rewrite the sync engine?"

System:
├─ Loads: agents/technical/staff-engineer.md
├─ Loads: agents/facilitation/devils-advocate.md
├─ Loads: skills/architecture/decision-matrix.md
├─ Loads: skills/risk-management/risk-assessment.md
└─ Applies: Decision framework + Risk analysis

Output:
✓ Structured decision matrix (rewrite vs refactor)
✓ Risk assessment with probabilities
✓ Pre-mortem analysis
✓ ADR (Architecture Decision Record)
```

### Створення Project Skill

Згенеруйте skill з вашого проєкту:

```bash
cd ~/your-project
# In Claude Code:
/skill-create --commits 100
```

**Що аналізується:**
- Commit messages → конвенції
- Code structure → архітектурні патерни
- File naming → стандарти найменування
- Common imports → dependencies patterns
- Test files → testing patterns

**Результат:** `skills/{project-name}-patterns/SKILL.md`

**Автоматичне використання:**
- При запуску агента в цьому проєкті → skill завантажується автоматично
- При запуску scenario → skill застосовується до всіх фаз
- При code review → паттерни проєкту враховуються

### Skills Categories

| Category | Purpose | Used By |
|----------|---------|---------|
| **architecture/** | ADR templates, decision matrices | Staff Engineer, Rewrite Decision |
| **planning/** | Epic breakdown, vertical slicing | Decomposer, Planner, Feature Decomposition |
| **code-quality/** | Refactoring patterns, test patterns | Code Reviewer, Refactor Cleaner |
| **security/** | OWASP checks, audit checklists | Security Reviewer |
| **tdd/** | Red-Green-Refactor workflow | TDD Guide |
| **risk-management/** | Risk assessment frameworks | Devil's Advocate, Rewrite Decision |

Детальніше: [skills/README.md](skills/README.md) та [skills/skills-index.md](skills/skills-index.md)

---

## Available Agents

### Technical Agents

| Agent | Main Bias | Use Case | Skills Used |
|-------|-----------|----------|-------------|
| [code-reviewer](agents/technical/code-reviewer.md) | Maintainability > cleverness | PR review, code quality | code-quality/* |
| [security-reviewer](agents/technical/security-reviewer.md) | Paranoid by default | Security audit, OWASP | security/* |
| [staff-engineer](agents/technical/staff-engineer.md) | Boring technology wins | Architecture decisions | architecture/* |
| [decomposer](agents/technical/decomposer.md) | Vertical slices > horizontal | Task breakdown | planning/* |
| [planner](agents/technical/planner.md) | Clarity over speed | Implementation planning | planning/* |
| [tdd-guide](agents/technical/tdd-guide.md) | Test first, always | TDD workflow | tdd/* |
| [refactor-cleaner](agents/technical/refactor-cleaner.md) | Less code = less bugs | Dead code cleanup | code-quality/* |

### Facilitation Agents

| Agent | Main Bias | Use Case | Skills Used |
|-------|-----------|----------|-------------|
| [devils-advocate](agents/facilitation/devils-advocate.md) | Assume nothing works | Challenge decisions | risk-management/* |

### Scenarios

| Scenario | Agents Used | Duration | Output |
|----------|-------------|----------|--------|
| [feature-decomposition](scenarios/delivery/feature-decomposition.md) | Decomposer → Staff Engineer | 30-90 min | Slices, estimates, dependencies |
| [rewrite-decision](scenarios/technical-decisions/rewrite-decision.md) | Staff Engineer → Devil's Advocate | 1-2 hours | ADR, risk assessment |

## Usage Examples

### 1. Quick Security Review

```bash
# In Claude Code CLI
/security-check src/Controller/Api/PaymentController.php
```

**What happens:**
- Loads: Security Reviewer agent
- Applies: security/owasp-top-10.md + security/security-audit-checklist.md
- Checks: Input validation, auth, PII leaks, SQL injection, XSS

**Output:** Structured security report with findings + recommendations

---

### 2. Feature Decomposition with Project Context

```bash
# In your project directory
cd ~/wellness-backend

# Then in Claude Code:
"Decompose feature: Add Apple Health integration"
```

**What happens:**
- Loads: Decomposer agent
- Finds: skills/wellness-backend-patterns/SKILL.md (auto)
- Applies: planning/epic-breakdown.md + planning/vertical-slicing.md
- Uses: Your project's naming conventions, test patterns, architecture

**Output:**
- Vertical slices (1-3 days each)
- Following YOUR project patterns
- With realistic estimates based on YOUR history

---

### 3. Architecture Decision (Rewrite vs Refactor)

```bash
"Should we rewrite the sync engine? It's slow and hard to maintain"
```

**What happens:**
- Phase 1: Staff Engineer analyzes problem
  - Uses: architecture/decision-matrix.md
- Phase 2: Devil's Advocate challenges
  - Uses: risk-management/risk-assessment.md
- Phase 3: Staff Engineer synthesizes
  - Creates: ADR (Architecture Decision Record)

**Output:** Structured decision with risks, alternatives, recommendation

---

### 4. TDD Workflow

```bash
/tdd "CalorieCalculator service"
```

**What happens:**
- Loads: TDD Guide agent
- Applies: tdd/tdd-workflow.md
- Enforces: Red → Green → Refactor cycle

**Output:**
1. Test cases first (failing tests)
2. Minimal implementation (make tests pass)
3. Refactor (improve code)
4. Coverage report

## Documentation

- **[How Scenarios Work](docs/how-it-works/how-scenarios-work.md)** — детальний гайд по multi-agent workflows
- **[Skills Index](skills/skills-index.md)** — повний каталог skills
- **[Skills Integration](docs/skills-integration-summary.md)** — як skills інтегруються з agents
- **[Agent Biases](agents/README.md)** — розуміння agent perspectives

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

## Roadmap

### ✅ Completed (Wave 1)
- [x] Core agents (8 agents: technical + facilitation)
- [x] Skills system with categories (architecture, planning, security, etc.)
- [x] Auto-loading skills in agents/scenarios
- [x] Scenarios (feature-decomposition, rewrite-decision)
- [x] Slash commands (/plan, /review, /tdd, /security-check)
- [x] Rules system (security, testing, coding-style, messaging, database)
- [x] Project skills auto-generation (/skill-create)
- [x] Documentation (how scenarios work, skills integration)

### 🎯 Wave 2: Expansion

**Additional Agents:**
- [ ] tech-lead.md — team coordination, delivery tracking
- [ ] mentor.md — 1:1, growth plans, career development
- [ ] incident-commander.md — crisis management, post-mortems
- [ ] interviewer.md — technical interviews, candidate evaluation

**Additional Skills:**
- [ ] estimation/ — task estimation, velocity tracking
- [ ] people/ — 1:1 meeting prep, feedback frameworks
- [ ] incident/ — incident response playbooks
- [ ] hiring/ — interview questions, rubrics

**Additional Scenarios:**
- [ ] incident-response.md — detection → mitigation → post-mortem
- [ ] tech-debt-prioritization.md — assess → prioritize → roadmap
- [ ] hiring-decision.md — interview → evaluation → offer
- [ ] sprint-planning.md — backlog → decomposition → commitment

**Documentation:**
- [x] docs/how-it-works/how-scenarios-work.md
- [ ] docs/how-it-works/how-agents-work.md
- [ ] docs/how-it-works/how-skills-work.md
- [ ] docs/customization-guide.md
- [ ] docs/best-practices.md

---

*Built for wellness/fitness tech team leads. Calibrate to your domain as needed.*
