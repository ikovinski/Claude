---
name: skill-create
description: Analyze git history to extract PHP/Symfony coding patterns and generate SKILL.md files. Learns from your team's actual practices.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /skill-create - Local Skill Generation for PHP/Symfony

Аналізує git history твого репозиторію щоб витягнути coding patterns і згенерувати SKILL.md файли, які навчать Claude практикам твоєї команди.

## Usage

```bash
/skill-create                        # Аналізує поточний репо, зберігає в ai-agents-system
/skill-create --commits 100          # Аналізує останні 100 комітів
/skill-create --path src/Service     # Аналізує конкретну директорію
/skill-create --local                # Зберігає в поточному проекті (.claude/skills/)
/skill-create --output ./custom/     # Custom output директорія
```

## Де зберігається результат

| Режим | Шлях | Коли використовувати |
|-------|------|---------------------|
| **Default (global)** | `~/.claude/skills/skills/{project-name}-patterns/SKILL.md` | Для переиспользування в всіх проектах |
| `--local` | `./.claude/skills/{project-name}-patterns/SKILL.md` | Тільки для цього проекту |
| `--output <path>` | `<path>/SKILL.md` | Custom location |

### Приклад

```bash
# Ти в ~/my-fitness-app
cd ~/my-fitness-app

# Запускаєш команду
/skill-create

# Результат зберігається в:
# ~/.claude/skills/skills/my-fitness-app-patterns/SKILL.md
#
# Тепер цей skill доступний для всіх проектів через ai-agents-system
```

## Що робить команда

1. **Парсить Git History** — аналізує коміти, зміни файлів, патерни
2. **Виявляє Patterns** — знаходить повторювані workflows і conventions
3. **Генерує SKILL.md** — створює валідний skill файл
4. **Адаптовано для PHP/Symfony** — розуміє Doctrine, Messenger, Services

---

## Крок 1: Збір Git Data

Виконай ці команди щоб зібрати дані:

```bash
# Останні коміти з файлами
git log --oneline -n 200 --name-only --pretty=format:"%H|%s|%ad" --date=short

# Найчастіше змінювані файли
git log --oneline -n 200 --name-only | grep -v "^$" | grep -v "^[a-f0-9]" | sort | uniq -c | sort -rn | head -20

# Патерни commit messages
git log --oneline -n 200 | cut -d' ' -f2- | head -50

# Автори та їх contribution
git shortlog -sn --no-merges -n 200

# Файли які часто змінюються разом
git log --oneline -n 100 --name-only --pretty=format:"---" | awk '/^---/{if(files)print files; files=""} /^[^-]/{files=files" "$0} END{print files}' | sort | uniq -c | sort -rn | head -10
```

---

## Крок 2: Аналіз PHP/Symfony Patterns

### Commit Conventions
```bash
# Перевірити чи використовують conventional commits
git log --oneline -n 100 | grep -E "^[a-f0-9]+ (feat|fix|chore|docs|refactor|test):" | wc -l

# Популярні префікси
git log --oneline -n 200 | sed 's/^[a-f0-9]* //' | cut -d':' -f1 | sort | uniq -c | sort -rn
```

### Symfony Structure
```bash
# Знайти основні директорії
find src -type d -maxdepth 2 | head -20

# Controller patterns
ls -la src/Controller/ 2>/dev/null | head -10

# Service patterns
ls -la src/Service/ 2>/dev/null | head -10

# Message handlers
find src -name "*Handler.php" -o -name "*Message.php" | head -20

# Repositories
find src -name "*Repository.php" | head -10
```

### Testing Patterns
```bash
# Test structure
find tests -type d -maxdepth 2 | head -10

# Test naming
find tests -name "*Test.php" | head -10

# Test to code ratio
echo "Code files: $(find src -name '*.php' | wc -l)"
echo "Test files: $(find tests -name '*Test.php' | wc -l)"
```

### Doctrine Patterns
```bash
# Entity patterns
find src -path "*/Entity/*.php" | head -10

# Migration patterns
ls -la migrations/ 2>/dev/null | tail -5

# Repository methods (custom queries)
grep -rn "public function find" src/Repository/ | head -10
```

### Message/Event Patterns
```bash
# Messages
find src -name "*Message.php" | head -10

# Event Listeners
find src -name "*Listener.php" -o -name "*Subscriber.php" | head -10

# Handlers
find src -name "*Handler.php" | head -10
```

---

## Крок 3: Генерація SKILL.md

На основі зібраних даних, згенеруй файл з такою структурою:

