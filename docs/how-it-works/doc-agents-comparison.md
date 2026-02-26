# Агенти документації: Technical Writer vs Architecture Doc Collector vs Codebase Doc Collector

Три агенти для документації з різними фокусами та підходами.

## Швидке порівняння

| Аспект | Technical Writer | Architecture Doc Collector | Codebase Doc Collector |
|--------|-----------------|------------------------|-------------|
| **Bias** | Audience first | Diagram first | Generate, don't write |
| **Підхід** | Ручний, детальний | Ручний, високорівневий | Автоматизований, code-driven |
| **Аудиторія** | Зовнішні команди, менеджери | Архітектори, нові члени команди | Розробники, CI/CD |
| **Вивід** | Stoplight.io docs | Confluence MD | CODEMAPS |
| **Тригер** | На запит | На запит | Автоматично/за розкладом |
| **Свіжість** | Ручні оновлення | Квартальний огляд | Авто-валідація |

---

## Коли використовувати кожного

```mermaid
flowchart TD
    Start[Потрібна документація] --> Q1{Хто аудиторія?}

    Q1 -->|Зовнішні команди, менеджери| TW[Technical Writer]
    Q1 -->|Архітектори, нові в команді| Q2{Який рівень?}
    Q1 -->|Розробники, CI/CD| DU[Codebase Doc Collector]

    Q2 -->|Системний, інтеграції| AD[Architecture Doc Collector]
    Q2 -->|Структура коду, модулі| DU

    TW --> OUT1[API Docs, Feature Specs, ADRs, Runbooks]
    AD --> OUT2[System Profile, Integration Catalog]
    DU --> OUT3[CODEMAPS, Validation Reports]
```

### Technical Writer

**Використовуй коли:**
- Пишеш API документацію для інших команд
- Створюєш feature specs для менеджерів/PM
- Документуєш архітектурні рішення (ADRs)
- Пишеш операційні runbooks для SRE

**Не використовуй для:**
- Внутрішньої документації структури коду
- Автоматичної генерації документації
- Системних оглядів архітектури

### Architecture Doc Collector

**Використовуй коли:**
- Онбордиш нових членів команди (системний контекст)
- Документуєш зовнішні інтеграції
- Створюєш system profiles для архітекторів
- C4 діаграми, context diagrams

**Не використовуй для:**
- Детальної документації API endpoints
- Документації модулів на рівні коду
- Автоматичних/частих оновлень

### Codebase Doc Collector

**Використовуй коли:**
- Генеруєш codemaps з codebase
- Валідуєш свіжість документації
- CI/CD перевірки документації
- Тримаєш docs в sync з кодом

**Не використовуй для:**
- Документації для stakeholders
- Бізнес-рівневих feature specs
- Високорівневих архітектурних рішень

---

## Порівняння виводу

### Technical Writer Output

```
docs/
├── references/
│   └── openapi.yaml           # API specification
├── features/
│   └── workout-sharing.md     # Feature spec для менеджерів
├── adr/
│   └── 0001-use-redis.md      # Architecture Decision Record
└── runbooks/
    └── billing-service.md     # Operational runbook
```

**Формат:** Stoplight.io compatible (OpenAPI 3.x, Markdown з frontmatter)

### Architecture Doc Collector Output

```
docs/
└── architecture/
    ├── system-profile.md      # Системний контекст та огляд
    ├── context-diagram.md     # C4 діаграми
    └── integrations/
        ├── README.md          # Каталог інтеграцій
        ├── payment/
        │   ├── apple-app-store.md
        │   └── google-play.md
        └── analytics/
            └── amplitude.md
```

**Формат:** Confluence-compatible Markdown, Mermaid діаграми

### Codebase Doc Collector Output

```
docs/CODEMAPS/
├── INDEX.md                   # Огляд всіх областей
├── controllers.md             # Маппінг API Controllers
├── services.md                # Структура сервісного шару
├── entities.md                # Doctrine entities та зв'язки
├── messages.md                # Message handlers
└── commands.md                # Console commands
```

**Формат:** Авто-згенерований Markdown з freshness metadata

---

## Порівняння Biases

### Technical Writer: "Audience First"

```
Перед написанням будь-чого:
1. ХТО буде це читати?
2. ЩО їм потрібно знати?
3. ЯК вони використають цю інформацію?

Вивід пріоритезує:
- Робочі приклади замість абстрактних пояснень
- Scannable формат (таблиці, списки)
- Без внутрішнього жаргону без пояснення
```

### Architecture Doc Collector: "Diagram First"

```
Перед написанням будь-чого:
1. Почни з context diagram
2. Покажи межі системи
3. Змапуй інтеграції та потоки даних

Вивід пріоритезує:
- Візуальне представлення (Mermaid)
- Таблиці для структурованих даних
- Посилання на детальну документацію
- Відстеження невідомого (Open Questions)
```

