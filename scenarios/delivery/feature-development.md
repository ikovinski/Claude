# Feature Development Scenario

---
name: feature-development
description: End-to-end feature development — from task analysis to PR. 6 phases with human checkpoints, artifact chain, quality gates.
category: delivery
triggers:
  - "Розроби нову фічу"
  - "Develop this feature end-to-end"
  - "Повний цикл розробки"
  - "Feature from scratch"
  - "Зроби фічу від початку до кінця"
participants:
  - Research Lead + Codebase Researcher (Phase 1)
  - Design Architect + Test Strategist + Devil's Advocate (Phase 2)
  - Phase Planner (Phase 3)
  - Implement Lead + Code Writer + Code Reviewers + Quality Gate (Phase 4)
  - Documentation Suite team (Phase 5)
  - PR command (Phase 6)
duration: varies (each phase independent)
skills:
  - auto:{project}-patterns
  - design-template (Phase 2)
  - adr-template (Phase 2)
  - api-contracts-template (Phase 2)
  - stoplight-docs (Phase 5, if applicable)
requires: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
---

## Situation

### Description

Потрібно розробити фічу або виправити баг від початку до кінця: дослідити кодову базу, спроектувати рішення, спланувати імплементацію, написати код з code review, оновити документацію, створити PR.

Кожна фаза — окрема команда. Кожна фаза може бути запущена незалежно. Між фазами — human checkpoints.

### Entry Points

Задача може потрапити у flow двома шляхами:

1. **Пряма задача** — опис від людини (issue, feature request, bug report)
   ```bash
   /feature "Add refund functionality to payments"
   ```

2. **Sentry Triage** — автоматично зібрані та категоризовані production issues
   ```bash
   /sentry-triage --project bodyfit-api --org bodyfit
   # → створює docs/tasks/task-{N}-{slug}/issue.md
   # → потім для кожного task:
   /feature --from docs/tasks/task-1-amqp-transport/issue.md "Fix AMQP transport errors"
   ```

   `issue.md` містить Sentry контекст (stacktrace, events, tags), що автоматично використовується в Phase 1 (Research) як вхідні дані.

---

## Process Flow

```
Задача (issue / feature request / bug report)
    │
    │   ┌─ OR ──────────────────────────────────────┐
    │   │                                           │
    │   │  /sentry-triage                           │
    │   │    → docs/tasks/triage-report.md               │
    │   │    → docs/tasks/task-{N}-{slug}/issue.md       │
    │   │                                           │
    │   │  Pick task → /feature --from issue.md     │
    │   └───────────────────────────┬───────────────┘
    │                               │
    ▼                               ▼
┌─────────────────────────────────────────────────┐
│  Phase 1: RESEARCH                /research     │
│                                                 │
│  Research Lead:                                 │
│    Quick Reconnaissance (read entry points)     │
│    Complexity Assessment (Small/Medium/Large)   │
│                                                 │
│  Small → Lead сканує сам, без команди           │
│  Medium → 2 Codebase Researcher(s)              │
│  Large → 3-4 Codebase Researcher(s)             │
│                                                 │
│  Sentry MCP для bug-fix контексту               │
│  Context7 для документації фреймворків          │
│                                                 │
│  Output: .workflows/{feature}/research/         │
│  Gate: Components, DataFlow, Open Questions     │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  Phase 2: DESIGN                  /design       │
│                                                 │
│  ┌─ Parallel Wave 1 ─────────────────────────┐  │
│  │ Design Architect:                         │  │
│  │   Contract-first (якщо нові endpoints)    │  │
│  │   C4 Component + DataFlow + Sequence      │  │
│  │   ADR з альтернативами та ризиками        │  │
│  │   Self-Review перед завершенням           │  │
│  │ Test Strategist (Stage A):                │  │
│  │   Аналіз існуючих тестових паттернів      │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  ┌─ Parallel Wave 2 ─────────────────────────┐  │
│  │ Devil's Advocate:                         │  │
│  │   Challenge assumptions, alternatives,    │  │
│  │   risks, consistency                      │  │
│  │ Test Strategist (Stage B):                │  │
│  │   Test cases, levels, coverage            │  │
│  │ Security Reviewer (optional, --security): │  │
│  │   PII/auth/payment design concerns        │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  Architect addresses CRITICAL/SIGNIFICANT       │
│  challenges (якщо є)                            │
│                                                 │
│  Output: .workflows/{feature}/design/           │
│  Gate: Diagrams valid, ADR has alternatives,    │
│        Challenge verdict not NEEDS REVISION     │
└─────────────────┬───────────────────────────────┘
                  │
              HUMAN CHECKPOINT (approve/change/reject)
              Engineers review & approve design
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  Phase 3: PLAN                    /plan         │
│                                                 │
│  Phase Planner:                                 │
│    Vertical-slice decomposition                 │
│    Dependency graph                             │
│    Parallel phases detection (execution waves)  │
│    Critical path identification                 │
│    TDD Approach per phase (tests-first order)   │
│    Verification criteria per phase              │
│    Risk mitigation for med/high-risk phases     │
│    Acceptance criteria per phase                │
│    Each phase = separate file                   │
│                                                 │
│  Replan loop: reads replan-needed.md from       │
│    /implement if exists → full re-plan          │
│                                                 │
│  Output: .workflows/{feature}/plan/             │
│  Gate: No cycles, all components covered,       │
│        execution waves valid, TDD + verify      │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  Phase 4: IMPLEMENT (per phase)   /implement    │
│                                                 │
│  Implement Lead координує:                      │
│    Code Writer — пише код за планом             │
│      (TDD порядок з phase-{N}.md)               │
│    Smoke Check — build + tests перед reviews    │
│    Code Reviewers (паралельно):                 │
│      - Security (OWASP)                         │
│      - Quality (complexity, SOLID)              │
│      - Design compliance                        │
│    Quality Gate:                                │
│      build → tests → linters → Sentry           │
│  Fix iterations (max 3)                         │
│                                                 │
│  Output: code + .workflows/{feature}/implement/ │
│  Gate: All reviews PASS, Quality Gate PASS      │
│                                                 │
│  Repeat for each phase from Plan                │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  Phase 5: DOCUMENTATION           /docs-suite   │
│  --feature {feature-name}                       │
│                                                 │
│  Team Lead перевіряє наявність артефактів:       │
│    .workflows/{feature}/research/               │
│    .workflows/{feature}/design/                 │
│    .workflows/{feature}/implement/              │
│  Знайдені → передає як контекст агентам         │
│  Не знайдені → агенти працюють як звичайно      │
│                                                 │
│  Technical Collector (focused on affected code)  │
│  → Architect Collector (design as baseline)  ─┐  │
│  → Swagger Collector (api-contracts as start) ─┤  │
│  → Technical Writer (after both complete)      │  │
│                                                 │
│  Output: docs/                                  │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  Phase 6: PR / CI                 /pr           │
│                                                 │
│  PR description з design references             │
│  Test plan з test-strategy                      │
│  Quality checks summary                         │
│  CI verification                                │
│                                                 │
│  Output: Pull Request                           │
└─────────────────────────────────────────────────┘
```

