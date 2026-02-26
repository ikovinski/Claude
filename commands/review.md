---
name: review
description: Perform code review on provided code or diff. Uses Code Reviewer agent.
allowed_tools: ["Read", "Grep", "Glob"]
agent: code-reviewer
---

# /review - Code Review

Проводить структурований code review з фокусом на maintainability, production-readiness та security.

## Usage

```bash
/review                          # Review staged changes (git diff --staged)
/review <file>                   # Review specific file
/review --security               # Focus on security issues
/review --performance            # Focus on performance
```

## What It Does

1. **Аналізує код** — читає diff або файл
2. **Застосовує biases** — maintainability > cleverness
3. **Знаходить issues** — blocking, suggestions, nitpicks
4. **Пропонує fixes** — конкретні рішення
5. **Відзначає позитивне** — для team learning

## Review Scope Options

| Scope | Focus |
|-------|-------|
| `full` | Complete review (default) |
| `security` | OWASP, secrets, injection, auth |
| `performance` | N+1, queries, caching |
| `quick` | Only blocking issues |

## Output Format

```markdown
## Summary
[1-2 sentences overall impression]

## Blocking Issues 🚫
[Must fix before merge]

1. **[Issue]** `file.php:123`
   - Why: [explanation]
   - Fix: [code suggestion]

## Suggestions 💡
[Should consider]

## Nitpicks 📝
[Minor, prefix with "nit:"]

## What's Good ✅
[Positive observations]

## Questions ❓
[Clarifications needed]
```

## Example

```
> /review src/MessageHandler/SyncWorkoutHandler.php

## Summary
Handler implements core sync logic but missing idempotency and error handling.

## Blocking Issues 🚫

1. **No idempotency check** `SyncWorkoutHandler.php:45`
   - Why: If message retries after partial success, duplicates created
   - Fix:
   ```php
   if ($this->workoutRepository->existsByExternalId($message->externalId)) {
       $this->logger->info('Already processed, skipping');
       return;
   }
   ```

2. **No error handling for API call** `SyncWorkoutHandler.php:52`
   - Why: API timeout = infinite requeue
   - Fix: Wrap in try-catch, throw RecoverableMessageHandlingException

## Suggestions 💡

1. **Add logging** — for production debugging

## What's Good ✅
- Proper use of #[AsMessageHandler]
- Constructor property promotion
```

## Checklist Applied

During review, I check:

### Security
- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] SQL injection prevention
- [ ] Health data not in logs

### Error Handling
- [ ] External calls have try-catch
- [ ] Message handlers are idempotent
- [ ] Graceful degradation

### Performance
- [ ] No N+1 queries
- [ ] Lists are paginated
- [ ] Appropriate indexes

### Code Quality
- [ ] Single responsibility
- [ ] Descriptive naming
- [ ] Tests for critical paths

---

*Uses [Code Reviewer Agent](../agents/code-reviewer.md)*
