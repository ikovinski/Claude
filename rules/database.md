# Database Rules (Doctrine / MySQL)

## Query Performance

### N+1 Prevention

```php
// GOOD: Eager loading with QueryBuilder
public function findWorkoutsWithExercises(int $userId): array
{
    return $this->createQueryBuilder('w')
        ->leftJoin('w.exercises', 'e')
        ->addSelect('e')
        ->where('w.user = :userId')
        ->setParameter('userId', $userId)
        ->getQuery()
        ->getResult();
}

// BAD: N+1 queries in loop
$workouts = $this->workoutRepository->findByUser($userId);
foreach ($workouts as $workout) {
    // This triggers N additional queries!
    foreach ($workout->getExercises() as $exercise) {
        // ...
    }
}
```

### Pagination Required

```php
// GOOD: Always paginate list endpoints
public function findRecentWorkouts(int $userId, int $page = 1, int $limit = 20): Paginator
{
    $query = $this->createQueryBuilder('w')
        ->where('w.user = :userId')
        ->setParameter('userId', $userId)
        ->orderBy('w.createdAt', 'DESC')
        ->setFirstResult(($page - 1) * $limit)
        ->setMaxResults($limit)
        ->getQuery();

    return new Paginator($query);
}

// BAD: Unbounded query
public function findAllWorkouts(int $userId): array
{
    return $this->findBy(['user' => $userId]); // Could return millions!
}
```

## Transaction Management

### Explicit Boundaries

```php
// GOOD: Explicit transaction for multi-entity operations
public function completeWorkout(Workout $workout): void
{
    $this->em->wrapInTransaction(function () use ($workout) {
        $workout->complete();
        $this->em->persist($workout);

        $stats = $this->statsCalculator->calculate($workout);
        $this->em->persist($stats);

        $achievement = $this->achievementChecker->check($workout);
        if ($achievement) {
            $this->em->persist($achievement);
        }
    });
}
```

### Flush Strategy

```php
// GOOD: Single flush at the end
foreach ($workouts as $workoutData) {
    $workout = new Workout($workoutData);
    $this->em->persist($workout);
}
$this->em->flush(); // One flush for all

// BAD: Flush in loop
foreach ($workouts as $workoutData) {
    $workout = new Workout($workoutData);
    $this->em->persist($workout);
    $this->em->flush(); // N flushes!
}
```

## Migration Safety

### Safe Migration Patterns

| Operation | Safe? | How to Make Safe |
|-----------|-------|------------------|
| Add nullable column | Yes | - |
| Add column with default | Yes | - |
| Add index | Careful | Use `ALGORITHM=INPLACE, LOCK=NONE` |
| Drop column | No | Remove code references first, then drop |
| Rename column | No | Add new → migrate data → drop old |
| Change column type | No | Add new → migrate → drop old |

### Migration Example

```php
// GOOD: Safe index creation for large tables
public function up(Schema $schema): void
{
    $this->addSql('CREATE INDEX CONCURRENTLY idx_workout_user_date
                   ON workout (user_id, created_at)');
}

// For MySQL, use pt-online-schema-change for large tables
```

## Index Guidelines

### Must Have Indexes

- Foreign keys (`user_id`, `workout_id`, etc.)
- Columns in WHERE clauses
- Columns in ORDER BY
- Columns in JOIN conditions

### Index Naming

```sql
-- Pattern: idx_{table}_{columns}
CREATE INDEX idx_workout_user_created ON workout (user_id, created_at);
CREATE INDEX idx_subscription_status ON subscription (status);
```

## Checklist

- [ ] No N+1 queries (check with Symfony Profiler)
- [ ] All list endpoints paginated
- [ ] Indexes on filtered/sorted columns
- [ ] Explicit transactions for multi-entity operations
- [ ] Single flush() per request/handler
- [ ] Migration tested on production-like data volume
