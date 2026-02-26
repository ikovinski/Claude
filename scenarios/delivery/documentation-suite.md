# Documentation Suite Scenario

## Metadata
```yaml
name: documentation-suite
category: delivery
trigger: Generate complete documentation suite from codebase
participants:
  - Team Lead (orchestrator)
  - Codebase Doc Collector (scanner)
  - Architecture Doc Collector (architect)
  - Technical Writer (writer)
duration: 60-120 minutes
skills:
  - auto:{project}-patterns
  - documentation/codemap-template
  - documentation/system-profile-template
  - documentation/integration-template
  - documentation/api-docs-template
  - documentation/feature-spec-template
team_execution: true
```

## Skills Usage in This Scenario

1. **codemap-template**: Codebase Doc Collector використовує для генерації `.codemap-cache/*.json` та `docs/CODEMAPS/*.md`
2. **system-profile-template**: Architecture Doc Collector використовує для system overview з context diagrams
3. **integration-template**: Architecture Doc Collector використовує для per-integration документації
4. **api-docs-template**: Technical Writer використовує для трансформації cache в OpenAPI spec
5. **feature-spec-template**: Technical Writer використовує для feature documentation
6. **{project}-patterns**: Всі агенти застосовують project-specific conventions

## Situation

### Description
Проєкт потребує повної документації, згенерованої з codebase — codemaps, architecture overview, API specs, feature docs. Типово це відбувається при підготовці до onboarding, pre-release documentation audit, або коли система виросла без відповідної документації.

### Common Triggers
- "Generate full documentation"
- "Document this project completely"
- "We need docs for onboarding"
- "Pre-release documentation audit"
- "Create architecture and API docs from code"
- "Prepare documentation for handoff"
- "Згенеруй повну документацію"
- "Підготуй документацію для нової команди"

### Wellness/Fitness Tech Context
- **Wearable integrations**: Кілька зовнішніх API (Garmin, Fitbit, Apple Health) потребують integration catalogs
- **Billing complexity**: Payment flows (Apple App Store, Google Play) потребують і architecture docs і API specs
- **Health data sensitivity**: Документація має відзначати PII/PHI handling без розкриття sensitive patterns
- **Monolith context**: Codemaps критичні для розуміння boundaries у великому codebase

---

## Participants

### Required
| Role/Agent | Model | Purpose in Scenario |
|------------|-------|---------------------|
| Team Lead (Claude) | opus | Оркеструє фази, керує task list, контролює phase gates, генерує INDEX |
| Codebase Doc Collector | sonnet | Сканує codebase, генерує `.codemap-cache/*.json` та `docs/CODEMAPS/*.md` |
| Architecture Doc Collector | sonnet | Консумує cache, генерує system profiles та integration catalogs |
| Technical Writer | sonnet | Консумує cache + architecture output, генерує OpenAPI та feature docs |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| Security Reviewer | Якщо проєкт обробляє PII/PHI і документація потребує security annotations |
| Code Reviewer | Якщо документація має включати code quality observations |

---

## Process Flow

### Phase 1: SCAN (blocking)
**Lead**: Codebase Doc Collector

Steps:
1. Перевірити що target project існує і є PHP/Symfony проєктом
2. Перевірити наявність `.codemap-cache/metadata.json` та оцінити freshness
3. Якщо cache fresh (< 7 днів) — повідомити, запропонувати reuse або rescan
4. Якщо cache stale/missing — виконати повний codebase scan
5. Згенерувати `.codemap-cache/*.json` (controllers, entities, services, messages, integrations)
6. Згенерувати `docs/CODEMAPS/*.md` (human-readable codemaps)
7. Запустити validation: verify cache matches actual code

**Output**: Fresh `.codemap-cache/` directory + `docs/CODEMAPS/*.md`
**Gate**: Team lead перевіряє що cache generation пройшов успішно (checks `metadata.json` stats)

### Phase 2: ANALYZE (parallel)
**Track A Lead**: Architecture Doc Collector
**Track B Lead**: Technical Writer
**Input**: Обидва читають з `.codemap-cache/`

Track A (Architecture Doc Collector):
1. Прочитати `.codemap-cache/integrations.json` — discover external APIs
2. Прочитати `.codemap-cache/services.json` — architecture diagram data
3. Прочитати `.codemap-cache/entities.json` — data model overview
4. Згенерувати `docs/architecture/system-profile.md` з Mermaid context diagram
5. Згенерувати `docs/architecture/integrations/*.md` для кожної інтеграції
6. Додати Open Questions section

