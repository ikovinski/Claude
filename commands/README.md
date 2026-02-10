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

| Command | Description | Agent used |
|---------|-------------|------------|
| `/plan` | Створення плану імплементації | Planner |
| `/code-review` | Code review | Code Reviewer |
| `/tdd` | Запуск TDD workflow | TDD Guide |
| `/security-check` | Security аудит | Security Reviewer |
| `/skill-create` | Генерація skill з git history | — |
| `/ai-debug` | Показати статус системи | — |
