---
name: bodyfit-engine-mobile-patterns
description: Coding patterns extracted from bodyfit-engine-mobile (MadMuscles/Unimeal backend)
version: 1.0.0
source: local-git-analysis
analyzed_commits: 100
tech_stack: PHP 8.3, Symfony 6.4, Doctrine ORM 2.14, RabbitMQ (AMQP)
---

# Bodyfit Engine Mobile Patterns

## Commit Conventions

Project uses **Jira ticket prefix** with optional conventional commit type:

```
{TICKET-ID}: {description}
{TICKET-ID} | {type}({scope}): {description}
```

### Prefixes
| Prefix | Team/Area |
|--------|-----------|
| `MA-` | MadMuscles features |
| `UA-` | Unimeal features |
| `PT-` | Platform/Infrastructure |
| `IUM-` | In-app/Billing |

### Examples
- `MA-2059: Add MyProgramPathAvailabilityChecker`
- `MA-2161 | docs(ci): document each workflow group`
- `UA-1498: Fixes according to code review`
- `PT-4631: Migrate bodyfit GitHub Actions to self-hosted runners`

## Code Architecture

```
code/src/
├── API/                    # API layer
│   ├── Resource/           # API resources and DTOs
│   │   ├── DTO/            # Request/Response DTOs
│   │   └── DataTransformer/ # DTO transformers
│   └── Response/           # Response formatters
├── Application/            # Application layer
│   └── UseCase/            # Use cases (MadMuscles, Unimeal)
├── Controller/             # Controllers
│   ├── API/                # API controllers
│   └── Admin/              # EasyAdmin controllers
├── Domain/                 # Domain layer (DDD)
│   ├── Entity/             # Domain entities
│   ├── Event/              # Domain events
│   ├── Message/            # Domain messages
│   ├── Service/            # Domain services
│   ├── Repository/         # Repository interfaces
│   ├── Specification/      # Specifications
│   └── ValueObject/        # Value objects
├── Entity/                 # Doctrine entities (legacy)
├── Form/                   # Form types and DTOs
│   └── DTO/                # Form DTOs
├── Infrastructure/         # Infrastructure layer
├── Integration/            # External integrations
│   └── */Handler/          # Integration event handlers
├── Message/                # Async messages (Messenger)
├── Module/                 # Bounded contexts (ChatBot, etc.)
├── Repository/             # Doctrine repositories
├── Service/                # Application services
└── ValueObject/            # Value objects (shared)
```

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Controller | `{Entity}Controller` / `{Entity}CrudController` | `WorkoutProgramCrudController` |
| Service | `{Domain}{Action}Service` | `FeatureAvailabilityService` |
| UseCase | `{Action}{Entity}UseCase` | `CompleteWorkoutUseCase` |
| Repository | `{Entity}Repository` | `UserEventRepository` |
| Checker | `{Feature}AvailabilityChecker` | `MyProgramPathAvailabilityChecker` |
| Interface | `{Name}Interface` | `FeatureNameAwareAvailabilityCheckerInterface` |
| Message | `{Action}{Entity}Message` | `AsyncTaskMessage` |
| Handler | `{Action}{Entity}Handler` | `OrderEventHandler` |
| DTO | `{Purpose}DTO` / `{Purpose}Resource` | `UserMobilePropertiesResource` |
| Enum | `{Entity}Enum` | `FeatureEnum`, `DietTypeEnum` |
| Test | `{ClassName}Test` | `MyProgramPathAvailabilityCheckerTest` |

## Code Style

### PHP Class Structure
```php
<?php

declare(strict_types=1);

namespace App\Domain\Service\FeatureAvailability\Checker;

use App\Domain\Entity\Feature\FeatureEnum;
use App\Domain\Entity\User\User;

readonly class MyProgramPathAvailabilityChecker implements FeatureNameAwareAvailabilityCheckerInterface
{
    private const SPLIT_NAME = 'mm_my_program_path_android';

    public function __construct(
        private SplitRepository $splitRepository,
        private UserEventRepository $userEventRepository,
    ) {
    }

    public function supports(FeatureEnum $feature): bool
    {
        return $feature->value === FeatureEnum::MM_MY_PROGRAM_PATH_AVAILABLE->value;
    }

    public function getResult(User $user): bool
    {
        // Implementation
    }
}
```

### Key Patterns
- Use `readonly` classes where applicable
- Constructor property promotion
- `declare(strict_types=1);` always
- Private constants for configuration
- Interface suffix: `Interface`

## Common Workflows