---

## Participants

### Phase 1: Research
| Role | Agent File | Model | When |
|------|-----------|-------|------|
| Research Lead | `agents/engineering/research-lead.md` | opus | always |
| Codebase Researcher (x2-4) | `agents/engineering/codebase-researcher.md` | sonnet | Medium/Large only |

*Small tasks: Lead scans solo, no team needed. Complexity determined by Quick Reconnaissance.*

### Phase 2: Design
| Role | Agent File | Model | When |
|------|-----------|-------|------|
| Design Architect | `agents/engineering/design-architect.md` | opus | always |
| Devil's Advocate | `agents/engineering/devils-advocate.md` | opus | after Architect (skip with --skip-challenge) |
| Test Strategist | `agents/engineering/test-strategist.md` | sonnet | Stage A parallel with Architect, Stage B parallel with Devil's Advocate |
| Security Reviewer | `agents/engineering/security-reviewer.md` | sonnet | optional (--security or PII/auth/payment detected) |

### Phase 3: Plan
| Role | Agent File | Model |
|------|-----------|-------|
| Phase Planner | `agents/engineering/phase-planner.md` | opus |

### Phase 4: Implement
| Role | Agent File | Model |
|------|-----------|-------|
| Implement Lead | `agents/engineering/implement-lead.md` | opus |
| Code Writer | `agents/engineering/code-writer.md` | sonnet |
| Security Reviewer | `agents/engineering/security-reviewer.md` | sonnet |
| Quality Reviewer | `agents/engineering/quality-reviewer.md` | sonnet |
| Design Reviewer | `agents/engineering/design-reviewer.md` | sonnet |
| Quality Gate | `agents/engineering/quality-gate.md` | sonnet |

### Phase 5: Documentation
| Role | Agent File | Model |
|------|-----------|-------|
| (see documentation-suite scenario) | `agents/documentation/*.md` | sonnet |

*When invoked with `--feature {name}`: Team Lead checks `.workflows/{feature}/` for design artifacts and passes them as context to teammates. Missing artifacts are silently skipped — agents fall back to scanning code directly.*

### Phase 6: PR
| Role | Agent File | Model |
|------|-----------|-------|
| (direct command, no agent) | — | — |

---

## Artifact Chain

