---
name: ai-debug
description: Show AI agents system status, analyze prompts, explain workflows
---

# /ai-debug - AI Agents System Status & Analyzer

## Usage

```bash
/ai-debug                           # Show system status
/ai-debug --prompt "your request"   # Analyze what will happen (agents + scenarios)
/ai-debug --agents                  # List all agents with biases
/ai-debug --scenarios               # List all scenarios with triggers
/ai-debug --commands                # List all commands (summary table)
/ai-debug --commands <name>         # Detailed info about specific command
```

---

## (default) System Status

### Instructions

1. Get current working directory
2. Extract project name (last part of path)
3. Check for project skill: `skills/{project-name}-patterns/SKILL.md`
4. List components from `commands/`, `agents/`, `scenarios/`, `rules/`

### Output Format

```
🔍 AI Agents System - Status
════════════════════════════

📁 Context
   ├─ Directory: {pwd}
   └─ Project:   {project-name}

📚 Project Skill
   └─ ✅ Found: {project}-patterns (v{version})
   -- or --
   └─ ❌ Not found (run /skill-create to generate)

⚡ Commands ({count})
   {list from commands/*.md}

🤖 Agents ({count})
   {list from agents/*.md}

🎬 Scenarios ({count})
   {list from scenarios/**/*.md}

📋 Rules ({count})
   {list from rules/*.md}

✅ System ready!
```

---

## --prompt "request" (Workflow Analyzer)

### Instructions

1. Parse the prompt
2. **First**: Match against scenario triggers (from `scenarios/**/*.md`)
3. **Then**: Match against agent triggers (from `agents/*.md`)
4. Identify: scenario OR agent, skills, output type
5. Generate workflow explanation

### Routing Priority

1. **Scenarios first** — multi-agent workflows для складних задач
2. **Agents second** — single-agent для простих задач

### Scenario Triggers

Read from each scenario file's metadata `trigger` field:

| Scenario | Triggers |
|----------|----------|
| `feature-decomposition` | "decompose", "break down", "epic breakdown", "task breakdown" |
| `rewrite-decision` | "should we rewrite", "rewrite vs refactor", "rebuild" |

### Agent Triggers

Read from each agent file's `triggers` field in frontmatter.

### Output Format (Scenario Match)

```
🔍 Prompt Analysis: "{prompt}"
══════════════════════════════

🎬 Scenario Match!
   ├─ Scenario:      {scenario-name}
   │                 scenarios/{category}/{scenario}.md
   ├─ Duration:      {duration from metadata}
   └─ Phases:        {number of phases}

👥 Agent Chain
   ├─ Phase 1: {agent-1} (lead)
   │           bias: {bias}
   ├─ Phase 2: {agent-2}
   │           bias: {bias}
   └─ Phase N: {agent-n}
               bias: {bias}

📚 Skills
   ├─ {skill-1}
   ├─ {skill-2}
   └─ auto:{project}-patterns (if exists)

⚙️  Workflow
   1. Phase 1: {agent-1} — {phase description}
   2. Phase 2: {agent-2} — {phase description}
   3. Decision point (user input)
   4. Phase N: {agent-n} — {phase description}

📤 Output
   ├─ Type:     Multi-phase deliverables
   ├─ Duration: {duration}
   └─ Includes: {list of deliverables}

💡 Tip: Scenarios включають decision points де потрібен ваш input
```

### Output Format (Agent Match)

```
🔍 Prompt Analysis: "{prompt}"
══════════════════════════════

📦 Routing
   ├─ Agent:         {agent-name}
   │                 agents/{agent}.md
   ├─ Skills:        {from agent's skills field}
   │                 skills/{category}/
   └─ Project Skill: {project}-patterns (if exists)

⚙️  Workflow
   1. Load agent: {agent-name} (bias: {from agent file})
   2. Load skills: {list}
   3. {action based on agent type}
   4. Generate output

📤 Output
   ├─ Type:     {Chat | File}
   ├─ Format:   {Markdown | YAML | OpenAPI}
   └─ Location: {path or "Chat response"}

💡 Preview
   {short example based on agent's output template}
```

### Examples

**Scenario match:**
```
> /ai-debug --prompt "Decompose feature: Add Apple Health integration"

🔍 Prompt Analysis: "Decompose feature: Add Apple Health integration"
═════════════════════════════════════════════════════════════════════

🎬 Scenario Match!
   ├─ Scenario:      Feature Decomposition
   │                 scenarios/delivery/feature-decomposition.md
   ├─ Duration:      30-90 minutes
   └─ Phases:        4

👥 Agent Chain
   ├─ Phase 1-2: Decomposer (lead)
   │             bias: Vertical slices > horizontal layers
   ├─ Phase 3:   Staff Engineer (validation)
   │             bias: Boring technology wins
   └─ Phase 4:   Decomposer (finalization)

📚 Skills
   ├─ planning/epic-breakdown
   ├─ planning/vertical-slicing
   └─ auto:wellness-backend-patterns ✓

⚙️  Workflow
   1. Phase 1: Scope Understanding
   2. Phase 2: Initial Decomposition
   3. Phase 3: Technical Validation (Staff Engineer)
   4. Phase 4: Finalization

📤 Output
   ├─ Type:     Multi-phase deliverables
   ├─ Duration: 30-90 min
   └─ Includes: Scope doc, Slices, Dependencies, Execution strategy
```

**Agent match:**
```
> /ai-debug --prompt "Review this code"

🔍 Prompt Analysis: "Review this code"
══════════════════════════════════════

📦 Routing
   ├─ Agent:         code-reviewer
   │                 agents/code-reviewer.md
   ├─ Skills:        code-quality/*
   └─ Project Skill: wellness-backend-patterns ✓

⚙️  Workflow
   1. Load agent: Code Reviewer (bias: Maintainability > cleverness)
   2. Load skills: code-quality/refactoring-patterns, test-patterns
   3. Analyze code
   4. Generate structured review

📤 Output
   ├─ Type:     Chat
   ├─ Format:   Markdown
   └─ Location: Chat response
```

