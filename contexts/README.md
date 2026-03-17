# Contexts

## What is it
Режимо-специфічні пріоритети та guardrails, які інжектяться в spawn prompts агентів через `[MODE CONTEXT]` секцію. Кожен контекст визначає фокус, пріоритети та red flags для конкретного режиму роботи.

## How it works
Контексти завантажуються командами (не агентами напряму):

| Context | File | Command | Injected into |
|---------|------|---------|---------------|
| `dev` | `contexts/dev.md` | `/implement` | Code Writer spawn prompt |
| `review` | `contexts/review.md` | `/implement` | Security, Quality, Design Reviewer spawn prompts |
| `research` | `contexts/research.md` | `/research` | Research Lead (self) + scanner spawn prompts |
| `planning` | `contexts/planning.md` | `/plan` | Phase Planner (self, single-agent command) |

Commands declare contexts in frontmatter (`context:` field) and inject them as `[MODE CONTEXT]` section in agent spawn prompts.

## Expected result
- Агенти отримують mode-specific пріоритети та red flags
- Code Writer фокусується на working code → tests → clean code
- Reviewers фокусуються на security → correctness → reliability
- Scanners фокусуються на facts → exploration → no proposals
- Planner фокусується на vertical slices → dependencies → risks
