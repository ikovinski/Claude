---
name: api-contracts-template
description: Template for API contract documentation — REST endpoints and async message contracts. Used by Design Architect during /design phase.
version: 1.0.0
---

# API Contracts Template Skill

Defines the format for API contract documentation. Covers REST endpoints and async message contracts (queues/topics).

## When This Skill Applies

- Design Architect creating `api-contracts.md` during `/design` phase
- Documenting API contracts outside the flow
- Reviewing API contract completeness

## Format: `api-contracts.md`

```markdown
# API Contracts: {Feature Name}

## Overview

{1-2 sentences — what API changes this feature introduces}

| Type | Count |
|------|-------|
| New endpoints | {n} |
| Modified endpoints | {n} |
| New async messages | {n} |
| Breaking changes | {n} |

---

## REST Endpoints

### {METHOD} {path}

**Description:** {what this endpoint does}
**Auth:** {Bearer token (ROLE_USER) / API key / none}
**Status:** NEW / MODIFIED

**Request:**
```json
{
  "field_name": "type — description",
  "nested": {
    "field": "type — description"
  }
}
```

**Response 200/201:**
```json
{
  "id": "string — unique identifier",
  "field": "type — description"
}
```

**Response 422 (Validation Error):**
```json
{
  "code": "VALIDATION_ERROR",
  "message": "string",
  "details": [
    {"field": "field_name", "error": "error description"}
  ]
}
```

**Other Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | UNAUTHORIZED | Missing or invalid auth token |
| 403 | FORBIDDEN | Insufficient permissions |
| 404 | NOT_FOUND | Resource does not exist |
| 409 | CONFLICT | Duplicate or conflicting state |

---

## Async Messages

### {queue/topic}.{action}

**Transport:** RabbitMQ / Kafka / SQS
**Direction:** publish / consume / both
**Status:** NEW / MODIFIED

**Payload:**
```json
{
  "event_type": "string — event identifier",
  "timestamp": "ISO 8601",
  "data": {
    "field": "type — description"
  }
}
```

**Idempotency Key:** {field or combination of fields}
**Retry Policy:** {max retries, backoff strategy}

---

## Breaking Changes

{List any breaking changes with migration path. Omit section if none.}

| Change | Affected Consumers | Migration Path |
|--------|-------------------|----------------|
| {description} | {who is affected} | {how to migrate} |
```

## Contract-First vs Architecture-First

| Scenario | Approach | Rationale |
|----------|----------|-----------|
| Feature adds new API endpoints | **Contract-first** — write contracts BEFORE architecture | Consumer-driven: define WHAT before HOW |
| Feature modifies existing endpoints | **Contract-first** — document changes BEFORE architecture | Understand impact on consumers first |
| Feature is internal (no API changes) | **Architecture-first** — skip contracts or write after | No consumer-facing changes to drive design |
| Feature adds async messages only | **Architecture-first** — message contracts in architecture | Message shapes often emerge from architecture decisions |

## Quality Checklist

- [ ] Every new/modified endpoint has request AND response schemas
- [ ] Error responses are documented (not just happy path)
- [ ] Auth requirements specified for each endpoint
- [ ] Async messages have idempotency key defined
- [ ] Breaking changes section present (even if empty / "None")
- [ ] JSON examples use realistic (not placeholder) data types
- [ ] Schemas are consistent with existing API conventions in the project
