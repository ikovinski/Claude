# Architecture Decision Record (ADR) Template

## Purpose
Document significant technical decisions for future reference and team alignment.

## Freshness Metadata

ADRs are historical records. Status changes (Deprecated/Superseded) must be tracked.

## Audience
- **Future maintainers**: Understand why things are built this way
- **Architects**: Review and approve decisions
- **New team members**: Learn system history

---

## Template

```markdown
---
stoplight-id: adr-{number}-{slug}
last_reviewed: YYYY-MM-DD
---

# ADR-{NNNN}: {Decision Title}

## Metadata

| Aspect | Value |
|--------|-------|
| **Status** | Proposed / Accepted / Deprecated / Superseded |
| **Date** | YYYY-MM-DD |
| **Last Reviewed** | YYYY-MM-DD |
| **Deciders** | @person1, @person2 |
| **Supersedes** | ADR-XXXX (if applicable) |
| **Superseded by** | ADR-YYYY (if applicable) |

## Context

{Describe the situation that led to this decision. Include:
- What problem are we facing?
- What constraints exist?
- What forces are at play?
- Why is a decision needed now?}

### Current State

{Describe how things work today, if relevant.}

### Problem Statement

{One sentence summarizing the core problem.}

## Decision

{State the decision clearly and concisely.}

**We will {action/choice}.**

{Expand on the decision if needed, but keep it focused.}

## Rationale

{Explain why this decision was made. What factors were most important?}

### Key Factors

1. **{Factor 1}**: {Why it matters}
2. **{Factor 2}**: {Why it matters}
3. **{Factor 3}**: {Why it matters}

## Alternatives Considered

### Option 1: {Name}

{Brief description}

| Pros | Cons |
|------|------|
| {Pro 1} | {Con 1} |
| {Pro 2} | {Con 2} |

**Why rejected**: {Reason}

### Option 2: {Name}

{Brief description}

| Pros | Cons |
|------|------|
| {Pro 1} | {Con 1} |
| {Pro 2} | {Con 2} |

**Why rejected**: {Reason}

### Option 3: {Selected Option}

{Brief description}

| Pros | Cons |
|------|------|
| {Pro 1} | {Con 1} |
| {Pro 2} | {Con 2} |

**Why selected**: {Reason}

## Consequences

### Positive

- {Benefit 1}
- {Benefit 2}
- {Benefit 3}

### Negative

- {Drawback 1}
- {Drawback 2}

### Neutral

- {Change that's neither good nor bad}

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {Risk 1} | High/Med/Low | High/Med/Low | {Mitigation} |
| {Risk 2} | High/Med/Low | High/Med/Low | {Mitigation} |

## Implementation

### Migration Plan

{How will we transition from current state to new state?}

### Timeline

| Phase | Description | Duration |
|-------|-------------|----------|
| Phase 1 | {Description} | {Time} |
| Phase 2 | {Description} | {Time} |

### Affected Systems

- {System 1}: {How it's affected}
- {System 2}: {How it's affected}

## References

- [Link to discussion thread]
- [Link to prototype/POC]
- [Link to relevant documentation]

---

## Notes

{Any additional context, meeting notes, or comments.}
```

---

## Lightweight ADR (for smaller decisions)

```markdown
---
stoplight-id: adr-{number}-{slug}
---

# ADR-{NNNN}: {Decision Title}

**Status**: Accepted | **Date**: YYYY-MM-DD | **Deciders**: @team

## Context

{2-3 sentences on the problem}

## Decision

We will {decision}.

## Consequences

**Positive**: {benefits}

**Negative**: {drawbacks}

## Alternatives Rejected

- {Option 1}: {Why not}
- {Option 2}: {Why not}
```

---

## ADR Numbering

```
docs/adr/
├── 0001-use-redis-for-sessions.md
├── 0002-adopt-event-sourcing.md
├── 0003-switch-to-kubernetes.md
└── README.md  # Index of all ADRs
```

### ADR Index Template

```markdown
# Architecture Decision Records

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-use-redis-for-sessions.md) | Use Redis for Sessions | Accepted | 2024-01-15 |
| [0002](0002-adopt-event-sourcing.md) | Adopt Event Sourcing | Accepted | 2024-02-01 |
| [0003](0003-switch-to-kubernetes.md) | Switch to Kubernetes | Proposed | 2024-02-10 |
```

---

## When to Write an ADR

**Write ADR for:**
- Technology choices (database, framework, library)
- Architecture patterns (event sourcing, CQRS, microservices)
- Integration approaches (sync vs async, API vs events)
- Security decisions (auth mechanism, encryption approach)
- Breaking changes to existing systems

**Don't write ADR for:**
- Implementation details
- Bug fixes
- Obvious choices with no alternatives
- Temporary solutions (document differently)

---

## Checklist

Before accepting ADR:

- [ ] Context clearly explains the problem
- [ ] Decision is stated clearly and unambiguously
- [ ] At least 2 alternatives were considered
- [ ] Consequences (positive AND negative) documented
- [ ] Risks identified with mitigations
- [ ] Implementation approach outlined
- [ ] Relevant stakeholders reviewed
- [ ] ADR number assigned and indexed
