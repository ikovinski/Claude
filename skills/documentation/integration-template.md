# Integration Template

Confluence-compatible. Бізнес-орієнтований формат.

## Template

```markdown
## [Назва Системи]

> Коротко призначення сторонньої системи

### Для чого

Для чого використовується дана інтеграція в контексті профілю системи.

### Актори

Основні учасники юз кейсів:
- {Актор 1}
- {Актор 2}

### Use Cases

- {Use case 1 — бізнесовий/продуктовий}
- {Use case 2}
- {Use case 3}

### Які дані

- {Дані що відправляємо}
- {Дані що отримуємо}

### Як інтегровано

**Тип**: HTTP API / Webhook / Messaging / File exchange / Shared DB

**API** (якщо релевантно): {Specific API name — Tax Calculation API, Payment API, CAPI etc.}

### Інтеграційні особливості

- {Особливість 1 — не очевидна з діаграм}
- {Особливість 2 — складна поведінка}
- {Особливість 3 — gotchas}
```

## Приклад: System Profile (Compact)

```markdown
# System Name

| | |
|---|---|
| **Stack** | PHP 8.3, Symfony, MySQL |
| **Owner** | Team |
| **Updated** | 2024-01-15 |

## Context

\`\`\`mermaid
flowchart LR
    User --> System --> External
\`\`\`

## Integrations

| Integration | Type | Status | Criticality |
|-------------|------|--------|-------------|
| Apple App Store | HTTP | Active | Critical |

## Open Questions

| ID | Question | Owner |
|----|----------|-------|
| OQ-1 | ? | @name |
```

## Приклад: Integration

```markdown
## Apple App Store

> Платформа дистрибуції iOS додатків та In-App Purchases

### Для чого

Валідація покупок підписок та одноразових покупок для iOS користувачів.

### Актори

- iOS користувачі (здійснюють покупки)
- Billing система (валідує receipts)
- Support команда (перевіряє статус підписок)

### Use Cases

- Валідація нової покупки підписки
- Перевірка статусу renewal
- Обробка refund notifications
- Відновлення покупок при переустановці

### Які дані

- Receipt data (відправляємо)
- Subscription status, expiration date (отримуємо)
- Server notifications про зміни статусу

### Як інтегровано

**Тип**: HTTP API + Webhook

**API**: App Store Server API v2, Server Notifications v2

### Інтеграційні особливості

- Sandbox vs Production endpoints — різні URL
- Receipt може містити кілька transactions — потрібно брати latest
- Server notifications можуть приходити з затримкою до 72 годин
- Потрібен retry механізм при 5xx відповідях
```

## Integration Categories

| Category | Examples |
|----------|----------|
| Payment | Apple App Store, Google Play, Stripe |
| Analytics | Amplitude, Mixpanel, Sentry |
| Marketing | Facebook CAPI, AppsFlyer, TikTok |
| Communication | Intercom, FCM, APNS |
| Infrastructure | AWS S3, CloudFront |
| Auth | Facebook, Google, Apple Sign-In |
| Internal | Web Backend, Email Service |
