# TDD Workflow

## Red-Green-Refactor Cycle

```
1. RED    → Write failing test
2. GREEN  → Write minimal code to pass
3. REFACTOR → Improve code quality
```

## Step-by-Step Process

### 1. RED: Write Failing Test

```php
class CalorieCalculatorTest extends TestCase
{
    public function testCalculatesCaloriesForRunning(): void
    {
        $calculator = new CalorieCalculator();

        // This will fail - CalorieCalculator doesn't exist yet
        $calories = $calculator->calculate(
            duration: 30,
            weight: 70,
            activityType: 'running'
        );

        $this->assertEquals(315, $calories);
    }
}
```

**Run test**: `phpunit` → ❌ FAILS (class not found)

### 2. GREEN: Minimal Implementation

```php
class CalorieCalculator
{
    public function calculate(int $duration, float $weight, string $activityType): int
    {
        // Hardcoded to pass test
        return 315;
    }
}
```

**Run test**: `phpunit` → ✅ PASSES

### 3. Add More Tests (RED again)

```php
public function testCalculatesCaloriesForCycling(): void
{
    $calculator = new CalorieCalculator();
    $calories = $calculator->calculate(30, 70, 'cycling');
    $this->assertEquals(250, $calories); // Different from running
}
```

**Run test**: `phpunit` → ❌ FAILS (returns 315, expected 250)

### 4. GREEN: Real Implementation

```php
class CalorieCalculator
{
    private const MET_VALUES = [
        'running' => 10.5,
        'cycling' => 8.0,
        'walking' => 3.5,
    ];

    public function calculate(int $duration, float $weight, string $activityType): int
    {
        $met = self::MET_VALUES[$activityType] ?? 1.0;
        return (int) ($duration * $weight * $met * 0.01 / 200);
    }
}
```

**Run tests**: `phpunit` → ✅ ALL PASS

### 5. REFACTOR: Improve Quality

```php
class CalorieCalculator
{
    public function __construct(
        private readonly MetValuesProvider $metProvider
    ) {}

    public function calculate(int $duration, float $weight, Activity $activity): int
    {
        $met = $this->metProvider->getMetFor($activity);
        return CalorieFormula::calculate($duration, $weight, $met);
    }
}
```

**Run tests**: `phpunit` → ✅ STILL PASS (behavior unchanged)

## TDD Rules

### The Three Laws (Uncle Bob)

1. **Don't write production code** until you have a failing test
2. **Don't write more test** than needed to fail
3. **Don't write more code** than needed to pass

### When to Write Tests First

✅ **Always test-first for**:
- New features
- Bug fixes (write test that reproduces bug)
- Complex business logic
- Algorithms

❌ **Can skip test-first for**:
- Prototype/spike code (but add tests after)
- Simple getters/setters
- Framework boilerplate

## TDD Patterns

### Test Data Builders

```php
class SubscriptionBuilder
{
    private string $status = 'active';
    private ?\DateTime $expiresAt = null;

    public function expired(): self {
        $this->expiresAt = new \DateTime('-1 day');
        return $this;
    }

    public function build(): Subscription {
        return new Subscription($this->status, $this->expiresAt);
    }
}

// Usage in tests
$subscription = (new SubscriptionBuilder())->expired()->build();
```

### Parameterized Tests

```php
/**
 * @dataProvider activityDataProvider
 */
public function testCalculatesCaloriesForActivity(
    string $activity,
    int $expectedCalories
): void {
    $calories = $this->calculator->calculate(30, 70, $activity);
    $this->assertEquals($expectedCalories, $calories);
}

public function activityDataProvider(): array
{
    return [
        'running' => ['running', 315],
        'cycling' => ['cycling', 240],
        'walking' => ['walking', 105],
    ];
}
```

### Test Doubles Hierarchy

```
Test Double
├── Dummy     → Passed but never used
├── Stub      → Returns canned answers
├── Spy       → Records calls for verification
├── Mock      → Pre-programmed expectations
└── Fake      → Working implementation (in-memory DB)
```

## TDD Workflow Checklist

- [ ] **Write test first** (RED)
- [ ] **Run test** → verify it fails
- [ ] **Write minimal code** (GREEN)
- [ ] **Run test** → verify it passes
- [ ] **Refactor** if needed
- [ ] **Run tests** → verify still pass
- [ ] **Commit** → small, frequent commits

## TDD Anti-Patterns to Avoid

### The Liar
Test passes but doesn't actually test anything
```php
public function testSomething(): void {
    $this->assertTrue(true); // ❌ Useless test
}
```

### Excessive Setup
```php
public function testWorkout(): void {
    $user = ...;     // 20 lines of setup
    $subscription = ...;
    $payment = ...;
    $workout = ...;
    // Actual test
}
// ✅ Use factories/builders instead
```

### Test Interdependence
```php
public function testA(): void { self::$sharedState = 'value'; }
public function testB(): void { $this->assertEquals('value', self::$sharedState); }
// ❌ Tests depend on execution order
```

### Slow Tests
```php
public function testSomething(): void {
    sleep(5); // ❌ Don't sleep in tests
    $this->client->request('POST', ...); // ❌ Real HTTP calls
}
// ✅ Mock external services
```

## Coverage Goals

Target **80%+ line coverage** but focus on:
- Critical paths (payment, auth)
- Business logic
- Edge cases

NOT:
- Getters/setters
- Framework code
- Simple constructors