Track B (Technical Writer):
1. Прочитати `.codemap-cache/controllers.json` — OpenAPI paths
2. Прочитати `.codemap-cache/entities.json` — schema generation
3. Прочитати `.codemap-cache/messages.json` — async API documentation
4. Згенерувати `docs/references/openapi.yaml`
5. Згенерувати `docs/features/*.md` для основних features
6. Додати Mermaid diagrams для key API flows

**Output (Track A)**: `docs/architecture/system-profile.md`, `docs/architecture/integrations/*.md`
**Output (Track B)**: `docs/references/openapi.yaml`, `docs/features/*.md`
**Gate**: Team lead чекає завершення обох tracks, перевіряє наявність deliverables

### Phase 3: COMPILE
**Lead**: Team Lead

Steps:
1. Інвентаризація всіх згенерованих документів
2. Перевірка повноти: CODEMAPS exist, architecture docs exist, API docs exist
3. Пошук gaps: інтеграції в cache але не в architecture docs, controllers не в OpenAPI
4. Призначення gap-filling tasks відповідним агентам
5. Перевірка cross-references: architecture docs → CODEMAPS, OpenAPI → features

**Output**: Gap report + додаткові документи якщо потрібно
**Gate**: Всі gaps заповнені

### Phase 4: CROSS-REVIEW
**Lead**: Rotates between agents

Steps:
1. Architecture Doc Collector review'є Technical Writer output:
   - Чи консистентні назви інтеграцій?
   - Чи всі endpoints з OpenAPI покриті в system profile?
   - Чи немає суперечностей у описах поведінки?
2. Technical Writer review'є Architecture Doc Collector output:
   - Чи system profile scannable (tables, not prose)?
   - Чи Mermaid diagrams мають valid syntax?
   - Чи integration docs мають достатньо деталей для external consumers?
   - Чи Open Questions actionable?
3. Обидва агенти створюють короткий review report
4. Team lead збирає findings та призначає corrections
5. Агенти виправляють свої outputs

**Output**: Consistency report, corrected documentation
**Gate**: Team lead підтверджує що cross-review findings addressed

### Phase 5: INDEX
**Lead**: Team Lead

Steps:
1. Згенерувати `docs/INDEX.md` — unified documentation catalog
2. Структура: секція per documentation type з links та descriptions
3. Додати freshness metadata (generation date, project stats)
4. Додати "How to regenerate" instructions з посиланням на `/docs-suite`
5. Відзвітувати final statistics

**Output**: `docs/INDEX.md` з повним каталогом документації
**Gate**: Scenario complete, final report presented to user

---

## Decision Points

### Decision 1: Cache Freshness
**Question**: Cache існує і < 7 днів. Перевикористати чи пересканувати?
**Options**:
- A: Reuse existing cache — швидко, але може пропустити нещодавні зміни
- B: Force rescan — повільніше, гарантовано свіжий cache
- C: Incremental — сканувати тільки змінені areas

**Recommended approach**: A для routine updates, B для pre-release

### Decision 2: Documentation Scope
**Question**: Які типи документації генерувати?
**Options**:
- A: Full (CODEMAPS + Architecture + API + Features) — default
- B: Architecture only (skip API docs)
- C: API only (skip architecture docs)
- D: Custom selection

**Recommended approach**: A для першого запуску, потім targeted updates через окремі команди

### Decision 3: Cross-Review Depth
**Question**: Наскільки глибоким має бути cross-review?
**Options**:
- A: Consistency check only (naming, linking)
- B: Full review (consistency + quality + completeness)
- C: Skip cross-review

**Recommended approach**: B для першої генерації, A для updates, C при обмеженому часі

---

## Prompts Sequence

