# Phase 1: RESEARCH

## Команда запуску

```
/research "Опис задачі або посилання на issue"
```

**Опції:**
- `--type bug` — фокус на bug-fix (підтягує Sentry issues)
- `--type feature` — фокус на нову функціональність (default)
- `--scope src/Service/Payment` — обмежити область дослідження
- `--sentry ISSUE-123` — прив'язати до конкретного Sentry issue

---

## Мета

Зібрати факти про поточний стан кодової бази в контексті задачі. Тільки аналіз і опис — без пропозицій. Дивитися на проєкт AS IS. Звузити кодову базу до релевантних частин — менше контексту = менше галюцинацій.

---

## Agent Team

```
team_name: "research-{feature-name}"
```

### Учасники

| Name | Agent | Model | Роль |
|------|-------|-------|------|
| lead | `agents/engineering/research-lead.md` | opus | Декомпозує задачу, обирає стратегію, синтезує |
| scanner | `agents/engineering/codebase-researcher.md` | sonnet | Сканує код, збирає факти |

### Як працює Lead

1. **Аналізує задачу** — визначає тип (bug/feature), scope
2. **Декомпозує на під-задачі дослідження:**
   - Архітектура — які компоненти залучені, границі системи
   - Дані — які entities/DTO задіяні, як зберігаються
   - Інтеграції — зовнішні сервіси, message handlers
   - (для bug-fix) Потік помилки — де виникає, як поширюється
3. **Запускає scanner** під кожну під-задачу з конкретним scope
   - Scanner отримує звужений scope (конкретні директорії/файли)
   - Scanner повертає факти: "що", "де", "як"
4. **Синтезує Research Report** — об'єднує результати sub-agents

### Sentry Integration (для bug-fix)

Коли `--type bug` або `--sentry`:
1. Lead підтягує деталі issue через `mcp__sentry__get_issue_details`
2. Отримує events через `mcp__sentry__list_issue_events`
3. Аналізує stack trace, tags, breadcrumbs
4. Передає контекст помилки scanner-у як додатковий input

### Context7 Integration

Доступний для scanner — підтягує документацію фреймворків/бібліотек за потребою (наприклад, як працює конкретний Symfony component).

---

## Процес

```
Input: Задача (issue description / bug report)
  │
  ▼
Research Lead аналізує задачу
  ├── Визначає тип: bug / feature
  ├── Визначає scope (які частини кодової бази)
  ├── [bug] Підтягує Sentry context
  └── Декомпозує на під-задачі
  │
  ▼
Lead запускає scanner під кожну під-задачу
  ├── Scanner 1: Architecture scope
  │   └── Компоненти, залежності, boundaries
  ├── Scanner 2: Data scope
  │   └── Entities, DTO, migrations, repositories
  ├── Scanner 3: Integration scope
  │   └── External APIs, message handlers, events
  └── [інші за потребою]
  │
  ▼
Lead збирає результати
  ├── Перевіряє повноту (всі під-задачі covered)
  ├── Виявляє конфлікти між результатами
  └── Синтезує фінальний Research Report
  │
  ▼
Output: .workflows/{feature}/research/
```

---

## Output Structure

### `.workflows/{feature}/research/research-report.md`

Фінальний звіт від Lead:

```markdown
# Research Report: {Feature Name}

## Summary
- Тип: bug / feature
- Scope: {які частини системи залучені}
- Складність: low / medium / high
- Ризики: {перелік ризиків знайдених під час дослідження}

## Components Involved
| Component | Path | Role | Impact |
|-----------|------|------|--------|
| PaymentController | src/Controller/Api/v2/ | Entry point | Direct |
| PaymentService | src/Service/Payment/ | Business logic | Direct |
| OrderEntity | src/Entity/ | Data model | Indirect |

## Data Flow
{Як дані проходять через систему в контексті задачі}

## External Dependencies
| Service | Type | Current Usage |
|---------|------|---------------|
| Stripe API | REST | Payment processing |
| Kafka | Async | Order events |

## Current Behavior (AS IS)
{Опис поточної поведінки без оцінок}

## [Bug Only] Error Analysis
- Sentry Issue: {link}
- Error: {message}
- Stack Trace Summary: {key points}
- Frequency: {how often}
- Affected Users: {scope of impact}

## Open Questions
- {Питання що потребують відповіді перед Design}

## Appendix: Raw Scans
- [codebase-scan.md](codebase-scan.md)
- [architecture-context.md](architecture-context.md)
- [integrations-map.md](integrations-map.md)
```

### Sub-agent outputs (appendix)

- `codebase-scan.md` — AS IS факти з коду (controllers, services, entities з їх signatures)
- `architecture-context.md` — системні границі, залежності між компонентами
- `integrations-map.md` — зовнішні сервіси, async flows

---

## Gate

Lead перевіряє перед завершенням:
- [ ] Всі під-задачі мають результати
- [ ] Components Involved таблиця не порожня
- [ ] Data Flow описаний
- [ ] Open Questions сформульовані
- [ ] [bug] Sentry context включений

---

## Anti-Patterns

1. **Пропозиції замість фактів** — Research описує що Є, а не що ПОВИННО бути
2. **Занадто широкий scope** — якщо scanner отримав весь `src/`, він поверне шум. Lead має звузити
3. **Ігнорування async flows** — message handlers і events часто є ключовими для розуміння
4. **Відсутність Open Questions** — якщо питань немає, дослідження було поверхневим
