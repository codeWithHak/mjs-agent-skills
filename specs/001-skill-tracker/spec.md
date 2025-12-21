# Feature Specification: Installing Skill Tracker

**Feature Branch**: `001-skill-tracker`
**Created**: 2025-12-21
**Status**: Draft
**Input**: User description: "Install skill tracker hooks for automatic skill usage measurement"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Initial Skill Tracker Setup (Priority: P1)

A developer setting up a new mjs-skills repository needs to install the skill tracking infrastructure so that skill usage can be automatically measured from day one. They run a single setup command and the system creates all necessary tracking components.

**Why this priority**: Without the tracking infrastructure in place, no skill measurements can occur. This is the foundational capability that enables all other skill evaluation activities.

**Independent Test**: Can be fully tested by running the setup command and verifying all tracking components are created. Delivers immediate value by enabling automatic skill usage collection.

**Acceptance Scenarios**:

1. **Given** a fresh mjs-skills repository without tracking, **When** user runs the setup script, **Then** hook scripts are created in `.claude/hooks/` directory
2. **Given** the setup script runs successfully, **When** checking the activity logs directory, **Then** `.claude/activity-logs/` directory exists
3. **Given** the setup script completes, **When** checking user settings, **Then** hook configuration is added to the settings file

---

### User Story 2 - Automatic Skill Activation Tracking (Priority: P2)

When a developer uses Claude Code and a skill is activated, the system automatically detects and logs the skill activation without any manual intervention. The developer can later review which skills were used during their session.

**Why this priority**: This delivers the core value proposition of measuring skill usage. Without this, the tracking infrastructure exists but provides no data.

**Independent Test**: Can be tested by activating any skill in Claude Code and verifying a log entry is created in the skill usage log.

**Acceptance Scenarios**:

1. **Given** skill tracker is installed, **When** Claude reads a SKILL.md file to activate a skill, **Then** a start event is logged with skill name, session ID, and timestamp
2. **Given** a skill activation is logged, **When** viewing the skill usage log, **Then** the entry contains valid JSON with all required fields

---

### User Story 3 - Skill Verification Result Capture (Priority: P2)

After a **procedural skill** runs its verification step, the system captures whether the skill succeeded or failed. This enables success rate calculations for procedural skills. Content skills (which have no verify.py) are tracked by activation only.

**Why this priority**: Success/failure tracking is essential for identifying unreliable procedural skills that need improvement or deletion.

**Independent Test**: Can be tested by running any procedural skill's verify.py and checking that the result (success/failure) is logged.

**Acceptance Scenarios**:

1. **Given** a procedural skill verification succeeds (exit code 0), **When** the verification completes, **Then** a verify event with status "success" is logged
2. **Given** a procedural skill verification fails (non-zero exit code), **When** the verification completes, **Then** a verify event with status "failure" is logged
3. **Given** a content skill (no verify.py) is activated, **When** tracking skill usage, **Then** only a start event is logged (no verify event expected)

---

### User Story 4 - Prompt Logging (Priority: P3)

All user prompts submitted to Claude Code are logged with session identifiers and timestamps, enabling correlation between prompts and skill activations.

**Why this priority**: Prompt logging provides context for skill activation patterns but is not required for basic skill usage measurement.

**Independent Test**: Can be tested by submitting any prompt and verifying it appears in the prompts log.

**Acceptance Scenarios**:

1. **Given** skill tracker is installed, **When** user submits a prompt, **Then** the prompt text is logged with session ID and timestamp

---

### User Story 5 - Weekly Usage Analysis (Priority: P3)

A developer can run an analysis command to see aggregated skill usage statistics including invocation counts, success rates (for procedural skills), unused skills, and high failure rate skills. The analysis differentiates between procedural skills (with verify.py) and content skills (without verify.py).

**Why this priority**: Analysis provides actionable insights but is a separate activity from data collection.

**Independent Test**: Can be tested by running the analysis script against sample log data and verifying the report output.

**Acceptance Scenarios**:

1. **Given** skill usage data exists, **When** running the analysis, **Then** a report shows invocation counts per skill grouped by skill type
2. **Given** skills exist in the skills directory, **When** running analysis, **Then** unused skills (zero invocations) are identified
3. **Given** a procedural skill has >30% failure rate, **When** running analysis, **Then** the skill is flagged as high failure rate
4. **Given** a content skill exists, **When** running analysis, **Then** success rate is shown as "N/A" (not applicable) since content skills have no verify.py

---

### User Story 6 - Installation Verification (Priority: P1)

After running setup, a developer can run a verification command to confirm all tracking components are correctly installed and configured.

**Why this priority**: Verification ensures the tracker is working before developers start relying on it for measurements.

**Independent Test**: Can be tested by running verify after setup and confirming all checks pass.

**Acceptance Scenarios**:

1. **Given** setup completed successfully, **When** running verification, **Then** all checks pass and exit code is 0
2. **Given** a required component is missing, **When** running verification, **Then** the specific missing item is reported and exit code is 1

---

### Edge Cases

