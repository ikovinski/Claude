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

## Quick Reference

See [skills-index.md](skills-index.md) для повного списку skills та їх використання в agents/scenarios.
