# README Template

## Purpose
Create service/project overview documentation for quick orientation.

## Audience
- **New team members**: Getting started quickly
- **Other teams**: Understanding what this service does
- **Future self**: Remembering setup after 6 months

---

## Service README Template

```markdown
# {Service Name}

{One-line description of what this service does.}

## Quick Links

| Resource | Link |
|----------|------|
| API Docs | [Stoplight]({link}) |
| Dashboard | [Grafana]({link}) |
| Logs | [Datadog]({link}) |
| CI/CD | [GitHub Actions]({link}) |
| Runbook | [Runbook](docs/runbook.md) |

## What This Service Does

{2-3 sentences explaining the business purpose. What problem does it solve?
Who are the users? What's the main functionality?}

### Key Features

- **{Feature 1}**: {Brief description}
- **{Feature 2}**: {Brief description}
- **{Feature 3}**: {Brief description}

### What This Service Does NOT Do

- {Thing people might assume but is handled elsewhere}
- {Out of scope functionality}

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│  This API   │────▶│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                    ┌──────┴──────┐
                    ▼             ▼
              ┌──────────┐  ┌──────────┐
              │ Service A │  │ Service B │
              └──────────┘  └──────────┘
```

### Tech Stack

| Component | Technology |
|-----------|------------|
| Language | PHP 8.3 |
| Framework | Symfony 6.4 |
| Database | MySQL 8.0 |
| Cache | Redis 7.x |
| Queue | RabbitMQ |
| Search | Elasticsearch 8.x |

### Dependencies

| Service | Purpose | Required? |
|---------|---------|-----------|
| {Service A} | {What we use it for} | Yes |
| {Service B} | {What we use it for} | No (graceful degradation) |

## Getting Started

### Prerequisites

- PHP 8.3+
- Composer
- Docker & Docker Compose
- Make (optional)

### Local Setup

```bash
# Clone repository
git clone {repo-url}
cd {service-name}

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Start dependencies (database, redis, etc.)
docker-compose up -d

# Run migrations
php bin/console doctrine:migrations:migrate

# Start development server
symfony serve
# or
php -S localhost:8000 -t public/
```

### Verify Setup

```bash
# Health check
curl http://localhost:8000/health

# Run tests
composer test

# Run static analysis
composer phpstan
```

## Development

### Project Structure

```
src/
├── Controller/      # API endpoints
├── Entity/          # Doctrine entities
├── Repository/      # Database queries
├── Service/         # Business logic
├── Message/         # Async message definitions
├── MessageHandler/  # Async message handlers
└── DTO/             # Data Transfer Objects
```

### Key Commands

```bash
# Run tests
composer test

# Run tests with coverage
composer test:coverage

# Static analysis
composer phpstan

# Code style fix
composer cs:fix

# All checks (pre-commit)
composer check
```

### Adding a New Feature

1. Create feature branch from `main`
2. Write tests first (TDD)
3. Implement feature
4. Run `composer check`
5. Create PR with description

## API Overview

### Base URL

| Environment | URL |
|-------------|-----|
| Local | `http://localhost:8000` |
| Staging | `https://api.staging.example.com` |
| Production | `https://api.example.com` |

### Authentication

All endpoints require Bearer token:

```bash
curl -H "Authorization: Bearer {token}" https://api.example.com/v1/resource
```

### Main Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/resources` | List resources |
| POST | `/v1/resources` | Create resource |
| GET | `/v1/resources/{id}` | Get single resource |
| PUT | `/v1/resources/{id}` | Update resource |
| DELETE | `/v1/resources/{id}` | Delete resource |

**Full API documentation**: [Stoplight]({link})

## Configuration

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `DATABASE_URL` | MySQL connection string | Yes | - |
| `REDIS_URL` | Redis connection string | Yes | - |
| `APP_ENV` | Environment (dev/prod) | No | `dev` |
| `LOG_LEVEL` | Logging verbosity | No | `info` |

### Feature Flags

| Flag | Description | Default |
|------|-------------|---------|
| `FEATURE_X_ENABLED` | Enable feature X | `false` |

## Testing

### Running Tests

```bash
# All tests
composer test

# Specific test file
php bin/phpunit tests/Unit/Service/MyServiceTest.php

# Specific test method
php bin/phpunit --filter testMethodName

# With coverage report
composer test:coverage
# Coverage report: coverage/index.html
```

### Test Categories

| Type | Directory | Purpose |
|------|-----------|---------|
| Unit | `tests/Unit/` | Isolated logic tests |
| Integration | `tests/Integration/` | Database, external services |
| Functional | `tests/Functional/` | API endpoints |

## Deployment

### CI/CD Pipeline

```
Push to main → Tests → Build → Deploy to Staging → Deploy to Production
                ↓
            (on PR) → Tests only
```

### Manual Deployment

```bash
# Deploy to staging
./deploy.sh staging

# Deploy to production (requires approval)
./deploy.sh production
```

### Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/{service}
```

## Monitoring

### Health Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/health/live` | K8s liveness probe |
| `/health/ready` | K8s readiness probe |

### Key Metrics

- **Response time P95**: < 200ms
- **Error rate**: < 0.1%
- **Availability**: 99.9%

### Alerts

| Alert | Threshold | Action |
|-------|-----------|--------|
| High Error Rate | > 1% for 5 min | Check logs |
| High Latency | P95 > 500ms | Check DB |

## Troubleshooting

### Common Issues

**Database connection failed**
```bash
# Check if database is running
docker-compose ps

# Check connection string in .env
grep DATABASE_URL .env
```

**Tests failing on fresh clone**
```bash
# Ensure test database exists
php bin/console doctrine:database:create --env=test
php bin/console doctrine:migrations:migrate --env=test
```

**Out of memory during tests**
```bash
# Increase PHP memory limit
php -d memory_limit=512M bin/phpunit
```

## Contributing

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes with tests
3. Run checks: `composer check`
4. Push and create PR
5. Request review from team

### Code Style

- PSR-12 coding standard
- PHPStan level max
- Tests required for new features

## Team

| Role | Contact |
|------|---------|
| Team Lead | @{name} |
| On-call | [PagerDuty]({link}) |
| Slack | #{channel} |

## License

{License type} - see [LICENSE](LICENSE) for details.
```

---

## Minimal README (for internal tools)

```markdown
# {Tool Name}

{One sentence description.}

## Setup

```bash
composer install
cp .env.example .env
# Edit .env with your values
```

## Usage

```bash
php bin/console app:command --option=value
```

## Commands

| Command | Description |
|---------|-------------|
| `app:import` | Import data from X |
| `app:export` | Export data to Y |

## Contact

@{owner} in #{channel}
```

---

## Checklist

Before committing README:

- [ ] One-line description clear and accurate
- [ ] Quick links all working
- [ ] Setup instructions tested on clean environment
- [ ] API overview matches actual endpoints
- [ ] Environment variables documented
- [ ] No secrets or credentials included
- [ ] Contact information current
