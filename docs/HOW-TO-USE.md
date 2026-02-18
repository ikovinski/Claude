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

### Крок 1: Переконайся що система встановлена

Виконай setup script:

```bash
# Перейди в директорію куди ти склонував систему
cd <path-to-cloned-repo>/ai-agents-system
chmod +x setup.sh
./setup.sh
```

Це створить:
- Symlink `~/.claude/ai-agents/` → твоя директорія з системою
- Оновить `~/.claude/CLAUDE.md` з інструкціями для Claude

### Крок 1.5: Або використовуй Slash Commands

Після встановлення доступні команди:

```bash
/plan "Add feature X"        # Planner agent + planning skills
/review src/file.php         # Code Reviewer + code-quality skills
/tdd "Service name"          # TDD Guide + tdd skills
/security-check src/Api/     # Security Reviewer + security skills
/skill-create                # Generate project skill
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

**Що це**: Переиспользовувані workflows та patterns, організовані по категоріях.

**Два типи:**
1. **Universal Skills** — для всіх проєктів (architecture, planning, security, etc.)
2. **Project Skills** — автогенеровані з git history конкретного проєкту

**Відмінність від агентів**: Skill — це "як робити", агент — це "з якої perspective дивитись".

**Структура:**

```
skills/
├── architecture/        # ADR templates, decision matrices
├── planning/            # Epic breakdown, vertical slicing
├── code-quality/        # Refactoring, test patterns
├── security/            # OWASP checks, security audit
├── tdd/                 # TDD workflow
├── risk-management/     # Risk assessment
└── {project}-patterns/  # Auto-generated (via /skill-create)
```

**Автоматичне завантаження:**
- Агент завантажує skills зі свого списку
- Система автоматично шукає project skill у поточній директорії
- Skills застосовуються до всіх операцій

**Приклад:**
```
Directory: ~/wellness-backend
Command: /plan "Add feature"

