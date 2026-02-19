---
name: ai-debug
description: Show AI agents system status, analyze prompts, explain workflows
---

# /ai-debug - AI Agents System Status & Analyzer

## Usage

```bash
/ai-debug                           # Show system status
/ai-debug --prompt "your request"   # Analyze what will happen
/ai-debug --agents                  # List all agents with biases
/ai-debug --commands                # List all commands (summary table)
/ai-debug --command <name>          # Detailed info about specific command
```

---

## (default) System Status

### Instructions

1. Get current working directory
2. Extract project name (last part of path)
3. Check for project skill: `skills/{project-name}-patterns/SKILL.md`
4. List components from `commands/`, `agents/`, `rules/`

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

⚡ Commands
   {list from commands/*.md}

🤖 Agents ({count})
   {list from agents/**/*.md}

📋 Rules
   {list from rules/*.md}

✅ System ready!
```

---

## --prompt "request" (Workflow Analyzer)

### Instructions

1. Parse the prompt
2. Match against routing rules (from agents' `triggers` field)
3. Identify: agent, skills, output type
4. Generate workflow explanation

### Routing Rules

Read from each agent file's `triggers` field in frontmatter.

### Output Format

```
🔍 Prompt Analysis: "{prompt}"
══════════════════════════════

📦 Routing
   ├─ Agent:         {agent-name}
   │                 agents/technical/{agent}.md
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

---

## --agents (Agent Reference)

### Instructions

1. Read all files from `agents/technical/*.md` and `agents/facilitation/*.md`
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
   └─ agents/technical/{agent}.md
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
   └─ agents/technical/{agent}.md
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