### Step 1: Cache Generation (Codebase Doc Collector)
**Prompt**:
```
[IDENTITY]
Ти — Codebase Doc Collector, Documentation Automation Specialist.

[BIASES]
1. Generate, Don't Write — документація має генеруватися з коду
2. Freshness Over Completeness — актуальна неповна > повна застаріла
3. Single Source of Truth — код — це правда

[CONTEXT]
Project: {{project_path}}
Task: Phase 1 of Documentation Suite scenario

[TASK]
Scan codebase at {{project_path}} and generate:
1. .codemap-cache/*.json (controllers, entities, services, messages, integrations)
2. docs/CODEMAPS/*.md (human-readable codemaps)

Check for existing cache first. If fresh (< 7 days), report stats and skip.
If stale or missing, perform full scan.

[OUTPUT]
## Phase 1: SCAN Complete

### Cache Status
- Previous cache: [found/not found]
- Action taken: [reused/regenerated]
- Generated at: [timestamp]

### Stats
| Component | Count |
|-----------|-------|
| Controllers | N |
| Entities | N |
| Services | N |
| Message Handlers | N |
| Integrations | N |

### Files Generated
[list all generated files]

### Validation
[PASSED/FAILED with details]
```

### Step 2a: Architecture Analysis (Architecture Doc Collector)
**Prompt**:
```
[IDENTITY]
Ти — Architecture Doc Collector, Architecture Documentation Specialist.

[BIASES]
1. Diagram First — Mermaid flowchart перед текстом
2. Business Focus — use cases та актори, не технічні деталі
3. Track Unknowns — Open Questions обов'язкові
4. Consistency — один шаблон для всіх інтеграцій

[CONTEXT]
Project: {{project_path}}
Cache: {{project_path}}/.codemap-cache/
Phase: 2A of Documentation Suite (parallel with Technical Writer)

[TASK]
Using .codemap-cache/ data:
1. Read integrations.json, services.json, entities.json
2. Generate docs/architecture/system-profile.md with Mermaid context diagram
3. Generate docs/architecture/integrations/*.md for each integration
4. Include Open Questions section

[OUTPUT]
## Phase 2A: Architecture Analysis Complete

### System Profile
- Generated: docs/architecture/system-profile.md
- Context diagram: [included/not included]
- Integrations found: N

### Integration Documents
| Integration | Category | File | Criticality |
|-------------|----------|------|-------------|
| [name] | [category] | [path] | [level] |

### Open Questions
| ID | Question | Suggested Owner |
|----|----------|----------------|
| OQ-1 | [question] | @[team] |
```

### Step 2b: API & Feature Documentation (Technical Writer)
**Prompt**:
```
[IDENTITY]
Ти — Technical Writer, Documentation Specialist для cross-team communication.

[BIASES]
1. Audience First — хто це читатиме і що їм потрібно зробити?
2. Visualize First — Mermaid diagrams для API flows
3. Scannable Over Comprehensive — tables, bullets, code blocks
4. Examples > Explanations — working curl commands over prose
5. Code-Driven Swagger — generate OpenAPI from cache

[CONTEXT]
Project: {{project_path}}
Cache: {{project_path}}/.codemap-cache/
Phase: 2B of Documentation Suite (parallel with Architecture Doc Collector)

[TASK]
Using .codemap-cache/ data:
1. Read controllers.json → generate docs/references/openapi.yaml
2. Read entities.json → generate OpenAPI schemas
3. Read messages.json → document async APIs
4. Identify major features → generate docs/features/*.md

[OUTPUT]
## Phase 2B: API & Feature Documentation Complete

### OpenAPI Specification
- Generated: docs/references/openapi.yaml
- Endpoints documented: N
- Schemas documented: N

### Feature Documentation
| Feature | File | Audience |
|---------|------|----------|
| [name] | [path] | [audience] |

### Mermaid Diagrams Included
[list of diagrams added]
```

### Step 4a: Cross-Review — Architecture reviews Writer
**Prompt**:
```
[TASK]
Review Technical Writer outputs for consistency with architecture documentation:
- docs/references/openapi.yaml
- docs/features/*.md

Check:
1. Integration names match between architecture and OpenAPI
2. Service names are consistent
3. Entity/schema names align
4. No contradictions in system behavior descriptions

[OUTPUT]
## Cross-Review: Architecture → Technical Writer

### Consistency Issues
| Location | Issue | Suggested Fix |
|----------|-------|--------------|
| [file:line] | [description] | [fix] |

### Verdict: [CONSISTENT / NEEDS FIXES]
```

