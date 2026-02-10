# Rules

## What is it
Обов'язкові правила для конкретних технологічних стеків. Rules застосовуються автоматично коли релевантні та визначають стандарти коду, вимоги безпеки та best practices.

## How to use
Rules завантажуються автоматично на основі контексту проєкту:

```
PHP/Symfony project → security, testing, coding-style, messaging, database rules
```

Rules потрібно перевіряти перед:
- Написанням нового коду
- Review існуючого коду
- Прийняттям архітектурних рішень

## Expected result
- Консистентна якість коду по всьому проєкту
- Дотримання security best practices
- Використання технологічно-специфічних патернів

## Available rules

| Rule | Purpose |
|------|---------|
| `security` | Захист PII/PHI, auth, encryption |
| `testing` | Вимоги до coverage, тестові патерни |
| `coding-style` | Стандарти PHP 8.3, Symfony 6.4 |
| `messaging` | Патерни RabbitMQ/Kafka, idempotency |
| `database` | Doctrine ORM, запобігання N+1, міграції |
