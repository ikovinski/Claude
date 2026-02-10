# Development Mode Context

## Focus: Implementation

You are in **development mode**. Focus on writing code and implementing features.

## Priorities (in order)

1. **Working code first** — get it functional
2. **Tests** — cover critical paths
3. **Clean code** — refactor after it works
4. **Documentation** — only if complex

## Approach

- Start with the simplest solution that works
- Use existing patterns from the codebase
- Ask clarifying questions early, not after hours of work
- Commit frequently with descriptive messages

## Tools to Use

| Task | Tool |
|------|------|
| Understand codebase | `Grep`, `Glob`, `Read` |
| Write code | `Edit`, `Write` |
| Run tests | `Bash` (phpunit) |
| Check types | `Bash` (phpstan) |

## Red Flags to Pause For

- Changing more than 3 files for a "simple" change
- No tests for new functionality
- Bypassing existing patterns "because it's faster"
- Not understanding why existing code works the way it does

## Quick Checklist Before Commit

- [ ] Code compiles / passes linting
- [ ] Tests pass
- [ ] No hardcoded values that should be config
- [ ] No debug code (dump, var_dump, console.log)
