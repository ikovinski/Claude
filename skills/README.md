# Skills

## What is it
Проєктно-специфічні патерни та конвенції, витягнуті з реальних codebase. Skills містять конвенції комітів, архітектурні патерни, стандарти найменування та практики команди.

## How to use
Skills завантажуються автоматично на основі поточної директорії:

```
Working in: ~/repo/wellness-backend
Looks for: ~/.claude/skills/wellness-backend-patterns/SKILL.md
```

Для створення нового skill:
```
/skill-create --commits 100
```

## Expected result
- Проєктно-специфічні конвенції застосовуються до всіх пропозицій
- Консистентний стиль коду відповідно до існуючого codebase
- Оголошення: "Loaded project skill: {skill-name}"

## Structure

```
skills/
├── architecture/              # Architecture decisions & ADR
│   ├── architecture-decision-template.md
│   └── decision-matrix.md
├── code-quality/              # Refactoring, testing, dead code
│   ├── refactoring-patterns.md
│   ├── test-patterns.md
│   └── dead-code-detection.md
├── planning/                  # Implementation planning & decomposition
│   ├── planning-template.md
│   ├── vertical-slicing.md
│   └── epic-breakdown.md
├── risk-management/           # Risk assessment & mitigation
│   └── risk-assessment.md
├── security/                  # Security audits & OWASP
│   ├── security-audit-checklist.md
│   └── owasp-top-10.md
├── tdd/                       # Test-Driven Development
│   └── tdd-workflow.md
├── engineering/               # Legacy general skills
│   ├── code-review.md
│   └── task-decomposition.md
└── {project}-patterns/        # Auto-generated з git history
    └── SKILL.md
```

## Categories

### [architecture/](architecture/)
ADR templates, decision matrices для архітектурних рішень.

### [code-quality/](code-quality/)
Refactoring patterns, test patterns, dead code detection.

### [planning/](planning/)
Implementation plans, vertical slicing, epic breakdown.

### [risk-management/](risk-management/)
Risk assessment, mitigation strategies.

### [security/](security/)
Security checklists, OWASP Top 10.

### [tdd/](tdd/)
TDD workflow, Red-Green-Refactor cycle.

### {project}-patterns/
Auto-generated project-specific patterns:
- Commit conventions
- Architecture patterns
- Naming standards
- Common imports/dependencies

## Skill Types

### Universal Skills
Reusable для всіх PHP/Symfony проєктів. Розподілені по категоріях (architecture, security, etc.).

### Project Skills
Генеруються через `/skill-create` з git history конкретного проєкту. Містять project-specific conventions.

## Як Skills Інтегруються

### З Agents

Агенти автоматично завантажують релевантні skills:

```yaml
# agents/technical/decomposer.md
skills:
  - auto:{project}-patterns      # Автоматично шукає у поточному проєкті
  - planning/epic-breakdown       # Завантажує universal skill
  - planning/vertical-slicing
```

**Коли агент запускається:**
1. Перевіряє поточну директорію
2. Шукає `~/.claude/skills/{directory-name}-patterns/SKILL.md`
3. Завантажує universal skills зі списку
4. Застосовує всі patterns до роботи

### З Scenarios

Scenarios декларують skills у metadata:

```yaml
# scenarios/delivery/feature-decomposition.md
skills:
  - auto:{project}-patterns
  - planning/epic-breakdown
  - planning/vertical-slicing
  - planning/planning-template
```

**Під час виконання scenario:**
- **Phase 1 (Decomposer)** → завантажує planning skills
- **Phase 2 (Staff Engineer)** → завантажує architecture skills
- **Project skill** → доступний для всіх фаз

### Приклад Real-World Usage

```
Directory: ~/wellness-backend
Task: "Decompose feature: Add Apple Health integration"

System loads:
├─ agents/technical/decomposer.md
├─ skills/wellness-backend-patterns/SKILL.md  ← Project-specific
├─ skills/planning/epic-breakdown.md          ← Universal
├─ skills/planning/vertical-slicing.md        ← Universal
└─ skills/planning/planning-template.md       ← Universal

Result:
✓ Slices follow wellness-backend naming conventions
✓ Tests match project test patterns
✓ Estimates based on historical velocity from git
✓ Architecture patterns from existing codebase
```

## Universal Skills vs Project Skills

| Aspect | Universal Skills | Project Skills |
|--------|------------------|----------------|
| **Location** | `skills/{category}/` | `skills/{project}-patterns/` |
| **Source** | Manually created | Auto-generated from git |
| **Scope** | All projects | Specific project |
| **Updates** | Manual | Re-run `/skill-create` |
| **Examples** | OWASP, ADR templates | Commit conventions, naming |

## Створення Project Skill

```bash
cd ~/your-project
# In Claude Code:
/skill-create --commits 100
```

**Аналізується:**
- Commit messages → patterns, prefixes, structure
- File structure → architecture, organization
- Code patterns → naming, common imports
- Test files → testing conventions
- Dependencies → frequently used packages

**Генерується:** `~/.claude/skills/{project-name}-patterns/SKILL.md`

**Результат:**
- Агенти в цьому проєкті автоматично використовують ці patterns
- Код proposals слідують вашим конвенціям
- Estimates базуються на вашій історії

## Quick Reference

See [skills-index.md](skills-index.md) для повного списку skills та їх використання в agents/scenarios.

## Related Documentation

- [How Scenarios Work](../docs/how-it-works/how-scenarios-work.md) — Як scenarios використовують skills
- [Skills Integration Summary](../docs/skills-integration-summary.md) — Огляд інтеграції
- [Skills Mapping](../docs/skills-mapping.md) — Маппінг agents → skills
