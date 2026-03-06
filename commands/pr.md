---
name: pr
description: PR phase — create Pull Request with design references, test plan from artifacts, and CI verification. No agents — direct command execution.
allowed_tools: ["Read", "Grep", "Glob", "Bash", "Write"]
triggers:
  - "create pr"
  - "створи pr"
  - "pull request"
skills:
  - auto:{project}-patterns
---

# /pr - Pull Request Creation

Creates a Pull Request with a structured description built from workflow artifacts — design references, test plan, quality checks summary.

## Usage

```bash
/pr {feature-name}                              # Create PR to main/master
/pr {feature-name} --base develop               # Target branch
/pr {feature-name} --draft                       # Draft PR
/pr {feature-name} --reviewers @user1,@user2     # Assign reviewers
```

## Prerequisites

Implementation phase completed:
```
.workflows/{feature-name}/design/adr.md              — design context
.workflows/{feature-name}/design/test-strategy.md     — test plan source
.workflows/{feature-name}/implement/                  — review reports
```

## This Is a Direct Command

No agents or teams — YOU (Claude) execute this directly using `Bash` and `gh` CLI.

## Execution

### Step 1: Gather Information

Run in parallel:

```bash
# Current branch and status
git status

# Changes vs base branch
git diff main...HEAD --stat

# Commit history for this feature
git log main...HEAD --oneline

# Check if remote tracking is set up
git branch -vv
```

### Step 2: Read Workflow Artifacts

Read available artifacts to build PR description:

1. `.workflows/{feature-name}/design/adr.md` → Summary and context
2. `.workflows/{feature-name}/design/test-strategy.md` → Test plan
3. `.workflows/{feature-name}/design/architecture.md` → Architecture changes summary
4. `.workflows/{feature-name}/plan/overview.md` → Phases breakdown
5. `.workflows/{feature-name}/implement/phase-*-report.md` → Quality checks results

### Step 3: Build PR Description

```markdown
## Summary
{1-3 bullets from ADR context — WHY this change}

## Architecture Decision
{Key decision from adr.md — what approach was chosen and why}

## Changes by Phase

### Phase 1: {title}
- {key changes}

### Phase 2: {title}
- {key changes}

## Test Plan

### New Tests Added
| Test | Type | Covers |
|------|------|--------|
{from test-strategy.md — actual tests written}

### Test Results
- Total: {N}, Passed: {N}, New: {N}
- Coverage (new code): {N}%

## Quality Checks
- [x] Security review: passed
- [x] Quality review: passed
- [x] Design compliance: passed
- [x] Build: passed
- [x] Linters: passed

## Design References
- Research: `.workflows/{feature-name}/research/research-report.md`
- Architecture: `.workflows/{feature-name}/design/architecture.md`
- ADR: `.workflows/{feature-name}/design/adr.md`
- Test Strategy: `.workflows/{feature-name}/design/test-strategy.md`
- Plan: `.workflows/{feature-name}/plan/overview.md`
```

### Step 4: Create PR

```bash
# Push if needed
git push -u origin HEAD

# Create PR
gh pr create \
  --title "{short descriptive title}" \
  --body "$(cat <<'EOF'
{generated PR description}
EOF
)"
```

With options:
- `--draft` → add `--draft` flag
- `--base develop` → add `--base develop`
- `--reviewers @user1,@user2` → add `--reviewer user1 --reviewer user2`

### Step 5: Verify CI

```bash
# Watch CI checks
gh pr checks {pr-number} --watch
```

If CI fails:
1. Read failure details
2. Analyze the error
3. If fixable — fix and push
4. If not — report to user

### Step 6: Report

```markdown
## PR Created: {feature-name}

**URL:** {pr-url}
**Branch:** {branch} → {base}
**Status:** {draft/ready}

### CI Checks
| Check | Status |
|-------|--------|
| {name} | PASS/FAIL/PENDING |

### Next Steps
{If CI passes: "Ready for human review"}
{If CI fails: "CI check {name} failed — {details}"}
```

---

## Important Notes

- PR description language: Ukrainian (per language rule)
- Commit messages: English (per git rule)
- Do NOT force push
- Do NOT add Co-Authored-By (per git rule)
- `.workflows/` files are included in the PR — they serve as design documentation
- If no workflow artifacts exist, create a simpler PR with just git diff analysis

---

## Related

- Previous phase: `/implement {feature-name}` or `/docs-suite`
- Full flow: `scenarios/delivery/feature-development.md`
