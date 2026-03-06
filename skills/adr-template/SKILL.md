---
name: adr-template
description: Template for Architecture Decision Records (ADR). Used by Design Architect during /design phase. Always one file per decision in adr/ directory.
version: 1.0.0
---

# ADR Template Skill

Defines the format for Architecture Decision Records. Always stored in `adr/` directory — one file per decision: `adr/001-{slug}.md`, `adr/002-{slug}.md`, etc.

## When This Skill Applies

- Design Architect creating ADR(s) during `/design` phase
- Documenting architecture decisions outside the flow
- Reviewing ADRs for completeness

## File Structure

```
.workflows/{feature}/design/adr/
├── 001-{decision-slug}.md
├── 002-{decision-slug}.md
└── ...
```

Always one file per decision, regardless of how many decisions there are. Slug is kebab-case of the decision title.

## Format: `adr/001-{slug}.md`

```markdown
# ADR-001: {Decision Title}

## Status
Proposed

## Context
{Facts from Research Report. What we know, not what we assume.}

## Decision
{What was decided and WHY}

## Alternatives Considered

### Alternative A: {name}
**Description:** {brief}
- **Pros:** {advantages}
- **Cons:** {disadvantages}

### Alternative B: {name}
**Description:** {brief}
- **Pros:** {advantages}
- **Cons:** {disadvantages}

### Why Not {Alternative}
{Why the chosen option is better in THIS context}

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {risk} | low/medium/high | low/medium/high | {concrete mitigation} |

## Consequences

### Positive
- {consequence}

### Negative
- {consequence}

### Neutral
- {consequence}
```

## Quality Checklist

- [ ] Each decision has at least 2 alternatives with real pros (not strawman)
- [ ] Each alternative has a scenario where it would be the better choice
- [ ] Context references Research Report facts, not assumptions
- [ ] Risks have concrete mitigations (not "we'll handle it later")
- [ ] Probability assessments are justified
- [ ] Consequences cover positive, negative, and neutral impacts
- [ ] Status is "Proposed" (changes to "Accepted" after human review)

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Strawman alternatives | Alternative has 0 pros, only cons | Every alternative must have real advantages in some context |
| Missing "Why Not" | Reader doesn't understand the reasoning | Explain why chosen option beats each alternative |
| Vague risks | "Something might go wrong" | Name specific failure mode with probability basis |
| Outcome-only | "We decided X" without reasoning | The WHY matters more than the WHAT |
| Kitchen sink | 10 alternatives for a simple decision | 2-3 serious alternatives is enough |
