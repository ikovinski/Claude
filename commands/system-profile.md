---
name: system-profile
description: Generate System Integration Profile — business-technical registry of all integrations with use cases, actors, data flows, Open Questions and Issues. Single agent, single document.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Agent"]
triggers:
  - "system profile"
  - "integration profile"
  - "профіль системи"
  - "опиши інтеграції"
skills:
  - auto:{project}-patterns
---

# /system-profile - System Integration Profile

Spawns a single System Profiler agent to generate a comprehensive integration profile of the target project.

## Usage

```bash
/system-profile                    # Full profile from code scan
/system-profile --with-artifacts   # Use existing docs-suite artifacts as input
```

## What It Produces

A single file `docs/system-profile.md` containing:
- **Context Diagram** — system + all external systems (Mermaid C4)
- **Integration Profiles** — every integration described with a consistent template (business reason, actors, use cases, data, integration type, risks)
- **Inline Diagrams** — sequence/flow diagrams per non-trivial integration
- **Open Questions (OQ)** — things that can't be determined from code, numbered globally
- **Issues** — problems found in code (TODOs, deprecated libs, missing error handling), numbered globally
- **Documentation Gaps** — what's still unknown per integration

## You Spawn a Single Agent

When this command runs, YOU (Claude) spawn a **single System Profiler agent** that does all the work. Your role is minimal:

1. Determine target project path
2. Load project skill if available
3. Spawn the agent
4. Report results when done

## Execution

### Step 1: Determine Target Project

```
If CWD is ai-agents-system:
  → Ask user: "В якому проєкті генерувати System Profile?"
  → User provides path or project name

If CWD is NOT ai-agents-system:
  → Target = CWD
```

### Step 2: Load Project Skill

```
{project-name} = basename of target project path
skill_path = "{target-project}/.claude/skills/{project-name}-patterns/SKILL.md"

If skill exists:
  → Read SKILL.md + references/*.md
  → Include as [PROJECT PATTERNS] in agent spawn prompt
```

### Step 3: Check for Existing Artifacts (--with-artifacts)

```
If --with-artifacts flag:
  technical_report = Glob("docs/.artifacts/technical-collection-report.md")
  architecture_report = Glob("docs/.artifacts/architecture-report.md")
  → Include paths in agent spawn prompt as [EXISTING ARTIFACTS]
```

### Step 4: Spawn System Profiler Agent

Read agent file: `agents/documentation/system-profiler.md`

Spawn agent with:

```
[AGENT IDENTITY]
{Full content of agents/documentation/system-profiler.md}

[CONTEXT]
Project path: {target_project_path}
Project name: {project-name}

[PROJECT PATTERNS — only if skill found]
{Content of SKILL.md + references}

[EXISTING ARTIFACTS — only if --with-artifacts and artifacts exist]
Technical Collection Report: docs/.artifacts/technical-collection-report.md
Architecture Report: docs/.artifacts/architecture-report.md
→ Use these as starting point. They contain pre-scanned integration data.
→ Still verify against actual code — artifacts may be outdated.

[TASK]
Generate System Integration Profile.
Execute the full process as described in your Task section.
Write output to: docs/system-profile.md
```

### Step 5: Report Results

When agent completes, read `docs/system-profile.md` and report:

```
## System Profile Generated

| Metric | Value |
|--------|-------|
| Output | docs/system-profile.md |
| Integrations profiled | N |
| With diagrams | N |
| Open Questions | N |
| Issues (Critical) | N |
| Issues (Total) | N |
| Documentation Gaps | N |
```

## Difference from /docs-suite

| Aspect | /docs-suite | /system-profile |
|--------|-------------|-----------------|
| **Focus** | Code structure, API, features | Integration landscape, business context |
| **Agents** | 4 agents (team) | 1 agent |
| **Output** | Multiple files (architecture, swagger, features) | Single `docs/system-profile.md` |
| **Audience** | Engineers (onboarding, code context) | Engineers + leads + stakeholders |
| **Integration detail** | Table: protocol, auth, direction | Full profile: business reason, actors, use cases, risks |
| **OQ/Issues** | Architect Collector OQ table | Numbered, categorized, with severity and assignee |
| **Requires** | Agent Teams | No special requirements |

## When to Use

- **Onboarding** — новий член команди повинен зрозуміти інтеграційний ландшафт
- **Audit** — ревью всіх зовнішніх залежностей системи
- **Planning** — підготовка до квартального планування (де ризики? де gaps?)
- **Incident post-mortem** — зрозуміти як система пов'язана із зовнішніми сервісами
- **Periodic refresh** — перегенерувати для актуалізації профілю

## Related

- Agent: `agents/documentation/system-profiler.md`
- Complementary: `/docs-suite` for code-focused documentation
- Example output format: Confluence-style integration profile
