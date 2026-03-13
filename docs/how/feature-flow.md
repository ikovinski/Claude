# Feature Development Flow — Посібник

Покроковий гайд по розробці фічі від задачі до Pull Request за допомогою AI агентів.

## Що це таке

6-фазний процес розробки з AI-агентами на кожному етапі:

```
Задача → Research → Design → [Human Review] → Plan → Implement → Docs → PR
```

Кожна фаза — окрема команда. Між фазами — ваш контроль. Агенти працюють з артефактами попередньої фази, а не вгадують.

## Передумови

1. **Agent Teams** увімкнені (для Research, Design, Implement):
   ```json
   // .claude/settings.json
   { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
   ```

2. **GitHub CLI** (`gh`) встановлений і авторизований — для `/pr`

3. **MCP сервери** (опціонально, але рекомендовано):
   - **Sentry** — контекст багів у Research, верифікація в Quality Gate
   - **Context7** — документація фреймворків для всіх фаз

## Швидкий старт

### Варіант A: З навігатором `/feature`

```bash
# 1. Ініціалізація
/feature "Додати функціонал повернень до платежів"

# 2. Система покаже наступний крок — виконуйте команди одну за одною
/research "Додати функціонал повернень до платежів"
/design payment-refund
# ... перегляньте дизайн ...
/plan payment-refund
/implement payment-refund --phase 1
/implement payment-refund --phase 2
/docs-suite
/pr payment-refund

# В будь-який момент — перевірити статус
/feature payment-refund --status
```

### Варіант B: Без навігатора

Кожна команда працює самостійно. Просто запускайте потрібну фазу:

```bash
/research "Виправити помилку авторизації"
# → .workflows/auth-fix/research/

/design auth-fix
# → .workflows/auth-fix/design/

/plan auth-fix
# → .workflows/auth-fix/plan/

/implement auth-fix --phase 1
# → код + .workflows/auth-fix/implement/
```

---

## Повний процес крок за кроком

### Фаза 1: Research

**Мета**: Зібрати факти про кодову базу AS IS. Жодних пропозицій — тільки те, що є.

```bash
/research "Опис задачі"
/research "Виправити баг оплати" --type bug --sentry PROJ-123
```

**Що відбувається**: Research Lead декомпозує задачу на скоупи (архітектура, дані, інтеграції), Codebase Researcher(s) сканують код паралельно.

**Результат**: `.workflows/{feature}/research/`
- `research-report.md` — головний звіт з компонентами, data flow, open questions
- `architecture-scan.md`, `data-scan.md`, `integration-scan.md` — деталі сканів

**Перевірте**:
- Components Involved — чи всі релевантні компоненти знайдені?
- Open Questions — чи є невирішені питання?

---

### Фаза 2: Design

**Мета**: Спроектувати рішення з діаграмами, ADR, тест-стратегією.

```bash
/design {feature-name}
```

**Що відбувається**: Design Architect створює архітектуру з Mermaid діаграмами (C4, DataFlow, Sequence), ADR з альтернативами. Test Strategist визначає тест-стратегію з Given/When/Then кейсами.

**Результат**: `.workflows/{feature}/design/`
- `architecture.md` — діаграми + архітектурні рішення
- `adr/*.md` — Architecture Decision Records (one per decision)
- `test-strategy.md` — тестові кейси + покриття
- `api-contracts.md` — нові/змінені endpoints (якщо є)

### Human Checkpoint

**Це обов'язковий крок.** Перегляньте артефакти дизайну перед продовженням:

1. Відкрийте `.workflows/{feature}/design/`
2. Перевірте діаграми — чи вони відповідають вашому розумінню?
3. Перевірте ADR — чи альтернативи розглянуті?
4. Перевірте тест-стратегію — чи покриті критичні шляхи?

Якщо все ок — переходьте до Plan. Якщо ні — внесіть зміни або перезапустіть `/design`.

---

### Фаза 3: Plan

**Мета**: Розбити дизайн на фази імплементації. Кожна фаза — вертикальний зріз, який можна деплоїти незалежно.

```bash
/plan {feature-name}
/plan {feature-name} --max-phases 5
```

**Що відбувається**: Phase Planner аналізує дизайн і створює ordered phases з залежностями.

**Результат**: `.workflows/{feature}/plan/`
- `overview.md` — список фаз, граф залежностей
- `phase-1.md`, `phase-2.md`, ... — деталі кожної фази

**Важливо**: Кожна фаза містить ВСІ шари (entity → service → controller → test). Це вертикальний зріз, а не горизонтальний ("Phase 1: всі entities" — неправильно).

---

### Фаза 4: Implement

**Мета**: Написати код, пройти code review, Quality Gate.

