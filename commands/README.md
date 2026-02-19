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

| Command | Description | Agent used | Skills applied |
|---------|-------------|------------|----------------|
| `/plan` | Створення плану імплементації | Planner | planning/* |
| `/code-review` | Code review | Code Reviewer | code-quality/* |
| `/tdd` | Запуск TDD workflow | TDD Guide | tdd/* |
| `/security-check` | Security аудит | Security Reviewer | security/* |
| `/docs` | Документація (Stoplight-compatible) | Technical Writer | documentation/* |
| `/skill-create` | Генерація skill з git history | — | — |
| `/ai-debug` | Показати статус системи | — | — |

## Examples з Skills

### `/plan` з Project Context

```bash
cd ~/wellness-backend
/plan "Add Apple Health integration"
```

**Loads:**
- Agent: Planner
- Skills: planning/planning-template.md, wellness-backend-patterns/SKILL.md

**Output:** Plan що слідує project conventions

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
