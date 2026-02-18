# Rewrite Decision Scenario

## Metadata
```yaml
name: rewrite-decision
category: technical-decisions
trigger: "Should we rewrite this?" question from team
participants:
  - Staff Engineer (lead)
  - Devil's Advocate (challenger)
  - Decomposer (if proceeding)
duration: 1-2 hours total
skills:
  - auto:{project}-patterns
  - architecture/architecture-decision-template
  - architecture/decision-matrix
  - risk-management/risk-assessment
```

## Skills Usage in This Scenario

1. **architecture-decision-template**: Staff Engineer створює ADR для rewrite decision
2. **decision-matrix**: Використовується для порівняння Rewrite vs Refactor
3. **risk-assessment**: Devil's Advocate оцінює ризики rewrite
4. **{project}-patterns**: Розуміння поточних проєктних патернів

## Situation

### Description
Команда або stakeholder пропонує переписати існуючий компонент/систему. Це одне з найризикованіших рішень у software development — більшість rewrites провалюються або займають значно більше часу ніж очікувалось.

### Common Triggers
- "Цей код неможливо підтримувати"
- "Легше переписати з нуля"
- "Технічний борг нас душить"
- "Новий фреймворк вирішить всі проблеми"
- "Попередня команда написала погано"

### Wellness/Fitness Tech Context
- **Workout tracking rewrite**: Sync logic з wearables складна, rewrite ризикує втратити edge cases
- **Nutrition database**: Роками збирались дані, migration critical
- **User data migration**: Health data = PII, rewrite з migration = high risk
- **Mobile app rewrite**: React Native → Flutter? App store transition складний

---

## Participants

### Required
| Role/Agent | Purpose in Scenario |
|------------|---------------------|
| Staff Engineer | Оцінка технічної доцільності, alternatives |
| Devil's Advocate | Challenge assumptions, find hidden risks |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| Decomposer | Якщо рішення "так" — breakdown на phases |
| Code Reviewer | Для аудиту поточного коду перед рішенням |

---

## Process Flow

### Phase 1: Problem Validation
**Lead**: Staff Engineer

Steps:
1. Чітко сформулювати ЩО саме хочемо переписати
2. Визначити ЧОМУ (конкретні проблеми, не загальне "погано")
3. Зібрати data: скільки bugs, час на changes, pain points
4. Записати припущення команди

**Output**: Problem Statement документ

### Phase 2: Alternative Analysis
**Lead**: Staff Engineer

Steps:
1. Explore alternatives до повного rewrite:
   - Incremental refactoring
   - Strangler pattern (поступова заміна)
   - Fix specific pain points
   - Extract worst parts
2. Для кожної альтернативи: effort vs impact

**Output**: Options comparison table

### Phase 3: Risk Challenge
**Lead**: Devil's Advocate

Steps:
1. Challenge кожне припущення з Phase 1
2. Identify historical patterns (компанії що робили rewrites)
3. Pre-mortem: чому rewrite може провалитись
4. Second-order effects: що ще зламається

**Output**: Risk assessment document

### Phase 4: Decision
**Lead**: Staff Engineer

Steps:
1. Synthesize findings
2. Make recommendation з reasoning
3. If "yes to rewrite" — умови (phased, feature parity first, etc.)
4. Document decision (ADR)

**Output**: Architecture Decision Record

---

## Decision Points

### Decision 1: Is this really a "rewrite" question?
**Question**: Чи дійсно потрібен повний rewrite, чи це disguised refactoring?
**Options**:
- A: Full rewrite — система фундаментально broken
- B: Major refactoring — можна зберегти core, замінити частини
- C: Targeted fixes — вирішити конкретні pain points

**Recommended approach**: Start with C, escalate to B if insufficient, A as last resort

### Decision 2: Rewrite scope
**Question**: Якщо rewrite — скільки одразу?
**Options**:
- A: Big bang — все одразу, повна заміна
- B: Strangler — нове паралельно, поступова міграція
- C: Module-by-module — один компонент за раз

**Recommended approach**: Almost always B or C. A = high risk.

---

## Prompts Sequence

### Step 1: Problem Analysis (Staff Engineer)
**Prompt**:
```
[IDENTITY]
Ти — Staff Engineer з досвідом оцінки rewrite decisions.

[BIASES]
1. Boring technology wins — rewrite на "нове та модне" зазвичай погана ідея
2. Reversibility matters — incremental changes > big bang
3. Solve real problems — не оптимізуй для гіпотетичних проблем

[CONTEXT]
Domain: Wellness/Fitness Tech
Team: {{team_size}} engineers

[TASK]
Analyze the following rewrite proposal:

Component: {{component_name}}
Current state: {{current_issues}}
Proposed solution: {{what_team_wants}}
Reasoning from team: {{why_they_want_rewrite}}

[OUTPUT]
## Problem Validation
- Is the problem clearly defined?
- What specific issues exist? (list with examples)
- What data supports this? (bugs, time spent, incidents)

## Hidden Questions
- What are we assuming without evidence?
- What would we need to prove before deciding?

## Alternatives to Full Rewrite
1. [Alternative 1]: Effort: X, Impact: Y, Risk: Z
2. [Alternative 2]: ...
3. [Alternative 3]: ...

## Initial Assessment
[Your preliminary view on whether rewrite is justified]
```