```markdown
---
name: {project-name}-patterns
description: Coding patterns extracted from {project-name} repository
version: 1.0.0
source: local-git-analysis
analyzed_commits: {count}
tech_stack: PHP 8.3, Symfony 6.4, Doctrine
---

# {Project Name} Patterns

## Commit Conventions

{Виявлені патерни commit messages}

Приклади:
- `feat(billing): add subscription renewal`
- `fix(workout): handle null duration`

## Code Architecture

```
src/
├── Controller/     # API endpoints ({naming_pattern})
├── Service/        # Business logic
├── Repository/     # Database queries
├── Entity/         # Doctrine entities
├── DTO/            # Data Transfer Objects
├── Message/        # Async messages
├── MessageHandler/ # Message processors
└── EventListener/  # Domain event handlers
```

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Controller | `{Entity}Controller` | `WorkoutController` |
| Service | `{Domain}Service` | `BillingService` |
| Repository | `{Entity}Repository` | `UserRepository` |
| Message | `{Action}{Entity}Message` | `SyncWorkoutMessage` |
| Handler | `{Message}Handler` | `SyncWorkoutMessageHandler` |
| DTO | `{Purpose}DTO` | `CreateWorkoutDTO` |

## Common Workflows

### Adding New API Endpoint
1. Create DTO in `src/DTO/Request/`
2. Add validation constraints
3. Create/update Service method
4. Add Controller action with #[Route]
5. Write functional test

### Adding Message Handler
1. Create Message in `src/Message/`
2. Create Handler in `src/MessageHandler/`
3. Add #[AsMessageHandler] attribute
4. Implement idempotency check
5. Write unit test for handler

### Database Changes
1. Update Entity
2. Generate migration: `bin/console make:migration`
3. Review migration SQL
4. Run migration: `bin/console doctrine:migrations:migrate`
5. Update Repository if needed

## Testing Patterns

- Location: `tests/Unit/`, `tests/Integration/`, `tests/Functional/`
- Naming: `{ClassName}Test.php`
- Coverage target: {detected}%

### Test Structure
```php
public function test{Action}{Condition}{ExpectedResult}(): void
{
    // Arrange
    // Act
    // Assert
}
```

## Code Quality Tools

{Виявлені з composer.json або config}

- PHPStan level: {level}
- PHP CS Fixer: {yes/no}
- Psalm: {yes/no}

## Team Practices

{Виявлені з git history}

- Average PR size: {lines}
- Most active areas: {directories}
- Review practices: {detected}
```

---

## Крок 4: Зберегти Skill

Збережи згенерований файл:

```bash
# Default location
skills/{project-name}-patterns/SKILL.md

# Or custom
{output-directory}/SKILL.md
```

---

## Приклад Output

Для wellness/fitness PHP/Symfony проєкту:

```markdown
---
name: wellness-app-patterns
description: Coding patterns from wellness-app backend
version: 1.0.0
source: local-git-analysis
analyzed_commits: 150
tech_stack: PHP 8.3, Symfony 6.4, Doctrine, RabbitMQ
---

# Wellness App Patterns

## Commit Conventions

Project uses **conventional commits** with scope:
- `feat(workout):` - Workout feature changes
- `feat(billing):` - Subscription/payment changes
- `fix(sync):` - External API sync fixes
- `refactor(entity):` - Doctrine entity changes

## Code Architecture

```
src/
├── Controller/Api/    # REST API (v1, v2 versioning)
├── Service/           # Business logic (injected via DI)
├── Repository/        # Doctrine repositories
├── Entity/            # Doctrine entities with traits
├── DTO/
│   ├── Request/       # Input validation
│   └── Response/      # API responses
├── Message/           # RabbitMQ messages
├── MessageHandler/    # Async processors
└── EventListener/     # Domain events
```

## Workflows

### Sync External Workout Data
1. API receives webhook → Controller validates
2. Dispatch `SyncWorkoutMessage` to queue
3. Handler fetches from external API
4. Check idempotency (external_id)
5. Persist via Repository
6. Dispatch `WorkoutSyncedEvent`

### Subscription Lifecycle
1. Payment webhook received
2. Validate signature
3. `ProcessPaymentMessage` dispatched
4. Handler updates subscription state
5. Audit log created
6. User notified

## Testing

- Unit tests: `tests/Unit/Service/`, `tests/Unit/MessageHandler/`
- Integration: `tests/Integration/Repository/`
- Functional: `tests/Functional/Controller/`
- Coverage: 82% (target: 80%)

## Code Quality

- PHPStan: level max
- PHP CS Fixer: PSR-12 + Symfony rules
- Psalm: level 2
```

---

## Пов'язані команди

- `/plan` — планування реалізації
- `/review` — review коду

---

*Адаптовано з [Everything Claude Code](https://github.com/anthropics/claude-code) для PHP/Symfony*
