---
name: qa-checklist
description: QA checklist generator — читає опис фічі з будь-якого формату (PDF, images, text, URL) і генерує структурований тест-чеклист.
allowed_tools: ["Read", "Write", "Glob", "Grep", "Bash", "WebFetch"]
triggers:
  - "qa-checklist"
  - "qa checklist"
  - "чеклист для"
  - "зроби чеклист"
---

# /qa-checklist - QA Checklist Generator

Читає опис фічі з файлів або URL та генерує структурований QA-чеклист.

## Usage

```bash
# Один файл
/qa-checklist path/to/feature.pdf

# Кілька файлів
/qa-checklist spec.pdf mockup.png

# URL
/qa-checklist https://confluence.example.com/feature-description

# Inline текст
/qa-checklist "Юзер може завантажити аватар. Підтримувані формати: JPG, PNG. Максимальний розмір: 5MB."

# З явним feature-id
/qa-checklist --id user-avatar path/to/spec.pdf

# Комбінація
/qa-checklist --id payment-refund spec.pdf flow-diagram.png https://jira.example.com/PROJ-123
```

## Supported Input Formats

| Format | How |
|--------|-----|
| `.pdf` | Read (native Claude PDF support) |
| `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif` | Read (native Claude vision) |
| `.md`, `.txt` | Read |
| URL | WebFetch |
| Inline text | Direct from command argument |

## Setup

```bash
mkdir -p .workflows/{feature-id}/qa
```

## Execution

### Step 1: Parse Arguments

З аргументу команди визнач:
- `--id {name}` → feature-id (опціонально)
- Шляхи до файлів (абсолютні або відносні від CWD проєкту)
- URL (рядки що починаються з `http://` або `https://`)
- Inline text (все що залишилось і не є флагом або шляхом)

Визнач `feature-id`:
- Якщо передано `--id {name}` — використовуй його
- Інакше — виведи kebab-case назву з першого файлу або тексту (наприклад `user-avatar-upload`)

### Step 2: Read Sources

Прочитай всі вхідні джерела:
- файли → `Read`
- URL → `WebFetch`
- inline text → використовуй напряму

Якщо файл не знайдено або не підтримується — повідом у секції `## Warnings` в output і продовжуй з доступними даними.
Якщо є проблеми з читанням данних за URL — повідом у секції `## Warnings` в output і продовжуй з доступними даними.

Додатково прочитай вміст директорії `docs/` (якщо є) — для розуміння контексту існуючих фічей.

### Step 3: Detect Platform

Чеклист генерується для **однієї** платформи. Визнач її: iOS / Android / Backend.
Якщо невідомо — виведи питання і чекай на відповідь перед продовженням.

> Якщо фіча охоплює кілька платформ — запусти `/qa-checklist` окремо для кожної.

### Step 4: Read Agent

Визнач HOME через `Bash`: `echo $HOME`.

Перевір підключення агента (qa-engineer):
- глобально: `Read $HOME/.claude/agents/engineering/qa-engineer.md`
- локально: `Read agents/engineering/qa-engineer.md`

Використовуй `Read` з абсолютним шляхом (підставляй $HOME), НЕ `Glob` з `~`.

Якщо агент не знайдено — виведи повідомлення і зупинись.
Якщо знайдено — прочитай і виконай його Process повністю.

### Step 5: Quality Gate

Після того як QA Engineer згенерував чеклист, ТИ (Claude) виступаєш як QA Team Lead і перевіряєш результат:
- Правильні техніки обрані для типу фічі?
- Обов'язкові Checklist-based Testing перевірки включені?
- Кожна перевірка конкретна і actionable (не розмита)?
- Expected result присутній для кожної перевірки?

Якщо є зауваження — надай конкретний фідбек QA Engineer і запроси виправлення. Повторюй до затвердження.

### Step 6: Save File

```bash
mkdir -p .workflows/{feature-id}/qa
```

Збережи результат у .workflows/{feature-id}/qa/checklist.md.
                                          
### Step 7: Report to User

Після збереження файлу:

```markdown
# QA Checklist Ready: {feature-id}

**File:** `.workflows/{feature-id}/qa/checklist.md`
**Total checks:** {N}

{обовʼязково додай Test Design Techniques секцію}
**Test Design Techniques:** перелік технік тест дизайну, які були використані

{якщо є Open Questions}
**Open Questions:** {N} — перевір секцію `## Open Questions` у файлі перед початком тестування

{якщо є Warnings}
**Warnings:** {список проблем з читанням файлів}
```

## Notes

- Зображення (wireframes, mockups, screenshots) читаються нативно — Claude бачить UI і витягує сценарії
- PDF читаються нативно — включно з таблицями та схемами
- Якщо опис фічі неповний — чеклист буде з `Open Questions` замість вигаданих сценаріїв
- Можна передати кілька джерел одночасно — агент синтезує їх в єдиний чеклист
