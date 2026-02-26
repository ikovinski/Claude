---
name: codemap
description: Generate architectural codemaps from PHP/Symfony codebase. Analyzes code structure and creates documentation.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Bash", "Edit"]
agent: codebase-doc-collector
---

# /codemap - Architectural Codemap Generator

Генерує архітектурні codemaps з PHP/Symfony codebase. Автоматично аналізує структуру коду і створює документацію.

## Usage

```bash
/codemap                        # Generate all codemaps
/codemap --area controllers     # Only controllers
/codemap --area services        # Only services
/codemap --validate             # Validate existing codemaps
```

## Output

| Flag | Output | Format | Path |
|------|--------|--------|------|
| — (default) | Files | Markdown | `docs/CODEMAPS/*.md` |
| `--validate` | Chat | Validation report | — |
| `--area <name>` | File | Markdown | `docs/CODEMAPS/{area}.md` |

### Generated Structure

```
docs/CODEMAPS/
├── INDEX.md              # Overview of all areas
├── controllers.md        # API Controllers mapping
├── services.md           # Service layer structure
├── entities.md           # Doctrine entities & relations
├── messages.md           # Message handlers (RabbitMQ)
├── integrations.md       # External API integrations
└── commands.md           # Console commands
```

## What It Does

1. **Scans codebase** — finds controllers, services, entities, handlers
2. **Extracts metadata** — routes, dependencies, relations
3. **Generates codemaps** — structured documentation with timestamps
4. **Validates** — checks if docs match actual code

## Options

### `--area <name>`

Generate codemap for specific area only:

| Area | Scans | Output |
|------|-------|--------|
| `controllers` | `src/Controller/**/*.php` | Routes, methods, DTOs |
| `services` | `src/Service/**/*.php` | Dependencies, public methods |
| `entities` | `src/Entity/**/*.php` | Properties, relations |
| `messages` | `src/**/*Handler.php` | Message type, async/sync |
| `integrations` | External API clients | Endpoints, auth |
| `commands` | `src/Command/**/*.php` | Arguments, options |

### `--validate`

Check existing codemaps against current code:

```
🔍 Codemap Validation
═════════════════════

📁 Checking: docs/CODEMAPS/

⚠️ Issues Found:

   Missing from docs:
   ├─ src/Service/NewFeatureService.php
   └─ src/Controller/Api/v2/NewController.php

   Stale references:
   └─ src/Service/OldService.php (deleted)

📊 Summary:
   ├─ Documented: 67/69 (97%)
   ├─ Stale: 1
   └─ Missing: 2

💡 Run /codemap to regenerate
```

## Process

### Phase 1: Discovery

```bash
# Find all PHP files by type
find src/Controller -name "*.php"
find src/Service -name "*.php"
find src/Entity -name "*.php"
find src -name "*Handler.php"
```

### Phase 2: Analysis

For each file:
- Extract class name and namespace
- Find routes (`#[Route]` attributes)
- Parse constructor dependencies
- Identify Doctrine relations
- Extract public methods

### Phase 3: Generation

Create markdown with:
- Freshness timestamp (`last_updated`)
- Component tables
- Mermaid diagrams (data flow)
- Cross-references

## Output Format

### Default (Full Generation)

```
🗺️ Codemap Generation
═════════════════════

📁 Analyzing: /path/to/project

📊 Found:
   ├─ Controllers: 15
   ├─ Services: 23
   ├─ Entities: 18
   ├─ Handlers: 8
   └─ Commands: 5

📝 Generated:
   ├─ docs/CODEMAPS/INDEX.md
   ├─ docs/CODEMAPS/controllers.md
   ├─ docs/CODEMAPS/services.md
   ├─ docs/CODEMAPS/entities.md
   ├─ docs/CODEMAPS/messages.md
   └─ docs/CODEMAPS/commands.md

✅ Validation: PASSED
   └─ All 69 components documented
```

### Codemap File Format

```markdown
# [Area] Codemap

---
last_updated: YYYY-MM-DD
generated_from: codebase
validation_status: passed
---

## Overview

Brief description of this area.

## Structure

\`\`\`
src/[Area]/
├── SubDir/
│   ├── File1.php
│   └── File2.php
└── MainFile.php
\`\`\`

## Key Components

| Component | Purpose | Location | Dependencies |
|-----------|---------|----------|--------------|
| ClassName | What it does | src/path/File.php | Dep1, Dep2 |

## Data Flow

\`\`\`mermaid
flowchart LR
    A[Input] --> B[Process] --> C[Output]
\`\`\`

## Related Areas

- [Link to related codemap](./related.md)
```

## When to Use

**Use /codemap for:**
- New team members onboarding
- After major refactoring
- Before release (documentation audit)
- Weekly freshness check

**Use /codemap --validate for:**
- PR review (check docs coverage)
- CI pipeline (documentation lint)
- Quick health check

**Don't use for:**
- API documentation (use /docs)
- Feature specs (use Technical Writer)
- High-level architecture (use Architecture Doc Collector)

## Integration with CI

```yaml
# .github/workflows/docs.yml
- name: Validate Codemaps
  run: |
    # Check for stale documentation
    claude /codemap --validate
```

## Freshness Policy

| Staleness | Action |
|-----------|--------|
| < 7 days | OK |
| 7-14 days | Warning in PR review |
| > 14 days | Block merge (suggest `/codemap`) |

---

*Uses [Codebase Doc Collector Agent](../agents/codebase-doc-collector.md)*