---

## --agents (Agent Reference)

### Instructions

1. Read all files from `agents/*.md`
2. Extract from each file's frontmatter and content:
   - `name` (from frontmatter)
   - `triggers` (from frontmatter)
   - `skills` (from frontmatter)
   - Bias (from ## Biases section, first item)
   - When to use (from description or ## When to Use)
3. Generate output using format below

### Output Format

```
🤖 Available Agents
═══════════════════

{emoji} {agent-name}
   ├ Bias:     {first bias from agent file}
   ├ When:     {use case description}
   ├ Triggers: {triggers from frontmatter}
   └ Skills:   {skills from frontmatter}

... repeat for each agent ...
```

### Agent Emoji Mapping

| Agent | Emoji |
|-------|-------|
| code-reviewer | 🔍 |
| security-reviewer | 🛡️ |
| planner | 📋 |
| feature-decomposer | 🧩 |
| tdd-guide | 🧪 |
| refactor-cleaner | 🧹 |
| architecture-advisor | 🏗️ |
| decision-challenger | 😈 |
| technical-writer | 📝 |
| architecture-doc-collector | 🏛️ |

---

## --scenarios (Scenario Reference)

### Instructions

1. Read all files from `scenarios/**/*.md`
2. Extract from each file's metadata:
   - `name`
   - `trigger`
   - `participants` (agent chain)
   - `duration`
   - `skills`
3. Generate output using format below

### Output Format

```
🎬 Available Scenarios
══════════════════════

📁 {category}/

   🎭 {scenario-name}
      ├ Trigger:      {trigger phrase}
      ├ Duration:     {duration}
      ├ Agent Chain:  {agent-1} → {agent-2} → ...
      └ Skills:       {skills list}

... repeat for each scenario ...

💡 Scenarios активуються через природну мову, не slash commands
```

### Example Output

```
🎬 Available Scenarios
══════════════════════

📁 delivery/

   🎭 Feature Decomposition
      ├ Trigger:      "decompose feature", "break down epic", "task breakdown"
      ├ Duration:     30-90 minutes
      ├ Agent Chain:  Decomposer → Staff Engineer → Decomposer
      └ Skills:       planning/epic-breakdown, planning/vertical-slicing

📁 technical-decisions/

   🎭 Rewrite Decision
      ├ Trigger:      "should we rewrite", "rewrite vs refactor"
      ├ Duration:     1-2 hours
      ├ Agent Chain:  Staff Engineer → Devil's Advocate → Staff Engineer
      └ Skills:       architecture/decision-matrix, risk-management/risk-assessment

💡 Scenarios активуються через природну мову, не slash commands
```

---

## --commands (Command Reference - Summary)

### Instructions

1. Read all files from `commands/*.md` (exclude README.md)
2. For each command:
   - Read command file (name, agent, usage)
   - Read agent file (skills, biases)
3. Generate list in format below (repeat for each command)

### Output Format

```
# Available Commands

---

## /{command-name} ({Agent-Name})

**Послідовність:**

1. Завантажується агент: {agent-id}
   └─ agents/{agent}.md
2. Завантажуються skills:
   ├─ {skill-1}
   ├─ {skill-2}
   └─ auto:{project}-patterns (якщо існує)
3. Застосовуються biases:
   ├─ {bias-1} — {description}
   └─ {bias-N} — {description}
4. Генерується output

**Output залежить від флагу:**

| Flag | Output | Формат | Шлях |
|------|--------|--------|------|
| {flag or —} | {Chat/File} | {format} | {path or "—"} |

---

... repeat for each command ...

💡 Use /ai-debug --command <name> for full details
```

### Data Sources

| Field | Source |
|-------|--------|
| Command name | command file frontmatter `name` or filename |
| Agent-Name | agent file frontmatter `name` (human-readable) |
| agent-id | command file frontmatter `agent` |
| Skills | agent file frontmatter `skills` |
| Biases | agent file `## Biases` section |
| Output table | command file `## Usage` + `## Output` sections |

---

## --command <name> (Single Command Details)

### Instructions

1. Find command file: `commands/{name}.md`
2. Read the command file
3. Read the agent file (from frontmatter `agent`)
4. Read agent's skills (from agent's `skills` field)
5. Read agent's biases (from `## Biases` section)
6. Generate detailed output using format below

### Output Format

```
## /{command-name} ({agent-name})

**Послідовність:**

1. Завантажується агент: {agent-name}
   └─ agents/{agent}.md
2. Завантажуються skills:
   ├─ {skill-1}
   ├─ {skill-2}
   └─ auto:{project}-patterns (якщо існує)
3. Застосовуються biases:
   ├─ {bias-1} — {bias-1-description}
   ├─ {bias-2} — {bias-2-description}
   └─ {bias-N} — {bias-N-description}
4. Генерується output

**Output залежить від флагу:**

| Flag | Output | Формат | Шлях |
|------|--------|--------|------|
| {flag or — (default)} | {Chat/File} | {Markdown/YAML/OpenAPI} | {path or "—"} |
| {next flag} | {Chat/File} | {format} | {path} |
```

### Data Sources

| Field | Source |
|-------|--------|
| Command name | command file frontmatter `name` |
| Agent name | command file frontmatter `agent` |
| Skills | agent file frontmatter `skills` |
| Biases | agent file `## Biases` section (name + description) |
| Output table | command file `## Usage` + `## Output` sections |
