# QA Checklist — Посібник

Генерація структурованого QA-чеклісту з опису фічі будь-якого формату.

## Що це таке

Один агент (QA Engineer) читає опис фічі, обирає відповідні техніки тест-дизайну і генерує конкретний чеклист з перевірками та очікуваними результатами:

```
Feature Description → Read Sources → Analyze → Select Techniques → Generate Checklist → Quality Gate → .workflows/{id}/qa/checklist.md
```

Агент **не пише тести і не фіксить баги**. Він генерує перевірки, які може виконати будь-який QA або розробник.

## Передумови

Не потребує Agent Teams. Агент (`qa-engineer.md`) має бути встановлений через `install.sh`.

## Швидкий старт

```bash
# PDF специфікація
/qa-checklist path/to/feature.pdf

# Зображення (wireframes, mockups, screenshots)
/qa-checklist mockup.png flow-diagram.jpg

# URL (Confluence, Notion, GitHub issue)
/qa-checklist https://confluence.example.com/feature-description

# Inline текст
/qa-checklist "Юзер може завантажити аватар. Формати: JPG, PNG. Макс розмір: 5MB."

# Комбінація джерел з явним feature-id
/qa-checklist --id payment-refund spec.pdf flow-diagram.png https://jira.example.com/PROJ-123

# Кілька файлів
/qa-checklist spec.pdf mockup.png notes.md
```

| Параметр | Обов'язковий | Опис |
|----------|-------------|------|
| файли / URL / текст | Так (хоча б один) | Джерела опису фічі |
| `--id {name}` | Ні | Feature ID для іменування output (інакше — автоматично з назви) |

---

## Підтримувані формати вводу

| Формат | Як читає | Примітки |
|--------|----------|----------|
| `.pdf` | `Read` (нативна підтримка Claude) | Включно з таблицями та схемами |
| `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif` | `Read` (Claude vision) | Бачить UI, витягує сценарії з wireframes |
| `.md`, `.txt` | `Read` | Plain text |
| URL | `WebFetch` | Confluence, Notion, GitHub, Jira |
| Inline текст | Напряму з аргументу | Для швидких чеклістів |

Можна передати **кілька джерел одночасно** — агент синтезує їх в єдиний чеклист.

---

## Повний процес крок за кроком

### Крок 1: Parse Arguments

Команда визначає:
- `--id {name}` → feature-id (або автогенерація kebab-case з назви файлу/тексту)
- Шляхи до файлів (абсолютні або відносні від CWD)
- URL (починаються з `http://` або `https://`)
- Inline текст (все інше)

---

### Крок 2: Read Sources

Читає всі вхідні джерела + опціонально `docs/` для контексту існуючих фіч. Якщо файл не знайдено або URL не відповідає — фіксує у секції `## Warnings` і продовжує з доступними даними.

---

### Крок 3: Detect Platform

Чеклист генерується для **однієї** платформи: iOS / Android / Backend. Якщо платформа неочевидна — запитує у користувача.

> Якщо фіча охоплює кілька платформ — запустіть `/qa-checklist` окремо для кожної.

---

### Крок 4: QA Engineer — Аналіз фічі

Агент виділяє з матеріалу:

| Що шукає | Навіщо |
|----------|--------|
| Основний функціонал | Scope чеклісту |
| Дійові особи (ролі) | Різні сценарії по ролях |
| Happy path | Базові перевірки |
| Граничні умови | BVA / EP кандидати |
| Суміжний функціонал | Регресійні ризики |
| Технічні деталі | API / DB перевірки |

Якщо опис **неповний або неоднозначний** — фіксує питання у `## Open Questions`. Не вигадує бізнес-логіку.

---

### Крок 5: QA Engineer — Вибір технік тест-дизайну

Агент обирає техніки за матрицею — **не всі, а тільки релевантні**:

| Фіча містить | Техніка |
|-------------|---------|
| Групи інпутів з однаковим результатом / діапазони / розміри файлів | Equivalence Partitioning (EP) |
| Діапазони з лімітами для числових значень / довжини | Boundary Value Analysis (BVA) |
| Кілька умов що впливають на результат / бізнес-правила | Decision Table |
| Багатокроковий flow зі статусами (замовлення, підписка, auth) | State Transition |
| Багато значень для параметрів / комбінації > 2 параметрів / форми > 2 полів | Pairwise |

**Завжди застосовуються** (якщо доречно): Error Guessing, Checklist-based Testing.

