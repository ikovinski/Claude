# Vertical Slicing

## What is Vertical Slice

**Horizontal** (layers):
```
Task 1: Build all database models
Task 2: Build all API endpoints
Task 3: Build all UI components
```
❌ Nothing works until all 3 done

**Vertical** (features):
```
Slice 1: User can view their workout (DB → API → UI)
Slice 2: User can create workout (DB → API → UI)
Slice 3: User can delete workout (DB → API → UI)
```
✅ Each slice delivers value

## Benefits

- **Early feedback** — users can try Slice 1 immediately
- **Risk reduction** — problems found early
- **Parallel work** — teams work on different slices
- **Incremental delivery** — deploy slice by slice

## How to Slice

### Example: Workout Tracking Feature

#### ❌ Bad (Horizontal)
1. Create all database tables
2. Build all API endpoints
3. Create all UI screens
4. Add all validations
5. Add all tests

#### ✅ Good (Vertical)

**Slice 1: View workout list**
- DB: Workout table (minimal fields)
- API: GET /api/workouts
- UI: List component
- Test: Can fetch and display
**Value**: User sees their workouts

**Slice 2: Create workout**
- DB: Add created_at field
- API: POST /api/workouts
- UI: Create form
- Test: Can create workout
**Value**: User can log workouts

**Slice 3: Add workout details**
- DB: Add duration, calories fields
- API: Update endpoints
- UI: Detail view
- Test: Can view details
**Value**: User sees detailed info

## Slicing Patterns

### Walking Skeleton
Найпростіший end-to-end flow
```
DB: Single table, 2 fields
API: One endpoint, no validation
UI: Basic form
Test: E2E smoke test
```
**Goal**: Prove architecture works

### Happy Path First
```
Slice 1: Happy path (no errors)
Slice 2: Add validation
Slice 3: Add error handling
Slice 4: Add edge cases
```

### Core Then Options
```
Slice 1: Core functionality (required fields)
Slice 2: Optional features (advanced filters)
Slice 3: Nice-to-haves (export PDF)
```

## Slicing Subscription Feature

### Slice 1: Basic Subscription
**User can subscribe to a plan**
- DB: `subscription` table (user_id, plan_id, status)
- API: `POST /api/subscriptions`
- Service: `SubscriptionService::create()`
- Test: Can create active subscription
**Deploy**: User can subscribe (manual payment)

### Slice 2: Payment Integration
**System charges credit card**
- DB: Add `payment_method_id`
- API: Integrate Stripe
- Service: `PaymentService::charge()`
- Test: Successful payment creates subscription
**Deploy**: Automated billing

### Slice 3: Subscription Expiration
**Expired subscriptions disable access**
- DB: Add `expires_at`
- Service: `SubscriptionService::isActive()`
- Middleware: Check subscription before API
- Test: Expired subscription blocked
**Deploy**: Access control works

### Slice 4: Renewal
**Auto-renew before expiration**
- Message: `RenewalCheckMessage`
- Handler: Find expiring, charge card
- Test: Subscription renewed automatically
**Deploy**: Retention improved

## How Small Should Slices Be?

**Too Big** (> 3 days):
- Hard to review
- High risk
- Delayed feedback

**Too Small** (< 1 hour):
- Overhead of review/deploy
- Incomplete functionality

**Just Right** (1-2 days):
- Reviewable PR
- Testable in isolation
- Delivers user value

## Slicing Checklist

- [ ] Slice works end-to-end (DB → UI)
- [ ] Slice delivers user value
- [ ] Slice is independently deployable
- [ ] Slice has tests
- [ ] Slice is 1-3 days of work
- [ ] Next slice builds on this one

## Anti-Patterns

### Technical Tasks
❌ "Build authentication system"
✅ "User can login with email/password"

### All-or-Nothing
❌ "Complete workout tracking"
✅ "User can view workouts" → "User can create workout" → ...

### Layer-by-Layer
❌ "Build all database models"
✅ "Implement 'view workout' feature" (includes model)

## Example: Nutrition Tracking

### Slice 1: Log food (simple)
- User types food name
- System logs it (no calories)
- User sees list of logged foods
**Value**: Food diary works

### Slice 2: Calorie lookup
- System searches food database
- Shows calorie info
- Saves calories with log
**Value**: Users track calories

### Slice 3: Daily totals
- System sums daily calories
- Shows daily goal progress
- Visual indicator (over/under)
**Value**: Users monitor intake

### Slice 4: Meal categories
- User tags food as breakfast/lunch/dinner
- Shows breakdown by meal
- Meal-specific goals
**Value**: Meal planning

Each slice = working feature, not half-built system.
