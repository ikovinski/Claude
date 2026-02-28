# Dev Workflow: PR Scenario

## Metadata
```yaml
name: dev-pr
category: dev-workflow
trigger: Create branch and commits for PR
participants: none (bash/gh only)
duration: 5-10 minutes
team_execution: false
```

## Situation

### Description
Sixth and final step of the `/dev` workflow. Prepares code for merge by creating a feature branch, staging relevant files, creating commit(s), generating a PR description draft, and optionally creating the PR. This step runs as a single bash-driven process -- no agent team needed, no subagent spawning.

**IMPORTANT RULES**:
- Commits NEVER include `Co-Authored-By` headers
- PR is NEVER created automatically -- always ASK the user first (default: no)
- `.workflows/` directory is NEVER committed

### Common Triggers
- Automatic progression from Review phase (when REVIEW.md verdict is APPROVED)
- `/dev --step pr` (manual trigger after review)
- "Create PR for [feature]"
- "Push branch and prepare PR"

### Wellness/Fitness Tech Context
- **Branch naming**: `feature/{feature-slug}` following project convention
- **Commit granularity**: Prefer logical commits per phase over single squash -- reviewers benefit from seeing auth, data model, sync, and status changes separately
- **PR description**: Include health data handling notes, migration warnings (especially for enum/column changes), security review summary
- **Migration safety**: PR description must call out migrations that require downtime or have backward compatibility implications
- **No force push**: Feature branches may be shared -- never force push

---

## Participants

### Required
| Role | Purpose |
|------|---------|
| Single (bash/gh CLI) | Git operations: branch creation, staging, commits, push, PR creation |

### Optional
| Role | When to Include |
|------|-----------------|
| None | This is a bash-only scenario. No agent team needed. |

---

## Process Flow

### Phase 1: VALIDATE
**Duration**: 1-2 minutes

Steps:
1. Read `.workflows/review/{feature-slug}/REVIEW.md`
2. Verify verdict is APPROVED (zero blocking issues)
3. If BLOCKED: abort with message "Review has blocking issues. Run `/dev --step implement` to fix, then `/dev --step review` again."
4. Read `.workflows/implement/PROGRESS.md` for complete file list
5. Read `.workflows/design/DESIGN.md` for feature overview

**Output**: Confirmation that review passed, context gathered

### Phase 2: BRANCH
**Duration**: 1-2 minutes

Steps:
1. Create branch: `feature/{feature-slug}`
   - If branch already exists: switch to it
   - Base branch: current branch (usually `main` or `master`)
2. Stage relevant files:
   - All new/modified production files from PROGRESS.md
   - All new/modified test files from PROGRESS.md
   - All new migration files from PROGRESS.md
   - Configuration changes (messenger.yaml, etc.)
3. Do NOT stage:
   - `.workflows/` directory (internal pipeline artifacts)
   - `.env` or credentials files
   - `.codemap-cache/` (if exists)
4. Verify staged files are correct: `git diff --cached --stat`

**Output**: Feature branch with correctly staged files

### Phase 3: COMMIT
**Duration**: 2-3 minutes

Steps:
1. Determine commit strategy:
   - **1-2 phases**: Single commit
   - **3+ phases**: Per-phase commits (one commit per implementation phase)
2. Create commit(s) using conventional commit format:
   ```
   # Single commit
   feat: {feature description}

   {Brief summary of all changes}

   # Per-phase commits
   feat({scope}): {phase description}

   {What this phase adds/changes}
   ```
3. **CRITICAL**: No `Co-Authored-By` in any commit message
4. Commit message rules:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `refactor:` for refactoring
   - Subject line under 72 characters
   - Body for details (what and why)
5. Use HEREDOC for commit messages:
   ```bash
   git commit -m "$(cat <<'EOF'
   feat: add Apple Health integration

   Add device-token authentication, data mapping, sync pipeline,
   and status endpoint for Apple Health wearable integration.
   EOF
   )"
   ```

**Output**: Commit(s) on feature branch -- NO Co-Authored-By

### Phase 4: PR DRAFT
**Duration**: 2-3 minutes

Steps:
1. Generate PR description from all pipeline artifacts:
   - **Title**: Short feature description (from task)
   - **Summary**: From DESIGN.md overview (2-3 bullet points)
   - **Changes**: From PLAN.md phases (what each phase adds)
   - **Architecture Decisions**: From design/adr/ files (one-line per ADR)
   - **Test Plan**: From REVIEW.md (coverage summary + manual test checklist)
   - **Security**: From REVIEW.md security section (OWASP + PII/PHI summary)
   - **Migration Notes**: If migrations exist (from PROGRESS.md) -- include backward compatibility assessment
2. Save draft to `.workflows/pr/PR.md`
3. Push branch to remote: `git push -u origin feature/{feature-slug}`

