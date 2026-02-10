---
name: plan
description: Create detailed implementation plan for a feature or refactoring. Uses Planner agent.
allowed_tools: ["Read", "Grep", "Glob"]
agent: planner
---

# /plan - Implementation Planning

Створює детальний план реалізації для фічі, рефакторингу або архітектурних змін.

## Usage

```bash
/plan <feature description>
/plan "Add workout sharing to social feed"
/plan "Refactor billing module to use event sourcing"
```

## What It Does

1. **Аналізує requirements** — уточнює що потрібно зробити
2. **Досліджує codebase** — знаходить affected areas
3. **Створює step-by-step план** — конкретні дії з файлами
4. **Ідентифікує ризики** — що може піти не так
5. **Визначає тестову стратегію** — як перевірити

## Process

### Phase 1: Clarification
Перед плануванням, я запитаю:
- Що конкретно має робити ця фіча?
- Які acceptance criteria?
- Які constraints (timeline, tech)?

### Phase 2: Codebase Analysis
Досліджу:
- Existing similar implementations
- Affected files and services
- Dependencies
- Test coverage

### Phase 3: Plan Generation
Створю план з:
- Phases (logical groupings)
- Steps (specific actions)
- File paths
- Dependencies between steps
- Risk assessment
- Testing strategy

## Output Format

```markdown
# Implementation Plan: [Feature Name]

## Overview
[2-3 sentences]

## Requirements
- [Requirement 1]
- [Requirement 2]

## Implementation Steps

### Phase 1: [Name]
#### Step 1.1: [Action]
**File:** `src/path/to/file.php`
**Action:** [What to do]
**Why:** [Reason]
**Dependencies:** None
**Risk:** Low/Medium/High

### Phase 2: [Name]
...

## Testing Strategy
- Unit tests: [what to test]
- Integration tests: [what to test]
- Functional tests: [what to test]

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
```

## Example

```
> /plan "Add ability to export workout history as PDF"

# Implementation Plan: Workout PDF Export

## Overview
Add feature allowing users to export their workout history as a formatted PDF document.

## Implementation Steps

### Phase 1: PDF Generation Service
#### Step 1.1: Add PDF library
**File:** `composer.json`
**Action:** Add `dompdf/dompdf` dependency
**Risk:** Low

#### Step 1.2: Create PDF Service
**File:** `src/Service/WorkoutPdfExportService.php`
**Action:** Create service with generatePdf(User, DateRange) method
**Dependencies:** Step 1.1

### Phase 2: API Endpoint
...
```

## When to Use

✅ **Use /plan for:**
- New features with multiple steps
- Refactoring existing code
- Database migrations
- API changes
- Multi-file changes

❌ **Don't use for:**
- Simple bug fixes
- One-file changes
- Config updates

---

*Uses [Planner Agent](../agents/technical/planner.md)*