### Step 4b: Cross-Review — Writer reviews Architecture
**Prompt**:
```
[TASK]
Review Architecture Doc Collector outputs for audience clarity:
- docs/architecture/system-profile.md
- docs/architecture/integrations/*.md

Check:
1. System profile is scannable (tables, not prose)
2. Mermaid diagrams render correctly (valid syntax)
3. Integration docs have sufficient detail for external consumers
4. Open Questions are actionable

[OUTPUT]
## Cross-Review: Technical Writer → Architecture

### Clarity Issues
| Location | Issue | Suggested Fix |
|----------|-------|--------------|
| [file:line] | [description] | [fix] |

### Verdict: [CLEAR / NEEDS IMPROVEMENTS]
```

### Step 5: Index Generation (Team Lead)
**Prompt**:
```
[TASK]
Generate docs/INDEX.md — unified documentation index.

[OUTPUT]
# Documentation Index

Generated: [date]
Project: [name]
Generated by: /docs-suite

## Code Architecture (CODEMAPS)
| Document | Description | Last Updated |
|----------|-------------|-------------|
| [link] | [desc] | [date] |

## System Architecture
| Document | Description | Last Updated |
|----------|-------------|-------------|
| [link] | [desc] | [date] |

## API Reference
| Document | Description | Last Updated |
|----------|-------------|-------------|
| [link] | [desc] | [date] |

## Feature Documentation
| Document | Description | Audience | Last Updated |
|----------|-------------|----------|-------------|
| [link] | [desc] | [audience] | [date] |

## Statistics
| Metric | Value |
|--------|-------|
| Total documents | N |
| Controllers documented | N |
| Entities documented | N |
| Integrations documented | N |
| Open questions | N |

## How to Regenerate
- Full: `/docs-suite`
- Code maps only: `/codemap`
- Architecture only: `/architecture-docs`
- API docs only: `/docs --api`
```

---

## Team-Based Execution

На відміну від feature-decomposition та rewrite-decision, які використовують sequential agent-switching, цей сценарій виконується як **Agent Team** для Phase 2 parallelism.

### Team Setup

```
Team Lead creates team:
  team_name: "docs-suite-{project-name}"
  description: "Documentation Suite generation"
```

### Teammates

| Name | Agent File | subagent_type | Model | Phases |
|------|-----------|---------------|-------|--------|
| scanner | codebase-doc-collector | codebase-doc-collector | sonnet | 1 |
| architect | architecture-doc-collector | architecture-doc-collector | sonnet | 2A, 4 |
| writer | technical-writer | technical-writer | sonnet | 2B, 4 |

### Phase Execution

```
Phase 1 (SCAN):
  Team lead spawns "scanner" teammate
  Assigns SCAN task via shared task list
  Waits for completion
  scanner goes idle

Phase 2 (ANALYZE):
  Team lead spawns "architect" and "writer" IN PARALLEL
  Creates tasks for both simultaneously
  Both read from .codemap-cache/ (no write conflicts)
  Team lead waits for BOTH to complete

Phase 3 (COMPILE):
  Team lead performs compilation directly
  If gaps found → sends messages to architect/writer via SendMessage

Phase 4 (CROSS-REVIEW):
  Team lead creates cross-review tasks
  architect reviews writer's output
  writer reviews architect's output
  Team lead collects findings, assigns corrections

Phase 5 (INDEX):
  Team lead generates index directly
  Sends shutdown_request to all teammates
  Calls TeamDelete to clean up
```

### Task List Structure

```
1. [scanner] Scan codebase and generate cache
2. [architect] Generate system profile and integration docs
3. [writer] Generate OpenAPI and feature docs
4. [lead] Compile and check for gaps
5. [architect] Cross-review writer output
6. [writer] Cross-review architect output
7. [lead] Generate INDEX.md
```

### Communication Pattern

- **Team lead → teammates**: Task assignments, phase gates
- **Teammates → team lead**: Completion reports, blockers
- **architect ↔ writer**: Не напряму; вся координація через team lead (уникнення complexity, team lead = single source of truth)

---

## Success Criteria

### Minimum Viable Outcome
- [ ] `.codemap-cache/` generated з усіма JSON files
- [ ] `docs/CODEMAPS/` generated з усіма markdown files
- [ ] `docs/architecture/system-profile.md` exists з context diagram
- [ ] `docs/references/openapi.yaml` exists з endpoints

