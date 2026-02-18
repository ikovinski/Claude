# Refactoring Patterns

## Common Refactorings

### Extract Method
**When**: Метод довший 20 рядків або робить більше однієї речі
```php
// Before
public function process($data) {
    // validation
    // transformation
    // saving
}

// After
public function process($data) {
    $this->validate($data);
    $transformed = $this->transform($data);
    $this->save($transformed);
}
```

### Replace Conditional with Polymorphism
**When**: Switch/if chains по типу об'єкта
```php
// Before
if ($type === 'admin') { ... }
elseif ($type === 'user') { ... }

// After
interface UserRole { public function can($action); }
class Admin implements UserRole { ... }
class RegularUser implements UserRole { ... }
```

### Introduce Parameter Object
**When**: Функція приймає 4+ параметри
```php
// Before
public function createSubscription($userId, $planId, $startDate, $promoCode) { }

// After
public function createSubscription(SubscriptionRequest $request) { }
```

### Replace Magic Numbers with Constants
```php
// Before
if ($status === 3) { }

// After
private const STATUS_ACTIVE = 3;
if ($status === self::STATUS_ACTIVE) { }
```

### Extract Service Class
**When**: Controller/Repository має business logic
```php
// Before: Controller
$calories = ($workout->duration * $user->weight * 0.035);

// After: Service
$calories = $this->calorieCalculator->calculate($workout, $user);
```

## Symfony-Specific

### Extract Form Type
**When**: Валідація дублюється
```php
class SubscriptionType extends AbstractType {
    public function buildForm(FormBuilderInterface $builder, array $options) {
        $builder->add('plan', ChoiceType::class, [...]);
    }
}
```

### Replace Array with DTO
```php
// Before
return ['id' => $id, 'name' => $name];

// After
readonly class WorkoutDto {
    public function __construct(
        public int $id,
        public string $name,
    ) {}
}
```

## Refactoring Checklist

- [ ] Tests існують перед рефакторингом
- [ ] Tests проходять після рефакторингу
- [ ] Змінена тільки структура, не behavior
- [ ] Код легше читати після змін
- [ ] Performance не погіршився