- What happens when hooks directory already has existing scripts? → Setup overwrites tracker scripts only (track-*.sh, analyze-skills.py), preserves unrelated scripts
- What happens when settings file has existing hook configurations? → Merge new hooks with existing (per FR-009)
- What happens when log files don't exist yet? → Hook scripts create log files on first write
- What happens when jq is not installed? → Verify script detects missing jq and fails with actionable install instructions
- What happens when SKILL.md path doesn't match expected pattern? → Hook ignores non-matching paths (no false positives)
- What happens when verify.py path is ambiguous? → Extract skill name from path segment immediately before `/scripts/verify.py`
- What happens when a skill has no verify.py (content skill)? → Track as content type; no verify events expected; success rate shows "N/A" in analysis
- How is skill type determined? → At analysis time: check if `scripts/verify.py` exists in skill directory (procedural) or not (content)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create hook scripts directory at `.claude/hooks/` during setup
- **FR-002**: System MUST create activity logs directory at `.claude/activity-logs/` during setup
- **FR-003**: System MUST create a prompt tracking hook that captures prompt text, session ID, and timestamp
- **FR-004**: System MUST create a skill start tracking hook that detects SKILL.md file reads and logs skill name, session ID, and timestamp
- **FR-005**: System MUST create a skill end tracking hook that captures verify.py results with success/failure status
- **FR-006**: System MUST create an analysis script that reports invocation counts, success rates, unused skills, and high failure rate skills
- **FR-007**: System MUST update the project's `.claude/settings.json` to register all tracking hooks
- **FR-008**: System MUST make all hook scripts executable after creation
- **FR-009**: System MUST preserve existing hook configurations when adding new ones
- **FR-010**: System MUST provide a verification script that checks all components are correctly installed, including jq availability
- **FR-011**: Verification script MUST exit with code 0 on success and code 1 on failure
- **FR-012**: Log files MUST use JSONL format (one JSON object per line)
- **FR-013**: All timestamps MUST be in ISO 8601 UTC format
- **FR-014**: Hook scripts MUST exit with code 0 to avoid blocking Claude Code operations
- **FR-015**: All logs MUST be stored locally within the project directory only (never transmitted externally)
- **FR-016**: Logs MUST be project-scoped (each project using copied skills maintains its own independent logs)
- **FR-017**: System MUST NOT implement automatic log rotation; user controls log deletion manually
- **FR-018**: Setup script MUST overwrite only tracker-specific scripts (track-*.sh, analyze-skills.py), preserving any unrelated user scripts in hooks directory
- **FR-019**: Analysis script MUST detect skill type at runtime by checking for `scripts/verify.py` in each skill directory
- **FR-020**: Analysis script MUST report skill type (procedural/content) in output
- **FR-021**: Analysis script MUST show success rate as "N/A" for content skills (no verify.py)
- **FR-022**: Analysis script MUST only flag high failure rate (>30%) for procedural skills

### Key Entities

- **Prompt Log Entry**: Captures user prompt submissions with timestamp, session_id, and prompt text
- **Skill Usage Event**: Records skill lifecycle with timestamp, session_id, skill name, event type (start/verify), and optional status (success/failure)
- **Hook Configuration**: Defines which events trigger which scripts, stored in settings file

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Setup completes in under 10 seconds for a typical repository
- **SC-002**: Verification passes on first attempt after successful setup
- **SC-003**: All skill activations are logged with 100% accuracy (no missed events, no false positives)
- **SC-004**: All skill verification results are captured with correct success/failure status
- **SC-005**: Hook execution adds less than 100ms overhead per event
- **SC-006**: Analysis report generates in under 5 seconds for repositories with up to 1000 log entries
- **SC-007**: Developer can confirm tracker is working within 2 minutes of running setup

## Clarifications

### Session 2025-12-21

- Q: What is the data handling policy for prompt logging? → A: Full prompts logged, local-only storage, user controls retention. Logs are project-scoped (each project maintains its own logs).
- Q: What is the log retention policy? → A: Manual deletion by user, no automatic rotation.
- Q: What happens when jq is not installed? → A: Verify script checks for jq, fails with actionable error if missing.
- Q: What happens when hooks directory has existing scripts? → A: Overwrite tracker scripts only (track-*.sh, analyze-skills.py), preserve unrelated scripts.

## Assumptions

- Claude Code hooks infrastructure is available and functioning
- The `jq` command-line tool is installed on the system for JSON parsing in shell scripts
- User has write permissions to `.claude/` directory in project root
- Project-level settings are used (`.claude/settings.json` in project, not `~/.claude/settings.json`)
- SKILL.md file reads occur via Bash (cat) or Read tool, detectable in PreToolUse hooks
- verify.py execution is detectable via command pattern matching in PostToolUse hooks
- Session IDs are provided by Claude Code in hook input data
- Hooks can output `{"async":true}` JSON for non-blocking execution

## Out of Scope

- Routing evaluation automation (manual process per PRD)
- Real-time dashboards or visualization
- Cross-repository skill usage aggregation
- Automatic skill pruning based on metrics
- Integration with external analytics platforms