**Output**: `.workflows/pr/PR.md` saved, branch pushed to remote

### Phase 5: ASK USER (Gated)
**Duration**: 1-2 minutes

Steps:
1. Display PR draft to user
2. **ASK**: "Create PR on GitHub? (default: no)"
3. If user says yes:
   - Create PR using `gh pr create` with generated title and description
   - Report PR URL to user
4. If user says no or does not respond (default):
   - Report: "Branch `feature/{slug}` pushed. PR draft saved to `.workflows/pr/PR.md`. You can create the PR manually when ready."

**Output**: PR URL (if approved) or branch + draft location (if declined)

---

## PR.md Format

```markdown
# PR: {Feature Title}

## Branch
`feature/{feature-slug}`

## Summary
- {Key change 1 from DESIGN.md}
- {Key change 2 from DESIGN.md}
- {Key change 3 from DESIGN.md}

## Changes

### Phase 1: {Phase Name}
- `{file_path}`: {what it does}
- `{file_path}`: {what it does}

### Phase 2: {Phase Name}
- `{file_path}`: {what it does}

### Phase N: {Phase Name}
- ...

## Architecture Decisions
- **ADR-001: {title}** -- {one-line summary of decision and rationale}
- **ADR-002: {title}** -- {one-line summary of decision and rationale}

## Test Plan
- Unit tests: {count} tests, {count} assertions
- Integration tests: {count} (mocked external APIs)
- Functional tests: {count} (API endpoints)
- Coverage: {assessment per area from REVIEW.md}

### Manual Testing
- [ ] {manual test step 1}
- [ ] {manual test step 2}
- [ ] {manual test step 3}

## Security Review
- **OWASP checks**: {PASS / summary of findings}
- **PII/PHI audit**: {PASS / summary of findings}
- **Secrets scan**: {PASS / summary of findings}

## Migration Notes
{If applicable: migration description, backward compatibility, rollback procedure}
{If none: "No migrations in this PR."}

## Review Notes
- Blocking issues resolved during review: {count}
- Suggestions from review: {count} ({which addressed, which deferred})
- Quality score: {X}/10
- Security score: {X}/10
```

---

## PR Description Template (for gh pr create)

When creating the actual GitHub PR, use this condensed format:

```markdown
## Summary
- {bullet 1}
- {bullet 2}
- {bullet 3}

## Changes
{List key changes by phase}

## Architecture Decisions
{Key ADR summaries}

## Test Plan
{Coverage summary}
- [ ] {manual test 1}
- [ ] {manual test 2}

## Security
- OWASP: {PASS/summary}
- PII/PHI: {PASS/summary}

## Migration
{If applicable, or "None"}
```

---

## Decision Points

### Decision 1: Commit Strategy
**Question**: Single commit or per-phase commits?
**Options**:
- A: Single commit -- clean history, easy revert (for 1-2 phases)
- B: Per-phase commits -- granular history, easier to review (default for 3+ phases)
- C: Ask user -- let them choose

**Recommended approach**: A for 1-2 phases, B for 3+ phases. Never ask unless user has a known preference.

### Decision 2: PR Creation
**Question**: Create PR on GitHub?
**Options**:
- A: Always ask user, default NO (default)
- B: Always create PR automatically
- C: Never create PR, only push branch

**Recommended approach**: A -- always ask, always default to no. NEVER auto-create PR (option B is forbidden).

### Decision 3: Files to Stage
**Question**: Which files to include in commits?
**Options**:
- A: Only production code + tests (minimal)
- B: Production code + tests + configs + migrations (default)
- C: Everything except .workflows/

**Recommended approach**: B -- include all implementation artifacts but never pipeline internals.

---

## Prompts Sequence

### Step 1: Validate + Branch + Commit
**Prompt**:
```
[TASK]
Create feature branch and commits for the /dev workflow PR step.

[CONTEXT]
Feature slug: {{feature_slug}}
Task: {{task_description}}
Progress: .workflows/implement/PROGRESS.md
Review: .workflows/review/{{feature_slug}}/REVIEW.md

[STEPS]
1. Verify REVIEW.md verdict is APPROVED (abort if BLOCKED)
2. Create branch: feature/{{feature_slug}}
3. Stage all production + test + config + migration files from PROGRESS.md
4. Do NOT stage: .workflows/, .env, .codemap-cache/
5. Create commit(s):
   - If 1-2 phases: single commit "feat: {{description}}"
   - If 3+ phases: one commit per phase "feat({{scope}}): {{phase_description}}"
6. CRITICAL: No Co-Authored-By in any commit

[COMMIT FORMAT]
Use HEREDOC:
git commit -m "$(cat <<'EOF'
feat: {description}

{body}
EOF
)"

NEVER add Co-Authored-By lines. This is a strict, non-negotiable rule.
```

