# CI/CD: Автоматична валідація документації

Приклади налаштування GitHub Actions для автоматичної перевірки та генерації документації.

## GitHub Actions

### 1. Базова валідація на PR

```yaml
# .github/workflows/docs-validation.yml
name: Documentation Validation

on:
  pull_request:
    branches: [main, master]
    paths:
      - 'src/**'
      - 'docs/**'

jobs:
  validate-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check documentation freshness
        run: |
          echo "🔍 Checking documentation freshness..."

          # Перевірка наявності CODEMAPS
          if [ ! -d "docs/CODEMAPS" ]; then
            echo "⚠️ docs/CODEMAPS directory not found"
            echo "Run /codemap to generate codemaps"
            exit 1
          fi

          # Перевірка frontmatter timestamps
          for file in docs/CODEMAPS/*.md; do
            if [ -f "$file" ]; then
              LAST_UPDATED=$(grep -m1 "last_updated:" "$file" | cut -d: -f2 | tr -d ' ')
              if [ -n "$LAST_UPDATED" ]; then
                DAYS_AGO=$(( ($(date +%s) - $(date -d "$LAST_UPDATED" +%s)) / 86400 ))
                if [ $DAYS_AGO -gt 14 ]; then
                  echo "⚠️ $file is $DAYS_AGO days old (threshold: 14)"
                fi
              fi
            fi
          done

          echo "✅ Documentation check complete"
```

### 2. Повний workflow з генерацією

```yaml
# .github/workflows/docs-full.yml
name: Documentation CI/CD

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
  schedule:
    # Щопонеділка о 9:00 UTC
    - cron: '0 9 * * 1'

env:
  DOCS_STALENESS_THRESHOLD: 14

jobs:
  # 1. Валідація на PR
  validate:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate codemaps exist
        run: |
          if [ ! -d "docs/CODEMAPS" ]; then
            echo "::error::docs/CODEMAPS not found. Run /codemap first."
            exit 1
          fi

      - name: Check for stale documentation
        run: |
          STALE_FILES=""
          for file in docs/CODEMAPS/*.md docs/features/*.md docs/runbooks/*.md; do
            if [ -f "$file" ]; then
              LAST_UPDATED=$(grep -m1 "last_updated:" "$file" 2>/dev/null | cut -d: -f2 | tr -d ' ')
              if [ -n "$LAST_UPDATED" ]; then
                DAYS_AGO=$(( ($(date +%s) - $(date -d "$LAST_UPDATED" +%s 2>/dev/null || echo 0)) / 86400 ))
                if [ $DAYS_AGO -gt ${{ env.DOCS_STALENESS_THRESHOLD }} ]; then
                  STALE_FILES="$STALE_FILES\n- $file ($DAYS_AGO days old)"
                fi
              fi
            fi
          done

          if [ -n "$STALE_FILES" ]; then
            echo "::warning::Stale documentation found:$STALE_FILES"
          fi

      - name: Check for missing docs
        run: |
          # Знайти контролери без документації
          for controller in src/Controller/**/*.php; do
            if [ -f "$controller" ]; then
              BASENAME=$(basename "$controller" .php)
              if ! grep -q "$BASENAME" docs/CODEMAPS/controllers.md 2>/dev/null; then
                echo "::warning::$controller not documented in codemaps"
              fi
            fi
          done

  # 2. Scheduled weekly check
  weekly-check:
    if: github.event_name == 'schedule'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate freshness report
        id: report
        run: |
          echo "# 📋 Weekly Documentation Report" > report.md
          echo "" >> report.md
          echo "**Generated:** $(date -u '+%Y-%m-%d %H:%M UTC')" >> report.md
          echo "" >> report.md

          # Codemaps status
          echo "## Codemaps" >> report.md
          if [ -d "docs/CODEMAPS" ]; then
            for file in docs/CODEMAPS/*.md; do
              if [ -f "$file" ]; then
                LAST_UPDATED=$(grep -m1 "last_updated:" "$file" 2>/dev/null | cut -d: -f2 | tr -d ' ')
                if [ -n "$LAST_UPDATED" ]; then
                  DAYS_AGO=$(( ($(date +%s) - $(date -d "$LAST_UPDATED" +%s 2>/dev/null || echo 0)) / 86400 ))
                  STATUS="✅"
                  [ $DAYS_AGO -gt 7 ] && STATUS="⚠️"
                  [ $DAYS_AGO -gt 14 ] && STATUS="🚨"
                  echo "- $STATUS $(basename $file): $DAYS_AGO days old" >> report.md
                fi
              fi
            done
          else
            echo "❌ docs/CODEMAPS not found" >> report.md
          fi

          cat report.md

      - name: Create issue if stale
        if: contains(steps.report.outputs.*, '🚨')
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('report.md', 'utf8');

            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '📋 Documentation needs update',
              body: report,
              labels: ['documentation', 'automated']
            });
```

### 3. PR Comment з статусом документації

```yaml
# .github/workflows/docs-pr-comment.yml
name: Documentation PR Comment

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  comment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate docs status
        id: status
        run: |
          # Збираємо статистику
          TOTAL_CODEMAPS=$(find docs/CODEMAPS -name "*.md" 2>/dev/null | wc -l)
          STALE_CODEMAPS=$(find docs/CODEMAPS -name "*.md" -mtime +14 2>/dev/null | wc -l)

          CHANGED_SRC=$(git diff --name-only origin/main...HEAD | grep "^src/" | wc -l)

          # Формуємо коментар
          COMMENT="## 📋 Documentation Status\n\n"
          COMMENT+="| Metric | Value |\n|--------|-------|\n"
          COMMENT+="| Codemaps | $TOTAL_CODEMAPS |\n"
          COMMENT+="| Stale (>14d) | $STALE_CODEMAPS |\n"
          COMMENT+="| Changed src/ files | $CHANGED_SRC |\n\n"

          if [ $CHANGED_SRC -gt 0 ] && [ $STALE_CODEMAPS -gt 0 ]; then
            COMMENT+="⚠️ **Recommendation:** Run \`/codemap\` to update documentation\n"
          else
            COMMENT+="✅ Documentation is up to date\n"
          fi

          echo "comment<<EOF" >> $GITHUB_OUTPUT
          echo -e "$COMMENT" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Comment on PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `${{ steps.status.outputs.comment }}`
            })
```

## Інтеграція з Slack

```yaml
# .github/workflows/docs-notify.yml
name: Documentation Notifications

on:
  schedule:
    - cron: '0 9 * * 1'  # Щопонеділка

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check and notify
        env:
          SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
        run: |
          STALE=$(find docs/CODEMAPS -name "*.md" -mtime +14 2>/dev/null | wc -l)

          if [ $STALE -gt 0 ]; then
            curl -X POST $SLACK_WEBHOOK \
              -H 'Content-Type: application/json' \
              -d "{
                \"text\": \"📋 *Documentation Alert*\n$STALE codemaps are older than 14 days.\nRun \`/codemap\` to update.\"
              }"
          fi
```

## Див. також

- [Hooks приклад](./hooks-example.md)
- [Codebase Doc Collector агент](../../../agents/codebase-doc-collector.md)
- [Freshness Policy](../../../skills/documentation/README.md#freshness-policy)