```
Phase 1 produces:
  .workflows/{feature}/research/
    ├── research-report.md          ◄── consumed by Phase 2, 3
    ├── architecture-scan.md
    ├── data-scan.md
    └── integration-scan.md

Phase 2 produces:
  .workflows/{feature}/design/
    ├── diagrams.md                 ◄── consumed by Phase 4, 6 (visual reference)
    ├── architecture.md             ◄── consumed by Phase 3, 4
    ├── adr/*.md                     ◄── consumed by Phase 3, 6
    ├── api-contracts.md            ◄── consumed by Phase 4
    ├── test-strategy.md            ◄── consumed by Phase 3, 4, 6
    ├── challenge-report.md         ◄── consumed by Phase 6 (PR context)
    └── security-review.md          ◄── optional, consumed by Phase 4, 6

Phase 3 produces:
  .workflows/{feature}/plan/
    ├── overview.md                 ◄── consumed by Phase 4, 6
    ├── phase-1.md                  ◄── consumed by Phase 4
    ├── phase-2.md                  ◄── consumed by Phase 4
    └── phase-N.md                  ◄── consumed by Phase 4

Phase 4 produces:
  code changes (in project)
  .workflows/{feature}/implement/
    ├── phase-{N}-report.md         ◄── consumed by Phase 6
    ├── phase-{N}-security-review.md
    ├── phase-{N}-quality-review.md
    ├── phase-{N}-design-review.md
    └── phase-{N}-quality-gate-report.md
  On structural blocker:
  .workflows/{feature}/plan/
    └── replan-needed.md            ◄── consumed by Phase 3 (replan loop)

Phase 5 consumes (if --feature):
  .workflows/{feature}/research/research-report.md
  .workflows/{feature}/design/architecture.md
  .workflows/{feature}/design/diagrams.md
  .workflows/{feature}/design/api-contracts.md
  .workflows/{feature}/design/adr/*.md
  .workflows/{feature}/implement/phase-*-report.md

Phase 5 produces:
  docs/                             ◄── committed with PR

Phase 6 produces:
  Pull Request on GitHub
```

---

## MCP Integration

| MCP | Phase | Usage |
|-----|-------|-------|
| **Sentry** | Pre (Triage) | Collect issues, details, tags for task creation |
| **Sentry** | 1 (Research) | Bug context — issue details, events, stack traces |
| **Sentry** | 4 (Implement) | Quality Gate — verify no new issues post-implementation |
| **Context7** | 1 (Research) | Framework/library documentation for understanding code |
| **Context7** | 2 (Design) | Best practices for architectural decisions |
| **Context7** | 4 (Implement) | API documentation for Code Writer |

---

## Decision Points

### Decision 1: Task Type
**Question**: Bug fix or new feature?
**Options**:
- A: Feature — full flow (Research → Design → Plan → Implement → Docs → PR)
- B: Bug fix — Research includes Sentry context, Design may be lighter
- C: Hotfix — skip Design/Plan, go Research → Implement (--skip-review) → PR

### Decision 2: Documentation Scope
**Question**: Update docs after implementation?
**Options**:
- A: Full docs-suite (new endpoints, architecture changes)
- B: Architecture only (structural changes, no API)
- C: Skip docs (internal refactoring, bug fix)

### Decision 3: PR Strategy
**Question**: One PR or per-phase PRs?
**Options**:
- A: Single PR after all phases (default for small features)
- B: Per-phase PRs (for large features — each phase = separate PR)

---

## Success Criteria

### Minimum Viable
- [ ] Research Report with Components Involved
- [ ] Architecture with at least 1 diagram
- [ ] Plan with phased decomposition
- [ ] Code passes Quality Gate
- [ ] PR created

### Good
- [ ] ADR with alternatives and risks
- [ ] Test strategy with concrete cases
- [ ] All 3 review scopes pass
- [ ] Test coverage ≥ 80% for new code
- [ ] PR description references design artifacts
- [ ] Each phase has TDD Approach and Verification sections
- [ ] Risk Mitigation documented for med/high-risk phases

### Excellent
- [ ] Zero high/medium issues in reviews without iterations
- [ ] Documentation updated via /docs-suite
- [ ] CI passes on first push
- [ ] Open Questions from Research all resolved by Design
- [ ] All phases have acceptance criteria met

---

## Anti-Patterns

1. **Skipping Research** — "I already know the code" → leads to missed dependencies and wrong assumptions
2. **Design without Research** — architecture decisions based on guessing, not facts
3. **Planning without Design review** — implementing unreviewed architecture → costly rework
4. **Horizontal phase slicing** — "Phase 1: entities, Phase 2: services" → untestable phases
5. **Skipping reviews** — "it's a simple change" → security/quality issues slip through
6. **Ignoring Quality Gate** — "tests will be fixed later" → technical debt accumulates
7. **PR without design refs** — reviewer has no context for WHY decisions were made
8. **Monolith PR** — 50+ files PR → impossible to review → rubber stamp → bugs
9. **Ignoring replan signal** — /implement creates replan-needed.md but developer continues with broken plan → wasted effort
10. **Plan without TDD** — phases without test-first order → Code Writer writes code first, adds tests as afterthought