### Step 2: PR Draft + Push + Ask User
**Prompt**:
```
[TASK]
Generate PR description, push branch, and ask user about PR creation.

[CONTEXT]
Branch: feature/{{feature_slug}}
Design: .workflows/design/DESIGN.md
Plan: .workflows/plan/{{feature_slug}}/001-PLAN.md
Review: .workflows/review/{{feature_slug}}/REVIEW.md
Progress: .workflows/implement/PROGRESS.md

[STEPS]
1. Generate PR description from all artifacts:
   - Summary from DESIGN.md
   - Changes from PLAN.md phases
   - ADRs from design/adr/
   - Test plan from REVIEW.md
   - Security summary from REVIEW.md
   - Migration notes from PROGRESS.md (if any)
2. Save to .workflows/pr/PR.md
3. Push branch: git push -u origin feature/{{feature_slug}}
4. Display PR draft to user
5. ASK: "Create PR on GitHub? (default: no)"
6. If user says yes: gh pr create --title "..." --body "..."
7. If user says no (default): report branch URL and PR.md location

[IMPORTANT]
- Default is NO for PR creation
- NEVER create PR without asking
- Include security review results in PR description
```

---

## Success Criteria

### Minimum Viable Outcome
- [ ] Feature branch created with correct name (`feature/{slug}`)
- [ ] Code committed with descriptive message(s)
- [ ] No `Co-Authored-By` in any commit
- [ ] No `.workflows/` files in any commit
- [ ] Branch pushed to remote
- [ ] `.workflows/pr/PR.md` saved

### Good Outcome
- [ ] Per-phase commits for 3+ phases (granular history)
- [ ] PR description includes all artifact summaries (design, ADRs, tests, security)
- [ ] Migration notes included if migrations exist
- [ ] Security review results in PR description
- [ ] User asked before PR creation (default: no)

### Excellent Outcome
- [ ] PR description is ready to merge without edits
- [ ] Commits follow conventional commit format consistently
- [ ] ADR references included in PR description with decision rationale
- [ ] Manual test checklist is specific and actionable
- [ ] PR created via `gh` with user approval

---

## Anti-Patterns

### What to Avoid

1. **Auto-Creating PR**: NEVER create a PR without explicit user approval. The default answer is NO. Branch + commits are always created, but PR creation is gated behind user confirmation.

2. **Co-Authored-By Headers**: NEVER add `Co-Authored-By` lines to any commit. This is a strict, non-negotiable rule. No exceptions.

