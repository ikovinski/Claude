# Commands

## What is it
Slash-команди для Claude Code CLI. Швидкий виклик workflows, які активують конкретних агентів або багатокрокові процеси.

## How to use
Введіть `/command` в Claude Code:

```
/plan "Add user authentication"
/code-review src/Service/PaymentService.php
/tdd "CalorieCalculator service"
/security-check src/Controller/Api/
/ai-debug
```

## Expected result
- Негайна активація відповідного workflow
- Оголошення агента та структурований вивід
- Покрокове керівництво через процес

## Available commands

| Command | Agent | Output | Description |
|---------|-------|--------|-------------|
| `/plan` | Planner | `docs/plans/*.md` | Створення плану імплементації |
| `/code-review` | Code Reviewer | Chat | Code review |
| `/tdd` | TDD Guide | Chat + Files | TDD workflow |
| `/security-check` | Security Reviewer | Chat | Security аудит |
| `/docs` | Technical Writer | Chat / Files | Документація (Stoplight) |
| `/docs --validate` | Technical Writer | Chat | Перевірка свіжості документації |
| `/codemap` | Doc-Updater | `docs/CODEMAPS/*.md` | Генерація codemaps з коду |
| `/codemap --validate` | Doc-Updater | Chat | Валідація codemaps vs код |
| `/architecture-docs` | Architecture Documenter | Chat / Files | System profiles (Confluence) |
| `/skill-create` | — | `skills/*.md` | Генерація skill з git |
| `/ai-debug` | — | Chat | Статус системи, аналіз |

## Examples з Skills

### `/plan` з Project Context

```bash
cd ~/wellness-backend
/plan "Add Apple Health integration"
```

**Loads:**
- Agent: Planner
- Skills: planning/planning-template.md, wellness-backend-patterns/SKILL.md

**Output:** `docs/plans/001.apple-health-integration.md`

```
docs/plans/
├── 001.apple-health-integration.md
├── 002.next-feature.md
└── ...
```

---

### `/security-check` з OWASP

```bash
/security-check src/Controller/Api/PaymentController.php
```

**Loads:**
- Agent: Security Reviewer
- Skills: security/owasp-top-10.md, security/security-audit-checklist.md

**Output:** OWASP Top 10 check + PII/PHI scan

---

### `/tdd` з Test Patterns

```bash
/tdd "CalorieCalculator service"
```

**Loads:**
- Agent: TDD Guide
- Skills: tdd/tdd-workflow.md, {project}-patterns/SKILL.md

**Output:** Red → Green → Refactor cycle з project test patterns

---

### `/docs` для Cross-Team APIs

```bash
/docs --api /api/v1/workouts
/docs --feature "Workout Sharing"
```

**Loads:**
- Agent: Technical Writer
- Skills: documentation/api-docs-template.md, documentation/feature-spec-template.md

**Output:** Stoplight-compatible OpenAPI або Feature Spec для stakeholders

---

### `/codemap` для Code-Driven Docs

```bash
/codemap                        # Generate all codemaps
/codemap --area controllers     # Only controllers
/codemap --validate             # Check codemaps vs code
```

**Loads:**
- Agent: Doc-Updater
- Skills: documentation/codemap-template.md

**Output:**
```
docs/CODEMAPS/
├── INDEX.md
├── controllers.md
├── services.md
├── entities.md
├── messages.md
└── commands.md
```

---

### `/architecture-docs` для System Overview

```bash
/architecture-docs
/architecture-docs --integration "Apple App Store"
/architecture-docs --scan
```

**Loads:**
- Agent: Architecture Documenter
- Skills: documentation/system-profile-template.md, documentation/integration-template.md

**Output:** System Profile з C4 diagrams, Integration Catalog, Open Questions
