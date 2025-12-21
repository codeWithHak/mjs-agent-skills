# Research: Installing Skill Tracker

**Date**: 2025-12-21
**Feature**: 001-skill-tracker

## Research Summary

All technical decisions were resolved during specification and clarification phases. No unknowns remain. This document consolidates the key decisions and their rationale.

---

## Decision 1: Hook Script Language

**Decision**: Bash for hook scripts

**Rationale**:
- Claude Code hooks execute shell commands natively
- Bash is universally available on macOS/Linux
- Minimal overhead for simple JSON parsing with jq
- No dependency installation required for hook execution

**Alternatives Considered**:
- Python hooks: Rejected due to additional startup overhead (~100ms vs ~10ms)
- Node.js hooks: Rejected, would require Node installation

---

## Decision 2: JSON Parsing Tool

**Decision**: jq for JSON parsing in bash hooks

**Rationale**:
- Standard tool for JSON manipulation in shell scripts
- Single binary, no runtime dependencies
- Fast execution (<10ms for simple extracts)
- Already common in developer toolchains

**Alternatives Considered**:
- Python json module: Would require Python invocation in bash, slower
- grep/sed: Fragile, breaks on complex JSON
- Native bash: Not practical for JSON parsing

**Dependency Note**: verify.py checks for jq availability and fails with install instructions if missing.

---

## Decision 3: Log Format

**Decision**: JSONL (JSON Lines) format

**Rationale**:
- One JSON object per line enables simple append operations
- Easy to parse with standard tools (jq, Python json)
- Human-readable for debugging
- Efficient for streaming reads (no need to parse entire file)

**Alternatives Considered**:
- SQLite: Overkill for append-only logs, adds dependency
- CSV: Poor fit for nested data (prompt text with newlines)
- Single JSON array: Requires full file rewrite on each append

---

## Decision 4: Settings File Location

**Decision**: User settings at `~/.claude/settings.json`

**Rationale**:
- Standard location for Claude Code user configuration
- Hooks are registered globally but use `$CLAUDE_PROJECT_DIR` for project paths
- Allows tracking across all projects with the skill installed

**Alternatives Considered**:
- Project-level settings: Would require configuration in each project
- Environment variables: Less persistent, harder to manage

---

## Decision 5: Skill Detection Pattern

**Decision**: Match `/skills/[skill-name]/SKILL.md` in file paths

**Rationale**:
- SKILL.md is always read when Claude activates a skill
- Path pattern is unambiguous (skills directory + SKILL.md)
- Works with both Bash commands (cat) and Read tool

**Pattern Regex**: `/skills/[^/]+/SKILL\.md`

**False Positive Prevention**:
- Only matches paths with `/skills/` directory
- Requires exact `SKILL.md` filename
- Ignores paths that don't match pattern (no partial matches)

---

## Decision 6: Verification Detection Pattern

**Decision**: Match `verify.py` in command and extract skill name from path

**Rationale**:
- All skills must have verify.py per constitution
- Path structure is consistent: `.../skills/[skill-name]/scripts/verify.py`
- Exit code available in PostToolUse response

**Extraction Logic**:
```bash
SKILL_NAME=$(echo "$COMMAND" | sed -E 's|.*/skills/([^/]+)/scripts/verify\.py.*|\1|')
```

---

## Decision 7: Analysis Threshold

**Decision**: Flag skills with >30% failure rate

**Rationale**:
- 30% threshold balances signal vs noise
- Lower threshold would flag skills during normal development
- Higher threshold would miss problematic skills

**Source**: PRD recommendation from skills-evaluation-prd.md

---

## Decision 8: Python Dependencies

**Decision**: Zero external Python dependencies

**Rationale**:
- Simplifies installation (no pip install required)
- Standard library covers all needs (json, pathlib, subprocess, datetime)
- Reduces version compatibility issues

**Standard Library Modules Used**:
- `json`: Parse/write JSONL
- `pathlib`: Cross-platform path handling
- `subprocess`: Check jq availability
- `stat`: Make files executable
- `datetime`: Timestamp generation
- `collections.defaultdict`: Count aggregation

---

## Best Practices Applied

### From Claude Code Hooks Documentation

1. **Always exit 0**: Hooks must not block Claude Code operations
2. **Use $CLAUDE_PROJECT_DIR**: Environment variable for project-relative paths
3. **Read from stdin**: Hook input is JSON on stdin
4. **Matcher patterns**: Use tool name matchers to filter events

### From Skills Evaluation PRD

1. **Three tracking dimensions**: Discovery, Execution, Value
2. **JSONL format**: For activity logs
3. **Session correlation**: Track session_id across events
4. **Verification capture**: Log verify.py exit codes

---

## No Unknowns Remaining

All technical decisions resolved. Proceed to Phase 1 design artifacts.
