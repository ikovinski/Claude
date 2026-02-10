# Templates

## What is it
Базові шаблони для створення нових агентів, skills, scenarios та конфігураційних файлів. Використовуйте їх як відправну точку при розширенні системи.

## How to use
Скопіюйте відповідний шаблон та налаштуйте:

```bash
cp templates/agent-template.md agents/technical/my-new-agent.md
# Відредагуйте файл з специфікою вашого агента
```

## Expected result
- Консистентна структура по всіх компонентах системи
- Необхідні секції заповнені placeholders
- Швидке створення нових agents/skills/scenarios

## Available templates

| Template | Use for |
|----------|---------|
| `agent-template.md` | Створення нових AI agents |
| `skill-template.md` | Створення нових project skills |
| `scenario-template.md` | Створення multi-step workflows |
| `global-claude-md.template` | Глобальна конфігурація CLAUDE.md |
