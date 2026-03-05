---
name: skill-from-git
description: Analyze git history to extract PHP/Symfony coding patterns and generate a skill following Claude's recommended structure. Learns from your team's actual practices.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
triggers:
  - "extract skill from git"
  - "learn patterns from git history"
  - "створи скіл з git історії"
skills: []
---

# /skill-from-git - Extract Project Skill from Git History

Analyzes git history of the current repository to extract coding patterns and generate a skill that teaches Claude your team's practices. Optimized for PHP/Symfony projects.

## Usage

```bash
/skill-from-git                        # Analyze current repo, save locally
/skill-from-git --commits 100          # Analyze last 100 commits
/skill-from-git --path src/Service     # Analyze specific directory
/skill-from-git --global               # Save to global ~/.claude/skills/
/skill-from-git --output ./custom/     # Custom output directory
```

## Output Structure

Generate skill following Claude's recommended structure:

```
{project-name}-patterns/
├── SKILL.md              # Main skill file (required)
├── scripts/              # Reusable scripts (if applicable)
├── references/           # Detailed docs loaded on demand
│   ├── architecture.md   # Detailed code architecture analysis
│   ├── workflows.md      # Common development workflows
│   └── conventions.md    # Naming, commit, and coding conventions
└── assets/               # Templates, configs (if applicable)
```

### Where the skill is saved

| Mode | Path | When to use |
|------|------|-------------|
| **Default (local)** | `./.claude/skills/{project-name}-patterns/` | This project only (recommended) |
| `--global` | `~/.claude/skills/{project-name}-patterns/` | Reuse across all projects |
| `--output <path>` | `<path>/{project-name}-patterns/` | Custom location |

### Example

```bash
# In ~/my-fitness-app
cd ~/my-fitness-app

# Run the command
/skill-from-git

# Result saved to:
# ./.claude/skills/my-fitness-app-patterns/
# ├── SKILL.md
# ├── references/
# │   ├── architecture.md
# │   ├── workflows.md
# │   └── conventions.md
# └── scripts/   (empty, created for future use)
```

## What this command does

1. **Parses Git History** - analyzes commits, file changes, patterns
2. **Detects Patterns** - finds recurring workflows and conventions
3. **Generates Skill** - creates a valid skill with proper structure
4. **PHP/Symfony aware** - understands Doctrine, Messenger, Services

---

## Step 1: Collect Git Data

Run these commands to gather data:

```bash
# Recent commits with files
git log --oneline -n 200 --name-only --pretty=format:"%H|%s|%ad" --date=short

# Most frequently changed files
git log --oneline -n 200 --name-only | grep -v "^$" | grep -v "^[a-f0-9]" | sort | uniq -c | sort -rn | head -20

# Commit message patterns
git log --oneline -n 200 | cut -d' ' -f2- | head -50

# Authors and contributions
git shortlog -sn --no-merges -n 200

# Files that change together
git log --oneline -n 100 --name-only --pretty=format:"---" | awk '/^---/{if(files)print files; files=""} /^[^-]/{files=files" "$0} END{print files}' | sort | uniq -c | sort -rn | head -10
```

---

## Step 2: Analyze PHP/Symfony Patterns

### Commit Conventions
```bash
# Check for conventional commits
git log --oneline -n 100 | grep -E "^[a-f0-9]+ (feat|fix|chore|docs|refactor|test):" | wc -l

# Popular prefixes
git log --oneline -n 200 | sed 's/^[a-f0-9]* //' | cut -d':' -f1 | sort | uniq -c | sort -rn
```

### Symfony Structure
```bash
# Main directories
find src -type d -maxdepth 2 | head -20

# Controller patterns
ls -la src/Controller/ 2>/dev/null | head -10

# Service patterns
ls -la src/Service/ 2>/dev/null | head -10

# Message handlers
find src -name "*Handler.php" -o -name "*Message.php" | head -20

# Repositories
find src -name "*Repository.php" | head -10
```

### Testing Patterns
```bash
# Test structure
find tests -type d -maxdepth 2 | head -10

# Test naming
find tests -name "*Test.php" | head -10

# Test to code ratio
echo "Code files: $(find src -name '*.php' | wc -l)"
echo "Test files: $(find tests -name '*Test.php' | wc -l)"
```

### Doctrine Patterns
```bash
# Entity patterns
find src -path "*/Entity/*.php" | head -10

# Migration patterns
ls -la migrations/ 2>/dev/null | tail -5

# Repository methods (custom queries)
grep -rn "public function find" src/Repository/ | head -10
```

