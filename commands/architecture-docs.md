---
name: architecture-docs
description: Generate high-level architecture documentation. System profiles, integration catalogs. Confluence-compatible Markdown.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash"]
agent: architecture-doc-collector
---

# /architecture-docs - Architecture Documentation

Генерує high-level архітектурну документацію: System Profile, Integration Catalog. Вивід сумісний з Confluence.

## Usage

```bash
/architecture-docs                       # Generate system profile
/architecture-docs --integration <name>  # Document specific integration
/architecture-docs --scan                # Discover all integrations
/architecture-docs --validate            # Check docs freshness
```

## Output

| Flag | Output | Format | Path |
|------|--------|--------|------|
| — (default) | File | Markdown | `docs/architecture/system-profile.md` |
| `--integration <name>` | File | Markdown | `docs/architecture/integrations/{category}/{name}.md` |
| `--scan` | Chat | Discovery report | — |
| `--validate` | Chat | Freshness report | — |

### Generated Structure

```
docs/architecture/
├── system-profile.md           # System overview + context diagram
└── integrations/
    ├── payment/
    │   ├── apple-app-store.md
    │   └── google-play.md
    ├── analytics/
    │   └── amplitude.md
    └── monitoring/
        └── sentry.md
```

## What It Does

1. **Читає cache** — використовує `.codemap-cache/` якщо існує (від `/codemap`)
2. **Сканує codebase** — HTTP clients, webhooks, messaging, SDKs
3. **Генерує System Profile** — context diagram, integrations table, open questions
4. **Документує інтеграції** — business-oriented, use cases, actors
5. **Пропонує наступні кроки** — review, publish to Confluence

## Process

### Phase 1: Discovery

Якщо є cache від Codebase Doc Collector:
```bash
cat .codemap-cache/integrations.json | jq '.integrations[].name'
cat .codemap-cache/services.json | jq '.services[].class'
```

Якщо немає cache (fallback):
```bash
grep -r "GuzzleHttp\|HttpClient" src/
grep -r "messenger.transport\|kafka" config/
grep -r "webhook" src/Controller/
grep -E "(sdk|client)" composer.json
```

### Phase 2: Analysis

Для кожної інтеграції визначити:
- Business purpose (чому потрібна)
- Actors (хто використовує)
- Use cases (що робить)
- Data flow (що відправляємо/отримуємо)
- Criticality (наскільки критична)

### Phase 3: Generation

Створити документи з:
- Mermaid diagrams (context, sequence)
- Tables for structured data
- Open Questions section

## Output Format

### System Profile

```markdown
# {System Name}

| | |
|---|---|
| **Stack** | PHP 8.3, Symfony, MySQL, Redis, RabbitMQ |
| **Owner** | {Team} |
| **Updated** | {Date} |

## Context

\`\`\`mermaid
flowchart LR
    User[Mobile User] --> Backend
    Admin --> Backend
    Backend --> AppStore[Apple App Store]
    Backend --> Amplitude
    Backend --> Sentry
\`\`\`

## Integrations

| Integration | Type | Status | Criticality |
|-------------|------|--------|-------------|
| Apple App Store | HTTP + Webhook | Active | Critical |
| Amplitude | HTTP | Active | High |

## Open Questions

| ID | Question | Owner |
|----|----------|-------|
| OQ-1 | {Question} | @{owner} |
```

### Integration Document

```markdown
## {Integration Name}

> {Short description}

### Для чого
{Business purpose}

### Актори
- {Actor 1}
- {Actor 2}

### Use Cases
- {Use case 1}
- {Use case 2}

### Які дані
- Відправляємо: {data}
- Отримуємо: {data}

### Як інтегровано
**Тип**: HTTP API / Webhook / Messaging
**API**: {API name if relevant}

### Інтеграційні особливості
- {Non-obvious things}
- {Gotchas}
```

## Examples

### System Profile

```
> /architecture-docs

🏛️ Architecture Documentation
═════════════════════════════

📁 Analyzing: /path/to/project

📊 Discovered:
   ├─ Integrations: 5
   ├─ Services: 23
   └─ External APIs: 3

📝 Generated:
   └─ docs/architecture/system-profile.md

💡 Next steps:
   ├─ /architecture-docs --integration "Apple App Store"
   └─ Review and add Open Questions
```

### Specific Integration

```
> /architecture-docs --integration "Apple App Store"

🏛️ Integration Documentation: Apple App Store
══════════════════════════════════════════════

📊 Analysis:
   ├─ Type: HTTP + Webhook
   ├─ Criticality: Critical (billing)
   └─ Files: 5 related files found

📝 Generated:
   └─ docs/architecture/integrations/payment/apple-app-store.md

⚠️ Open Questions added:
   └─ OQ-1: How to handle webhook signature validation failures?
```

### Discovery Scan

```
> /architecture-docs --scan

🔍 Integration Discovery
════════════════════════

📁 Scanning: src/, config/, composer.json

🌐 HTTP Clients (GuzzleHttp):
   ├─ src/Service/AppleStoreClient.php
   ├─ src/Service/AmplitudeClient.php
   └─ src/Service/IntercomClient.php

📨 Messaging (Kafka/RabbitMQ):
   ├─ config/packages/messenger.yaml
   └─ 3 message handlers

🪝 Webhooks:
   └─ src/Controller/WebhookController.php

📦 SDKs (composer.json):
   ├─ sentry/sentry-symfony
   └─ amplitude/amplitude-php

💡 Run /architecture-docs to generate system profile
```

## Integration with Other Commands

### Recommended Workflow

```
1. /codemap              # Generate code-level cache
2. /architecture-docs    # Use cache for discovery, add business context
3. /docs --feature X     # Detailed feature documentation
```

### Data Flow

```
/codemap → .codemap-cache/ → /architecture-docs → docs/architecture/
                                    ↓
                              (manual analysis)
                                    ↓
                           system-profile.md
                           integrations/*.md
```

## When to Use

**Use /architecture-docs for:**
- System overview for stakeholders
- Onboarding new team members
- Integration catalog
- Pre-refactoring documentation
- Confluence pages

**Don't use for:**
- API endpoint documentation (use `/docs`)
- Code-level documentation (use `/codemap`)
- Feature specifications (use `/docs --feature`)
- Operational runbooks (use `/docs --runbook`)

## Confluence Compatibility

Generated Markdown works with:
- **Mermaid Diagrams for Confluence** macro
- **Markdown Macro** with Mermaid support

Best practices:
- Use `flowchart LR/TB` for diagrams
- Tables for structured data
- Keep sections concise

## Freshness Policy

| Doc Type | Fresh | Stale | Outdated |
|----------|-------|-------|----------|
| System Profile | < 90 days | 90-180 days | > 180 days |
| Integrations | < 30 days | 30-90 days | > 90 days |

---

*Uses [Architecture Doc Collector Agent](../agents/architecture-doc-collector.md)*
