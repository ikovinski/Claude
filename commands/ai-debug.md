---
name: ai-debug
description: Show AI agents system status - loaded skills, available commands, active rules
---

# /ai-debug - AI Agents System Status

Shows what's currently loaded and available.

## Instructions

When user runs `/debug`, perform these checks and display results:

### 1. Current Context
```
Working directory: {pwd}
Project name: {last part of path}
```

### 2. Project Skill Check
Look for: `~/.claude/ai-agents/skills/{project-name}-patterns/SKILL.md`

- If exists: Read and show skill metadata (name, version, tech_stack)
- If not exists: Show "No project skill found"

### 3. Available Commands
List all files in `~/.claude/ai-agents/commands/`:
- /plan
- /review
- /tdd
- /security-check
- /skill-create
- /debug

### 4. Available Rules
List all files in `~/.claude/ai-agents/rules/`:
- security.md
- testing.md
- coding-style.md
- messaging.md
- database.md

### 5. Available Agents
List agents from `~/.claude/ai-agents/agents/`:
- technical/code-reviewer.md
- technical/security-reviewer.md
- technical/planner.md
- technical/decomposer.md
- technical/tdd-guide.md
- technical/refactor-cleaner.md
- technical/staff-engineer.md
- facilitation/devils-advocate.md

## Output Format

```
🔍 AI Agents System - Debug Info
================================

📁 Context:
   Directory: /Users/ivan/repo/wellness-backend
   Project: wellness-backend

📚 Project Skill:
   ✅ Found: wellness-backend-patterns (v1.0.0)
   Tech: PHP 8.3, Symfony 6.4, Doctrine ORM
   -- or --
   ❌ Not found for: wellness-backend

⚡ Commands: /plan, /review, /tdd, /security-check, /skill-create, /debug
📋 Rules: security, testing, coding-style, messaging, database
🤖 Agents: code-reviewer, security-reviewer, planner, decomposer, tdd-guide, refactor-cleaner, staff-engineer, devils-advocate

✅ System ready!
```
