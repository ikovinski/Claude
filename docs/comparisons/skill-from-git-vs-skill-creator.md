# /skill-from-git vs /skill-creator

Two different tools for creating skills. They serve different purposes and complement each other.

## At a Glance

| | `/skill-from-git` | `/skill-creator` |
|---|---|---|
| **Source** | Custom command (amo-claude-workflows) | Anthropic official plugin |
| **Purpose** | Auto-extract patterns from git history | Design any skill from scratch |
| **Input** | Git commits, file structure, conventions | User requirements and conversation |
| **Scope** | PHP/Symfony projects | Any domain, any tech stack |
| **Output** | Project-patterns skill with references/ | Any kind of skill (scripts/, references/, assets/) |
| **Automation** | High - runs git commands, analyzes automatically | Low - interactive, requires user input |

## When to Use Each

### Use `/skill-from-git` when:
- You want to quickly capture a PHP/Symfony project's coding patterns
- You need to onboard Claude to an existing codebase
- The patterns already exist in git history and just need extraction
- You want a project-specific skill with architecture, workflows, and conventions

### Use `/skill-creator` when:
- You want to build a skill for a non-PHP domain (e.g., pdf-editor, brand-guidelines)
- The skill needs custom scripts, assets, or templates
- You're creating a skill that doesn't map to an existing codebase
- You need guidance on skill structure, metadata quality, and packaging
- You want to iterate on and improve an existing skill

## How They Differ in Output

### /skill-from-git generates:
```
{project}-patterns/
├── SKILL.md                  # Lean overview + quick reference
└── references/
    ├── architecture.md       # Directory structure, components
    ├── workflows.md          # Dev workflows (API, handlers, DB)
    └── conventions.md        # Naming, commits, code quality
```

### /skill-creator can generate:
```
{any-skill}/
├── SKILL.md                  # Purpose, triggers, usage guide
├── scripts/                  # Reusable code (Python, Bash)
├── references/               # Domain docs, schemas, policies
└── assets/                   # Templates, images, boilerplate
```

## Can They Work Together?

Yes. A practical workflow:

1. Run `/skill-from-git` to auto-extract your project's patterns
2. Use `/skill-creator` to refine, add custom scripts, or extend the generated skill
3. Use `/skill-creator` to package and validate the final result

## Summary

| Question | Answer |
|----------|--------|
| Are they redundant? | No - different inputs, different scopes |
| Should I keep both? | Yes |
| Which one first? | `/skill-from-git` for PHP projects, `/skill-creator` for everything else |
| Can they chain? | Yes - extract with `/skill-from-git`, refine with `/skill-creator` |