### Step 2: Risk Challenge (Devil's Advocate)
**Prompt**:
```
[IDENTITY]
Ти — Devil's Advocate. Твоя місія: знайти причини чому rewrite може провалитись.

[BIASES]
1. Assume nothing works — prove with evidence
2. Question consensus — "всі хочуть rewrite" = red flag
3. Historical patterns — більшість rewrites fail

[CONTEXT]
Domain: Wellness/Fitness Tech
Health data = sensitive, migration risks high

Previous analysis:
{{paste_staff_engineer_output}}

[TASK]
Challenge the rewrite proposal:

[OUTPUT]
## Assumptions I'm Challenging

### Assumption: "Current system is unmaintainable"
- Evidence for: [what supports this]
- Evidence against: [what contradicts]
- What would prove/disprove: [verification]

### Assumption: "Rewrite will be faster than fixing"
[same structure]

### Assumption: "Team has capacity for rewrite"
[same structure]

## Failure Scenarios

### Scenario: Second System Syndrome
Trigger: Team adds "improvements" during rewrite
Sequence: Scope creep → delayed delivery → pressure → cut corners → same problems
Probability: HIGH (very common)
Mitigation: Strict feature parity first rule

### Scenario: Lost Knowledge
[similar structure]

### Scenario: Parallel Maintenance Burden
[similar structure]

## Pre-Mortem
It's 12 months from now, rewrite failed. Most likely reasons:
1. ...
2. ...
3. ...

## Questions Team Must Answer
1. ...
2. ...
```

### Step 3: Final Decision (Staff Engineer)
**Prompt**:
```
[IDENTITY]
Ти — Staff Engineer, приймаєш фінальне рішення.

[INPUT]
Problem Analysis: {{phase_1_output}}
Risk Assessment: {{phase_2_output}}

[TASK]
Synthesize і make recommendation.

[OUTPUT]
## Decision Summary

### Recommendation: [REWRITE / REFACTOR / FIX / MORE DATA NEEDED]

### Reasoning
[Why this decision given all inputs]

### If Proceeding with Changes
- Approach: [big bang / strangler / incremental]
- First phase scope: [specific]
- Success criteria: [measurable]
- Rollback plan: [if things go wrong]

### Conditions / Guardrails
- [condition 1]
- [condition 2]

## ADR (Architecture Decision Record)

**Title**: [Component] Rewrite Decision
**Date**: {{date}}
**Status**: [Proposed/Accepted/Rejected]

**Context**:
[Why we needed to make this decision]

**Decision**:
[What we decided]

**Consequences**:
- Positive: [benefits]
- Negative: [costs/risks we're accepting]
- Neutral: [changes that are neither good nor bad]
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] Clear decision (rewrite/don't rewrite/need more data)
- [ ] Documented reasoning
- [ ] Key risks identified

### Good Outcome
- [ ] Alternatives explored thoroughly
- [ ] Assumptions challenged and validated
- [ ] Team aligned on decision

### Excellent Outcome
- [ ] ADR created for future reference
- [ ] Phased plan if proceeding
- [ ] Clear success metrics defined
- [ ] Rollback plan documented

---

## Anti-Patterns

### What to Avoid
1. **Sunk Cost Fallacy**: "Ми вже стільки вклали у поточну систему" — irrelevant для forward-looking decision
2. **Grass is Greener**: "Новий фреймворк все вирішить" — зазвичай ні
3. **Second System Effect**: Rewrite стає excuse для add all features we ever wanted
4. **Big Bang Rewrite**: Все одразу = maximum risk

### Warning Signs
- Team unanimous за rewrite без analysis — groupthink
- No data, тільки feelings про "поганий код"
- Rewrite scope growing під час обговорення
- "Це займе тільки кілька тижнів" для major rewrite

---

## Example Walkthrough

### Context
Команда хоче переписати workout sync engine з Node.js на Go "для performance".

### How It Played Out

**Phase 1 (Staff Engineer)**:
- Problem: "Sync slow" — але тільки для users з 1000+ workouts (0.1% users)
- Actual issue: N+1 query in sync logic, not language performance
- Alternative identified: Fix N+1, add pagination

**Phase 2 (Devil's Advocate)**:
- Challenge: Team не має Go experience
- Risk: 6 months learning + rewrite, meanwhile sync still slow
- Pre-mortem: "Rewrite delayed, had to maintain two systems"

**Phase 3 (Decision)**:
- Recommendation: **FIX** (not rewrite)
- Action: Optimize existing sync, benchmark after
- Condition: If still slow after optimization, revisit Go decision з benchmark data

### Outcome
- N+1 fix took 2 days
- Sync improved 50x for heavy users
- No rewrite needed
- Team learned to benchmark before rewrite discussions

---

## Related

- **Pre-requisite scenarios**: Technical debt audit (sometimes)
- **Follow-up scenarios**: feature-decomposition (if rewrite approved)
- **Alternative scenarios**: incremental-refactoring (when rewrite not justified)
