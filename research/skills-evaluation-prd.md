# Skills Evaluation PRD

> **Purpose**: Practical measurement of skill value using Claude Code hooks.
> **Philosophy**: If we can't measure it, we can't improve it. But measurement must be zero-overhead.
> **Key Constraint**: No custom infrastructure. Use what Claude Code provides out of the box.

---

## Part 1: What We're Measuring

### The Three Dimensions

| Dimension | Question | Why It Matters |
|-----------|----------|----------------|
| **Discovery & Routing** | Does the right skill fire for the right task? | Wrong skill = wrong outcome or wasted context |
| **Execution Success** | Does the skill complete its job? | Broken skills erode trust |
| **Value Delivered** | Was invoking the skill worth it? | Dead weight skills pollute the library |

### The Core Insight

> **If two skills plausibly trigger on the same query, at least one of them is incorrectly designed.**

This single rule catches most skill design failures before they compound.

---

## Part 2: Claude Code Hooks — The Measurement Layer

### Available Hooks (Out of the Box)

| Hook | When | What You Capture |
|------|------|------------------|
| `UserPromptSubmit` | User submits prompt | `prompt`, `session_id`, `timestamp` |
| `PreToolUse` | Before tool execution | `tool_name`, `tool_input` |
| `PostToolUse` | After tool completion | `tool_name`, `tool_input`, `tool_response` |
| `Stop` | Agent finishes | Task complete signal |
| `SessionStart` | Session begins | Context for correlation |

### How Skills Get Invoked

When Claude activates a skill, it reads the SKILL.md file:

```bash
# Claude issues this command
cat /path/to/.claude/skills/deploying-kafka-k8s/SKILL.md
```

**Detection pattern**: `PreToolUse` with matcher `Bash|View` + grep for `/skills/.*/SKILL.md`

---

## Part 3: Minimal Skill Tracker Implementation

### File Structure

```
.claude/
├── hooks/
│   ├── track-prompt.sh           # UserPromptSubmit hook
│   ├── track-skill-start.sh      # PreToolUse hook  
│   └── track-skill-end.sh        # PostToolUse hook
├── activity-logs/
│   ├── prompts.jsonl             # All prompts
│   └── skill-usage.jsonl         # Skill invocations
└── settings.json                 # Hook configuration
```

### settings.json Configuration

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/track-prompt.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash|View",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/track-skill-start.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|View",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/track-skill-end.sh"
          }
        ]
      }
    ]
  }
}
```

### track-prompt.sh

```bash
#!/bin/bash
# Captures: prompt text, timestamp, session_id
# Output: prompts.jsonl

LOG_DIR="$CLAUDE_PROJECT_DIR/.claude/activity-logs"
mkdir -p "$LOG_DIR"

# Read JSON from stdin
INPUT=$(cat)

# Extract fields
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log to JSONL
echo "{\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"$SESSION_ID\",\"prompt\":$(echo "$PROMPT" | jq -Rs .)}" >> "$LOG_DIR/prompts.jsonl"

exit 0
```

### track-skill-start.sh

```bash
#!/bin/bash
# Detects skill activation via SKILL.md file reads
# Output: skill-usage.jsonl (start event)

LOG_DIR="$CLAUDE_PROJECT_DIR/.claude/activity-logs"
mkdir -p "$LOG_DIR"

INPUT=$(cat)

# Check if this is a skill file read
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .tool_input.file_path // empty')

if echo "$COMMAND" | grep -q '/skills/.*/SKILL.md'; then
  # Extract skill name from path
  SKILL_NAME=$(echo "$COMMAND" | sed -E 's|.*/skills/([^/]+)/SKILL.md.*|\1|')
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Log skill activation
  echo "{\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"$SESSION_ID\",\"skill\":\"$SKILL_NAME\",\"event\":\"start\"}" >> "$LOG_DIR/skill-usage.jsonl"
fi

