---
name: sentry-triage
description: Sentry triage — збирає issues з Sentry, категоризує по критичності та типу, групує в tasks для feature-development flow.
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "TodoWrite", "mcp__sentry__list_issues", "mcp__sentry__get_issue_details", "mcp__sentry__get_issue_tag_values", "mcp__sentry__list_issue_events", "mcp__sentry__list_events", "mcp__sentry__analyze_issue_with_seer", "mcp__sentry__find_projects"]
triggers:
  - "sentry-triage"
  - "sentry triage"
  - "збери помилки"
  - "проаналізуй sentry"
skills:
  - auto:{project}-patterns
---

# /sentry-triage - Sentry Issue Triage

Collects issues from Sentry, categorizes by severity and type, groups related issues, and creates task files for the feature-development flow.

## Usage

```bash
/sentry-triage
# → asks: "Sentry project slug?" → user enters project slug → runs triage
```

### Optional filters (after project prompt)

| Argument | Default | Description |
|----------|---------|-------------|
| `--env` | all | Environment filter: `prod`, `stage`, `prod,stage`, or omit for all |
| `--period` | `14d` | Time period for analysis |
| `--min-events` | `10` | Minimum events threshold to include |
| `--category` | all | Filter by category (AMQP, DB, etc.) |
| `--top` | `50` | Max issues to enrich with details |
| `--tasks-dir` | `docs/tasks` | Output directory for task files |

Filters can be passed inline:
```bash
/sentry-triage --env prod --period 30d --category DB
/sentry-triage --env stage
/sentry-triage --env prod,stage --min-events 100
```

## You Are the Sentry Triager

When this command runs, YOU (Claude) become the **Sentry Triager** agent. Read the full agent persona from:

```
agents/engineering/sentry-triager.md
```

Apply the agent's identity, biases, and process.

## Execution

### Step 0: Ask Project & Validate

1. **Ask user for project slug:**
   ```
   Sentry project slug (e.g. bodyfit-api):
   ```
   Wait for user input. This is the `projectSlugOrId` used in all Sentry MCP calls.

2. **Resolve org and region** from project:
   ```
   find_projects(query: "{project}")
   ```
   Extract `organization.slug` and region from response.

3. Parse optional filters (`--env`, `--period`, `--min-events`, `--category`, `--top`, `--tasks-dir`)

4. **Resolve `--env` to Sentry query fragment:**

   | `--env` value | Query fragment |
   |---------------|---------------|
   | `prod` | `environment:production` |
   | `stage` | `environment:staging` |
   | `prod,stage` | `environment:production environment:staging` |
   | not set | _(no environment filter)_ |

   Map short aliases to Sentry environment names. If the project uses non-standard names (e.g. `prod` instead of `production`), adapt after checking `get_issue_tag_values(tagKey: "environment")`.

5. Announce config:
   ```
   Sentry Triage:
     Project: {project}
     Org:     {org} (auto-detected)
     Env:     {env or "all"}
     Period:  {period}
     Filters: {min-events, category, top — if set}
   ```

5. Create output directory:
   ```bash
   mkdir -p {tasks-dir}
   ```

### Step 1: Collect Issues

Fetch unresolved issues sorted by frequency.

Build query string: start with `"is:unresolved"`, then append the environment fragment from Step 0 if `--env` was provided.

```
# Example: --env prod
mcp__sentry__list_issues(
  projectSlugOrId: "{project}",
  query: "is:unresolved environment:production",
  sort: "freq",
  limit: 100,
  regionUrl: "{region}"
)

# Example: no --env (all environments)
mcp__sentry__list_issues(
  projectSlugOrId: "{project}",
  query: "is:unresolved",
  sort: "freq",
  limit: 100,
  regionUrl: "{region}"
)
```

If result is empty — warn and suggest adjusting `--period` or checking project slug.

**Quick stats:** count total issues, note the events range (max → min).

