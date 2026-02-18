# Epic Breakdown

## Epic Structure

```
Epic (3-6 months)
├─ Feature 1 (2-4 weeks)
│  ├─ Story 1.1 (2-5 days)
│  ├─ Story 1.2 (2-5 days)
│  └─ Story 1.3 (2-5 days)
├─ Feature 2 (2-4 weeks)
└─ Feature 3 (2-4 weeks)
```

## Breakdown Process

### 1. Define Epic Goal
**Example**: Enable users to track their fitness journey

### 2. Identify Features
- Workout tracking
- Nutrition logging
- Progress analytics
- Goal setting

### 3. Break Features into Stories
**Feature**: Workout Tracking

**Stories**:
- User can log a workout manually
- User can sync workouts from Garmin
- User can view workout history
- User can edit past workouts
- User can delete workouts

### 4. Add Acceptance Criteria
**Story**: User can log workout manually

**AC**:
- Given I'm on workout page
- When I fill type, duration, date
- Then workout appears in history
- And I see calorie estimate

## Story Template

```markdown
**As a** [user type]
**I want to** [action]
**So that** [benefit]

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2

**Technical Notes**:
- API endpoint: POST /api/workouts
- DB table: workouts

**Estimate**: 3 points
```

## Example: Subscription Epic

### Epic: Paid Subscriptions

**Goal**: Monetize app through premium subscriptions

**Timeline**: 3 months
**Value**: $50K/month revenue

---

### Feature 1: Basic Subscription (2 weeks)

**Story 1.1**: User can view subscription plans
- AC: Plans displayed with features/prices
- AC: Free vs Pro comparison shown

**Story 1.2**: User can subscribe to plan
- AC: Can enter payment method
- AC: Subscription activated immediately

**Story 1.3**: User can cancel subscription
- AC: Can cancel from settings
- AC: Confirmation dialog shown

---

### Feature 2: Payment Integration (3 weeks)

**Story 2.1**: Stripe payment processing
- AC: Credit card accepted
- AC: Payment confirmation shown

**Story 2.2**: Recurring billing
- AC: Auto-charged monthly
- AC: Email receipt sent

**Story 2.3**: Failed payment handling
- AC: Retry with exponential backoff
- AC: User notified of failure

---

### Feature 3: Access Control (2 weeks)

**Story 3.1**: Premium features locked
- AC: Non-subscribers see upgrade prompt
- AC: Subscribers access all features

**Story 3.2**: Grace period for failed payments
- AC: 3-day grace before access revoked
- AC: Banner shown during grace period

## Vertical Slicing

### Horizontal (❌ Bad)
- All UI components
- All API endpoints
- All database tables
- All tests

### Vertical (✅ Good)
- MVP: Subscribe → Pay → Access unlocked
- V2: Cancel subscription
- V3: Failed payment handling
- V4: Grace periods

## Story Sizing

**1 point** (1 day): Simple CRUD
**2 points** (2 days): Basic feature
**3 points** (3 days): Standard story
**5 points** (5 days): Complex feature
**8+ points**: TOO BIG → split it

## Acceptance Criteria Checklist

- [ ] Functional requirements clear
- [ ] Happy path defined
- [ ] Edge cases identified
- [ ] Error handling specified
- [ ] Security considered
- [ ] Performance criteria
- [ ] Testable
