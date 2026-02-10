---
name: tdd
description: Start TDD workflow - write tests first, then implement. Uses TDD Guide agent.
allowed_tools: ["Read", "Write", "Edit", "Bash", "Grep"]
agent: tdd-guide
---

# /tdd - Test-Driven Development

Запускає TDD workflow: спочатку пишемо failing test, потім implementation.

## Usage

```bash
/tdd <what to implement>
/tdd "CalorieCalculator that calculates burned calories based on workout type and duration"
/tdd "Message handler for syncing workouts from external API"
```

## TDD Cycle

```
     ┌─────────────────┐
     │   1. RED        │
     │ Write failing   │
     │    test         │
     └────────┬────────┘
              │
              ▼
     ┌─────────────────┐
     │   2. GREEN      │
     │ Write minimal   │
     │ implementation  │
     └────────┬────────┘
              │
              ▼
     ┌─────────────────┐
     │   3. REFACTOR   │
     │ Improve code    │
     │ (tests pass)    │
     └────────┬────────┘
              │
              ▼
         [Repeat]
```

## What I'll Do

### Step 1: Write Test First (RED)
```php
public function testCalculateReturnsCorrectCalories(): void
{
    $calculator = new CalorieCalculator();
    $workout = new Workout(duration: 30, type: WorkoutType::Running);

    $result = $calculator->calculate($workout);

    $this->assertEquals(350, $result->getCalories());
}
```

### Step 2: Run Test (Verify FAILS)
```bash
vendor/bin/phpunit tests/Unit/Service/CalorieCalculatorTest.php
# Expected: FAIL (class doesn't exist yet)
```

### Step 3: Write Minimal Implementation (GREEN)
```php
class CalorieCalculator
{
    public function calculate(Workout $workout): CalorieResult
    {
        // Minimal implementation to pass test
        return new CalorieResult(350);
    }
}
```

### Step 4: Run Test (Verify PASSES)
```bash
vendor/bin/phpunit tests/Unit/Service/CalorieCalculatorTest.php
# Expected: PASS
```

### Step 5: Add More Tests & Refactor
- Add edge cases (zero, negative, null)
- Add different workout types
- Refactor implementation
- Keep tests green

## Edge Cases I'll Cover

```php
// Null handling
public function testCalculateThrowsOnNullWorkout(): void

// Zero duration
public function testCalculateWithZeroDurationReturnsZero(): void

// Negative values
public function testCalculateThrowsOnNegativeDuration(): void

// Boundaries
public function testCalculateWithMaxDuration(): void

// Different types
public function testCalculateForRunning(): void
public function testCalculateForCycling(): void
```

## Output

I'll provide:
1. **Test file** with comprehensive tests
2. **Implementation file** that passes all tests
3. **Coverage report** (target: 80%+)

## Example Session

```
> /tdd "Service that validates workout data before saving"

# TDD Session: WorkoutValidatorService

## Step 1: Test File (RED)

Creating `tests/Unit/Service/WorkoutValidatorServiceTest.php`:

```php
class WorkoutValidatorServiceTest extends TestCase
{
    public function testValidateReturnsValidResultForValidWorkout(): void
    {
        $validator = new WorkoutValidatorService();
        $workout = new WorkoutDTO(
            duration: 30,
            type: 'running',
            calories: 350
        );

        $result = $validator->validate($workout);

        $this->assertTrue($result->isValid());
    }

    public function testValidateReturnsErrorForNegativeDuration(): void
    {
        $validator = new WorkoutValidatorService();
        $workout = new WorkoutDTO(duration: -10, type: 'running');

        $result = $validator->validate($workout);

        $this->assertFalse($result->isValid());
        $this->assertContains('duration', $result->getErrors());
    }

    // ... more tests
}
```

Run tests? [Y/n]
```

## Coverage Target

| Area | Target |
|------|--------|
| Services | 80% |
| Message Handlers | 90% |
| Billing Logic | 95% |

---

*Uses [TDD Guide Agent](../agents/technical/tdd-guide.md)*
