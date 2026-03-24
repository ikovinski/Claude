# Documentation Suite — Посібник

Генерація повної документації проєкту за допомогою команди агентів.

## Що це таке

5-фазний процес генерації документації з 4 агентами:

```
Codebase → Collect → Analyze (arch + swagger) → Write → Cross-Review → Finalize
```

Кожен агент отримує артефакт попередньої фази — а не сканує код самостійно. Це гарантує узгодженість між архітектурою, API специфікацією та feature-статтями.

## Передумови

1. **Agent Teams** увімкнені:
   ```json
   // .claude/settings.json
   { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
   ```

2. **MCP Context7** (опціонально) — документація фреймворків для агентів

## Швидкий старт

```bash
# Повна документація
/docs-suite

# Тільки архітектура (без API docs та feature-статей)
/docs-suite --scope architecture

# Тільки API docs
/docs-suite --scope api

# Stoplight-сумісний формат (SMD, toc.json, Getting Started)
/docs-suite --format stoplight

# Прив'язка до feature — агенти фокусуються на змінених компонентах
/docs-suite --feature payment-refund

# Без cross-review (швидший запуск)
/docs-suite --skip-review
```

---

## Повний процес крок за кроком

### Фаза 1: Collect

**Агент**: Technical Collector (sonnet)

**Мета**: Зібрати всі факти про кодову базу AS IS. Контролери, сервіси, entities, хендлери, міграції, async flows, конфігурація.

**Що відбувається**: Агент детектує технологію (PHP/Symfony, Node, Go), сканує структуру проєкту і збирає таблицю компонентів із кількісними показниками.

**Результат**: `docs/.artifacts/technical-collection-report.md`

**Перевірте**: У звіті є таблиця Components Summary зі значеннями > 0 для кожного типу.

---

### Фаза 2: Analyze (паралельно)

Два агенти запускаються одночасно та читають з `docs/.artifacts/technical-collection-report.md`.

#### Track A: Architect Collector (sonnet)

**Мета**: Архітектурний аналіз системи.

**Результат**: `docs/.artifacts/architecture-report.md` з:
- C4 Context Diagram (Mermaid)
- Component Diagram (Mermaid)
- Sequence / Flow diagrams для ключових flows
- Async flows (messages, events, cron)
- ER diagram для ключових entities
- Integration catalog
- Open Questions

#### Track B: Swagger Collector (sonnet)

**Мета**: Генерація OpenAPI специфікації.

**Результат**:
- `docs/.artifacts/openapi.yaml` — схема без описів (опис додає Technical Writer)
- `docs/.artifacts/swagger-coverage-report.md` — покриття та gaps

**Перевірте**:
- `architecture-report.md` містить хоча б один ` ```mermaid ` блок (без ASCII art)
- `openapi.yaml` має секцію `paths:`

---

### Фаза 3: Write

**Агент**: Technical Writer (sonnet)

**Мета**: Перетворити артефакти на документацію для людей.

**Читає**:
- `docs/.artifacts/technical-collection-report.md`
- `docs/.artifacts/architecture-report.md`
- `docs/.artifacts/openapi.yaml`

**Результат**:
- `docs/features/*.md` — feature-статті по доменах
- `docs/openapi.yaml` — збагачений Swagger (описи, приклади, посилання)
- `docs/INDEX.md` — єдина точка входу в документацію

При `--format stoplight` додатково:
- `docs/getting-started.md`
- `docs/toc.json`
- `docs/reference/openapi.yaml` (Stoplight layout)
- SMD синтаксис у всіх статтях (`<!-- theme: -->` callouts)

**Перевірте**: Є хоча б 1 feature-стаття, `docs/INDEX.md` існує.

---

### Фаза 4: Cross-Review

**Lead**: Team Lead координує, агенти рев'юють артефакти один одного.

#### Матриця рев'ю

| Reviewer | Рев'ює | Фокус |
|----------|--------|-------|
| Architect | Swagger | Naming endpoints відповідає архітектурі |
| Architect | Technical Writer | Діаграми в статтях узгоджені з архітектурою |
| Swagger | Technical Writer | Описи відповідають реальній поведінці endpoint'ів |
| Technical Writer | Architect | Mermaid валідний, OQ actionable |
| Technical Writer | Swagger | Структура схем логічна, naming консистентний |

Кожен reviewer виробляє таблицю findings з severity (high/medium/low). Тільки `high` і `medium` потребують виправлень. Team Lead призначає fix tasks і верифікує виправлення.

**Пропуск**: `--skip-review`

---

### Фаза 5: Finalize

**Lead**: Team Lead безпосередньо.

1. Оновлює `docs/INDEX.md` фінальним списком файлів
2. Перевіряє валідність cross-references між документами
3. При `--format stoplight` — верифікує SMD синтаксис, `toc.json`
4. Вимикає всіх teammates та видаляє команду (`TeamDelete`)
5. Виводить фінальну статистику

---

## --feature режим

При `--feature {feature-id}` Team Lead перед запуском агентів підтягує артефакти з `.workflows/{feature-id}/`:

| Агент | Artifact | Як використовує |
|-------|----------|-----------------|
| scanner | `research/research-report.md`, `implement/phase-*-report.md` | Фокусується на зачіпнутих компонентах |
| architect | `design/architecture.md`, `design/diagrams.md`, `design/adr/*.md` | Базелайн, переносить актуальні діаграми |
| api-spec | `design/api-contracts.md` | Стартова точка для extraction |

Якщо `.workflows/{feature-id}/` не існує — агенти сканують код як зазвичай, без помилок.

---

## Де шукати артефакти

```
docs/
├── .artifacts/                          # Проміжні артефакти (між агентами)
│   ├── technical-collection-report.md   # Technical Collector
│   ├── architecture-report.md           # Architect Collector
│   ├── openapi.yaml                     # Swagger Collector
│   ├── swagger-coverage-report.md       # Swagger Collector
│   └── cross-review-*.md                # Cross-review findings
├── features/                            # Feature-статті
│   ├── payments.md
│   └── workouts.md
├── openapi.yaml                         # Збагачений Swagger (plain markdown)
├── INDEX.md                             # Головний вхід
│
│   # Тільки при --format stoplight:
├── getting-started.md
├── toc.json
└── reference/
    └── openapi.yaml
```

---

## Поради

1. **Artifact chain — це правило, не рекомендація.** Агенти не сканують код напряму (крім Phase 1). Якщо Technical Collector пропустив компонент — він не з'явиться в architecture чи swagger.

2. **ASCII art = баг.** Якщо в architecture-report є box-drawing символи замість ` ```mermaid ` блоків — Team Lead відправить fix request автоматично.

3. **Cross-review — не formality.** Часто знаходить невідповідності між архітектурним описом та реальними endpoint'ами.

4. **`--scope architecture`** — якщо потрібна лише архітектура без API docs. Займає менше часу та токенів.

5. **Open Questions** в `architecture-report.md` — сигнал де архітектор не знайшов достатньо контексту. Варто відповісти вручну або запустити `/system-profile` для глибшого аналізу.

---

## Різниця між `/docs-suite` та `/system-profile`

| Аспект | `/docs-suite` | `/system-profile` |
|--------|--------------|-------------------|
| Фокус | Структура коду, API, features | Інтеграційний ландшафт, бізнес-контекст |
| Агентів | 4 (команда) | 1 |
| Виходів | Багато файлів | Один `docs/system-profile.md` |
| Аудиторія | Розробники | Розробники + leads + stakeholders |
| Вимоги | Agent Teams | Нічого |