```bash
/implement {feature-name} --phase 1
/implement {feature-name} --phase 2
# ... повторити для кожної фази з плану
```

**Що відбувається** (для кожної фази):
1. **Code Writer** пише код за планом (послідовно, задача за задачею)
2. **3 Code Reviewers** перевіряють паралельно:
   - Security (OWASP Top 10)
   - Quality (складність, SOLID)
   - Design compliance (відповідність архітектурі)
3. **Фікс-ітерації** — Writer виправляє знахідки reviewer'ів (макс. 3 ітерації)
4. **Quality Gate** — автоматичні перевірки: build, tests, linters, coverage

**Результат**: Код + `.workflows/{feature}/implement/`
- `phase-{N}-report.md` — звіт фази
- `security-review.md`, `quality-review.md`, `design-review.md`
- `quality-gate-report.md`

**Опції**:
```bash
--skip-review          # Пропустити code review (для hotfix)
--reviewers security   # Тільки security review
--auto-fix             # Автоматично застосовувати фікси від reviewer'ів
```

---

### Фаза 5: Documentation (опціонально)

**Мета**: Оновити документацію проекту.

```bash
/docs-suite
/docs-suite --scope api          # Тільки API docs
/docs-suite --scope architecture # Тільки архітектура
```

Повністю перевикористовує існуючий Documentation Suite з 4 агентами. Детальний гайд: `docs/comparisons/documentation-agents-and-suite.md`.

**Коли потрібно**: Нові endpoints, архітектурні зміни, нові інтеграції.
**Коли можна пропустити**: Внутрішній рефакторинг, баг-фікс.

---

### Фаза 6: Pull Request

**Мета**: Створити PR з посиланнями на дизайн-артефакти.

```bash
/pr {feature-name}
/pr {feature-name} --draft
/pr {feature-name} --base develop
/pr {feature-name} --reviewers @user1,@user2
```

**Що відбувається**: Збирає інформацію з workflow артефактів (ADR, test-strategy, phase reports) і створює структурований PR через `gh` CLI.

**PR включає**: Summary, Architecture Decision, Changes by Phase, Test Plan, Quality Checks, Design References.

---

## Типи задач

### Feature (повний флоу)

```bash
/feature "Додати нову фічу"
# Research → Design → [Review] → Plan → Implement → Docs → PR
```

### Bug Fix (з Sentry контекстом)

```bash
/feature "Виправити помилку" --type bug --sentry PROJ-123
# Research (+ Sentry дані) → Design (легший) → Plan → Implement → PR
```

### Hotfix (скорочений флоу)

```bash
/feature "Виправити typo" --type hotfix
# Research → Implement (--skip-review) → PR
```

---

## Де шукати артефакти

Все зберігається в `.workflows/{feature-name}/` цільового проекту:

```
.workflows/payment-refund/
├── state.json                    # Стан флоу (якщо /feature)
├── research/
│   ├── research-report.md        # Головний звіт
│   ├── architecture-scan.md
│   ├── data-scan.md
│   └── integration-scan.md
├── design/
│   ├── architecture.md           # C4, DataFlow, Sequence
│   ├── adr/                      # Architecture Decision Records
│   │   ├── 001-{slug}.md
│   │   └── ...
│   ├── test-strategy.md          # Given/When/Then кейси
│   └── api-contracts.md          # API контракти
├── plan/
│   ├── overview.md               # Фази + залежності
│   ├── phase-1.md
│   ├── phase-2.md
│   └── phase-N.md
└── implement/
    ├── phase-1-report.md
    ├── phase-2-report.md
    ├── security-review.md
    ├── quality-review.md
    ├── design-review.md
    └── quality-gate-report.md
```

`.workflows/` файли включаються в PR — вони слугують проектною документацією.

---

## Поради

1. **Не пропускайте Research** — навіть якщо "знаєте код". Агенти знаходять залежності, які ви пропустили.

2. **Human Review — не формальність** — це єдиний момент для корекції курсу до початку імплементації. Фікс на етапі Design коштує мінімум, на етапі Implement — максимум.

3. **Фази — вертикальні зрізи** — кожна фаза повинна бути деплойною. "Фаза 1: всі entities" — антипатерн.

4. **Quality Gate не чіпайте** — якщо тести падають, фіксіть код, а не пропускайте перевірки.

5. **Використовуйте `/feature --status`** — для відстеження прогресу, особливо при перерві в роботі.

6. **Один PR vs Per-Phase PRs** — для маленьких фіч один PR, для великих (50+ файлів) — окремий PR на фазу.

---

## Детальна довідка

Для повного опису всіх параметрів, агентів і артефактів див. [feature-flow-reference.md](feature-flow-reference.md).
