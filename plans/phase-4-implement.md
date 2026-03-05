# Phase 4: IMPLEMENT

## Команда запуску

```
/implement {feature-name} --phase {N}
```

**Опції:**
- `--phase 1` — реалізувати конкретну фазу (обов'язково)
- `--reviewers security,quality,design` — які code reviewers запустити (default: all)
- `--skip-review` — пропустити code review (для hotfix)
- `--auto-fix` — автоматично виправляти issues від reviewers

**Prereq:** Phase 3 (Plan) завершена — `.workflows/{feature}/plan/phase-{N}.md` існує.

---

## Мета

Реалізувати конкретну фазу з плану. Lead декомпозує фазу на задачі, Code Writer пише код, Code Reviewers перевіряють з різних ракурсів. Quality Gate перевіряє build/tests/linters.

---

## Agent Team

```
team_name: "implement-{feature-name}-phase-{N}"
```

### Учасники

| Name | Agent | Model | Роль |
|------|-------|-------|------|
| lead | `agents/engineering/implement-lead.md` | opus | Декомпозиція фази, координація |
| writer | `agents/engineering/code-writer.md` | sonnet | Пише код |
| reviewer-security | `agents/engineering/code-reviewer.md` | sonnet | Scope: OWASP, security |
| reviewer-quality | `agents/engineering/code-reviewer.md` | sonnet | Scope: complexity, architecture |
| reviewer-design | `agents/engineering/code-reviewer.md` | sonnet | Scope: відповідність design |
| gate | `agents/engineering/quality-gate.md` | sonnet | Build, tests, linters |

### Code Reviewer — конфігурований scope

Один і той же агент `code-reviewer.md`, але кожен instance отримує свій scope через spawn prompt:

```
reviewer-security:
  agent: agents/engineering/code-reviewer.md
  scope: security
  focus:
    - OWASP Top 10
    - Input validation
    - SQL injection, XSS
    - Authentication/authorization
    - Secrets exposure

reviewer-quality:
  agent: agents/engineering/code-reviewer.md
  scope: quality
  focus:
    - Cyclomatic complexity (max 10)
    - Cognitive complexity (max 15)
    - Domain model (anemic vs rich)
    - Architecture layers compliance
    - DRY, SOLID principles

reviewer-design:
  agent: agents/engineering/code-reviewer.md
  scope: design-compliance
  focus:
    - Matches architecture from design/architecture.md
    - Components match planned structure
    - Data flow matches sequence diagrams
    - API contracts match design/api-contracts
    - Test coverage matches test-strategy.md
```

---

## Процес

```
Input:
  ├── .workflows/{feature}/plan/phase-{N}.md
  ├── .workflows/{feature}/design/ (всі артефакти)
  └── .workflows/{feature}/research/research-report.md
  │
  ▼
Implementation Lead:
  1. Читає phase-{N}.md
  2. Декомпозує на конкретні задачі для Code Writer
  3. Визначає порядок (entities → services → controllers → tests)
  │
  ▼
Code Writer (послідовно по задачах):
  ├── Task 1: Create/modify files per plan
  ├── Task 2: Write tests per test-strategy
  ├── Task 3: Create migrations if needed
  └── ...кожна задача = конкретні файли
  │
  ▼
Code Reviewers (ПАРАЛЕЛЬНО — кожен зі своїм scope):
  ├── Security Reviewer → security-review.md
  ├── Quality Reviewer → quality-review.md
  └── Design Reviewer → design-review.md
  │
  ▼
Lead збирає review findings:
  ├── Critical/High → Code Writer виправляє
  ├── Medium → Code Writer виправляє або Lead justifies
  └── Low → документується, не блокує
  │
  ▼ (цикл поки не пройде)
  │
Quality Gate:
  ├── ✓ Build passes
  ├── ✓ All tests pass (existing + new)
  ├── ✓ Test coverage sufficient
  ├── ✓ Linters pass (PHPStan, Psalm, CS-Fixer / ESLint)
  ├── ✓ Cyclomatic complexity within limits
  └── ✓ Cognitive complexity within limits
  │
  ▼
Sentry verification (optional):
  └── Перевірка що немає нових issues
  │
  ▼
Output:
  ├── Code changes (staged, not committed)
  └── .workflows/{feature}/implement/phase-{N}-report.md
```

---

## Review Output Format

### `.workflows/{feature}/implement/phase-{N}-review.md`

```markdown
# Code Review: Phase {N}

## Security Review
| File | Issue | Severity | Status |
|------|-------|----------|--------|
| src/Service/PaymentService.php:45 | Missing input validation | high | FIXED |
| src/Controller/RefundController.php:23 | No CSRF protection | medium | JUSTIFIED: API only |

**Verdict:** PASS

## Quality Review
| File | Issue | Severity | Status |
|------|-------|----------|--------|
| src/Service/RefundService.php:67 | Cyclomatic complexity: 12 (max 10) | high | FIXED |
| src/Service/RefundService.php:89 | Anemic model — logic in service | medium | FIXED |

**Verdict:** PASS

## Design Compliance Review
| File | Issue | Severity | Status |
|------|-------|----------|--------|
| src/Controller/RefundController.php | Route differs from API contract | high | FIXED |

**Verdict:** PASS

## Quality Gate
| Check | Result |
|-------|--------|
| Build | PASS |
| Tests (142 total, 8 new) | PASS |
| Test Coverage (new code: 87%) | PASS |
| PHPStan (level 8) | PASS |
| Psalm | PASS |
| PHP CS Fixer | PASS |

## Summary
- Total issues found: 5
- Fixed: 4
- Justified: 1
- Phase status: COMPLETE
```

---

## Quality Gate Checks

### Build
```bash
# PHP/Symfony
composer install --no-interaction
php bin/console cache:clear

# Node/JS
npm ci
npm run build
```

### Tests
```bash
# PHP/Symfony
php bin/phpunit
# перевірити що нові тести є
# перевірити coverage нового коду

# Node/JS
npm test
```

### Linters
```bash
# PHP/Symfony
vendor/bin/phpstan analyse --level=8
vendor/bin/psalm
vendor/bin/php-cs-fixer fix --dry-run --diff

# Node/JS
npm run lint
```

### Complexity
```bash
# PHP
vendor/bin/phpmd src text codesize --minimumpriority 2

# Generic
# Code Reviewer agents перевіряють вручну
```

---

## Sentry Verification

Після Quality Gate, якщо Sentry доступний:

1. `mcp__sentry__list_issues` — перевірити що немає нових issues з останнього commit
2. Для bug-fix: `mcp__sentry__get_issue_details` — перевірити що оригінальний issue resolved
3. Результат додається до phase-{N}-report.md

---

## Iteration Loop

Якщо Code Review або Quality Gate не проходить:

```
Writer fixes → Reviewers re-check (тільки failed checks) → Gate re-run
Max iterations: 3
Якщо після 3 ітерацій не проходить → Lead ескалює до користувача
```

---

## Anti-Patterns

1. **Review після всіх фаз** — ревью кожної фази окремо, поки код свіжий
2. **Ігнорування Medium issues** — вони накопичуються в технічний борг
3. **Skip Quality Gate** — "потім пофіксимо" ніколи не працює
4. **Один reviewer на все** — кожен scope потребує фокусу
5. **Code Writer ігнорує plan** — writer повинен слідувати phase-{N}.md, а не імпровізувати
6. **Тести окремо від коду** — тести пишуться разом з функціональністю
