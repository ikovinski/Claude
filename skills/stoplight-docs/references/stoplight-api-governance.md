# Stoplight API Governance — Reference Guide

Зібрано з офіційної документації та блогу Stoplight для використання при проєктуванні, рев'ю та документуванні API.

## Що таке API Governance

API governance — практика застосування правил і політик до API: стандартизація описів, контрактів, дизайну, протоколів та якісних рев'ю по всьому портфелю API.

### Переваги

- Повторне використання компонентів, запобігання дублюванню
- Вирівнювання стейкхолдерів щодо цілей і дизайну
- Покращення discoverability API
- Зниження витрат, підвищення якості

## API Style Guide — що включити

### 1. Архітектурний стиль

Визначити підхід: REST, RPC, GraphQL, Hypermedia. Задокументувати, який стиль для яких use cases.

### 2. Формат опису API

Обрати стандарт: **OpenAPI 3.x** (рекомендовано), AsyncAPI, RAML. Усі API мають описуватись у machine-readable форматі.

### 3. Naming Conventions

| Елемент | Правило | Приклад |
|---------|---------|---------|
| URL paths | kebab-case | `/user-accounts` |
| Path parameters | camelCase | `{productId}` |
| Query parameters | camelCase | `?sortOrder=asc` |
| Ресурси | Множина (plural nouns) | `/users`, `/orders` |
| Ідентифікатори | Американська англійська, lowercase | — |
| Host | Тільки lowercase | `api.example.com` |

**Заборонено в URL:**
- Trailing slashes (`/users/`)
- Файлові розширення (`.json`, `.xml`)
- HTTP-дієслова в path (`/getUsers`)
- Спеціальні символи (`%20`, `&`, `+`)
- Query parameters в URI definition

### 4. Error Handling

Стандартизувати коди помилок та формат відповідей:
- Однаковий формат error response по всіх API
- Людино- та машиночитана інформація про помилку
- Чітке визначення: `400 Bad Request` vs `422 Unprocessable Entity`
- Приклад хорошої практики: Facebook Graph API error format з subcodes

### 5. Authentication & Authorization

- **Завжди HTTPS** (HTTP тільки для localhost)
- OAuth 2.0 — індустріальний стандарт
- Підтримувані схеми: OAuth2, JWT, OpenID Connect, Mutual TLS, API Keys
- Ніколи не HTTP Basic Auth
- UUID замість integer для ідентифікаторів
- Документувати security schemes через OpenAPI spec
- RBAC (Role-Based Access Control)

### 6. Versioning

- Включати тільки major version (`v1`, `v2`), без minor
- Обрати один підхід і дотримуватись:
  - URL-level: `api.example.com/v1`
  - Path-level: `/v1/products`
  - Header-based (version в headers)
- Не змішувати стратегії в одному API

## URL Structure

```
Protocol → Host → Path → Parameters
```

### Host conventions

Обрати одну конвенцію:
- **Path-based**: `domain.com/api`
- **Subdomain-based**: `api.domain.com`

### Path правила

- Обов'язковий `/status` endpoint для кожного API
- Path parameters визначати на рівні path, не operation
- Не використовувати цифри в parameter names

## Security Best Practices

Базується на OWASP Top 10 API Security Risks:

| Область | Рекомендація |
|---------|-------------|
| Шифрування | TLS/SSL для даних in transit та at rest |
| Input validation | Валідація та санітизація user input (SQL injection, XSS) |
| Rate limiting | Обмеження частоти запитів |
| WAF | Web Application Firewall для вхідного трафіку |
| Моніторинг | Безперервне спостереження, логування активності |
| Design-first | Залучення security-експертів на етапі проєктування |

## Design Review — три підходи

| Підхід | Плюси | Мінуси |
|--------|-------|--------|
| Manual | Бачить нюанси дизайну | Повільний, ресурсомісткий |
| Automated | Швидкий, послідовний | Без гнучкості |
| **Hybrid** (рекомендовано) | Швидкість + людська оцінка | Потребує налаштування |

## Enforcement — Spectral

[Spectral](https://stoplight.io/open-source/spectral) — open-source лінтер для API описів (ESLint для API).

### Де запускати

- **Design-time**: Stoplight Studio, VS Code, JetBrains IDE
- **CI/CD**: GitHub Actions, перевірка pull requests
- **Overrides**: Виключення для legacy API

### Публічні Style Guides

Компанії, що публікують свої API style guides як Spectral rulesets:
- Adidas, Azure, Box, DigitalOcean

### Формат правил

JSON/YAML конфігурація. Правила можуть перевіряти:
- Naming conventions для OpenAPI моделей
- Заборону integers в URL
- Наявність обов'язкових полів
- Формат error responses

## Компоненти програми governance

| Компонент | Опис |
|-----------|------|
| API Descriptions | Machine-readable формати (OpenAPI) + auto-generated docs |
| Style Guide | Архітектура, naming, error handling, auth |
| Central API Catalog | Пошуковий репозиторій для discovery та reuse |
| Reusable Components | Бібліотека headers, parameters, models |
| SLAs | Класифікація mission-critical API |
| Automation | Лінтери, mock API, auto-generated документація |

## Впровадження — покроковий план

1. **Визначити цілі та стейкхолдерів** — interview лідерів, API roadmap
2. **Створити API inventory** — документувати всі існуючі API, призначити ownership
3. **Дослідити API landscape** — формати, документація, security policies
4. **Стандартизувати термінологію** — однакові визначення по всій організації
5. **Створити style guide** — почати з ключових правил, розширювати поступово
6. **Автоматизувати enforcement** — Spectral, CI/CD integration
7. **Побудувати каталог** — centralized repository з можливістю пошуку

---

## Джерела

- [Get Started with API Governance](https://docs.stoplight.io/docs/api-best-practices/governance/get-started-with-governance)
- [How to Create a Successful API Governance Program](https://blog.stoplight.io/how-to-create-a-successful-api-governance-program)
- [API Style Guides & Best Practices](https://stoplight.io/api-style-guides-guidelines-and-best-practices)
- [Six Things to Include in Your API Style Guide](https://blog.stoplight.io/six-things-you-should-include-in-your-api-style-guide)
- [Automating API Design Guidelines](https://blog.stoplight.io/style-guides-rulebook-series-automating-api-design-guidelines)
- [Consistent API URLs with OpenAPI](https://blog.stoplight.io/consistent-api-urls-with-openapi-and-style-guides)
- [API Security Management Guide](https://blog.stoplight.io/api-security-management-guide)
- [Spectral Open Source](https://stoplight.io/open-source/spectral)
