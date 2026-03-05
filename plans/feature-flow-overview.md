# Feature Development Flow — Overview

## Рішення

| # | Питання | Рішення |
|---|---------|---------|
| 1 | Scope технологій | Multi-tech з профілями (PHP/Symfony default, Node/JS, Go — автодетект) |
| 2 | Human checkpoints | Повна зупинка між фазами — кожна фаза окрема команда |
| 3 | Артефакти | `.workflows/{feature-name}/` в цільовому проєкті |
| 4 | Оркестрація | Agent Teams для всіх фаз. Implement — команда з декількома code-reviewers |
| 5 | Sentry MCP | Research (контекст бага) + Implement (верифікація) |
| 6 | Context7 MCP | Available для всіх агентів за потребою |

---

## Flow Diagram

```
Задача (issue / опис)
    │
    ▼
┌─────────────────────────────────────────────┐
│  Phase 1: RESEARCH            /research     │
│  Lead декомпозує задачу → sub-agents        │
│  ├── Codebase Researcher (AS IS факти)      │
│  ├── Architecture Researcher (границі)      │
│  ├── Integration Researcher (зовнішні API)  │
│  └── Lead → Research Report                 │
│  Sentry: підтягує issues для bug-fix        │
│  Context7: документація фреймворків         │
└─────────────────┬───────────────────────────┘
                  │ .workflows/{feature}/research/
                  ▼
┌─────────────────────────────────────────────┐
│  Phase 2: DESIGN              /design       │
│  ├── Architecture (C4, DataFlow, Sequence)  │
│  ├── ADR (ризики, рішення, альтернативи)    │
│  ├── Test Strategy (кейси, стратегії)       │
│  └── API Contracts (якщо є нові endpoints)  │
│  Gate: контроль якості design               │
└─────────────────┬───────────────────────────┘
                  │ .workflows/{feature}/design/
                  │
                  ▼  ◄── HUMAN CHECKPOINT
              Engineers review & approve
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Phase 3: PLAN                /plan         │
│  Декомпозиція на фази імплементації         │
│  ├── phase-1.md (окремо деліверабельна)     │
│  ├── phase-2.md                             │
│  └── phase-N.md                             │
│  Кожна фаза = окрема задача з criteria      │
└─────────────────┬───────────────────────────┘
                  │ .workflows/{feature}/plan/
                  ▼
┌─────────────────────────────────────────────┐
│  Phase 4: IMPLEMENT (per phase)  /implement │
│  Lead декомпозує фазу → запускає команду    │
│  ├── Code Writer (пише код)                 │
│  ├── Code Reviewer: Security (OWASP)        │
│  ├── Code Reviewer: Quality (complexity)    │
│  ├── Code Reviewer: Design (відповідність)  │
│  └── інші reviewers за потребою             │
│  Quality Gate:                              │
│    ✓ build  ✓ tests  ✓ linters              │
│    ✓ design compliance  ✓ security          │
│  Sentry: перевірка нових помилок            │
└─────────────────┬───────────────────────────┘
                  │ code changes + .workflows/{feature}/implement/
                  ▼
┌─────────────────────────────────────────────┐
│  Phase 5: DOCUMENTATION       /docs-suite   │
│  (EXISTING — повністю перевикористовується)  │
│  Technical Collector → Architect Collector   │
│  → Swagger Collector → Technical Writer     │
└─────────────────┬───────────────────────────┘
                  │ docs/
                  ▼
┌─────────────────────────────────────────────┐
│  Phase 6: PR / CI             /pr           │
│  ├── PR description з посиланнями на design │
│  ├── Test plan з design/test-strategy       │
│  └── CI checks verification                │
└─────────────────────────────────────────────┘
```

---

## Команди

| Команда | Фаза | Тип | Агенти |
|---------|------|-----|--------|
| `/research` | 1 | Agent Team | Research Lead + sub-agents |
| `/design` | 2 | Agent Team | Design Architect + ADR Writer + Test Strategist |
| `/plan` | 3 | Single Agent | Phase Planner |
| `/implement` | 4 | Agent Team | Implement Lead + Code Writer + Code Reviewers |
| `/docs-suite` | 5 | Agent Team | EXISTS — Technical/Architect/Swagger Collector + Writer |
| `/pr` | 6 | Command | PR creation з артефактів |
| `/feature` | all | Orchestrator | Мета-команда, запускає фази послідовно |

---

## Артефакти

Всі проміжні артефакти зберігаються в `.workflows/{feature-name}/` цільового проєкту:

```
.workflows/{feature-name}/
├── state.json                    # стан флоу (current phase, decisions)
├── research/
│   ├── research-report.md        # фінальний звіт від Research Lead
│   ├── codebase-scan.md          # AS IS факти
│   ├── architecture-context.md   # системні границі
│   └── integrations-map.md       # зовнішні залежності
├── design/
│   ├── architecture.md           # C4, DataFlow, Sequence diagrams
│   ├── adr.md                    # Architecture Decision Record
│   ├── test-strategy.md          # тестова стратегія
│   └── api-contracts.md          # нові/змінені API endpoints
├── plan/
│   ├── overview.md               # загальний план з фазами
│   ├── phase-1.md                # окрема фаза
│   ├── phase-2.md
│   └── phase-N.md
└── implement/
    ├── progress.md               # трекінг прогресу
    ├── phase-1-review.md         # результати code review
    └── quality-gate-report.md    # фінальний звіт якості
```

---

## Нові агенти (потрібно створити)

| Агент | Файл | Фаза | Опис |
|-------|------|------|------|
| Research Lead | `agents/engineering/research-lead.md` | 1 | Декомпозує задачу, обирає стратегію, синтезує звіт |
| Codebase Researcher | `agents/engineering/codebase-researcher.md` | 1 | AS IS факти — що, де, як |
| Design Architect | `agents/engineering/design-architect.md` | 2 | C4, DataFlow, Sequence, ADR |
| Test Strategist | `agents/engineering/test-strategist.md` | 2 | Тестова стратегія, кейси |
| Phase Planner | `agents/engineering/phase-planner.md` | 3 | Декомпозиція на фази |
| Implement Lead | `agents/engineering/implement-lead.md` | 4 | Оркестрація імплементації |
| Code Writer | `agents/engineering/code-writer.md` | 4 | Пише код |
| Code Reviewer | `agents/engineering/code-reviewer.md` | 4 | Ревью з конфігурованим scope |
| Quality Gate | `agents/engineering/quality-gate.md` | 4 | Перевірка build/tests/linters |

---

## Існуючі ресурси для перевикористання

| Ресурс | Як використовується |
|--------|-------------------|
| `scenarios/delivery/documentation-suite.md` | Phase 5 повністю |
| `agents/documentation/*` | Phase 5 повністю |
| `skills/stoplight-docs/` | Phase 5 (якщо Stoplight format) |
| `templates/agent-template.md` | Шаблон для нових агентів |
| `rules/language.md` | Всі агенти — мова комунікації |
| `rules/git.md` | Phase 6 — PR/commit rules |
| MCP: context7 | Всі фази — документація бібліотек |
| MCP: sentry | Phase 1 (bug context) + Phase 4 (verification) |

---

## Детальні специфікації

- [Phase 1: Research](phase-1-research.md)
- [Phase 2: Design](phase-2-design.md)
- [Phase 3: Plan](phase-3-plan.md)
- [Phase 4: Implement](phase-4-implement.md)
- [Phase 5-6: Documentation + PR/CI](phase-5-6-docs-pr.md)
- [New Agents Specification](new-agents-spec.md)
- [Implementation Roadmap](roadmap.md)
