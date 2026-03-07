---
name: tdd-approach
description: Template for TDD Approach and Verification sections in implementation phase plans. Technology-agnostic — project skill provides concrete commands and patterns.
version: 1.0.0
---

# TDD Approach Skill

Defines the format for Test-Driven Development sections in phase plan files (`phase-{N}.md`). Ensures Code Writer knows **what tests to write first** before implementation code.

## When This Skill Applies

- Phase Planner creating `phase-{N}.md` files during `/plan`
- Code Writer reading phase plan during `/implement`
- Reviewing phase plans for TDD completeness

## Principles

1. **Tests First** — кожна фаза починається з тестів, а не з коду
2. **Test Names = Spec** — назви тестів описують поведінку, не реалізацію
3. **Given/When/Then** — кожен тест має чітку структуру
4. **From Strategy** — тести беруться з test-strategy.md, не вигадуються
5. **Technology-Agnostic** — формат не залежить від мови/фреймворку. Project skill ({project}-patterns) додає конкретні команди та патерни

## Format: TDD Approach Section

Додається в `phase-{N}.md` після секції `Implementation Notes`, перед `Acceptance Criteria`.

```markdown
## TDD Approach

### Write Tests First

Order of test creation (write and run these BEFORE implementation code):

| # | Test | Type | Behavior | From Strategy |
|---|------|------|----------|---------------|
| 1 | {TestClass::testMethodName} | unit | Given {context}, When {action}, Then {expected} | test-strategy.md #{N} |
| 2 | {TestClass::testEdgeCase} | unit | Given {context}, When {edge case}, Then {expected} | test-strategy.md #{N} |
| 3 | {FunctionalTestClass::testEndpoint} | functional | Given {setup}, When {API call}, Then {response} | test-strategy.md #{N} |

### Test Skeleton

{Pseudo-code skeleton showing test structure — NOT full implementation, just enough for Code Writer to understand the pattern}

```
test {testMethodName}:
    // Arrange: {what to set up}
    // Act: {what action to perform}
    // Assert: {what to verify}
```

### Red-Green-Refactor Order

1. {Write test X — expect RED (fails because code doesn't exist)}
2. {Write minimal code to make test X GREEN}
3. {Write test Y — expect RED}
4. {Extend code to make test Y GREEN}
5. {Refactor if needed — all tests stay GREEN}
```

## Format: Verification Section

Додається в `phase-{N}.md` після `Acceptance Criteria`.

```markdown
## Verification

Commands to verify this phase is complete. Run in order:

| # | Check | Command / Action | Expected |
|---|-------|-----------------|----------|
| 1 | Unit tests | {run unit tests for this phase} | All pass |
| 2 | Functional tests | {run functional/integration tests} | All pass |
| 3 | Full test suite | {run all tests} | No regressions |
| 4 | Schema validation | {validate DB schema if migrations} | Schema valid |
| 5 | Linter | {run linter} | No new violations |
| 6 | Build | {run build} | Build succeeds |

### Smoke Test

{Manual or automated check that proves the phase works end-to-end:}
- {e.g., "Call POST /api/v1/... with payload X, expect response Y"}
- {e.g., "Send message to queue X, verify handler processes it"}
```

## Notes for Phase Planner

- **Command / Action** column: describe WHAT to run, not the exact CLI command. Project skill provides exact commands. Приклади:
  - "Run unit tests for {ComponentName}" (not `php bin/phpunit tests/Unit/...`)
  - "Validate database schema" (not `php bin/console doctrine:schema:validate`)
  - "Run linter" (not `vendor/bin/php-cs-fixer fix --dry-run`)
- **Smoke Test**: один конкретний end-to-end сценарій що доводить фаза працює. Для API — конкретний endpoint + payload + response. Для async — конкретне повідомлення + очікуваний результат.
- **Test Skeleton**: pseudo-code, не конкретна мова. Code Writer + project skill адаптують під стек.
- **From Strategy**: обов'язково вказувати номер test case з test-strategy.md — це traceability.

## Quality Checklist

- [ ] Every test references a case from test-strategy.md
- [ ] Tests cover happy path + at least 1 edge case + at least 1 error case
- [ ] Test names describe behavior, not implementation ("testCalculatesTotalWithDiscount", not "testMethod1")
- [ ] Red-Green-Refactor order makes sense (dependencies respected)
- [ ] Verification commands cover: tests, schema, linter, build
- [ ] Smoke test is concrete and verifiable
- [ ] No technology-specific commands (delegated to project skill)

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Tests after code | Code Writer writes implementation first, adds tests as afterthought | TDD section comes BEFORE Implementation Notes in phase plan |
| Vague test names | "testService", "testController" — no behavior described | Use Given/When/Then in Behavior column |
| Missing edge cases | Only happy path tested | Require at least 1 edge case and 1 error case per component |
| No verification | Phase has acceptance criteria but no way to check them | Every acceptance criterion maps to a verification command |
| Technology lock-in | "Run `php bin/phpunit`" in plan | Describe action, let project skill provide commands |
| Tests without strategy link | Tests invented by Planner, not from test-strategy.md | Always reference test-strategy.md case number |
