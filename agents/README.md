# Agents

## What is it
AI-персони з визначеними упередженнями та сферами експертизи. Кожен агент має свою перспективу, формат виводу та стиль прийняття рішень.

## How to use
1. Прочитати файл агента для завантаження персони та упереджень
2. Застосувати перспективу агента до вашого завдання
3. Дотримуватись структури виводу, визначеної у файлі агента

```
"Research codebase" → loads research-lead.md + codebase-researcher.md
"Architecture decision" → loads design-architect.md
"Review security" → loads security-reviewer.md
```

## Expected result
- Послідовний, опінійований фідбек з конкретної точки зору
- Структурований вивід відповідно до формату агента
- Чітке оголошення: "Applying [Agent Name] with bias: [main bias]"

## Engineering agents

| Agent | File | Bias | Use for |
|-------|------|------|---------|
| Task Refiner | `engineering/task-refiner.md` | Clarify before building | Уточнення нечіткої задачі через діалог, structured task document |
| Research Lead | `engineering/research-lead.md` | Describe, don't prescribe | Декомпозиція задачі, оркестрація research, синтез звіту |
| Codebase Researcher | `engineering/codebase-researcher.md` | Facts only, no proposals | Сканування кодової бази AS IS |
| Design Architect | `engineering/design-architect.md` | Contract-first, boring technology wins | Діаграми, архітектура, ADR, API contracts |
| Test Strategist | `engineering/test-strategist.md` | Test strategy before implementation | Тест-стратегія, кейси, coverage expectations |
| Phase Planner | `engineering/phase-planner.md` | Vertical slices > horizontal layers | Декомпозиція дизайну на фази імплементації |
| Implement Lead | `engineering/implement-lead.md` | Orchestrate, don't implement | Оркестрація імплементації, координація команди |
| Code Writer | `engineering/code-writer.md` | Working code > clever code | Написання коду суворо по плану |
| TDD Guide | `engineering/tdd-guide.md` | Test first, always | TDD-коуч — test-first, якість тестів, ізоляція |
| Security Reviewer | `engineering/security-reviewer.md` | Paranoid by default | OWASP Top 10, secrets, injection, access control |
| Quality Reviewer | `engineering/quality-reviewer.md` | Complexity, SOLID, domain model | Складність, layer compliance |
| Design Reviewer | `engineering/design-reviewer.md` | Implementation must match design | Перевірка відповідності коду дизайн-артефактам |
| Quality Gate | `engineering/quality-gate.md` | Build, tests, linters — all green | Запуск build, тестів, linters, Sentry check |
| Devil's Advocate | `engineering/devils-advocate.md` | Assume nothing works | Оскарження архітектурних рішень, слабкі припущення |
| Sentry Triager | `engineering/sentry-triager.md` | Categorize and group by root cause | Збір, категоризація, групування Sentry issues |
| QA Engineer | `engineering/qa-engineer.md` | Coverage-driven, structured checklists | Генерація QA чеклісту з опису фічі (PDF, images, URL, text) |

## Documentation agents

| Agent | File | Bias | Use for |
|-------|------|------|---------|
| Technical Collector | `documentation/technical-collector.md` | Generate, don't write | Збір фактів проекту AS IS |
| Architect Collector | `documentation/architect-collector.md` | Diagram first, tables over prose | Архітектурний аналіз, діаграми (Mermaid, C4) |
| Swagger Collector | `documentation/swagger-collector.md` | Code is the source of truth | Генерація OpenAPI spec з коду |
| Technical Writer | `documentation/technical-writer.md` | Audience first, examples > explanations | Feature articles, Swagger enrichment |
| System Profiler | `documentation/system-profiler.md` | Use cases and integrations registry | Integration Profile — use cases, actors, data flows |
