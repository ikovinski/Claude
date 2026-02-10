# Coding Style Rules

## PHP 8.3 / Symfony 6.4 Standards

### Type Safety

```php
// GOOD: Full type declarations
public function calculateCalories(
    readonly WorkoutData $workout,
    ?UserPreferences $preferences = null
): CalorieResult {
    // ...
}

// BAD: Missing types
public function calculateCalories($workout, $preferences = null) {
    // ...
}
```

### Class Design

```php
// GOOD: Readonly class for immutable data
readonly class WorkoutSummary
{
    public function __construct(
        public int $totalCalories,
        public Duration $duration,
        public array $exercises,
    ) {}
}

// GOOD: Constructor property promotion
class WorkoutService
{
    public function __construct(
        private readonly WorkoutRepository $repository,
        private readonly EventDispatcherInterface $dispatcher,
    ) {}
}
```

### Enums Over Constants

```php
// GOOD: Backed enum
enum SubscriptionStatus: string
{
    case Active = 'active';
    case Cancelled = 'cancelled';
    case Expired = 'expired';

    public function isActive(): bool
    {
        return $this === self::Active;
    }
}

// BAD: Magic strings
const STATUS_ACTIVE = 'active';
```

### Attributes Over Annotations

```php
// GOOD: PHP 8 attributes
#[Route('/api/workouts', name: 'workout_list', methods: ['GET'])]
#[IsGranted('ROLE_USER')]
public function list(): JsonResponse

// BAD: Doctrine annotations
/** @Route("/api/workouts") */
```

### File Organization

| Guideline | Value |
|-----------|-------|
| Typical file size | 200-400 lines |
| Maximum file size | 800 lines |
| One class per file | Always |
| Organize by | Feature/Domain, not type |

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Message | `{Action}{Entity}Message` | `CreateWorkoutMessage` |
| Handler | `{Message}Handler` | `CreateWorkoutMessageHandler` |
| Event | `{Entity}{Action}Event` | `WorkoutCompletedEvent` |
| Repository | `{Entity}Repository` | `WorkoutRepository` |
| Service | `{Domain}Service` | `WorkoutTrackingService` |

### Comments Policy

```php
// GOOD: Explain "why", not "what"
// Garmin API returns calories in kcal*10 for precision
$calories = $apiResponse->calories / 10;

// BAD: Obvious comment
// Get the user
$user = $this->userRepository->find($id);
```
