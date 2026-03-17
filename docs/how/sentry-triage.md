# Sentry Triage — Посібник

Збір та категоризація production issues з Sentry в actionable tasks для feature-development flow.

## Що це таке

Один агент (Sentry Triager) збирає issues з Sentry, категоризує по критичності та типу, групує пов'язані issues по root cause, і записує структуровані task files:

```
Sentry Issues → Collect → Enrich → Categorize → Group → docs/tasks/
```

Агент **не пропонує рішень**. Тільки збирає факти і структурує задачі. Рішення — в `/feature` flow.

## Передумови

**Sentry MCP** налаштований і підключений. Перевірте що `mcp__sentry__*` tools доступні.

## Швидкий старт

```bash
# Базовий запуск
/sentry-triage
# → агент запитає: "Sentry project slug?"
# → введіть назву проєкту, наприклад: bodyfit-api

# Production only
/sentry-triage --env prod

# Staging only
/sentry-triage --env stage

# Обидва середовища, за 30 днів
/sentry-triage --env prod,stage --period 30d

# Тільки DB помилки
/sentry-triage --env prod --category DB --top 20

# Тільки часті issues
/sentry-triage --env prod --min-events 100
```

| Параметр | За замовч. | Опис |
|----------|-----------|------|
| `--env` | all | `prod`, `stage`, `prod,stage` або не вказувати |
| `--period` | `14d` | Часовий діапазон |
| `--min-events` | `10` | Мінімальний поріг для включення в tasks |
| `--category` | all | AMQP, DB, Business Logic, тощо |
| `--top` | `50` | Макс. issues для деталізації |
| `--tasks-dir` | `docs/tasks` | Директорія для task files |

---

## Повний процес крок за кроком

### Крок 1: Collect Issues

Агент запитує `project slug`, авто-визначає organization та region через Sentry MCP.

Збирає до 100 unresolved issues, відсортованих за частотою (`sort: freq`). Якщо результат порожній — попереджає про можливий невірний slug або занадто суворі фільтри.

---

### Крок 2: Enrich Top Issues

Для top `{--top}` issues за events count агент паралельно викликає `get_issue_details`:
- Exception type + message
- Stacktrace root frames (file, line, function)
- First seen / last seen
- Events count
- Tags (environment, server)

Для CRITICAL кандидатів додатково:
- `get_issue_tag_values(tagKey: "environment")`
- `get_issue_tag_values(tagKey: "url")`

---

### Крок 3: Categorize

#### Критичність

| Severity | Критерії |
|----------|----------|
| **CRITICAL** | events > 500 AND (last_seen < 24h OR user-facing flow) |
| **HIGH** | events > 100 AND last_seen < 14d AND active |
| **MEDIUM** | events > 10 AND last_seen < 30d |
| **LOW** | events < 10 OR last_seen > 30d |

Коригування:
- User-facing errors (API, notifications) → підвищити на 1 рівень
- Background/cron з retry → можна знизити на 1 рівень
- Production > Staging за пріоритетом

#### Категорія

| Category | Сигнали |
|----------|---------|
| **AMQP** | TransportException, AMQPConnection, RabbitMQ, messenger transport |
| **DB** | ConnectionLost, Deadlock, ForeignKeyConstraint, DBAL, timeout |
| **Business Logic** | Domain exceptions, validation errors, entity-level "not found" |
| **Circuit Breaker** | CircuitBreaker у class/message, зовнішні сервіси з circuit pattern |
| **Notification** | FCM, APNS, Push, Socket error iOS/Android |
| **Integration** | HTTP client errors, rate limit, third-party SDK |
| **Runtime** | TypeError, unexpected null, type mismatch |
| **Validation** | Input validation, constraint violations |
| **Infrastructure** | Memory, DNS, network-level |

---

### Крок 4: Group Related Issues

Issues групуються по спільній root cause — один group = одна task:

- **Same stacktrace root** — однаковий file:function у root frame
- **Same exception class + same component** — всі `TransportException` в AMQP transport
- **Same external dependency** — всі помилки Stripe / Iterable / тощо
- **Causal chain** — issue A спричиняє issue B (connection lost → handler failed)

Головна issue в групі — та з найбільшою кількістю events.
Standalone issues з severity >= MEDIUM — окремі tasks.

---

### Крок 5: Write Output

**`docs/tasks/triage-report.md`** — повний звіт:
```
# Sentry Triage Report

| Severity | Issues |
| CRITICAL | n       |
| HIGH     | n       |
| MEDIUM   | n       |

## Groups Identified
| Group | Issues | Root Cause | Task |

## Category Summary
| Category | CRITICAL | HIGH | MEDIUM | Total |
```

**`docs/tasks/{issue-short-id}-{slug}/issue.md`** — per-group task file:
```
# Task Title

Severity: CRITICAL / HIGH / MEDIUM
Category: AMQP / DB / ...

## Issues (таблиця з ID, events, last seen)
## Description (людська мова — що відбувається, на що впливає)
## Stacktrace (root cause frames)
## Context (environment, flow, frequency trend)
## Tags (top values)
## Related Issues (якщо група)

→ /feature --from docs/tasks/{slug}/issue.md "..."
```

---

## Після triage

Кожен `issue.md` готовий для `/feature` flow:

```bash
# Взяти task і запустити feature flow
/feature --from docs/tasks/BODYFIT-9H9-amqp-transport/issue.md "Fix AMQP transport errors"

# Або вручну з Sentry контекстом
/research --type bug --sentry BODYFIT-9H9 "Fix AMQP transport errors"
```

`issue.md` містить Sentry issue IDs (для `--sentry` флагу), stacktrace (для scope identification), та готову команду `/feature`.

---

## Повторний запуск

`/sentry-triage` можна запускати щотижня:
- **Перезаписує** `triage-report.md` свіжими даними
- **НЕ перезаписує** існуючі `{issue-short-id}-{slug}/issue.md` — пропускає якщо директорія є

Щоб примусово перегенерувати task — видаліть директорію вручну.

---

## Де шукати результат

```
docs/tasks/
├── triage-report.md                   ← Повний triage звіт
├── BODYFIT-9H9-amqp-transport/
│   └── issue.md                       ← Task для /feature
├── BODYFIT-A2K-db-connection/
│   └── issue.md
└── BODYFIT-B3M-notification-delay/
    └── issue.md
```

---

## Поради

1. **Запускайте з `--env prod` для реального пріоритету.** Всі environments разом можуть заповнити список staging-шумом.

2. **Group by root cause — не by error message.** 5 різних AMQP errors від одного broken connection = 1 task. Не 5 tasks.

3. **Агент не пропонує рішень** — якщо в `issue.md` є щось схоже на "треба зробити X" — це сигнал що агент вийшов за межі ролі.

4. **`--min-events 100` для великих проєктів.** На активних системах 10 events — шум. Підіймайте поріг для фокусу на реальних проблемах.

5. **CRITICAL issues — починайте зі звіту, а не tasks.** `triage-report.md` дає швидкий overview перед зануренням у деталі.

6. **Sentry Triage + Feature Flow = ефективний bug cycle.** Triage раз на тиждень → pick top task → `/feature --from issue.md` → research → design → implement → PR.
