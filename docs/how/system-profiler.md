# System Profiler — Посібник

Генерація повного Integration Profile системи — бізнес-технічного реєстру всіх зовнішніх інтеграцій.

## Що це таке

Один агент сканує кодову базу і виробляє єдиний документ — "паспорт системи":

```
Codebase → Scan integrations → Profile each → Collect OQ + Issues → docs/system-profile.md
```

Integration Profile відповідає на три питання по кожній інтеграції:
- **Для чого?** — бізнес-причина
- **Як?** — технічна деталь (тип, протокол, auth)
- **Що невідомо?** — Open Questions та Issues з коду

## Передумови

Не потребує Agent Teams. Запускається будь-де.

## Швидкий старт

```bash
# Повний профіль (сканування коду)
/system-profile

# З артефактами /docs-suite (швидше, якщо вже є)
/system-profile --with-artifacts
```

При запуску з директорії `amo-claude-workflows` — агент запитає, для якого проєкту генерувати.

---

## Повний процес крок за кроком

### Крок 1: Detect Technology

Агент визначає технологію за `composer.json`, `package.json`, `go.mod` та вибирає стратегію сканування:

**PHP/Symfony** — шукає в `src/Client/`, `src/Integration/`, `src/Api/`, `composer.json`, `.env`, `config/packages/`

**Node/JS** — шукає в `src/clients/`, `src/integrations/`, `package.json`, `.env`

---

### Крок 2: Context Diagram

Агент будує C4 Context Diagram (Mermaid) — система в центрі, всі зовнішні системи навколо з типами зв'язків. Це перше, що читач бачить у документі.

---

### Крок 3: Profile Each Integration

Для кожної знайденої інтеграції заповнюється єдиний шаблон:

| Поле | Що містить |
|------|-----------|
| **Для чого** | Бізнес-причина (якщо не зрозуміло — OQ) |
| **Актори** | User / Admin / System (cron, queue) |
| **Use Cases** | Конкретні бізнес-сценарії |
| **Які дані** | Що передається і отримується |
| **Як інтегровано** | Тип, бібліотека, напрямок, auth |
| **Особливості** | Error handling, rate limits, retry, ризики |
| **Діаграма** | Sequence або flowchart (якщо flow > 2 кроків) |

Інтеграції групуються по категоріях:
- Payment & Monetization
- Marketing & Attribution
- Communication & Support
- Analytics & Monitoring
- Infrastructure & Media
- Internal Services
- Authentication

---

### Крок 4: Open Questions та Issues

Генеруються автоматично під час аналізу коду.

**Open Questions (OQ-001, OQ-002...)** — речі, які не можна визначити з коду:
- Бізнес-логіка, яка не очевидна
- Невідомий initiator flow
- Неясна конфігурація

**Issues (ISSUE-001, ISSUE-002...)** — проблеми в коді:
- `TODO` / `FIXME` / `HACK` пов'язані з інтеграціями
- Deprecated packages або API versions
- Відсутній error handling при зовнішніх викликах
- Hardcoded credentials або URLs
- Відсутній retry/fallback для критичних інтеграцій

---

### Крок 5: Compile Document

Агент збирає все в один файл `docs/system-profile.md`.

**Структура документа:**
```
# System Integration Profile: {Project}

> Stats: N integrations, N OQ, N issues

## Context Diagram       ← Mermaid C4, всі зовнішні системи
## Integration Template  ← Опис шаблону
## Integrations
   ### Payment & Monetization
   ### Marketing & Attribution
   ### Communication & Support
   ### Analytics & Monitoring
   ### Infrastructure & Media
   ### Internal Services
   ### Authentication
## Open Questions        ← OQ-001..., по категоріях
## Issues                ← Critical + Documentation Gaps
## Summary               ← Статистика по категоріях
```

---

## --with-artifacts режим

Якщо вже запускали `/docs-suite` — агент використовує готові артефакти:
- `docs/.artifacts/technical-collection-report.md` — база для виявлення інтеграцій
- `docs/.artifacts/architecture-report.md` — Integration Catalog як стартова точка

Артефакти опціональні — якщо їх немає, агент сканує код самостійно. Якщо вони застаріли — агент верифікує проти реального коду.

---

## Де шукати результат

```
docs/
└── system-profile.md    ← Єдиний вихідний файл
```

Один документ — зручно для Confluence, зручно для читання.

---

## Поради

1. **Нульовий OQ = поганий знак.** Агент з біасом "Track Unknowns Aggressively" — якщо він не знайшов жодного OQ, значить не заглибився достатньо. Перевірте розділ Open Questions.

2. **Бізнес-причина — не з коду.** Якщо для інтеграції написано "невідомо" — це сигнал для команди, не баг агента.

3. **Issues = технічний борг.** Все що знайшов агент (TODO, deprecated libs, відсутній retry) — це конкретні задачі, які можна взяти в `/feature`.

4. **Periodic refresh.** System Profile застаріває при кожній новій інтеграції. Запускайте раз на квартал або перед аудитом.

5. **Доповнення до `/docs-suite`.** docs-suite покриває структуру коду та API. system-profile покриває бізнес-контекст інтеграцій. Ці документи доповнюють один одного.

---

## Коли використовувати

| Ситуація | Причина |
|----------|---------|
| Onboarding нового члена команди | Швидко зрозуміти "з чим система пов'язана" |
| Аудит зовнішніх залежностей | Список всіх інтеграцій з ризиками |
| Квартальне планування | Де gaps? Де ризики? |
| Incident post-mortem | Як система пов'язана із зовнішнім сервісом |
| Pre-release перевірка | Чи всі нові інтеграції задокументовані? |

---

## Різниця між `/system-profile` та `/docs-suite`

| Аспект | `/system-profile` | `/docs-suite` |
|--------|------------------|--------------|
| Фокус | Інтеграційний ландшафт | Структура коду, API, features |
| Агентів | 1 | 4 (команда) |
| Виходів | Один файл | Багато файлів |
| Аудиторія | Engineers + leads + stakeholders | Розробники |
| Потребує Agent Teams | Ні | Так |