### Good Outcome
- [ ] Integration catalogs generated для всіх discovered integrations
- [ ] Feature docs generated для major features
- [ ] Cross-references між документами valid
- [ ] Mermaid diagrams render correctly

### Excellent Outcome
- [ ] Cross-review completed без consistency issues
- [ ] `docs/INDEX.md` generated з complete catalog
- [ ] Open Questions tracked в architecture docs
- [ ] Всі документи мають freshness timestamps
- [ ] Statistics match actual codebase (validated)

---

## Anti-Patterns

### What to Avoid

1. **Sequential Where Parallel Works**: Запускати Architecture Doc Collector потім Technical Writer послідовно, коли обидва тільки читають з cache — втрата часу

2. **Skipping Cache**: Кожен агент самостійно сканує codebase — duplicated work, inconsistent results (це проблема яку cooperation protocol вирішує)

3. **No Cross-Review**: Генерація docs ізольовано з припущенням consistency — naming дрифтує між architecture та API docs

4. **One-Shot Mentality**: Трактувати як "запустити раз" замість repeatable pipeline — docs стають stale

5. **Over-Generating**: Створювати docs для internal implementation details що жоден external consumer не потребує

6. **Ignoring Open Questions**: Трактувати architecture doc collection як fully automated коли потрібен manual business context input

### Warning Signs
- Всі документи мають однакову структуру — ймовірно не адаптовані під audience
- Zero Open Questions — not looking hard enough
- No Mermaid diagrams — missing visualization opportunity
- INDEX.md not generated — немає єдиної точки входу

---

## Example Walkthrough

### Context
Команда готується до onboarding 3 нових інженерів для `wellness-backend` проєкту.

### How It Played Out

**Phase 1 (SCAN)**:
```
Codebase Doc Collector scanning: ~/wellness-backend
Found: 15 controllers, 18 entities, 23 services, 8 handlers, 5 integrations
Cache: .codemap-cache/ (6 JSON files)
CODEMAPS: docs/CODEMAPS/ (7 markdown files)
Validation: PASSED
```

**Phase 2 (ANALYZE — parallel)**:
```
Track A (Architecture Doc Collector):
  System Profile: wellness backend context diagram (Mermaid)
  5 integrations: Apple App Store, Google Play, Amplitude, Sentry, Intercom
  3 Open Questions identified

Track B (Technical Writer):
  OpenAPI: 32 endpoints documented
  4 feature docs: Workout Tracking, Subscription Management, Social Feed, Notifications
  8 Mermaid sequence diagrams
```

**Phase 3 (COMPILE)**:
```
Team Lead inventory:
  CODEMAPS: 7 files ✅
  Architecture: system-profile + 5 integrations ✅
  API: openapi.yaml + 4 features ✅
  Gap: Kafka topics not in architecture docs
  → Assigned to Architecture Doc Collector
```

**Phase 4 (CROSS-REVIEW)**:
```
Architecture → Writer:
  Issue: OpenAPI uses "AppStoreClient", architecture uses "Apple App Store"
  Fix: Standardize to "Apple App Store" everywhere

Writer → Architecture:
  Issue: System profile has prose-heavy integration section
  Fix: Convert to table format for scannability
```

**Phase 5 (INDEX)**:
```
Generated: docs/INDEX.md
Total: 19 documents
Coverage: 100% controllers, 100% integrations
```

### Outcome
- Нові інженери отримують `docs/INDEX.md` як entry point
- Codemaps для code navigation
- Architecture overview для high-level understanding
- API specs для integration work
- Feature docs для business context
- Загальний час: ~90 хвилин

---

## Related

- **Cooperation Protocol**: [doc-agents-cooperation.md](../../docs/how-it-works/doc-agents-cooperation.md) — Cache-based handoff between agents
- **Comparison**: [docs-suite-vs-individual-commands.md](../../docs/how-it-works/docs-suite-vs-individual-commands.md) — /docs-suite vs /codemap + /architecture-docs + /docs
- **Individual Commands**: [/codemap](../../commands/codemap.md), [/docs](../../commands/docs.md), [/architecture-docs](../../commands/architecture-docs.md)
- **Agent Files**: [codebase-doc-collector](../../agents/codebase-doc-collector.md), [architecture-doc-collector](../../agents/architecture-doc-collector.md), [technical-writer](../../agents/technical-writer.md)