### Message/Event Patterns
```bash
# Messages
find src -name "*Message.php" | head -10

# Event Listeners
find src -name "*Listener.php" -o -name "*Subscriber.php" | head -10

# Handlers
find src -name "*Handler.php" | head -10
```

---

## Step 3: Generate Skill Files

### 3a. Create directory structure

```bash
SKILL_DIR="{output-path}/{project-name}-patterns"
mkdir -p "$SKILL_DIR/scripts" "$SKILL_DIR/references" "$SKILL_DIR/assets"
```

### 3b. Generate SKILL.md (main file, keep lean)

SKILL.md should contain only high-level purpose and reference pointers. Detailed information goes into `references/` files.

```markdown
---
name: {project-name}-patterns
description: Coding patterns extracted from {project-name} repository. This skill should be used when working on the {project-name} codebase to follow established team conventions.
---

# {Project Name} Patterns

## Purpose

Extracted coding patterns from {project-name} ({tech_stack}).
Based on analysis of {count} commits.

## Quick Reference

| Aspect | Details |
|--------|---------|
| Tech Stack | {detected stack} |
| Test Coverage | {detected}% |
| Commit Style | {conventional/freeform} |
| Code Quality | PHPStan level {n}, {other tools} |

## How to Use

- For architecture and directory structure, load `references/architecture.md`
- For development workflows (API endpoints, handlers, DB changes), load `references/workflows.md`
- For naming, commit, and coding conventions, load `references/conventions.md`

## Key Patterns (Always Apply)

{Top 3-5 most important patterns that should always be in context}
```

### 3c. Generate references/architecture.md

```markdown
# {Project Name} - Architecture

## Code Structure

{Detected directory tree with annotations}

## Key Components

{Services, repositories, handlers - what each layer does}

## Dependencies and Integrations

{External APIs, message queues, databases detected from config}
```

### 3d. Generate references/workflows.md

```markdown
# {Project Name} - Development Workflows

## Adding New API Endpoint
{Steps detected from commit patterns}

## Adding Message Handler
{Steps detected from commit patterns}

## Database Changes
{Steps detected from migration patterns}

## Testing Workflow
{Test structure and patterns}
```

### 3e. Generate references/conventions.md

```markdown
# {Project Name} - Conventions

## Commit Conventions
{Detected patterns with examples}

## Naming Conventions
| Type | Pattern | Example |
|------|---------|---------|
{Detected naming patterns}

## Code Quality Tools
{Detected from composer.json / config}

## Team Practices
{Detected from git history: PR sizes, active areas, etc.}
```

---

## Step 4: Save and Verify

1. Write all files to the target directory
2. Verify SKILL.md has valid YAML frontmatter with `name` and `description`
3. Verify all `references/` files are referenced from SKILL.md
4. Remove any empty `scripts/` or `assets/` directories if nothing was generated for them

---

## Example Output

For a wellness/fitness PHP/Symfony project, the generated skill would be:

```
wellness-app-patterns/
├── SKILL.md
└── references/
    ├── architecture.md
    ├── workflows.md
    └── conventions.md
```

**SKILL.md** (lean, ~50 lines):
```markdown
---
name: wellness-app-patterns
description: Coding patterns from wellness-app backend. This skill should be used when working on the wellness-app codebase to follow established team conventions for PHP 8.3, Symfony 6.4, Doctrine, and RabbitMQ.
---

# Wellness App Patterns

## Purpose

Extracted coding patterns from wellness-app (PHP 8.3, Symfony 6.4, Doctrine, RabbitMQ).
Based on analysis of 150 commits.

## Quick Reference

| Aspect | Details |
|--------|---------|
| Tech Stack | PHP 8.3, Symfony 6.4, Doctrine, RabbitMQ |
| Test Coverage | 82% (target: 80%) |
| Commit Style | Conventional commits with scope |
| Code Quality | PHPStan max, PHP CS Fixer PSR-12+Symfony, Psalm level 2 |

## How to Use

- For architecture and directory structure, load `references/architecture.md`
- For development workflows (API endpoints, handlers, DB changes), load `references/workflows.md`
- For naming, commit, and coding conventions, load `references/conventions.md`

## Key Patterns (Always Apply)

1. All async operations go through RabbitMQ messages with idempotency checks
2. Controllers are thin - business logic lives in Services
3. Every message handler must check `external_id` for idempotency
4. Tests follow AAA pattern: Arrange, Act, Assert
5. API versioning via `Controller/Api/v1/`, `Controller/Api/v2/`
```

---

## Related commands

- `/plan` - implementation planning
- `/code-review` - code review
- `/skill-creator` - create any skill from scratch (not git-based)
