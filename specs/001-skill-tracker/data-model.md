# Data Model: Installing Skill Tracker

**Date**: 2025-12-21
**Feature**: 001-skill-tracker

## Overview

The skill tracker uses two JSONL log files for persistent storage. No database or external storage required.

---

## Entity 1: Prompt Log Entry

**File**: `.claude/activity-logs/prompts.jsonl`

**Purpose**: Record all user prompts for context and correlation with skill activations.

### Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| timestamp | string (ISO 8601) | Yes | UTC timestamp when prompt was submitted |
| session_id | string | Yes | Claude Code session identifier |
| prompt | string | Yes | Full prompt text submitted by user |

### Example

```json
{"timestamp":"2025-12-21T10:00:00Z","session_id":"abc123","prompt":"Deploy Kafka to the staging cluster"}
```

### Validation Rules

- `timestamp` must be valid ISO 8601 UTC format (YYYY-MM-DDTHH:MM:SSZ)
- `session_id` must be non-empty string
- `prompt` must be non-empty string (may contain newlines, special characters)

### Write Behavior

- Append-only (new entries added to end of file)
- File created on first write if not exists
- No automatic rotation or deletion

---

## Entity 2: Skill Usage Event

**File**: `.claude/activity-logs/skill-usage.jsonl`

**Purpose**: Track skill activations and verification results.

### Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| timestamp | string (ISO 8601) | Yes | UTC timestamp of event |
| session_id | string | Yes | Claude Code session identifier |
| skill | string | Yes | Skill name (directory name under .claude/skills/) |
| event | enum | Yes | Event type: "start" or "verify" |
| status | enum | Conditional | For "verify" events: "success" or "failure" |

### Examples

**Skill Activation (start event)**:
```json
{"timestamp":"2025-12-21T10:01:00Z","session_id":"abc123","skill":"deploying-kafka-k8s","event":"start"}
```

**Verification Success**:
```json
{"timestamp":"2025-12-21T10:05:00Z","session_id":"abc123","skill":"deploying-kafka-k8s","event":"verify","status":"success"}
```

**Verification Failure**:
```json
{"timestamp":"2025-12-21T10:05:00Z","session_id":"abc123","skill":"deploying-kafka-k8s","event":"verify","status":"failure"}
```

### Validation Rules

- `timestamp` must be valid ISO 8601 UTC format
- `session_id` must be non-empty string
- `skill` must be valid skill name (lowercase, hyphens, no spaces)
- `event` must be exactly "start" or "verify"
- `status` required when `event` is "verify", must be "success" or "failure"
- `status` should be absent when `event` is "start"

### Write Behavior

- Append-only
- File created on first write if not exists
- Events are independent (no foreign key relationships)

---

## Entity 3: Hook Configuration

**File**: `.claude/settings.json` (project-level, in project root)

**Purpose**: Register hooks with Claude Code. Using project-level settings ensures hooks are scoped to this project only.

### Schema (within settings.json)

```typescript
interface HookConfiguration {
  hooks: {
    [eventType: string]: HookEntry[];
  }
}

interface HookEntry {
  matcher: string;  // Tool name regex pattern or empty for all
  hooks: Hook[];
}

interface Hook {
  type: "command";
  command: string;  // Shell command to execute
}
```

### Supported Event Types

| Event | When Triggered | Matcher Examples |
|-------|----------------|------------------|
| UserPromptSubmit | User submits prompt | "" (empty = all) |
| PreToolUse | Before tool execution | "Bash\|View\|Read" |
| PostToolUse | After tool completion | "Bash\|View\|Read" |

### Example

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/track-prompt.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Read|Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/track-skill-start.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/track-skill-end.sh"
          }
        ]
      }
    ]
  }
}
```

### Async Hook Output

Hooks can return JSON to control execution:
```bash
echo '{"async":true,"asyncTimeout":15000}'  # Non-blocking, 15s timeout
```

For tracking hooks, we use async to avoid blocking Claude Code operations.

### Merge Behavior

When setup.py updates settings:
1. Load existing `.claude/settings.json` (or empty object if file missing)
2. For each hook event type:
   - If event type not present, add entire configuration
   - If event type present, check if our command already registered
   - Only add if command not already in list (avoid duplicates)
3. Write back with proper JSON formatting

---

## Relationships

```
┌─────────────────┐      ┌─────────────────────┐
│  Prompt Entry   │      │  Skill Usage Event  │
├─────────────────┤      ├─────────────────────┤
│ timestamp       │      │ timestamp           │
│ session_id ─────┼──────┤ session_id          │
│ prompt          │      │ skill               │
└─────────────────┘      │ event               │
                         │ status?             │
                         └─────────────────────┘
```

**Correlation**: Entries are correlated by `session_id`. A single session may have:
- Multiple prompts
- Multiple skill activations
- Multiple verification events

**No Referential Integrity**: Log files are independent. Missing session_id matches are acceptable (prompts may not trigger skills).

---

## Storage Estimates

| Scenario | Log Size | Growth Rate |
|----------|----------|-------------|
| Light usage (10 prompts/day) | ~5KB/day | ~150KB/month |
| Medium usage (50 prompts/day) | ~25KB/day | ~750KB/month |
| Heavy usage (200 prompts/day) | ~100KB/day | ~3MB/month |

**Recommendation**: Manual cleanup every 3-6 months or when logs exceed 10MB.

---

## Skill Type Detection

Skills are classified at analysis time (not at logging time) based on directory structure:

| Skill Type | Detection Rule | Example |
|------------|----------------|---------|
| Procedural | `scripts/verify.py` exists in skill directory | `installing-skill-tracker`, `deploying-kafka-k8s` |
| Content | No `scripts/verify.py` in skill directory | `internal-comms`, `fetching-library-docs` |

**Detection Logic** (in analyze-skills.py):
```python
def get_skill_type(skill_name: str) -> str:
    verify_path = Path(f".claude/skills/{skill_name}/scripts/verify.py")
    return "procedural" if verify_path.exists() else "content"
```

---

## Analysis Aggregations

The analyze-skills.py script computes:

| Metric | Calculation | Applies To |
|--------|-------------|------------|
| Invocation count | COUNT WHERE event="start" GROUP BY skill | All skills |
| Success count | COUNT WHERE event="verify" AND status="success" GROUP BY skill | Procedural only |
| Failure count | COUNT WHERE event="verify" AND status="failure" GROUP BY skill | Procedural only |
| Success rate | success_count / (success_count + failure_count) | Procedural only |
| Unused skills | skills in .claude/skills/ NOT IN invocation counts | All skills |
| High failure rate | Skills where failure_rate > 0.3 | Procedural only |

**Content Skills**: Show invocation count only. Success rate displays as "N/A" since content skills have no verification step.