3. **Staging .workflows/**: The `.workflows/` directory contains internal pipeline state (research, design, plan, progress, review artifacts). It must NEVER be committed. These are working documents, not deliverable code.

4. **Single Giant Commit**: For implementations with 3+ phases, per-phase commits provide better git history and easier code review. Each commit should correspond to one implementation phase.

5. **Vague PR Description**: Writing "implemented feature" without details. The PR description should synthesize information from all pipeline artifacts -- design decisions, changes per phase, test coverage, security review, migration notes.

6. **Force Push**: Never force push feature branches. If commit history needs cleaning, use interactive rebase locally before the first push.

7. **Staging Secrets**: Never stage `.env`, `credentials.json`, or other files containing secrets. Verify staged files before committing.

### Warning Signs
- `Co-Authored-By` appears in any commit message -- strict rule violated
- `.workflows/` files appear in `git diff --cached` -- internal artifacts leaked
- PR created without asking user -- user consent not obtained
- Single commit for 4+ phases -- granular history lost
- PR description has no security section -- review summary incomplete
- Migration notes missing when migrations exist -- deployment risk not communicated
- `.env` or credential files in staged changes -- secrets exposed

---

## Example Walkthrough

### Context
Task: "Add Apple Health integration to the wellness-backend"
4 phases implemented, review passed with APPROVED verdict, 0 blocking issues.

### How It Played Out

**Phase 1 (VALIDATE)**:
```
Read REVIEW.md:
  Verdict: APPROVED
  Quality Score: 9/10
  Security Score: 9/10
  Blocking Issues: 0

Read PROGRESS.md:
  Phase 1: 4 files (client, token entity mod, migration, controller)
  Phase 2: 2 files (mapper, DTO)
  Phase 3: 4 files (message, handler, webhook controller, messenger.yaml)
  Phase 4: 1 file (status controller)
  + 8 test files

Read DESIGN.md:
  Apple Health integration with device-token auth, push-based sync, existing entity mapping

All clear. Proceeding.
```

**Phase 2 (BRANCH)**:
```
git checkout -b feature/apple-health-integration

Staged files (19 total):
  src/Service/Integration/AppleHealth/AppleHealthClient.php
  src/Service/Integration/AppleHealth/AppleHealthMapper.php
  src/Entity/IntegrationToken.php (modified)
  src/DTO/AppleHealth/AppleHealthWorkoutData.php
  src/Message/AppleHealthSyncMessage.php
  src/MessageHandler/AppleHealthSyncHandler.php
  src/Controller/Api/V1/Integration/AppleHealthConnectController.php
  src/Controller/Api/V1/Integration/AppleHealthWebhookController.php
  src/Controller/Api/V1/Integration/AppleHealthStatusController.php
  migrations/Version20240115_AddAppleHealthTokenType.php
  config/packages/messenger.yaml (modified)
  + 8 test files

NOT staged:
  .workflows/ (internal)
  .env (secrets)
```

**Phase 3 (COMMIT -- per-phase, 4 phases)**:
```
Commit 1:
  feat(auth): add Apple Health device-token authentication

  - Create AppleHealthClient with device-token auth flow
  - Extend IntegrationToken entity with APPLE_HEALTH type
  - Add connect endpoint POST /api/v1/integrations/apple-health/connect
  - Add migration for token type enum extension

Commit 2:
  feat(mapping): add Apple Health data mapper

  - Create AppleHealthMapper for HealthKit to entity conversion
  - Create AppleHealthWorkoutData DTO with readonly properties
  - Handle unknown workout types gracefully with enum

Commit 3:
  feat(sync): add Apple Health sync pipeline

  - Create AppleHealthSyncMessage + AppleHealthSyncHandler
  - Add webhook endpoint with HMAC signature + timestamp verification
  - Configure apple-health.sync queue in messenger.yaml
  - Handler is idempotent (deduplication by externalId)

Commit 4:
  feat(status): add Apple Health connection status endpoint

  - Create status endpoint GET /api/v1/integrations/apple-health/status
  - Returns connected/disconnected based on token validity

(No Co-Authored-By in any commit)
```

**Phase 4 (PR DRAFT)**:
```
Generated .workflows/pr/PR.md with full description.

git push -u origin feature/apple-health-integration
  → Branch pushed to remote
```

**Phase 5 (ASK USER)**:
```
Displayed PR draft to user.

"Create PR on GitHub? (default: no)"

User: "yes"

gh pr create \
  --title "Add Apple Health integration" \
  --body "$(cat <<'EOF'
## Summary
- Add Apple Health wearable integration using existing adapter pattern
- Device-token auth (not OAuth2) via HealthKit background delivery
- 3 new API endpoints: connect, webhook, status
- Push-based sync pipeline with idempotent handler

## Changes
### Phase 1: Auth Foundation
- AppleHealthClient, IntegrationToken extension, connect endpoint, migration

### Phase 2: Data Mapping
- AppleHealthMapper, AppleHealthWorkoutData DTO

### Phase 3: Sync Pipeline
- SyncMessage, SyncHandler, webhook controller, messenger.yaml config

### Phase 4: Status Endpoint
- Status endpoint for connection health check

## Architecture Decisions
- ADR-001: Device-token auth (Apple Health is device-level, not OAuth2)
- ADR-002: Push-based sync via HealthKit background delivery
- ADR-003: Map to existing Workout/HealthMetric entities (no new tables)

## Test Plan
- 15 unit tests, 35 assertions
- 3 integration tests (mocked Apple API)
- 3 functional tests (API endpoints)
- Coverage: 87% health data, 92% handlers, 85% endpoints

- [ ] Connect with valid Apple Health token and verify stored
- [ ] Send webhook with valid HMAC signature and verify workout created
- [ ] Send webhook with invalid signature and verify 403
- [ ] Check status endpoint returns connected/disconnected correctly

## Security
- OWASP: PASS (all 10 checks)
- PII/PHI: PASS (health data not in logs, encrypted at rest)
- Webhook: HMAC signature + timestamp verification

## Migration
- Add APPLE_HEALTH to token_type enum (backward compatible)
- No downtime required, no data migration needed
EOF
)"

→ PR URL: https://github.com/org/wellness-backend/pull/42
```

### Outcome
- Feature branch with 4 granular commits (one per implementation phase)
- No Co-Authored-By in any commit
- Comprehensive PR description synthesized from all pipeline artifacts
- PR created only after explicit user approval
- Total time: ~8 minutes

---

## Related

- **Previous step**: [5-review.md](./5-review.md) -- Full-scope code review
- **Next step**: None (final step of /dev workflow)
- **Input**: All pipeline artifacts (`.workflows/design/`, `.workflows/plan/`, `.workflows/implement/`, `.workflows/review/`)
- **Output**: Git branch + commits, `.workflows/pr/PR.md`, PR on GitHub (if user approves)
- **No agent team**: This scenario uses bash/gh CLI directly, no subagent spawning
