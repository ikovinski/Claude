# Hooks

Hooks are automated actions that trigger on Claude Code events.

## Event Types

| Event | When it Fires | Use Case |
|-------|---------------|----------|
| `PreToolUse` | Before a tool executes | Validation, reminders, confirmation |
| `PostToolUse` | After a tool finishes | Formatting, linting, feedback |
| `Stop` | When Claude responds | Catch issues in responses |
| `UserPromptSubmit` | When user sends message | Pre-processing |

## Action Types

| Type | Description |
|------|-------------|
| `message` | Show informational message |
| `warning` | Show warning (yellow) |
| `confirm` | Ask for confirmation before proceeding |
| `command` | Run shell command |
| `block` | Block the action entirely |

## Matcher Syntax

Matchers use expression syntax:

```
tool == 'Edit'                           # Exact match
path matches '\\.php$'                   # Regex match
command matches '(npm|yarn)'             # Multiple patterns
tool == 'Bash' && command matches 'git'  # Combined conditions
```

## Available Variables

| Variable | Description |
|----------|-------------|
| `tool` | Tool name (Edit, Bash, Write, etc.) |
| `path` | File path (for file operations) |
| `command` | Command string (for Bash) |
| `response` | Claude's response (for Stop event) |

## How to Use

### Option 1: Claude Code Settings

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "tool == 'Edit' && path matches '\\.php$'",
        "command": "echo 'Editing PHP file'"
      }
    ]
  }
}
```

### Option 2: Project-Specific

Claude Code reads hooks from project settings if configured.

## Examples

### Block Dangerous Commands

```json
{
  "event": "PreToolUse",
  "matcher": "tool == 'Bash' && command matches 'rm -rf'",
  "action": {
    "type": "block",
    "message": "Dangerous command blocked. Use explicit paths."
  }
}
```

### Auto-Format on Save

```json
{
  "event": "PostToolUse",
  "matcher": "tool == 'Edit' && path matches '\\.php$'",
  "action": {
    "type": "command",
    "command": "php-cs-fixer fix {{path}}"
  }
}
```

### Remind About Tests

```json
{
  "event": "Stop",
  "matcher": "response matches 'created.*Handler'",
  "action": {
    "type": "message",
    "content": "New handler created. Don't forget to add tests for idempotency!"
  }
}
```

## Testing Hooks

Hooks are evaluated at runtime. To test:

1. Create a hook in `hooks.json`
2. Trigger the matching action in Claude Code
3. Observe the hook behavior
4. Adjust matcher if needed

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Hook not firing | Check matcher regex escaping (`\\.` for literal dot) |
| Command fails | Ensure command is in PATH, use full paths |
| Too many confirmations | Make matcher more specific |
