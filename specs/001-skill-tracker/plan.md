# Implementation Plan: Installing Skill Tracker

**Branch**: `001-skill-tracker` | **Date**: 2025-12-21 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-skill-tracker/spec.md`

## Summary

Install Claude Code hooks for automatic skill usage tracking. The system creates bash hook scripts that capture prompt submissions, skill activations (via SKILL.md reads), and verification results (via verify.py exit codes). All data is stored in JSONL format locally. A Python analysis script provides weekly usage reports.

## Technical Context

**Language/Version**: Bash 4+ for hooks, Python 3.8+ for setup/verify/analysis
**Primary Dependencies**: jq (JSON parsing in bash), Python standard library only
**Storage**: JSONL files in `.claude/activity-logs/` (prompts.jsonl, skill-usage.jsonl)
**Testing**: Manual verification via verify.py, integration testing with sample hook inputs
**Target Platform**: macOS/Linux with Claude Code installed
**Project Type**: Single project (skill with setup scripts)
**Performance Goals**: <100ms per hook execution, <10s setup, <5s analysis for 1000 entries
**Constraints**: Zero external Python dependencies, must not block Claude Code operations
**Scale/Scope**: Personal use, single repository, ~1000 log entries typical

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Skills Over Tools | PASS | Skill encodes judgment about what to measure and how to detect activations |
| II. Gerund Naming | PASS | `installing-skill-tracker` follows gerund pattern |
| III. Trigger-Based Descriptions | PASS | Description includes "Use when setting up a new mjs-skills repo" |
| IV. Token Discipline | PASS | SKILL.md will be <300 tokens, verify.py output <100 chars |
| V. Verification Required | PASS | verify.py checks all components, exits 0/1 with messages |
| VI. MCP Output Discipline | N/A | No MCP tools used in this skill |
| VII. Failure Escalation | PASS | Verify fails with actionable error, stops on missing jq |

**Gate Status**: PASSED - No violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-skill-tracker/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (hook input/output schemas)
└── tasks.md             # Phase 2 output (created by /sp.tasks)
```

### Source Code (repository root)

```text
.claude/skills/installing-skill-tracker/
├── SKILL.md                    # Skill definition with YAML frontmatter
└── scripts/
    ├── setup.py                # Main setup script (creates hooks, updates settings)
    └── verify.py               # Verification script (checks all components)

.claude/hooks/                  # Created by setup.py
├── track-prompt.sh             # UserPromptSubmit hook
├── track-skill-start.sh        # PreToolUse hook (detects SKILL.md reads)
├── track-skill-end.sh          # PostToolUse hook (captures verify.py results)
└── analyze-skills.py           # Weekly analysis script

.claude/activity-logs/          # Created by setup.py
├── prompts.jsonl               # Prompt log entries (created on first write)
└── skill-usage.jsonl           # Skill usage events (created on first write)
```

**Structure Decision**: Single skill project with scripts/ subdirectory. Hook scripts are deployed to `.claude/hooks/` at project level. Settings are updated in user's `~/.claude/settings.json`.

## Implementation Components

### Component 1: setup.py

**Purpose**: Main entry point that creates all tracking infrastructure.