### Step 2: Enrich Top Issues

For the top `{--top}` issues by event count:

```
mcp__sentry__get_issue_details(
  issueId: "{ISSUE-ID}",
  organizationSlug: "{org}",
  regionUrl: "{region}"
)
```

Extract per issue:
- Exception type + message
- Stacktrace root frames (file, line, function)
- First seen / last seen
- Events count
- Tags (environment, server)

**Parallelism**: call `get_issue_details` for multiple issues in parallel where possible.

For CRITICAL candidates (high events), additionally fetch:
```
mcp__sentry__get_issue_tag_values(issueId: "{ID}", tagKey: "environment", regionUrl: "{region}")
mcp__sentry__get_issue_tag_values(issueId: "{ID}", tagKey: "url", regionUrl: "{region}")
```

### Step 3: Categorize

Apply categorization rules from the agent file:

1. **Severity** (CRITICAL / HIGH / MEDIUM / LOW) — based on events count + recency + user impact
2. **Category** (AMQP, DB, Business Logic, etc.) — based on exception type + stacktrace

If `--category` filter provided — only create tasks for matching category, but still show all in triage report.

If `--min-events` provided — exclude issues below threshold from task creation (still list in report).

### Step 4: Group Related Issues

Group by shared root cause:
- Same stacktrace root (file:function)
- Same exception class in same component
- Same external dependency
- Causal chain (connection lost → handler failed)

Each group becomes one task. Standalone issues with severity >= MEDIUM also become individual tasks.

### Step 5: Write Output

Following the agent's output format:

1. **`{tasks-dir}/triage-report.md`** — full report with severity tables, groups, category summary
2. **`{tasks-dir}/task-{N}-{slug}/issue.md`** — per group/issue, with Sentry context for `/feature` intake

Numbering: tasks ordered by severity (CRITICAL first), then by events count within severity.

Slug: kebab-case from primary error description (e.g. `amqp-transport-errors`, `db-connection-timeout`, `notification-delay`).

### Step 6: Summary

Output triage summary to user following the agent's Output Summary format.

Include recommended priority order for tackling tasks.

---

## Output Structure

```
{tasks-dir}/
├── triage-report.md
├── task-1-{slug}/
│   └── issue.md
├── task-2-{slug}/
│   └── issue.md
├── task-3-{slug}/
│   └── issue.md
└── ...
```

## Integration with Feature Flow

Each created task is ready for the feature-development flow:

```bash
# Pick a task and start feature flow
/feature --from docs/tasks/task-1-amqp-transport/issue.md "Fix AMQP transport errors"

# Or manually — task description serves as research input
/research --type bug --sentry {PRIMARY-ISSUE-ID} "{task title}"
```

The `issue.md` file contains:
- Sentry issue IDs (for `--sentry` flag in `/research`)
- Stacktrace (for scope identification)
- Context and tags (for understanding impact)
- Suggested `/feature` command

---

## Re-running

Running `/sentry-triage` again will:
- **Overwrite** `triage-report.md` with fresh data
- **NOT overwrite** existing `task-{N}-{slug}/issue.md` files — skip if directory exists
- To force overwrite, delete the task directory first

This allows incremental triage — run weekly, only new tasks are created.

---

## Examples

### Basic
```bash
/sentry-triage
# → "Sentry project slug:" → bodyfit-api → runs triage (all environments)
```

### Production only
```bash
/sentry-triage --env prod
# → only production issues
```

### Staging only
```bash
/sentry-triage --env stage
```

### Both environments explicitly
```bash
/sentry-triage --env prod,stage --period 30d --min-events 100
```

### Focus on category
```bash
/sentry-triage --env prod --category DB --top 20
```

---

## Related

- Agent: `agents/engineering/sentry-triager.md`
- Next step: `/feature --from docs/tasks/task-N/issue.md` → full development flow
- Scenario: `scenarios/delivery/feature-development.md`
