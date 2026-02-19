# Claude Code Hooks: Автоматична валідація документації

Приклади налаштування Claude Code hooks для автоматичної валідації документації.

## Що таке Hooks?

Claude Code hooks — це shell команди, які виконуються автоматично у відповідь на події. Конфігуруються у `.claude/settings.json`.

## Приклади конфігурацій

### 1. Базова валідація при старті сесії

```json
// .claude/settings.json
{
  "hooks": {
    "session-start": [
      {
        "command": "echo '📋 Checking documentation freshness...'",
        "description": "Нагадування про перевірку документації"
      }
    ]
  }
}
```

### 2. Валідація перед комітом

```json
// .claude/settings.json
{
  "hooks": {
    "pre-commit": [
      {
        "command": "bash scripts/validate-docs.sh",
        "description": "Перевірка свіжості документації перед комітом",
        "on_failure": "warn"
      }
    ]
  }
}
```

### 3. Повна конфігурація для Codebase Doc Collector

```json
// .claude/settings.json
{
  "hooks": {
    "session-start": [
      {
        "command": "echo '📚 Project skill: checking...' && test -f skills/${PWD##*/}-patterns/SKILL.md && echo '✅ Found' || echo '❌ Not found'",
        "description": "Перевірка project skill при старті"
      }
    ],
    "pre-commit": [
      {
        "command": "bash -c 'if git diff --cached --name-only | grep -q \"^src/\"; then echo \"⚠️ Code changes detected. Consider running /codemap\"; fi'",
        "description": "Нагадування про оновлення codemaps",
        "on_failure": "continue"
      }
    ],
    "post-commit": [
      {
        "command": "bash -c 'DAYS_OLD=$(find docs/CODEMAPS -name \"*.md\" -mtime +14 2>/dev/null | wc -l); if [ $DAYS_OLD -gt 0 ]; then echo \"⚠️ $DAYS_OLD codemaps older than 14 days\"; fi'",
        "description": "Перевірка старих codemaps після коміту",
        "on_failure": "continue"
      }
    ]
  }
}
```

## Допоміжний скрипт

```bash
#!/bin/bash
# scripts/validate-docs.sh

echo "🔍 Validating documentation..."

# Перевірка наявності CODEMAPS
if [ ! -d "docs/CODEMAPS" ]; then
    echo "⚠️ docs/CODEMAPS not found. Run /codemap to generate."
    exit 0
fi

# Перевірка свіжості (файли старші 14 днів)
STALE_COUNT=$(find docs/CODEMAPS -name "*.md" -mtime +14 2>/dev/null | wc -l | tr -d ' ')

if [ "$STALE_COUNT" -gt 0 ]; then
    echo "⚠️ Found $STALE_COUNT stale codemaps (>14 days old):"
    find docs/CODEMAPS -name "*.md" -mtime +14 -exec basename {} \;
    echo ""
    echo "💡 Run /codemap to update"
    exit 1
fi

echo "✅ All documentation is fresh"
exit 0
```

## Встановлення

```bash
# 1. Створити директорію scripts
mkdir -p scripts

# 2. Створити скрипт валідації
cat > scripts/validate-docs.sh << 'EOF'
#!/bin/bash
# ... скрипт вище ...
EOF

# 3. Зробити виконуваним
chmod +x scripts/validate-docs.sh

# 4. Додати hooks до .claude/settings.json
# (вручну або через Claude)
```

## Поведінка on_failure

| Значення | Опис |
|----------|------|
| `"fail"` | Зупинити операцію при помилці |
| `"warn"` | Показати попередження, продовжити |
| `"continue"` | Ігнорувати помилку, продовжити |

## Доступні події

| Подія | Коли спрацьовує |
|-------|-----------------|
| `session-start` | При запуску Claude Code |
| `pre-commit` | Перед git commit |
| `post-commit` | Після git commit |
| `pre-push` | Перед git push |
| `post-push` | Після git push |

## Див. також

- [CI/CD приклад](./cicd-example.md)
- [Codebase Doc Collector агент](../../../agents/technical/codebase-doc-collector.md)
- [/codemap команда](../../../commands/codemap.md)