### Codebase Doc Collector: "Generate, Don't Write"

```
Основний принцип:
- Документація має ГЕНЕРУВАТИСЯ з коду
- Ручна документація = застаріла документація
- Код — це джерело правди

Вивід пріоритезує:
- Freshness timestamps
- Валідацію проти актуального коду
- Автоматичну регенерацію
- CI/CD інтеграцію
```

---

## Інтеграція між агентами

```mermaid
flowchart LR
    subgraph Scanner
        DU[Codebase Doc Collector]
    end

    subgraph Cache[".codemap-cache/"]
        CACHE[(JSON Cache)]
    end

    subgraph Consumers
        TW[Technical Writer]
        AD[Architecture Doc Collector]
    end

    Code[(Codebase)] --> DU
    DU -->|scan| CACHE
    DU -->|CODEMAPS| DevDocs[Developer Docs]

    CACHE -->|controllers, entities| TW
    CACHE -->|integrations, services| AD

    TW -->|API Docs| ExtTeams[Зовнішні команди]
    TW -->|Feature Specs| Managers[Менеджери/PM]

    AD -->|System Profile| NewMembers[Нові в команді]
    AD -->|Integrations| Architects[Архітектори]
```

### Workflow співпраці (Cache-based)

```
1. /codemap — Codebase Doc Collector сканує код, генерує cache + CODEMAPS
         ↓
2. /docs --api — Technical Writer читає cache → OpenAPI (high automation)
         ↓
3. /architecture-docs — Architecture Doc Collector читає cache → discovery (low automation)
         ↓
4. /codemap --validate — перевірка синхронізації
```

**Детальніше:** [Doc Agents Cooperation Protocol](./doc-agents-cooperation.md)

### Крос-посилання

| Коли Codebase Doc Collector знаходить... | Пропонує... |
|-------------------------------|-------------|
| Новий API endpoint без документації | `/docs --api <endpoint>` (Technical Writer) |
| Нову інтеграцію не в system profile | `/architecture-docs --integration` (Architecture Doc Collector) |
| Застарілий feature spec | `/docs --feature <name>` (Technical Writer) |

---

## Маппінг команд

| Агент | Команда | Вивід |
|-------|---------|-------|
| Technical Writer | `/docs --api <endpoint>` | OpenAPI + Mermaid |
| Technical Writer | `/docs --feature <name>` | Feature spec |
| Technical Writer | `/docs --adr <decision>` | ADR |
| Technical Writer | `/docs --runbook <service>` | Runbook |
| Technical Writer | `/docs --validate` | Freshness report |
| Architecture Doc Collector | `/architecture-docs` | System profile |
| Architecture Doc Collector | `/architecture-docs --integration` | Integration doc |
| Architecture Doc Collector | `/architecture-docs --scan` | Integration catalog |
| Codebase Doc Collector | `/codemap` | Всі CODEMAPS |
| Codebase Doc Collector | `/codemap --area <area>` | Конкретний codemap |
| Codebase Doc Collector | `/codemap --validate` | Validation report |

---

## Використані Skills

| Агент | Skills |
|-------|--------|
| Technical Writer | `api-docs-template`, `feature-spec-template`, `adr-template`, `runbook-template`, `readme-template` |
| Architecture Doc Collector | `system-profile-template`, `integration-template` |
| Codebase Doc Collector | `codemap-template` |

---

## Відповідальність за свіжість

| Тип документа | Відповідальний агент | Поріг свіжості |
|---------------|---------------------|----------------|
| API Docs | Technical Writer | 7-14 днів |
| Feature Specs | Technical Writer | 14-30 днів |
| ADRs | Technical Writer | Річний огляд |
| Runbooks | Technical Writer | 30-60 днів |
| System Profile | Architecture Doc Collector | 90-180 днів |
| Integrations | Architecture Doc Collector | 30-90 днів |
| CODEMAPS | Codebase Doc Collector | 7-14 днів |

---

## Підсумок

| Потреба | Агент | Команда |
|---------|-------|---------|
| API docs для інших команд | Technical Writer | `/docs --api` |
| Feature spec для PM | Technical Writer | `/docs --feature` |
| Runbook для SRE | Technical Writer | `/docs --runbook` |
| Системний огляд для нового члена команди | Architecture Doc Collector | `/architecture-docs` |
| Документація інтеграцій | Architecture Doc Collector | `/architecture-docs --integration` |
| Мапа структури коду | Codebase Doc Collector | `/codemap` |
| Перевірка свіжості docs | Codebase Doc Collector | `/codemap --validate` або `/docs --validate` |

---

**Запам'ятай:**
- **Technical Writer** = детальний, для зовнішньої аудиторії
- **Architecture Doc Collector** = високорівневий, для архітекторів
- **Codebase Doc Collector** = автоматизований, для розробників
