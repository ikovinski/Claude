# Test Patterns

## PHPUnit Patterns

### AAA Pattern (Arrange-Act-Assert)
```php
public function testSubscriptionRenewal(): void
{
    // Arrange
    $subscription = $this->createExpiredSubscription();

    // Act
    $this->renewalService->renew($subscription);

    // Assert
    $this->assertTrue($subscription->isActive());
    $this->assertNotNull($subscription->getRenewedAt());
}
```

### Data Providers
**When**: Той самий тест з різними inputs
```php
/**
 * @dataProvider calorieDataProvider
 */
public function testCalorieCalculation(int $duration, float $weight, int $expected): void
{
    $result = $this->calculator->calculate($duration, $weight);
    $this->assertEquals($expected, $result);
}

public function calorieDataProvider(): array
{
    return [
        'light workout' => [30, 70.0, 150],
        'heavy workout' => [60, 80.0, 400],
    ];
}
```

### Test Doubles

#### Mock (перевіряє взаємодію)
```php
$emailService = $this->createMock(EmailService::class);
$emailService->expects($this->once())
    ->method('send')
    ->with($this->equalTo('user@example.com'));
```

#### Stub (повертає значення)
```php
$apiClient = $this->createStub(GarminApiClient::class);
$apiClient->method('getWorkouts')->willReturn([...]);
```

### Object Mother Pattern
```php
class WorkoutFactory
{
    public static function createRunning(): Workout {
        return new Workout(type: 'running', duration: 30);
    }

    public static function createWithCalories(int $calories): Workout {
        return new Workout(calories: $calories);
    }
}

// Usage
$workout = WorkoutFactory::createRunning();
```

## Symfony-Specific

### KernelTestCase для Integration Tests
```php
class WorkoutRepositoryTest extends KernelTestCase
{
    private WorkoutRepository $repository;

    protected function setUp(): void {
        self::bootKernel();
        $this->repository = self::getContainer()->get(WorkoutRepository::class);
    }
}
```

### WebTestCase для Functional Tests
```php
class ApiControllerTest extends WebTestCase
{
    public function testCreateWorkout(): void {
        $client = static::createClient();
        $client->request('POST', '/api/workouts', [...]);

        $this->assertResponseIsSuccessful();
        $this->assertJson($client->getResponse()->getContent());
    }
}
```

## Test Organization

```
tests/
├── Unit/              # Ізольовані класи
│   ├── Service/
│   └── Entity/
├── Integration/       # Кілька компонентів разом
│   ├── Repository/
│   └── MessageHandler/
└── Functional/        # End-to-end через HTTP
    └── Controller/
```

## Test Naming

```php
// ❌ Bad
public function testWorkout() { }

// ✅ Good
public function testCaloriesCalculatedCorrectlyForRunningWorkout() { }
public function testSubscriptionExpiresAfterCancellation() { }
public function testThrowsExceptionWhenUserNotFound() { }
```

## Coverage Targets

| Code Type | Minimum | Target |
|-----------|---------|--------|
| Payment/Billing | 90% | 95% |
| Message Handlers | 80% | 90% |
| API Endpoints | 75% | 85% |
| Services | 70% | 80% |
