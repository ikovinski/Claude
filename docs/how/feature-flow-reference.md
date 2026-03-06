# Feature Development Flow — Довідник

Технічна довідка: команди, агенти, артефакти, MCP інтеграція.

---

## Команди

### /feature

Мета-команда — навігатор флоу. Не виконує фази, а трекає стан і підказує наступний крок.

```bash
/feature "Опис задачі"                              # Ініціалізація
/feature {name} --status                              # Перевірити стан
/feature {name} --resume                              # Продовжити з останньої фази
/feature "Опис" --type bug --sentry PROJ-123          # Bug fix flow
/feature "Опис" --type hotfix                         # Скорочений flow
/feature "Опис" --skip-docs                           # Без Phase 5
```

**Стан** зберігається у `.workflows/{name}/state.json`. Фази визначаються як завершені по наявності артефактів:

| Фаза | Завершена коли |
|------|---------------|
| research | `research/research-report.md` існує |
| design | `design/architecture.md` існує |
| design-review | Ручне підтвердження |
| plan | `plan/overview.md` існує |
| implement | `implement/phase-{N}-report.md` для всіх фаз |
| docs | `docs/INDEX.md` існує в проекті |
| pr | PR URL записаний в state.json |

---

### /research

Дослідження кодової бази. Факти AS IS.

```bash
/research "Опис задачі"
/research "Опис" --type bug --sentry PROJ-123
/research "Опис" --scope architecture,data
```

| Параметр | Опис |
|----------|------|
| `--type bug` | Додає Sentry контекст до дослідження |
| `--sentry PROJ-123` | ID Sentry issue для витягування stack trace і events |
| `--scope` | Обмежити скоупи сканування (architecture, data, integration, error) |

**Команда агентів**: Research Lead (opus) + Codebase Researcher(s) (sonnet)

---

### /design

Проектування рішення.

```bash
/design {feature-name}
```

Читає `research/research-report.md` і створює архітектуру + тест-стратегію.

**Команда агентів**: Design Architect (opus) + Test Strategist (sonnet)

---

### /plan

Декомпозиція дизайну на фази імплементації.

```bash
/plan {feature-name}
/plan {feature-name} --max-phases 5
/plan {feature-name} --granularity fine
```

| Параметр | Опис |
|----------|------|
| `--max-phases` | Максимальна кількість фаз |
| `--granularity` | `fine` (детальні фази) або `coarse` (укрупнені) |

**Агент**: Phase Planner (opus). Один агент, без команди.

---

### /implement

Імплементація однієї фази з плану.

```bash
/implement {feature-name} --phase 1
/implement {feature-name} --phase 2 --reviewers security,quality
/implement {feature-name} --phase 1 --skip-review
/implement {feature-name} --phase 1 --auto-fix
```