exit 0
```

### track-skill-end.sh

```bash
#!/bin/bash
# Captures skill completion and verify.py results
# Output: skill-usage.jsonl (end event)

LOG_DIR="$CLAUDE_PROJECT_DIR/.claude/activity-logs"
mkdir -p "$LOG_DIR"

INPUT=$(cat)

# Check for verify.py execution
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
RESPONSE=$(echo "$INPUT" | jq -r '.tool_response // empty')

if echo "$COMMAND" | grep -q 'verify.py'; then
  # Extract skill name from verify.py path
  SKILL_NAME=$(echo "$COMMAND" | sed -E 's|.*/skills/([^/]+)/scripts/verify.py.*|\1|')
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Check if verification passed (exit code 0)
  if echo "$RESPONSE" | grep -q '"exit_code": 0\|"exitCode": 0'; then
    STATUS="success"
  else
    STATUS="failure"
  fi
  
  echo "{\"timestamp\":\"$TIMESTAMP\",\"session_id\":\"$SESSION_ID\",\"skill\":\"$SKILL_NAME\",\"event\":\"verify\",\"status\":\"$STATUS\"}" >> "$LOG_DIR/skill-usage.jsonl"
fi

exit 0
```

---

## Part 4: Skill Discovery & Routing Evaluation

### The Problem

A skill can be technically perfect but **never get invoked** because:
- Name is wrong (not findable)
- Description is vague (router can't match)
- Trigger overlaps with other skills (collision)

### Evaluation Types

#### Type A: Positive Trigger (Must Fire)

```yaml
eval: routing.kafka.positive
query: "I need event streaming between services"
expected:
  selected_skill: deploying-kafka-k8s
failure_if:
  - no skill selected
  - generic infra skill selected
```

**Why this matters**: Query never says "Kafka" — tests semantic alignment, not keyword matching.

#### Type B: Negative Trigger (Must NOT Fire)

```yaml
eval: routing.kafka.negative
query: "Set up synchronous REST communication between services"
expected:
  selected_skill: none
failure_if:
  - deploying-kafka-k8s selected
```

**Why this matters**: Prevents over-eager skills. Protects from silent architectural errors.

#### Type C: Collision Resolution

```yaml
eval: routing.kafka.collision
query: "Set up messaging for microservices"
expected:
  selected_skill: deploying-kafka-k8s
rejected_skills:
  - deploying-redis-k8s
  - configuring-dapr-pubsub
```

**Why this matters**: This is where most skill libraries fail. Forces mutually exclusive descriptions.

### Running Routing Evals Manually

No automation needed. Just run these probes:

```bash
# In Claude Code, submit these prompts and observe which skill activates

# Positive trigger test
"I need event streaming between services"
# → Should trigger: deploying-kafka-k8s
# → Check: grep "deploying-kafka" .claude/activity-logs/skill-usage.jsonl | tail -1

# Negative trigger test  
"Set up synchronous REST communication"
# → Should trigger: scaffolding-fastapi-dapr (or none)
# → Failure: deploying-kafka-k8s activated

# Collision test
"Set up messaging for microservices"
# → Should trigger: deploying-kafka-k8s
# → Should NOT trigger: configuring-dapr-pubsub
```

### Routing Eval Log Format

Add to `routing-evals.jsonl`:

```json
{"timestamp":"2024-12-20T10:00:00Z","eval":"routing.kafka.positive","query":"event streaming between services","expected":"deploying-kafka-k8s","actual":"deploying-kafka-k8s","pass":true}
{"timestamp":"2024-12-20T10:05:00Z","eval":"routing.kafka.negative","query":"synchronous REST communication","expected":"none","actual":"scaffolding-fastapi-dapr","pass":true}
{"timestamp":"2024-12-20T10:10:00Z","eval":"routing.kafka.collision","query":"messaging for microservices","expected":"deploying-kafka-k8s","actual":"configuring-dapr-pubsub","pass":false}
```

---

## Part 5: Value Metrics

### What to Measure

| Metric | How to Calculate | What It Tells You |
|--------|------------------|-------------------|
| **Invocation Count** | Count skill starts per skill | Which skills are actually used |
| **Success Rate** | verify passes / total invocations | Which skills work reliably |
| **Time Saved** | Manual time estimate - actual time | ROI of each skill |
| **Routing Accuracy** | Correct triggers / total triggers | Naming/description quality |

### analyze-skills.py

```python
#!/usr/bin/env python3
"""Analyze skill usage from activity logs."""
import json
from collections import defaultdict
from pathlib import Path
from datetime import datetime