Loads:
→ planning/planning-template.md (universal)
→ wellness-backend-patterns/SKILL.md (project-specific)
```

**Файли**: `skills/*/`

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

## Як Працює Автоматичне Завантаження

### Loading Sequence

Коли ти викликаєш агента або команду:

```
1. Визначення агента
   ↓
   "Review this code" → Code Reviewer agent

2. Завантаження universal skills
   ↓
   Agent metadata: skills: [code-quality/*]
   Loads: refactoring-patterns.md, test-patterns.md

3. Пошук project skill
   ↓
   Current dir: ~/wellness-backend
   Looks for: ~/.claude/skills/wellness-backend-patterns/SKILL.md
   Status: ✓ Found → loads conventions

4. Застосування rules
   ↓
   Always applied: security, testing, coding-style, messaging, database

5. Виконання
   ↓
   Agent + Universal Skills + Project Skills + Rules
```

### Приклад: Feature Decomposition

```bash
cd ~/wellness-backend
"Decompose feature: Add workout sharing"
```

**Що завантажується:**

| Type | File | Why |
|------|------|-----|
| Agent | decomposer.md | Main persona |
| Universal Skill | planning/epic-breakdown.md | Decomposition methodology |
| Universal Skill | planning/vertical-slicing.md | Slicing technique |
| Project Skill | wellness-backend-patterns/SKILL.md | Project conventions |
| Rule | security.md | Health data rules |
| Rule | testing.md | Coverage requirements |

**Результат:**
- Slices слідують wellness-backend naming (з project skill)
- Vertical по архітектурі (з universal skill)
- З урахуванням health data security (з rules)

### Переваги Auto-Loading

✅ **Consistency** — завжди використовуються правильні patterns
✅ **Zero config** — працює одразу, без налаштувань
✅ **Project-aware** — адаптується до кожного проєкту
✅ **Extensible** — додав skill → він автоматично використовується

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

### Сценарій 4: Skills Auto-Loading

**Запит**:
```bash
cd ~/wellness-backend
/security-check src/Controller/Api/PaymentController.php
```

**Що відбувається**:
1. Claude завантажує Security Reviewer agent
2. Автоматично завантажує universal skills:
   - `skills/security/owasp-top-10.md`
   - `skills/security/security-audit-checklist.md`
3. Перевіряє чи є project skill:
   - Шукає `skills/wellness-backend-patterns/SKILL.md` ✓
   - Завантажує project conventions
4. Застосовує rules:
   - `rules/security.md` (PII/PHI protection)

**Очікуваний output**:
```
Security Review с використанням:
→ OWASP Top 10 checks
→ Project-specific patterns (wellness-backend)
→ Health data PII/PHI rules

## Findings

🔴 CRITICAL: SQL Injection risk [line 23]
Code: `$query = "SELECT * FROM payments WHERE id = " . $id;`
Project pattern: У wellness-backend завжди використовуйте prepared statements
Fix: Use $em->find() or parameterized query

🟡 WARNING: No input validation [line 15]
...
```

### Сценарій 5: Challenge рішення

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

### Створення нового universal skill

1. Вибрати категорію або створити нову:
   ```bash
   skills/
   ├── architecture/   # For ADR, design decisions
   ├── planning/       # For decomposition, estimates
   ├── security/       # For security checks
   └── your-category/  # New category
   ```

2. Створити skill file: `skills/{category}/{skill-name}.md`

3. Структура файлу:
   ```markdown
   # Skill Name

   ## Purpose
   What this skill does

   ## When to Use
   Specific scenarios

   ## Process
   Step-by-step workflow

   ## Output Format
   Expected deliverables

   ## Examples
   Real-world usage
   ```

4. Додати до агента який буде використовувати:
   ```yaml
   # agents/technical/your-agent.md
   skills:
     - your-category/your-skill
   ```

### Створення project skill (автоматично)

```bash
cd ~/your-project
/skill-create --commits 100
```

Аналізує:
- Commit messages → patterns
- Code structure → architecture
- File naming → conventions
- Tests → testing patterns

Генерує: `~/.claude/skills/{project}-patterns/SKILL.md`

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

### Slash Commands (Швидкі)

| Command | Що робить | Skills |
|---------|-----------|--------|
| `/plan "feature"` | Implementation plan | planning/* |
| `/review file.php` | Code review | code-quality/* |
| `/tdd "ServiceName"` | TDD workflow | tdd/* |
| `/security-check src/` | Security audit | security/* |
| `/skill-create` | Generate project skill | — |

### Природна мова (Гнучкі)

| Що хочу | Як сказати |
|---------|------------|
| Quick code check | "Швидко глянь на цей код" |
| Full review | "Детальний review з фокусом на security" |
| Break down task | "Розбий на таски по 1-3 дні" |
| Validate architecture | "Перевір чи це правильний підхід" |
| Find risks | "Що може піти не так?" |
| Compare options | "Порівняй варіанти A і B" |
| Decompose epic | "Decompose feature: [опис]" |
| Rewrite decision | "Should we rewrite [component]?" |

---

## Підтримка

Якщо щось не працює або потрібна допомога:
1. Перевір цей документ
2. Подивись приклади в агентах і скілах
3. Читай документацію:
   - [How Scenarios Work](docs/how-it-works/how-scenarios-work.md)
   - [Skills Integration](docs/skills-integration-summary.md)
   - [README.md](README.md) — загальний огляд
4. Запитай Claude про конкретну проблему

## Додаткова Документація

- **[README.md](README.md)** — System overview, installation, examples
- **[CLAUDE.md](CLAUDE.md)** — Quick reference, routing, biases
- **[docs/how-it-works/how-scenarios-work.md](docs/how-it-works/how-scenarios-work.md)** — Multi-agent workflows
- **[skills/README.md](skills/README.md)** — Skills system explained
- **[skills/skills-index.md](skills/skills-index.md)** — Complete skills catalog
- **[agents/README.md](agents/README.md)** — Agent biases overview
- **[commands/README.md](commands/README.md)** — Slash commands reference