| Параметр | Опис |
|----------|------|
| `--phase N` | Номер фази з плану (обов'язковий) |
| `--reviewers` | Які reviewer'и запускати: `security`, `quality`, `design` |
| `--skip-review` | Пропустити code review (для hotfix) |
| `--auto-fix` | Автоматично застосовувати фікси |

**Команда агентів**: Implement Lead (opus, ви) + Code Writer (sonnet) + 3x Code Reviewer (sonnet) + Quality Gate (sonnet)

**Цикл виконання**:
```
Writer (послідовно) → Reviewers (паралельно) → Fix (якщо потрібно, макс 3) → Quality Gate
```

---

### /docs-suite

Генерація документації. Перевикористовує існуючий Documentation Suite.

```bash
/docs-suite
/docs-suite --scope architecture
/docs-suite --scope api
/docs-suite --skip-review
```

---

### /pr

Створення Pull Request через `gh` CLI.

```bash
/pr {feature-name}
/pr {feature-name} --draft
/pr {feature-name} --base develop
/pr {feature-name} --reviewers @user1,@user2
```

Пряма команда без агентів. Збирає PR description з workflow артефактів.

---

## Агенти

### Engineering агенти

| Агент | Модель | Режим | Фаза |
|-------|--------|-------|------|
| Research Lead | opus | default | Research |
| Codebase Researcher | sonnet | plan (read-only) | Research |
| Design Architect | opus | default | Design |
| Test Strategist | sonnet | default | Design |
| Phase Planner | opus | default | Plan |
| Implement Lead | opus | — (це ви) | Implement |
| Code Writer | sonnet | acceptEdits | Implement |
| Code Reviewer (x3) | sonnet | plan (read-only) | Implement |
| Quality Gate | sonnet | default | Implement |

**Принцип**: Opus для лідів і планерів (складне міркування), Sonnet для виконавців (швидкість).

### Code Reviewer — три скоупи

Один файл агента (`code-reviewer.md`), три інстанси з різним фокусом:

| Скоуп | Фокус |
|-------|-------|
| **security** | OWASP Top 10, input validation, SQL injection, XSS, secrets exposure |
| **quality** | Cyclomatic complexity (max 10), cognitive complexity (max 15), SOLID, DRY |
| **design-compliance** | Відповідність architecture.md, data flow, API contracts, test-strategy.md |

### Documentation агенти

| Агент | Фаза docs-suite |
|-------|-----------------|
| Technical Collector | Phase 1: збір фактів |
| Architect Collector | Phase 2A: архітектура |
| Swagger Collector | Phase 2B: OpenAPI |
| Technical Writer | Phase 3: статті |

---

## Артефакти — хто створює, хто споживає

```
Research Report ──────► Design Architect
                ──────► Phase Planner

Architecture.md ──────► Phase Planner
                ──────► Code Writer
                ──────► Code Reviewer (design)
                ──────► PR description

ADR ──────────────────► Phase Planner
                ──────► PR description

Test Strategy ────────► Phase Planner
                ──────► Code Writer
                ──────► Code Reviewer (design)
                ──────► PR description

Phase Plans ──────────► Code Writer
                ──────► Implement Lead

Phase Reports ────────► PR description
Review Reports ───────► PR description
```

---

## MCP інтеграція

| MCP | Фаза | Використання |
|-----|-------|-------------|
| **Sentry** | Research | Bug контекст: issue details, events, stack traces |
| **Sentry** | Implement (Quality Gate) | Верифікація: перевірка нових issues після імплементації |
| **Context7** | Research | Документація фреймворків для розуміння коду |
| **Context7** | Design | Best practices для архітектурних рішень |
| **Context7** | Implement (Code Writer) | API документація для написання коду |

---

## Quality Gate — перевірки по технологіях

### PHP/Symfony

| # | Перевірка | Команда |
|---|-----------|---------|
| 1 | Dependencies | `composer install` |
| 2 | Cache | `php bin/console cache:clear --env=test` |
| 3 | Tests | `php bin/phpunit --testdox` |
| 4 | PHPStan | `vendor/bin/phpstan analyse` |
| 5 | Psalm | `vendor/bin/psalm` (якщо є psalm.xml) |
| 6 | Code Style | `vendor/bin/php-cs-fixer fix --dry-run --diff` |
| 7 | Coverage | `php bin/phpunit --coverage-text` |

### Node/JS

| # | Перевірка | Команда |
|---|-----------|---------|
| 1 | Dependencies | `npm ci` |
| 2 | Build | `npm run build` |
| 3 | Tests | `npm test` |
| 4 | Lint | `npm run lint` |
| 5 | Types | `npx tsc --noEmit` (TypeScript) |

### Go

| # | Перевірка | Команда |
|---|-----------|---------|
| 1 | Build | `go build ./...` |
| 2 | Tests | `go test ./... -v` |
| 3 | Lint | `golangci-lint run` |
| 4 | Vet | `go vet ./...` |

---

## Troubleshooting

### "Agent Teams не працюють"

Перевірте що в `.claude/settings.json` є:
```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

### "Command не знайдена"

Slash-команди мають бути у `~/.claude/commands/` або `.claude/commands/` проекту. Перевірте що файл має правильний YAML frontmatter з `name`.

### "/implement каже що план не знайдений"

Спочатку виконайте `/plan {feature-name}`. Файл `.workflows/{feature}/plan/phase-{N}.md` повинен існувати.

### "Quality Gate падає на тестах"

Quality Gate тільки репортить, не фіксить. Перегляньте `quality-gate-report.md` — там повний вивід помилок. Виправте код і перезапустіть `/implement`.

### "Reviewer знайшов проблеми, але Writer не може виправити за 3 ітерації"

Після 3 невдалих ітерацій система ескалює до вас. Варіанти:
1. Виправити вручну
2. Перезапустити `/implement` з `--skip-review` (для некритичних знахідок)
3. Перезапустити з `--reviewers quality` (тільки конкретний скоуп)

### "Хочу перезапустити одну фазу"

Просто запустіть команду знову — вона перезапише артефакти. Наприклад:
```bash
/design payment-refund    # Перезапустить Design з поточного Research
```

---

## Пов'язані файли

| Тип | Шлях |
|-----|------|
| Основний посібник | `docs/how/feature-flow.md` |
| Сценарій | `scenarios/delivery/feature-development.md` |
| Плани (дизайн системи) | `plans/` |
| Engineering агенти | `agents/engineering/` |
| Documentation агенти | `agents/documentation/` |
| Команди | `commands/` |
