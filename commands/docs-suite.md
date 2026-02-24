---
name: docs-suite
description: Generate complete documentation suite. Orchestrates Codebase Doc Collector, Architecture Doc Collector, and Technical Writer as a team.
allowed_tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
agent: null
scenario: delivery/documentation-suite
---

# /docs-suite - Documentation Suite

Оркеструє 3 документаційні агенти як команду для генерації повної документації проєкту з codebase. Виконує scan, architecture analysis, API docs та cross-review в одному pipeline.

## Usage

```bash
/docs-suite                          # Full documentation (current project)
/docs-suite <path>                   # Specific project
/docs-suite --scope architecture     # Only architecture docs
/docs-suite --scope api              # Only API docs
/docs-suite --no-cross-review        # Skip cross-review phase
/docs-suite --force-rescan           # Force cache regeneration
```

## Output

| Flag | Output | Path |
|------|--------|------|
| — (default) | Full documentation suite | `docs/` (all subdirectories) |
| `--scope architecture` | Architecture only | `docs/architecture/` |
| `--scope api` | API docs only | `docs/references/` |
| `--force-rescan` | Force fresh cache | `.codemap-cache/` + all docs |

### Generated Structure

```
docs/
├── INDEX.md                         # Unified documentation catalog
├── CODEMAPS/                        # Code architecture maps
│   ├── INDEX.md
│   ├── controllers.md
│   ├── services.md
│   ├── entities.md
│   ├── messages.md
│   └── integrations.md
├── architecture/                    # System-level documentation
│   ├── system-profile.md
│   └── integrations/
│       ├── payment/
│       │   └── apple-app-store.md
│       └── analytics/
│           └── amplitude.md
├── references/                      # API specifications
│   └── openapi.yaml
└── features/                        # Feature documentation
    ├── workout-tracking.md
    └── subscription-management.md
```

## What It Does

5-phase pipeline з 3 агентами:

### Phase 1: SCAN
**Agent**: Codebase Doc Collector
- Сканує codebase (controllers, entities, services, messages, integrations)
- Генерує `.codemap-cache/*.json` (structured data)
- Генерує `docs/CODEMAPS/*.md` (human-readable maps)

### Phase 2: ANALYZE (parallel)
**Agents**: Architecture Doc Collector + Technical Writer (одночасно)
- Architecture: system profile, integration catalog, context diagrams
- Writer: OpenAPI spec, feature docs, API flow diagrams

### Phase 3: COMPILE
**Agent**: Team Lead
- Інвентаризація всіх docs
- Gap detection (components без документації)
- Призначення fixes відповідним агентам

### Phase 4: CROSS-REVIEW
**Agents**: Architecture Doc Collector ↔ Technical Writer
- Architecture review'є Writer output (naming, consistency)
- Writer review'є Architecture output (clarity, scannability)

### Phase 5: INDEX
**Agent**: Team Lead
- Генерує `docs/INDEX.md` — єдиний entry point
- Statistics та regeneration instructions

## Output Format

```
📚 Documentation Suite
══════════════════════

📁 Project: /path/to/project

Phase 1: SCAN ✅
   ├─ Controllers: 15
   ├─ Entities: 18
   ├─ Services: 23
   ├─ Handlers: 8
   └─ Integrations: 5

Phase 2: ANALYZE ✅
   ├─ Architecture: system-profile + 5 integrations
   └─ API: openapi.yaml + 4 feature docs

Phase 3: COMPILE ✅
   ├─ Gaps found: 1
   └─ Gaps fixed: 1

Phase 4: CROSS-REVIEW ✅
   ├─ Consistency issues: 2
   └─ All fixed: ✅

Phase 5: INDEX ✅
   └─ docs/INDEX.md generated

📊 Summary:
   ├─ Total documents: 19
   ├─ Coverage: 100%
   └─ Open questions: 3

⏱️ Duration: ~90 minutes
```

## Examples

### Full Documentation Suite

```
> /docs-suite

Starting Documentation Suite scenario...
Team: docs-suite-wellness-backend

Phase 1: Scanning codebase...
[Codebase Doc Collector generates cache + CODEMAPS]

Phase 2: Analyzing (parallel)...
[Architecture Doc Collector → system profile]
[Technical Writer → OpenAPI + features]

Phase 3: Compiling...
[Gap: Kafka topics missing from architecture → assigned to architect]

Phase 4: Cross-reviewing...
[Naming mismatch fixed: "AppStoreClient" → "Apple App Store"]
[System profile table format improved]

Phase 5: Generating index...
[docs/INDEX.md created]

✅ Documentation Suite complete. Entry point: docs/INDEX.md
```

### Architecture Only

```
> /docs-suite --scope architecture

Starting Documentation Suite (architecture scope)...

Phase 1: Scanning codebase...
Phase 2: Architecture analysis only...
Phase 5: Generating index...

✅ Architecture docs generated: docs/architecture/
```

## When to Use

| Situation | Command |
|-----------|---------|
| Потрібна повна документація з нуля | `/docs-suite` |
| Onboarding нових інженерів | `/docs-suite` |
| Pre-release documentation audit | `/docs-suite` |
| Project handoff іншій команді | `/docs-suite` |
| Потрібен тільки codemap | `/codemap` |
| Потрібен тільки OpenAPI | `/docs --api` |
| Потрібен тільки system profile | `/architecture-docs` |
| Оновити один тип docs | Відповідна окрема команда |

## Relationship to Individual Commands

`/docs-suite` **оркеструє** три окремі команди як координовану команду:

```
/docs-suite = /codemap + /architecture-docs + /docs
              + parallel execution
              + cross-review
              + gap detection
              + unified INDEX.md
```

Детальне порівняння: [docs-suite-vs-individual-commands.md](../docs/how-it-works/docs-suite-vs-individual-commands.md)

## Decision Points

Сценарій запитує user input в 3 точках:

| # | Question | Default |
|---|----------|---------|
| 1 | Cache exists — reuse or rescan? | Reuse if < 7 days |
| 2 | What scope? (full/architecture/api) | Full |
| 3 | Cross-review depth? (full/consistency/skip) | Full |

---

*Uses [Documentation Suite Scenario](../scenarios/delivery/documentation-suite.md)*
*Agents: [Codebase Doc Collector](../agents/codebase-doc-collector.md), [Architecture Doc Collector](../agents/architecture-doc-collector.md), [Technical Writer](../agents/technical-writer.md)*
