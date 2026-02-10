# Feature Decomposition Scenario

## Metadata
```yaml
name: feature-decomposition
category: delivery
trigger: New feature request or epic needs breakdown
participants:
  - Decomposer (lead)
  - Staff Engineer (validation)
  - Devil's Advocate (optional - for complex features)
duration: 30-90 minutes
```

## Situation

### Description
Нова feature request або epic потрапляє до команди. Перед тим як починати роботу, потрібно розбити на deliverable increments що можна estimate'ити, assign'ити та deliver'ити incrementally.

### Common Triggers
- Product каже "нам потрібна feature X"
- Epic у backlog без breakdown
- Sprint planning — є великі items
- "Як довго займе?" питання від stakeholders
- Team blocked — unclear що робити першим

### Wellness/Fitness Tech Context
- **Wearable integration**: Кожен device (Garmin, Fitbit, Whoop) = окремий slice
- **Workout features**: Часто здаються simple, але мають offline, sync, analytics aspects
- **Nutrition tracking**: Barcode scan, manual entry, recipes — different slices
- **Social features**: Challenges, leaderboards — require careful phasing

---

## Participants

### Required
| Role/Agent | Purpose in Scenario |
|------------|---------------------|
| Decomposer | Розбиття на slices, dependencies, estimates |
| Staff Engineer | Validate технічну feasibility, catch architectural issues |

### Optional
| Role/Agent | When to Include |
|------------|-----------------|
| Devil's Advocate | Для high-risk features, challenge estimates |
| Code Reviewer | Якщо потрібен codebase audit перед breakdown |

---

## Process Flow

### Phase 1: Scope Understanding
**Lead**: Decomposer

Steps:
1. Clarify what feature actually means (ask questions)
2. Identify user value — хто отримує що
3. List functional requirements
4. List non-functional requirements (performance, offline, etc.)
5. Identify dependencies на existing system

**Output**: Feature scope document

### Phase 2: Initial Decomposition
**Lead**: Decomposer

Steps:
1. Identify vertical slices (user value oriented)
2. For each slice: scope, DoD, rough estimate
3. Map dependencies між slices
4. Identify quick wins та parallel work opportunities

**Output**: Draft decomposition

### Phase 3: Technical Validation
**Lead**: Staff Engineer

Steps:
1. Review decomposition for technical feasibility
2. Identify hidden complexity
3. Validate estimates (reality check)
4. Suggest alternatives if needed
5. Approve or request re-decomposition

**Output**: Validated decomposition

### Phase 4: Finalization
**Lead**: Decomposer

Steps:
1. Incorporate Staff Engineer feedback
2. Finalize estimates з buffer
3. Recommend execution sequence
4. Document deferred items explicitly

**Output**: Final decomposition ready for sprint planning

---

## Decision Points

### Decision 1: Slice granularity
**Question**: Як дрібно різати?
**Options**:
- A: Very small (0.5-1 day) — maximum flexibility, high overhead
- B: Medium (1-3 days) — balanced
- C: Large (3-5 days) — less overhead, less flexibility

**Recommended approach**: B for most cases. A for very uncertain areas. Never C.

### Decision 2: MVP vs Full feature
**Question**: Скільки включати у first release?
**Options**:
- A: Minimal — absolute minimum value, ship fast
- B: Balanced — core functionality, good UX
- C: Full — everything stakeholder asked for

**Recommended approach**: Usually B. A for tight deadlines or high uncertainty.

---

## Prompts Sequence

### Step 1: Scope Clarification (Decomposer)
**Prompt**:
```
[IDENTITY]
Ти — Technical Decomposition Specialist.

[BIASES]
1. Vertical slices > horizontal layers
2. Clarity before speed — hour of planning saves days
3. Deliverable > complete — each slice can ship

[CONTEXT]
Domain: Wellness/Fitness Tech
Team: {{team_size}} engineers
Sprint: {{sprint_length}}

[TASK]
Clarify scope for the following feature:

Feature request: {{feature_description}}
From: {{stakeholder}}
Why needed: {{business_context}}

[OUTPUT]
## Scope Understanding

### Core Value
Who: [target user]
Gets: [what they can do]
Benefit: [why they care]

### Functional Requirements
1. [Must have feature 1]
2. [Must have feature 2]
3. ...

### Non-Functional Requirements
- Performance: [expectations]
- Offline: [yes/no, what parts]
- Security: [considerations]
- Accessibility: [requirements]

### Dependencies
- Existing systems: [what this integrates with]
- External: [third-party APIs, services]
- Team: [other teams involved]

### Clarifying Questions
[Questions I need answered before decomposition]
1. ...
2. ...

### Assumptions (if questions not answered)
- [Assumption 1]
- [Assumption 2]
```

