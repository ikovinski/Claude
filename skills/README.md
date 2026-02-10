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
├── {project-name}-patterns/    # Auto-generated з git history
│   └── SKILL.md
└── engineering/                # Manual reusable skills
    ├── code-review.md
    └── task-decomposition.md
```

## Skill contents
- Конвенції commit messages
- Патерни архітектури коду
- Стандарти найменування
- Типові imports та dependencies
- Командно-специфічні практики
