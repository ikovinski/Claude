# Examples

## What is it
Приклади конфігурацій, використання та референсні імплементації, що показують як ефективно використовувати AI agents system.

## How to use
Переглядайте examples щоб:
- Побачити як агенти викликаються на практиці
- Зрозуміти очікувані inputs та outputs
- Скопіювати патерни для власних use cases

## Structure

```
examples/
├── automation/                    # Автоматизація процесів
│   └── docs/                      # Автоматизація документації
│       ├── hooks-example.md       # Claude Code hooks
│       └── cicd-example.md        # GitHub Actions
└── README.md
```

## Automation

Приклади автоматизації Doc-Updater та валідації документації.

| Приклад | Опис | Коли використовувати |
|---------|------|---------------------|
| [hooks-example.md](automation/docs/hooks-example.md) | Claude Code hooks | Локальна розробка, перед комітом |
| [cicd-example.md](automation/docs/cicd-example.md) | GitHub Actions | PR validation, scheduled checks |

### Quick Start: Hooks

```json
// .claude/settings.json
{
  "hooks": {
    "pre-commit": [
      {
        "command": "bash scripts/validate-docs.sh",
        "on_failure": "warn"
      }
    ]
  }
}
```

### Quick Start: GitHub Actions

```yaml
# .github/workflows/docs.yml
name: Docs Validation
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          STALE=$(find docs/CODEMAPS -name "*.md" -mtime +14 | wc -l)
          [ $STALE -gt 0 ] && echo "⚠️ $STALE stale codemaps"
```

## Coming Soon

- [ ] Agent invocation examples
- [ ] Scenario walkthroughs
- [ ] Skill generation examples
- [ ] Custom agent creation