### Adding New Feature Availability Checker
1. Create checker in `src/Domain/Service/FeatureAvailability/Checker/`
2. Implement `FeatureNameAwareAvailabilityCheckerInterface`
3. Add `supports()` method for feature enum
4. Add `getResult()` method with business logic
5. Add feature enum value in `FeatureEnum.php`
6. Register in `config/services/feature_availability.yaml`
7. Write unit test in `tests/Unit/Domain/Service/FeatureAvailability/`

### Adding A/B Test (Split Test)
1. Create migration with split configuration:
   ```php
   // src/Migrations/Version{timestamp}.php
   ```
2. Update split pipeline YAML:
   ```yaml
   # config/split_pipeline/pipeline.mad_muscles.*.yaml
   ```
3. Add user event type if needed in `UserEventType.php`
4. Implement checker/service logic

### Adding User Property
1. Add property to `MadMusclesUserPropertiesInterface`
2. Implement in `MadMusclesUserProperties` value object
3. Update `MadMusclesPropertiesAggregator` service
4. Update `UserMobilePropertiesResource` DTO
5. Update `UserMobilePropertiesTransformer`
6. Update test fixtures and JSON resources

### Database Changes (Doctrine)
1. Update Entity class with new fields/relations
2. Generate migration: `bin/console make:migration`
3. Review generated SQL in migration file
4. Run migration: `bin/console doctrine:migrations:migrate`
5. Update Repository if custom queries needed

## Testing Patterns

### Structure
```
code/tests/
├── Unit/                   # Fast, isolated unit tests
│   ├── Domain/Service/     # Domain service tests
│   └── Service/            # Application service tests
├── Integration/            # Tests with real dependencies
│   ├── Repository/         # Database tests
│   └── Service/            # Service integration tests
├── Functional/             # API/Controller tests
│   └── API/                # HTTP request tests
└── Fixtures/               # Test data factories
    └── Factory/            # Foundry factories
```

### Test Naming
```php
public function test{Action}{Condition}{ExpectedResult}(): void
{
    // testResultFalseBecauseOfInactiveTest
    // testResultFalseBecauseUserAlreadyFinishedPath
    // testResultTrue
}
```

### Test Structure (Arrange-Act-Assert)
```php
public function testResultFalseBecauseOfInactiveTest(): void
{
    // Arrange
    $split = $this->createMock(Split::class);
    $split->expects($this->once())->method('isEnabled')->willReturn(false);
    $this->splitRepository->expects($this->once())->method('findOneByName')->willReturn($split);

    // Act
    $result = $this->checker->getResult($this->createMock(User::class));

    // Assert
    $this->assertFalse($result);
}
```

### Coverage Stats
- Code files: ~8,887
- Test files: ~1,545
- Ratio: ~17% test files to code files

## Code Quality Tools

| Tool | Configuration | Level |
|------|---------------|-------|
| PHPStan | `phpstan.neon` | Level 6 |
| Psalm | `psalm.xml` | Error level 3 |

### Running Checks
```bash
# PHPStan
./vendor/bin/phpstan analyse

# Psalm
./vendor/bin/psalm

# Unit tests
./vendor/bin/phpunit --testsuite unit

# Code style
./vendor/bin/php-cs-fixer fix --dry-run
```

## Domain Modules

### MadMuscles (Workout App)
- Workout programs and exercises
- AI coaching (ChatBot module)
- Feature availability checks
- Split testing (A/B tests)

### Unimeal (Diet App)
- Meal planning
- Diet quizzes
- Nutrition tracking

### Shared Modules
- Billing (In-App purchases, subscriptions)
- User management
- Analytics (Amplitude)
- Intercom integration

## Key Configuration Files

| File | Purpose |
|------|---------|
| `config/services.yaml` | Main service definitions |
| `config/services/feature_availability.yaml` | Feature checkers |
| `config/split_pipeline/*.yaml` | A/B test configurations |
| `phpstan.neon` | Static analysis config |
| `psalm.xml` | Psalm config |

## Team Practices

### Contributors (Recent 100 commits)
- Andriy Demchyshyn (64)
- Andrii Nahornyi (49)
- Yurii Matsak (48)
- denysmarchuk (32)
- panasovskiy (27)

### Branch Naming
- `feature/{TICKET}-{description}` — new features
- `{TICKET}-{description}` — bug fixes / improvements

### PR Flow
1. Create feature branch from `master`
2. Implement with tests
3. Run PHPStan + Psalm + Unit tests
4. Create PR with Jira ticket reference
5. Code review
6. Merge to master