**Responsibilities**:
- Create `.claude/hooks/` directory if not exists
- Create `.claude/activity-logs/` directory if not exists
- Write hook scripts (track-prompt.sh, track-skill-start.sh, track-skill-end.sh)
- Write analysis script (analyze-skills.py)
- Make all scripts executable (chmod +x)
- Update `~/.claude/settings.json` with hook configurations
- Preserve existing settings/hooks (merge, don't replace)
- Overwrite only tracker-specific scripts (track-*.sh, analyze-skills.py)

**Key Logic**:
```python
# Hook script content stored as multi-line strings
# Settings merge: load existing → add our hooks → write back
# Idempotent: safe to run multiple times
```

### Component 2: track-prompt.sh

**Purpose**: Log user prompts submitted to Claude Code.

**Trigger**: UserPromptSubmit hook event

**Input** (from stdin):
```json
{"prompt": "...", "session_id": "..."}
```

**Output**: Append to `.claude/activity-logs/prompts.jsonl`
```json
{"timestamp": "2025-12-21T10:00:00Z", "session_id": "abc123", "prompt": "..."}
```

**Error Handling**: Always exit 0 (never block Claude Code)

### Component 3: track-skill-start.sh

**Purpose**: Detect skill activation by matching SKILL.md file reads.

**Trigger**: PreToolUse hook event (matcher: `Bash|View|Read`)

**Detection Pattern**:
- Command/path contains `/skills/[skill-name]/SKILL.md`
- Extract skill name from path segment

**Input** (from stdin):
```json
{"tool_input": {"command": "cat .../skills/my-skill/SKILL.md"}, "session_id": "..."}
```

**Output**: Append to `.claude/activity-logs/skill-usage.jsonl`
```json
{"timestamp": "...", "session_id": "...", "skill": "my-skill", "event": "start"}
```

### Component 4: track-skill-end.sh

**Purpose**: Capture skill verification results (success/failure).

**Trigger**: PostToolUse hook event (matcher: `Bash|View|Read`)

**Detection Pattern**:
- Command contains `verify.py`
- Extract skill name from path: `.../skills/[skill-name]/scripts/verify.py`

**Input** (from stdin):
```json
{"tool_input": {"command": "python .../scripts/verify.py"}, "tool_response": {"exit_code": 0}, "session_id": "..."}
```

**Output**: Append to `.claude/activity-logs/skill-usage.jsonl`
```json
{"timestamp": "...", "session_id": "...", "skill": "my-skill", "event": "verify", "status": "success"}
```

### Component 5: analyze-skills.py

**Purpose**: Generate weekly usage report.

**Reads**:
- `.claude/activity-logs/skill-usage.jsonl`
- `.claude/activity-logs/prompts.jsonl`
- `.claude/skills/*/SKILL.md` (to find all skills)

**Report Contents**:
- Total prompts logged
- Total skill invocations
- Per-skill: invocation count, success count, failure count
- Unused skills (exist in skills/ but zero invocations)
- High failure rate skills (>30% failure rate)
- Overall success rate

### Component 6: verify.py

**Purpose**: Validate skill tracker installation.

**Checks**:
1. `.claude/hooks/` directory exists
2. `.claude/activity-logs/` directory exists
3. All required hook scripts exist and are executable:
   - track-prompt.sh
   - track-skill-start.sh
   - track-skill-end.sh
   - analyze-skills.py
4. `~/.claude/settings.json` exists and contains hook configurations
5. Required events configured: UserPromptSubmit, PreToolUse, PostToolUse
6. jq command available on system

**Exit Codes**:
- 0: All checks pass, print "Skill tracker installed correctly"
- 1: Any check fails, print specific error with diagnostic command

### Component 7: SKILL.md

**Purpose**: Skill definition file for Claude Code routing.

**Content**:
```yaml
---
name: installing-skill-tracker
description: |
  Installs Claude Code hooks for automatic skill usage tracking.
  Use when setting up a new mjs-skills repo or enabling measurement.
---

## Quick Start

python .claude/skills/installing-skill-tracker/scripts/setup.py

## Instructions

1. Run setup: `python .claude/skills/installing-skill-tracker/scripts/setup.py`
2. Verify: `python .claude/skills/installing-skill-tracker/scripts/verify.py`
3. Use skills normally — tracking is automatic

## If Verification Fails

1. Check jq installed: `which jq`
2. Check permissions: `ls -la .claude/hooks/`
3. Check settings: `cat ~/.claude/settings.json | jq .hooks`
4. **Stop and report** — hooks must work before building skills
```

## Hook Configuration Schema

Settings added to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/track-prompt.sh"}]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash|View|Read",
        "hooks": [{"type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/track-skill-start.sh"}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|View|Read",
        "hooks": [{"type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/track-skill-end.sh"}]
      }
    ]
  }
}
```

## Complexity Tracking

No violations to justify. Implementation follows constitution principles with minimal complexity.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| jq not installed | Medium | High (hooks fail silently) | verify.py checks for jq |
| Hook blocks Claude Code | Low | High | All hooks exit 0, fast execution |
| Settings file corruption | Low | Medium | Backup before modify, validate JSON |
| Pattern mismatch (false negatives) | Medium | Low | Test with real skill activations |
| Log file permissions | Low | Low | Create with user permissions |

## Test Strategy

### Manual Tests

1. **Setup Test**: Run setup.py, verify all files created
2. **Verify Test**: Run verify.py, confirm exit 0
3. **Hook Test**: Activate a skill, check skill-usage.jsonl for entry
4. **Analysis Test**: Run analyze-skills.py with sample data
5. **Idempotency Test**: Run setup.py twice, verify no duplicates in settings

### Integration Tests

1. Fresh repo: setup → verify → activate skill → check logs
2. Existing hooks: setup → verify existing hooks preserved
3. Missing jq: verify → should fail with clear message
