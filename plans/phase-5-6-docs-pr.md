# Phase 5: DOCUMENTATION + Phase 6: PR/CI

---

## Phase 5: DOCUMENTATION

### Команда запуску

```
/docs-suite
```

**Existing command** — повністю перевикористовується без змін.

### Зв'язок з Feature Flow

Після завершення Phase 4 (Implement) всіх фаз, документація оновлюється:
- Technical Collector сканує оновлений код
- Architect Collector оновлює діаграми
- Swagger Collector оновлює OpenAPI spec
- Technical Writer оновлює/створює feature articles

### Коли запускати

| Ситуація | Scope |
|----------|-------|
| Нова фіча з новими endpoints | Full (`/docs-suite`) |
| Нова фіча без API змін | Architecture only (`/docs-suite --scope architecture`) |
| Bug fix | Зазвичай не потрібно |
| Рефакторинг | Architecture only, якщо змінилась структура |

### Артефакти

Output йде в `docs/` проєкту (не в `.workflows/`), бо це постійна документація:
```
docs/
├── .artifacts/          # проміжні (technical-collection, etc.)
├── features/            # feature articles
├── INDEX.md             # entry point
├── getting-started.md   # (Stoplight)
├── toc.json             # (Stoplight)
└── openapi.yaml         # enriched spec
```

---

## Phase 6: PR / CI

### Команда запуску

```
/pr {feature-name}
```

**Опції:**
- `--draft` — створити draft PR
- `--base main` — target branch (default: main/master)
- `--reviewers @user1,@user2` — призначити reviewers

### Мета

Створити Pull Request з повним описом, посиланнями на design артефакти, test plan з test-strategy.

### Процес

```
Input:
  ├── .workflows/{feature}/ (всі артефакти)
  ├── Git diff (всі зміни від feature branch)
  └── CI configuration
  │
  ▼
1. Збирає інформацію:
   ├── git diff main...HEAD
   ├── git log main...HEAD
   ├── .workflows/{feature}/design/adr.md
   └── .workflows/{feature}/design/test-strategy.md
  │
  ▼
2. Генерує PR:
   ├── Title (short, descriptive)
   ├── Summary (з ADR context)
   ├── Changes breakdown (per phase)
   ├── Test Plan (з test-strategy)
   ├── Design References (links to design docs)
   └── Checklist
  │
  ▼
3. Push + Create PR via gh CLI
  │
  ▼
4. Verify CI checks
```

### PR Template

```markdown
## Summary
{1-3 речення з ADR context}

## Architecture Decision
{Посилання на .workflows/{feature}/design/adr.md або inline summary}

## Changes by Phase

### Phase 1: {title}
- {зміни}

### Phase 2: {title}
- {зміни}

## Test Plan
{З test-strategy.md}

### Added Tests
| Test | Type | Covers |
|------|------|--------|
| ... | unit | ... |
| ... | functional | ... |

## Quality Checks
- [x] Build passes
- [x] All tests pass
- [x] Linters pass
- [x] Security review: passed
- [x] Design compliance: verified

## Design References
- Research: `.workflows/{feature}/research/research-report.md`
- Architecture: `.workflows/{feature}/design/architecture.md`
- ADR: `.workflows/{feature}/design/adr.md`
- Test Strategy: `.workflows/{feature}/design/test-strategy.md`
- Implementation Plan: `.workflows/{feature}/plan/overview.md`
```

### CI Verification

Після створення PR, перевірити що CI проходить:
```bash
gh pr checks {pr-number} --watch
```

Якщо CI fails — аналізувати помилку, виправляти, push fix commit.

---

## Anti-Patterns

1. **PR без design references** — ревьюер не розуміє контекст рішень
2. **Один великий PR** — краще per-phase PRs для великих фіч
3. **Skip CI verification** — CI може знайти issues що Quality Gate пропустив (environment differences)
4. **PR description "see commits"** — PR description повинен бути self-contained
