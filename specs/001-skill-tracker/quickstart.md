# Quickstart: Installing Skill Tracker

**Time to complete**: < 2 minutes

## Prerequisites

- Claude Code installed
- jq installed (`brew install jq` on macOS, `apt install jq` on Ubuntu)
- Write access to `~/.claude/` directory

## Installation

### Step 1: Run Setup

```bash
python .claude/skills/installing-skill-tracker/scripts/setup.py
```

**Expected output**:
```
==================================================
SKILL TRACKER SETUP
==================================================

Project directory: /path/to/your/project

✓ Created .claude/hooks
✓ Created .claude/activity-logs

✓ Created .claude/hooks/track-prompt.sh
✓ Created .claude/hooks/track-skill-start.sh
✓ Created .claude/hooks/track-skill-end.sh
✓ Created .claude/hooks/analyze-skills.py

✓ Added UserPromptSubmit hook
✓ Added PreToolUse hook
✓ Added PostToolUse hook
✓ Updated .claude/settings.json

==================================================
SETUP COMPLETE
==================================================

Next steps:
1. Verify installation: python .claude/skills/installing-skill-tracker/scripts/verify.py
2. Use skills normally — tracking is automatic
3. Run weekly: python .claude/hooks/analyze-skills.py
```

### Step 2: Verify Installation

```bash
python .claude/skills/installing-skill-tracker/scripts/verify.py
```

**Expected output**:
```
✓ Skill tracker installed correctly
```

## Usage

### Automatic Tracking (Zero Overhead)

Once installed, tracking happens automatically:

1. **Prompts**: Every prompt you submit is logged
2. **Skill Activations**: When Claude reads a SKILL.md file, it's logged
3. **Verifications**: When verify.py runs, success/failure is logged

### Weekly Analysis

Run the analysis script to see usage statistics:

```bash
python .claude/hooks/analyze-skills.py
```

**Example output**:
```
======================================================================
SKILL USAGE ANALYSIS
======================================================================

Analysis date: 2025-12-21 10:00
Log directory: /path/to/project/.claude/activity-logs

Total prompts logged: 147
Total skill invocations: 43

PROCEDURAL SKILLS (with verify.py):
Skill                               Invocations    Success    Failure    Rate
------------------------------------------------------------------------------
deploying-kafka-k8s                           8          7          1    87.5%
scaffolding-fastapi-dapr                      6          6          0   100.0%

CONTENT SKILLS (no verify.py):
Skill                               Invocations    Success Rate
----------------------------------------------------------------------
internal-comms                               12         N/A
fetching-library-docs                        18         N/A

⚠️  UNUSED SKILLS (2):
   - building-voice-interfaces (procedural)
   - integrating-monaco-editor (content)

⚠️  HIGH FAILURE RATE SKILLS (>30%):
   - deploying-postgres-k8s: 40% failure rate

======================================================================
Procedural skills success rate: 88.4%
======================================================================
```

### View Raw Logs

```bash
# View recent skill usage
tail -10 .claude/activity-logs/skill-usage.jsonl | jq .

# View recent prompts (truncated for privacy)
tail -5 .claude/activity-logs/prompts.jsonl | jq '.prompt[:50]'

# Count skill activations
grep '"event":"start"' .claude/activity-logs/skill-usage.jsonl | wc -l
```

## Troubleshooting

### Verification Fails

1. **Missing jq**:
   ```bash
   which jq  # Should show path
   # If not: brew install jq (macOS) or apt install jq (Ubuntu)
   ```

2. **Permission issues**:
   ```bash
   ls -la .claude/hooks/  # Check executable permissions
   chmod +x .claude/hooks/*.sh  # Fix if needed
   ```

3. **Settings not updated**:
   ```bash
   cat .claude/settings.json | jq .hooks
   # Should show UserPromptSubmit, PreToolUse, PostToolUse
   ```

### No Data in Logs

1. Activate a skill manually to test
2. Check log directory exists: `ls .claude/activity-logs/`
3. Check hook scripts are executable

## Uninstallation

To remove the skill tracker:

```bash
# Remove hook scripts
rm .claude/hooks/track-*.sh
rm .claude/hooks/analyze-skills.py

# Remove logs (optional - preserves data)
rm -rf .claude/activity-logs/

# Edit ~/.claude/settings.json to remove hook entries
# (manual edit required)
```

## Next Steps

1. Use skills normally for a week
2. Run weekly analysis to identify unused or failing skills
3. Delete skills with zero usage or high failure rates