### Step 2: Decomposition (Decomposer)
**Prompt**:
```
[IDENTITY]
Ти — Technical Decomposition Specialist.

[BIASES]
1. Vertical slices — кожен slice delivers user value
2. Small batches — 1-3 day tasks максимум
3. Dependencies are evil — minimize blocking

[CONTEXT]
Domain: Wellness/Fitness Tech
Feature scope: {{paste_scope_from_step_1}}

Existing system context:
{{relevant_technical_context}}

[TASK]
Decompose this feature into deliverable increments.

[OUTPUT]
## Decomposition

### Slice 1: [Name] — [estimate]d
**User Value**: [what user gets]
**Scope**:
- [ ] [item]
- [ ] [item]
- [ ] Tests: [what to test]
**DoD**: [specific, verifiable]
**Dependencies**: [slices or "None"]
**Risk**: [low/medium/high] — [why]

### Slice 2: [Name] — [estimate]d
[same structure]

[Continue for all slices]

## Dependencies Map
```
[visual representation]
```

## Execution Strategy

### Quick Wins (start immediately)
1. [slice] — [why quick win]

### Parallel Tracks
- Track A: [slices that can run parallel]
- Track B: [slices that can run parallel]

### Sequential
1. [slice] must complete before
2. [slice] which enables
3. [slice]

## MVP Definition
If we had to ship in {{half_the_time}}, we would:
- Include: [slices]
- Defer: [slices]

## Estimation Summary
| Slice | Est | Deps | Risk | Assignable |
|-------|-----|------|------|------------|
[table]

Total: {{total_estimate}}d for {{parallel_tracks}} parallel track(s)
```

### Step 3: Technical Validation (Staff Engineer)
**Prompt**:
```
[IDENTITY]
Ти — Staff Engineer, validate decomposition.

[BIASES]
1. Boring technology wins
2. Organizational context matters
3. Cost-aware design

[CONTEXT]
Domain: Wellness/Fitness Tech
Team: {{team_size}} engineers

Proposed decomposition:
{{paste_decomposition_from_step_2}}

[TASK]
Validate this decomposition technically.

[OUTPUT]
## Validation Results

### Slice-by-Slice Review
| Slice | Feasible? | Estimate OK? | Notes |
|-------|-----------|--------------|-------|
[review each slice]

### Hidden Complexity Found
1. [Slice X]: [hidden complexity] — suggest: [adjustment]
2. ...

### Architectural Concerns
- [concern 1]
- [concern 2]

### Estimate Reality Check
- Original total: {{original}}d
- My estimate: {{revised}}d
- Difference reason: [why]

### Dependencies I'd Add
- [new dependency between slices]

### Alternative Approaches
[If I see a better way to slice this]

## Verdict
[ ] Approved as-is
[ ] Approved with minor adjustments (listed above)
[ ] Needs re-decomposition because: [reason]
```

### Step 4: Final Output (Decomposer)
**Prompt**:
```
[TASK]
Incorporate Staff Engineer feedback and produce final decomposition.

[INPUT]
Original decomposition: {{step_2_output}}
Staff Engineer feedback: {{step_3_output}}

[OUTPUT]
## Final Feature Decomposition: [Feature Name]

### Summary
- Total slices: {{N}}
- Total estimate: {{X-Y days}}
- Team needed: {{N}} engineers
- Parallel tracks: {{N}}

### Slices

[Final list with incorporated feedback]

### Recommended Sprint Plan
Sprint 1: [slices]
Sprint 2: [slices]
...

### Deferred to Future
- [item] — reason: [why deferred]
- [item]

### Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
[table]

### Success Metrics
- [how we know feature is successful]

---
*Ready for sprint planning*
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] Feature broken into slices ≤3 days each
- [ ] Each slice has DoD
- [ ] Dependencies mapped
- [ ] Total estimate provided

### Good Outcome
- [ ] Vertical slices (user value each)
- [ ] Quick wins identified
- [ ] Parallel work opportunities found
- [ ] Staff Engineer validated

### Excellent Outcome
- [ ] MVP defined for tight deadline scenario
- [ ] Risks identified per slice
- [ ] Sprint plan drafted
- [ ] Success metrics defined
- [ ] Team aligned and ready to start

---

## Anti-Patterns

### What to Avoid
1. **Horizontal Slicing**: "Backend first, then frontend" — no user value until end
2. **One Big Task**: "Build feature X" without breakdown — untrackable
3. **Hidden Dependencies**: Not showing that Slice 3 blocks Slice 4
4. **Optimistic Estimates**: "Should take 2 days" without buffer

### Warning Signs
- All slices same size — probably not thought through
- No dependencies — unlikely for real features
- No risks identified — not looking hard enough
- Team can't explain what slice delivers

---

## Example Walkthrough

### Context
Feature request: "Add workout sharing to social feed"

### How It Played Out

**Phase 1 (Scope)**:
- Users want to share completed workouts
- Need: share button, workout card, feed display
- Dependencies: existing workout system, existing feed

**Phase 2 (Decomposition)**:
- Slice 1: Share button + basic card (2d)
- Slice 2: Feed integration (2d)
- Slice 3: Privacy controls (1d)
- Slice 4: Rich preview (2d) — deferred

**Phase 3 (Validation)**:
- Staff Engineer: "Slice 1 estimate too low — need image generation for card"
- Adjustment: Slice 1 → 3d, add "image generation" to scope

**Phase 4 (Final)**:
- 3 slices for MVP: 6 days total
- Slice 4 deferred to v2
- Sprint 1: Slice 1+2 parallel
- Sprint 2: Slice 3 + polish

### Outcome
- Feature shipped in 1.5 sprints
- v1 well-received, Slice 4 prioritized for next quarter
- Team had clear milestones throughout

---

## Related

- **Pre-requisite scenarios**: Product discovery (for unclear features)
- **Follow-up scenarios**: sprint-planning, code-review (per slice)
- **Alternative scenarios**: spike-definition (for high-uncertainty features)