Checklist-based Testing включає **pre-defined чеклісти** за платформою (iOS/Android apps testing, API testing, A/B testing) — визначаються правилом `qa-checklist-selection`.

---

### Крок 6: QA Engineer — Генерація чеклісту

Чеклист структурується за **блоками** (функціонал, скрін, API ендпоінт). Кожен пункт:
- Конкретна дія (не "перевірити форму", а "ввести email без @, натиснути Submit")
- Очікуваний результат після дії

---

### Крок 7: Quality Gate

Після генерації Claude виступає як **QA Team Lead** і перевіряє результат:
- Правильні техніки обрані для типу фічі?
- Обов'язкові Checklist-based Testing перевірки включені?
- Кожна перевірка конкретна і actionable?
- Expected result присутній для кожної перевірки?

Якщо є зауваження — повертає QA Engineer з конкретним фідбеком. Повторює до затвердження.

---

### Крок 8: Save & Report

Зберігає у `.workflows/{feature-id}/qa/checklist.md` і виводить:

```
# QA Checklist Ready: {feature-id}

**File:** .workflows/{feature-id}/qa/checklist.md
**Total checks:** N
**Test Design Techniques:** EP, BVA, Decision Table, Error Guessing, Checklist-based Testing
**Open Questions:** N — перевір перед початком тестування
```

---

## Де шукати результат

```
.workflows/{feature-id}/qa/
└── checklist.md
```

---

## Формат чеклісту

```markdown
# QA Checklist: {Feature Name}

**Feature ID:** {feature-id}

## Summary
{2-4 речення: що робить фіча, хто використовує, головний QA-ризик}

## Checklist

### {Блок 1: назва функціоналу/скріна}

- [ ] {Конкретна дія} → {Очікуваний результат}
- [ ] {Конкретна дія} → {Очікуваний результат}

### {Блок 2}

- [ ] ...

## Open Questions
1. {Питання до BA/PO}

## Warnings
- {Файл не знайдено / формат не підтримується}
```

---

## Компоненти

| Компонент | Значення |
|-----------|----------|
| Команда | `commands/qa-checklist.md` |
| Агент | `agents/engineering/qa-engineer.md` (sonnet) |
| Rules | language, qa-checklist-selection |
| Skills | test-design-techniques, auto:{project}-patterns |

---

## Поради

1. **Більше джерел = кращий чеклист.** PDF + mockups + URL дає повніший scope ніж тільки текст. Агент синтезує всі джерела разом.

2. **Open Questions — не баг, а фіча.** Якщо опис неповний, агент не вигадує. Він ставить питання. Відповідайте на них і перезапускайте.

3. **Одна платформа за раз.** iOS і Android можуть мати різні edge cases. Краще два чеклісти по 30 перевірок ніж один на 60 зі змішаними платформами.

4. **Використовуйте `--id` для консистентності.** Якщо фіча вже має feature-id з `/feature` flow — передайте його щоб чеклист зберігся в правильну директорію.

5. **Pre-defined чеклісти додаються автоматично.** За правилом `qa-checklist-selection` — для iOS/Android додаються platform-specific перевірки, для Backend — API testing, для A/B тестів — відповідний pre-defined чеклист.

6. **Агент бачить зображення.** Wireframes, mockups, screenshots читаються нативно через Claude vision. Агент витягує UI-сценарії прямо з картинки.

---

## Коли використовувати

| Ситуація | Причина |
|----------|---------|
| Нова фіча перед тестуванням | Структурований QA scope замість ad-hoc |
| Отримали PDF/mockup від PM | Швидко перетворити на actionable перевірки |
| Regression planning | Зрозуміти що може зламатись |
| Перед релізом | Чеклист для smoke/sanity testing |
| Після `/design` або `/implement` | Доповнити test-strategy конкретними manual checks |

---

## Різниця між `/qa-checklist` та test-strategy (у `/design`)

| Аспект | `/qa-checklist` | test-strategy |
|--------|----------------|---------------|
| Фокус | Manual QA перевірки | Автоматизовані тести + стратегія |
| Формат | Чеклист з конкретними кроками | План: unit/integration/e2e розподіл |
| Хто виконує | QA або розробник вручну | CI/CD автоматично |
| Коли | Перед manual testing | Під час Design фази |
| Агент | QA Engineer | Test Strategist |
| Техніки | EP, BVA, Decision Table, State Transition, Pairwise, Error Guessing, Checklist-based | Coverage expectations, test doubles strategy |
