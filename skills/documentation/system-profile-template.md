# System Profile Template

Confluence-compatible. Лаконічний формат.

## Template

```markdown
# {System Name}

| | |
|---|---|
| **Stack** | PHP 8.3, Symfony 6.4, MySQL, Redis, RabbitMQ |
| **Repo** | [link] |
| **Owner** | Team Name |
| **Updated** | YYYY-MM-DD |

## Context Diagram

\`\`\`mermaid
flowchart TB
    User[User] --> System[{System Name}]
    Admin[Admin] --> System
    System --> Ext1[External 1]
    System --> Ext2[External 2]
    System --> DB[(Database)]
\`\`\`

## Integrations

| Category | Integration | Type | Status | Criticality |
|----------|-------------|------|--------|-------------|
| Payment | Apple App Store | HTTP | Active | Critical |
| Payment | Google Play | HTTP | Active | Critical |
| Analytics | Amplitude | HTTP | Active | High |
| Monitoring | Sentry | SDK | Active | High |

→ Details: [integrations/](integrations/)

## Dependencies

| Service | Purpose | Impact if Down |
|---------|---------|----------------|
| MySQL | Primary DB | Critical |
| Redis | Cache | Degraded performance |
| RabbitMQ | Async jobs | Delayed processing |

## Open Questions

| ID | Question | Owner | Status |
|----|----------|-------|--------|
| OQ-1 | {Question} | @name | Open |

## Issues

| ID | Description | Priority |
|----|-------------|----------|
| ISSUE-1 | {Description} | High |

## Changelog

| Date | Change | Author |
|------|--------|--------|
| YYYY-MM-DD | Initial | @name |
```

## Guidelines

1. **Diagram first** — Context diagram на початку
2. **Tables** — Все структуроване в таблицях
3. **Links** — До деталей інтеграцій
4. **Track unknowns** — OQ та Issues обов'язкові
