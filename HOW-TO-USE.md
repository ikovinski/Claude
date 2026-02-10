# Як користуватися AI Agents System

Детальний гайд для роботи з системою агентів.

## Зміст

1. [Швидкий старт](#швидкий-старт)
2. [Концепції](#концепції)
3. [Сценарії використання](#сценарії-використання)
4. [Налаштування](#налаштування)
5. [Розширення системи](#розширення-системи)

---

## Швидкий старт

### Крок 1: Переконайся що CLAUDE.md підключений

У твоєму `~/.claude/CLAUDE.md` має бути посилання на систему:

```markdown
# Global Claude Instructions

## AI Agents System

I have access to a library of specialized agents at `~/repo/ai-agents-system/`.

When appropriate, I should read and apply agents from this library:

- **Code reviews** → read `~/repo/ai-agents-system/skills/engineering/code-review.md`
- **Architecture decisions** → read `~/repo/ai-agents-system/agents/technical/staff-engineer.md`
- **Task breakdown** → read `~/repo/ai-agents-system/agents/technical/decomposer.md`
- **Challenging decisions** → read `~/repo/ai-agents-system/agents/facilitation/devils-advocate.md`

When using an agent, announce: "Applying [Agent Name] perspective with bias: [main bias]"
```

### Крок 2: Просто пиши запити

Система автоматично визначає який агент потрібен:

```
Ти: "Зроби review цього коду: [код]"
Claude: "Applying Code Reviewer perspective with bias: Maintainability > cleverness"
        [структурований review]

Ти: "Декомпозуй фічу: додати шейринг тренувань"
Claude: "Applying Decomposer perspective with bias: Vertical slices > horizontal layers"
        [розбивка на слайси]
```

---

## Концепції

### Агенти (Agents)

**Що це**: AI-персони зі специфічними biases (упередженнями), які визначають їх perspective.

**Чому biases важливі**: Без biases всі агенти давали б generic відповіді. Biases роблять кожного агента цінним для конкретної задачі.

| Агент | Головний bias | Коли використовувати |
|-------|---------------|---------------------|
| Code Reviewer | Maintainability > cleverness | Перевірка коду перед merge |
| Decomposer | Vertical slices > horizontal layers | Розбивка великих задач |
| Staff Engineer | Boring technology wins | Архітектурні рішення |
| Devil's Advocate | Assume nothing works | Перевірка рішень на міцність |

**Файли**: `agents/technical/`, `agents/facilitation/`

### Скіли (Skills)

**Що це**: Переиспользовувані workflow для конкретних задач.

**Відмінність від агентів**: Скіл — це "як робити", агент — це "з якої perspective дивитись".

| Скіл | Що робить |
|------|-----------|
| code-review | Структура review, checklist, output format |
| task-decomposition | Процес розбивки, критерії slice, DoD |

**Файли**: `skills/engineering/`

### Сценарії (Scenarios)

**Що це**: Багатокрокові процеси, що використовують декілька агентів.

**Приклад**: Feature Decomposition сценарій:
1. Phase 1 (Decomposer): Зрозуміти scope
2. Phase 2 (Decomposer): Розбити на slices
3. Phase 3 (Staff Engineer): Validate технічно
4. Phase 4 (Decomposer): Фіналізувати

**Файли**: `scenarios/delivery/`, `scenarios/technical-decisions/`

### Правила (Rules)

**Що це**: Завжди-активні guidelines, які застосовуються автоматично.

| Правило | Що регулює |
|---------|------------|
| security.md | PII/PHI захист, auth, encryption |
| testing.md | Coverage вимоги, test patterns |
| coding-style.md | PHP 8.3, Symfony 6.4 стандарти |
| messaging.md | RabbitMQ/Kafka idempotency |
| database.md | N+1, transactions, migrations |

**Файли**: `rules/`

### Контексти (Contexts)

**Що це**: Режими фокусування для різних типів роботи.

| Контекст | Фокус |
|----------|-------|
| dev.md | Написання коду, implementation |
| review.md | Пошук проблем, безпека |
| research.md | Дослідження, розуміння |
| planning.md | Декомпозиція, стратегія |

**Як використовувати**: Можна завантажити контекст для focused роботи:
```
Ти: "Переключись в review mode і подивись на цей код"
```

**Файли**: `contexts/`

### Хуки (Hooks)

**Що це**: Автоматичні тригери на події Claude Code.

**Приклади**:
- Перед `git push` — підтвердження
- Після редагування `.php` — запуск PHP CS Fixer
- При створенні migration — нагадування про безпеку

**Файли**: `hooks/hooks.json`

---

## Сценарії використання

### Сценарій 1: Code Review

**Запит**:
```
Зроби review цього коду:

#[AsMessageHandler]
class SyncWorkoutHandler
{
    public function __construct(
        private EntityManagerInterface $em,
        private WorkoutApiClient $apiClient,
    ) {}

    public function __invoke(SyncWorkoutMessage $message): void
    {
        $user = $this->em->find(User::class, $message->userId);
        $workouts = $this->apiClient->getWorkouts($user->getExternalToken());

        foreach ($workouts as $workout) {
            $entity = new Workout();
            $entity->setUser($user);
            $entity->setData($workout);
            $this->em->persist($entity);
        }

        $this->em->flush();
    }
}

Контекст: Message handler для синхронізації тренувань з external API
```

**Що відбувається**:
1. Claude читає `agents/technical/code-reviewer.md`
2. Застосовує biases (maintainability, production-first, etc.)
3. Видає структурований output (Summary, Blocking Issues, Suggestions, etc.)

**Очікуваний output**:
```
Applying Code Reviewer perspective with bias: Maintainability > cleverness

## Summary
Функціональний handler, але missing critical error handling та idempotency.

## Blocking Issues 🚫
1. **No null check for User** [line 12]
   - Why: User може бути deleted...
   - Fix: ...

2. **No error handling for API call** [line 13]
   ...
```

### Сценарій 2: Декомпозиція фічі

**Запит**:
```
Декомпозуй фічу:

"Додати систему нотифікацій для subscription events через Kafka"

Контекст:
- У нас є RabbitMQ для internal messaging
- Kafka налаштований, але не використовується для цього
- Команда: 5 developers
- Sprint: 2 тижні
```

**Що відбувається**:
1. Claude читає `scenarios/delivery/feature-decomposition.md`
2. Проходить через 4 фази (Scope → Decomposition → Validation → Final)
3. На кожній фазі показує output і питає про продовження

**Очікуваний output (скорочено)**:
```
Applying Decomposer perspective with bias: Vertical slices > horizontal layers

## Phase 1: Scope Understanding

### Core Value
Who: Operations team + users
Gets: Real-time notifications about subscription changes
Benefit: Faster response to issues, better user experience

### Clarifying Questions
1. Які саме events потрібно відправляти?
2. Хто consumer цих events?
...

Продовжити до Phase 2? [Yes/No]
```

### Сценарій 3: Архітектурне рішення

**Запит**:
```
Архітектурне рішення:

Ми розглядаємо перехід на event sourcing для subscription management.
Поточна система: Doctrine entities з audit log через listeners.
Проблема: Складно відновити історію змін для debugging.

Що думаєш?
```

**Що відбувається**:
1. Claude читає `agents/technical/staff-engineer.md`
2. Застосовує biases (boring technology wins, reversibility over perfection)
3. Видає аналіз з options і recommendation

### Сценарій 4: Challenge рішення

**Запит**:
```
Ми вирішили переписати billing module з нуля замість рефакторингу.
Причини: поточний код важко підтримувати, багато legacy.

Challenge це рішення.
```

**Що відбувається**:
1. Claude читає `agents/facilitation/devils-advocate.md`
2. Застосовує biases (assume nothing works, question consensus)
3. Знаходить assumptions для challenge, failure scenarios, pre-mortem

---

## Налаштування

### Зміна domain context

Всі агенти калібровані для wellness/fitness tech + PHP/Symfony. Щоб змінити:

1. Оновити domain context в кожному агенті (`agents/*/`)
2. Оновити tech stack в `rules/coding-style.md`
3. Оновити приклади в `skills/`

### Додавання нових rules

1. Створити файл в `rules/`:
```markdown
# New Rule Name

## What This Covers
...

## Requirements
...

## Code Examples
...

## Checklist
- [ ] Item 1
- [ ] Item 2
```

2. Додати до routing table в `CLAUDE.md`

3. Додати до frontmatter відповідних агентів:
```yaml
rules:
  - security
  - testing
  - your-new-rule  # Add here
```

### Налаштування hooks

Відредагувати `hooks/hooks.json`:

```json
{
  "event": "PreToolUse",
  "matcher": "tool == 'Bash' && command matches 'your-pattern'",
  "action": {
    "type": "confirm",
    "message": "Your confirmation message"
  }
}
```

---

## Розширення системи

### Створення нового агента

1. Скопіювати template: `templates/agent-template.md`

2. Заповнити:
   - **Frontmatter**: name, tools, model, triggers, rules
   - **Identity**: Role, Background, Core Responsibility
   - **Biases**: Primary (3-4), Secondary (3-4), Anti-biases
   - **Expertise Areas**: Primary, Secondary, Domain Context
   - **Communication Style**: Tone, Language Patterns, Response Structure
   - **Prompt Template**: Ready-to-use prompt

3. Додати до routing table в `CLAUDE.md`

### Створення нового сценарію

1. Скопіювати template: `templates/scenario-template.md`

2. Заповнити:
   - **Metadata**: participants, duration, triggers
   - **Situation**: Description, Common Triggers
   - **Participants**: Required, Optional agents
   - **Process Flow**: Phases with leads and outputs
   - **Decision Points**: Choices to make during scenario
   - **Prompts Sequence**: Specific prompts for each step

3. Додати до routing table в `CLAUDE.md`

### Створення нового скілу

1. Скопіювати template: `templates/skill-template.md`

2. Заповнити:
   - **Metadata**: complexity, time_estimate, requires_context
   - **Purpose**: What it does
   - **When to Use / NOT to Use**
   - **Prompt**: Ready-to-use prompt with placeholders
   - **Quality Bar**: Must Have, Should Have, Nice to Have
   - **Examples**: Input/Output pairs

3. Додати до routing table в `CLAUDE.md`

---

## Troubleshooting

### "Агент не застосовується"

Перевір:
1. Чи є посилання на систему в `~/.claude/CLAUDE.md`
2. Чи співпадає trigger pattern з твоїм запитом
3. Чи правильний шлях до файлу агента

### "Output не структурований"

Агент має мати секцію **Output Format** з конкретним template. Перевір що ця секція присутня і що Claude її читає.

### "Biases не застосовуються"

Biases мають бути:
1. Явно перелічені в агенті
2. Згадані в prompt template
3. Показані в анонсі ("Applying X with bias: Y")

### "Hooks не працюють"

Перевір:
1. JSON syntax в `hooks/hooks.json`
2. Regex escaping (`\\.` для literal dot)
3. Matcher conditions (tool name, path pattern)

---

## Приклади prompt'ів

### Code Review
```
Зроби review цього коду:
[код]
Контекст: [що цей код робить]
Scope: full | security | performance | quick
```

### Декомпозиція
```
Декомпозуй фічу:
[опис фічі]
Контекст:
- Команда: [розмір]
- Sprint: [довжина]
- Існуюча система: [що вже є]
```

### Архітектура
```
Архітектурне рішення:
Проблема: [опис]
Варіанти які розглядаємо: [список]
Constraints: [обмеження]
```

### Challenge
```
Challenge це рішення:
[опис рішення]
Причини: [чому так вирішили]
Stakes: [що втратимо якщо помилимось]
```

---

## Корисні команди

| Що хочу | Як сказати |
|---------|------------|
| Quick code check | "Швидко глянь на цей код" |
| Full review | "Детальний review з фокусом на security" |
| Break down task | "Розбий на таски по 1-3 дні" |
| Validate architecture | "Перевір чи це правильний підхід" |
| Find risks | "Що може піти не так?" |
| Compare options | "Порівняй варіанти A і B" |

---

## Підтримка

Якщо щось не працює або потрібна допомога:
1. Перевір цей документ
2. Подивись приклади в агентах і скілах
3. Запитай Claude про конкретну проблему
