# Skill Tracker

Automatic skill usage measurement for Claude Code using hooks.

## Quick Start

```bash
# Install
python3 .claude/skills/installing-skill-tracker/scripts/setup.py

# Verify
python3 .claude/skills/installing-skill-tracker/scripts/verify.py

# View usage report
python3 .claude/hooks/analyze-skills.py
```

## What Gets Tracked

| Event | When | Log File |
|-------|------|----------|
| Prompt | Every user message | `.claude/activity-logs/prompts.jsonl` |
| Skill activation | Any file read from `.claude/skills/[name]/` | `.claude/activity-logs/skill-usage.jsonl` |
| Verification | Every `verify.py` execution | `.claude/activity-logs/skill-usage.jsonl` |

## How It Works

The tracker installs three Claude Code hooks:

```
.claude/hooks/
├── track-prompt.sh        # UserPromptSubmit hook
├── track-skill-start.sh   # PreToolUse hook (skill detection)
├── track-skill-end.sh     # PostToolUse hook (verify.py detection)
└── analyze-skills.py      # Usage analysis script
```

Hooks are registered in `.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": ".claude/hooks/track-prompt.sh" }] }],
    "PreToolUse": [{ "matcher": "Read|Bash", "hooks": [{ "type": "command", "command": ".claude/hooks/track-skill-start.sh" }] }],
    "PostToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command", "command": ".claude/hooks/track-skill-end.sh" }] }]
  }
}
```

## Log Format

### prompts.jsonl

```json
{"timestamp":"2025-12-21T10:00:00Z","session_id":"abc123","prompt":"Deploy Kafka to staging"}
```

### skill-usage.jsonl

```json
{"timestamp":"2025-12-21T10:01:00Z","session_id":"abc123","skill":"deploying-kafka-k8s","event":"start"}
{"timestamp":"2025-12-21T10:05:00Z","session_id":"abc123","skill":"deploying-kafka-k8s","event":"verify","status":"success"}
```

## Skill Types

The analyzer detects skill types automatically:

| Type | Detection | Success Rate |
|------|-----------|--------------|
| Procedural | Has `scripts/verify.py` | Calculated from verify events |
| Content | No `scripts/verify.py` | Shows "N/A" |

## Usage Report

```
======================================================================
SKILL USAGE ANALYSIS
======================================================================

Total prompts logged: 147
Total skill invocations: 43

PROCEDURAL SKILLS (with verify.py):
Skill                               Invocations    Success    Failure     Rate
--------------------------------------------------------------------------------
deploying-kafka-k8s                           8          7          1    87.5%

CONTENT SKILLS (no verify.py):
Skill                               Invocations    Success Rate
----------------------------------------------------------------------
internal-comms                               12             N/A

UNUSED SKILLS (2):
   - building-voice-interfaces (procedural)
   - integrating-monaco-editor (content)

HIGH FAILURE RATE SKILLS (>30%):
   - deploying-postgres-k8s: 40% failure rate

======================================================================
Procedural skills success rate: 88.4%
======================================================================
```

## Requirements

- **jq**: Required for JSON parsing in bash hooks
  ```bash
  # macOS
  brew install jq

  # Linux
  apt install jq
  ```

- **Python 3.8+**: For setup, verify, and analyze scripts

## Troubleshooting

### Hooks not firing

1. Check settings.json is valid:
   ```bash
   cat .claude/settings.json | jq .
   ```

2. Restart Claude Code to pick up new settings

### Missing skill activations

Skill activation is detected when **any file** in `.claude/skills/[name]/` is read. If a skill is invoked but doesn't read files, it won't be tracked.

### Logs not created

1. Check hooks are executable:
   ```bash
   ls -la .claude/hooks/*.sh
   ```

2. Check jq is installed:
   ```bash
   jq --version
   ```

3. Run verify:
   ```bash
   python3 .claude/skills/installing-skill-tracker/scripts/verify.py
   ```

## Privacy

- All logs are **local only** (stored in `.claude/activity-logs/`)
- Logs are **gitignored** by default
- No data is transmitted externally
- User controls log retention (manual deletion)

## Reinstall

If hooks get corrupted or deleted:

```bash
python3 .claude/skills/installing-skill-tracker/scripts/setup.py
```

Setup is idempotent - running it multiple times won't create duplicate hooks.