LOG_DIR = Path(".claude/activity-logs")

def load_jsonl(path: Path) -> list:
    if not path.exists():
        return []
    with open(path) as f:
        return [json.loads(line) for line in f if line.strip()]

def analyze():
    skill_usage = load_jsonl(LOG_DIR / "skill-usage.jsonl")
    prompts = load_jsonl(LOG_DIR / "prompts.jsonl")
    
    # Count invocations
    invocations = defaultdict(int)
    successes = defaultdict(int)
    failures = defaultdict(int)
    
    for event in skill_usage:
        skill = event.get("skill", "unknown")
        
        if event.get("event") == "start":
            invocations[skill] += 1
        elif event.get("event") == "verify":
            if event.get("status") == "success":
                successes[skill] += 1
            else:
                failures[skill] += 1
    
    # Report
    print("=" * 60)
    print("SKILL USAGE ANALYSIS")
    print("=" * 60)
    print(f"\nTotal prompts: {len(prompts)}")
    print(f"Total skill invocations: {sum(invocations.values())}")
    print(f"\n{'Skill':<30} {'Invocations':>12} {'Success':>10} {'Failure':>10}")
    print("-" * 62)
    
    for skill in sorted(invocations.keys(), key=lambda x: invocations[x], reverse=True):
        s = successes[skill]
        f = failures[skill]
        rate = f"{s}/{s+f}" if (s+f) > 0 else "N/A"
        print(f"{skill:<30} {invocations[skill]:>12} {s:>10} {f:>10}")
    
    # Unused skills detection
    skill_dirs = list(Path(".claude/skills").glob("*/SKILL.md"))
    all_skills = {p.parent.name for p in skill_dirs}
    used_skills = set(invocations.keys())
    unused = all_skills - used_skills
    
    if unused:
        print(f"\n⚠️  UNUSED SKILLS ({len(unused)}):")
        for skill in sorted(unused):
            print(f"  - {skill}")
    
    # High failure rate skills
    print(f"\n⚠️  HIGH FAILURE RATE SKILLS:")
    for skill in invocations:
        total = successes[skill] + failures[skill]
        if total > 0 and failures[skill] / total > 0.3:
            rate = failures[skill] / total * 100
            print(f"  - {skill}: {rate:.0f}% failure rate")

if __name__ == "__main__":
    analyze()
```

---

## Part 6: The Evaluation Checklist

### Before Shipping a Skill

```markdown
## Routing Evaluation

- [ ] Positive trigger test passed (natural language → skill activates)
- [ ] Negative trigger test passed (unrelated query → skill does NOT activate)
- [ ] No collision with existing skills (mutually exclusive descriptions)
- [ ] Description includes "Use when [specific trigger]"
- [ ] Name is findable (would you search for this exact term?)

## Execution Evaluation

- [ ] verify.py returns 0 on success
- [ ] verify.py returns 1 with actionable error on failure
- [ ] Single prompt → complete execution (no clarification needed)
- [ ] Works on Claude Code
- [ ] Works on Goose (if cross-agent required)

## Value Evaluation (After 1 Week of Use)

- [ ] Invocation count > 0 (skill is actually used)
- [ ] Success rate > 80% (skill works reliably)
- [ ] No routing collisions observed in logs
- [ ] Would you recreate this skill if it were deleted?
```

### The Ultimate Test

> **Would you recreate this skill if it were deleted?**

If the answer is no, the skill has no value. Delete it.

---

## Part 7: Practical Workflow

### Daily: Passive Collection

Hooks run automatically. No action needed.

```
User prompt → track-prompt.sh → prompts.jsonl
Skill activated → track-skill-start.sh → skill-usage.jsonl  
Skill verified → track-skill-end.sh → skill-usage.jsonl
```

### Weekly: Analysis

```bash
# Run analysis
python .claude/hooks/analyze-skills.py

# Output example:
# ============================================================
# SKILL USAGE ANALYSIS
# ============================================================
# 
# Total prompts: 147
# Total skill invocations: 43
# 
# Skill                         Invocations    Success    Failure
# --------------------------------------------------------------
# fetching-library-docs                  18         17          1
# deploying-kafka-k8s                     8          7          1
# scaffolding-fastapi-dapr                6          6          0
# ...
#
# ⚠️  UNUSED SKILLS (3):
#   - building-voice-interfaces
#   - integrating-monaco-editor
#   - deploying-kong-k8s
#
# ⚠️  HIGH FAILURE RATE SKILLS:
#   - deploying-postgres-k8s: 40% failure rate
```

### Monthly: Routing Evals

Run the manual routing probes for each skill:
1. Positive trigger test
2. Negative trigger test
3. Collision test

Log results in `routing-evals.jsonl`.

### Quarterly: Prune

Delete skills that:
- Zero invocations in 3 months
- < 50% success rate
- Fail routing evals consistently

---

## Part 8: The Decision Framework

### When to Keep a Skill

| Signal | Action |
|--------|--------|
| High invocation + high success | Keep and polish |
| High invocation + low success | Fix or rewrite |
| Low invocation + high success | Check routing/naming |
| Low invocation + low success | Delete |

### When to Merge Skills

If routing evals show collision:
1. Check if skills serve same intent
2. If yes → merge into one skill with clearer scope
3. If no → make descriptions mutually exclusive

### When to Split a Skill

If success rate varies by use case:
1. Identify the failing scenarios
2. Extract into separate skill with narrow scope
3. Update routing to distinguish

---

## Part 9: Installation

### Quick Start

```bash
# Create directories
mkdir -p .claude/hooks .claude/activity-logs

# Create hook scripts (copy from Part 3)
touch .claude/hooks/track-prompt.sh
touch .claude/hooks/track-skill-start.sh
touch .claude/hooks/track-skill-end.sh
chmod +x .claude/hooks/*.sh

# Create analysis script (copy from Part 5)
touch .claude/hooks/analyze-skills.py
chmod +x .claude/hooks/analyze-skills.py

# Add hook configuration to settings.json
# (copy from Part 3)
```

### Verify Installation

```bash
# Test hook detection
echo '{"prompt":"test","session_id":"test123"}' | .claude/hooks/track-prompt.sh
cat .claude/activity-logs/prompts.jsonl
# Should show: {"timestamp":"...","session_id":"test123","prompt":"test"}
```

---

## Summary

| What | How | Zero Overhead? |
|------|-----|----------------|
| Track skill invocations | `PreToolUse` + `PostToolUse` hooks | ✅ Automatic |
| Measure success rate | Parse `verify.py` exit codes | ✅ Automatic |
| Evaluate routing | Manual probes + log analysis | ✅ < 5 min/skill |
| Calculate ROI | Weekly `analyze-skills.py` run | ✅ Automatic |

### The Core Rule (Repeat Often)

> **If two skills plausibly trigger on the same query, at least one is incorrectly designed.**

This single rule, enforced through routing evals, prevents skill library rot.

---

*Document version: 1.0*
*Built on: Claude Code hooks, existing skill tracker patterns*
*Custom infrastructure required: None*
