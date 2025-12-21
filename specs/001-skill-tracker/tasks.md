# Tasks: Installing Skill Tracker

**Input**: Design documents from `/specs/001-skill-tracker/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, etc.)
- Exact file paths included in descriptions

## Path Conventions

```text
.claude/skills/installing-skill-tracker/
├── SKILL.md
└── scripts/
    ├── setup.py
    └── verify.py

.claude/hooks/                  # Created by setup.py
├── track-prompt.sh
├── track-skill-start.sh
├── track-skill-end.sh
└── analyze-skills.py
```

---

## Phase 1: Setup (Project Structure)

**Purpose**: Create skill directory structure

- [x] T001 Create skill directory at .claude/skills/installing-skill-tracker/
- [x] T002 Create scripts subdirectory at .claude/skills/installing-skill-tracker/scripts/

---

## Phase 2: Foundational (Skill Definition)

**Purpose**: Create SKILL.md for Claude Code routing - MUST complete before skill can be activated

**⚠️ CRITICAL**: Skill cannot be discovered or used until SKILL.md exists

- [x] T003 Create SKILL.md with YAML frontmatter (name, description with "Use when" trigger) at .claude/skills/installing-skill-tracker/SKILL.md
- [x] T004 Add Quick Start section to SKILL.md with setup command
- [x] T005 Add Instructions section to SKILL.md with step-by-step setup/verify commands
- [x] T006 Add "If Verification Fails" section to SKILL.md with diagnostic commands

**Checkpoint**: SKILL.md complete - skill is now discoverable by Claude Code

---

## Phase 3: User Story 1 - Initial Setup (Priority: P1) 🎯 MVP

**Goal**: Create setup.py that installs all tracking infrastructure with a single command

**Independent Test**: Run `python .claude/skills/installing-skill-tracker/scripts/setup.py` and verify all hook scripts and directories are created

### Implementation for User Story 1

- [x] T007 [US1] Create setup.py skeleton with imports and path constants at .claude/skills/installing-skill-tracker/scripts/setup.py
- [x] T008 [US1] Add setup_directories() function to create .claude/hooks/ and .claude/activity-logs/ directories in setup.py
- [x] T009 [US1] Add TRACK_PROMPT_SH constant with bash script content (outputs async JSON, reads stdin JSON, extracts prompt/session_id, writes to prompts.jsonl) in setup.py
- [x] T010 [US1] Add TRACK_SKILL_START_SH constant with bash script content (outputs async JSON, detects SKILL.md reads, extracts skill name, writes start event) in setup.py
- [x] T011 [US1] Add TRACK_SKILL_END_SH constant with bash script content (outputs async JSON, detects verify.py runs, captures exit code, writes verify event) in setup.py
- [x] T012 [US1] Add ANALYZE_SKILLS_PY constant with Python script content (loads JSONL, detects skill types via scripts/verify.py check, counts invocations/successes/failures for procedural skills, shows N/A for content skills, identifies unused skills) in setup.py
- [x] T013 [US1] Add setup_hook_scripts() function to write all script files and make executable in setup.py
- [x] T014 [US1] Add HOOKS_CONFIG constant with settings.json hook configuration in setup.py
- [x] T015 [US1] Add setup_settings() function with merge logic (load existing .claude/settings.json, add our hooks if not present, write back) in setup.py
- [x] T016 [US1] Add main() function that calls all setup functions and prints status in setup.py

**Checkpoint**: setup.py complete - running it creates all tracking infrastructure (enables US2, US3, US4, US5)

---

## Phase 4: User Story 6 - Installation Verification (Priority: P1)

**Goal**: Create verify.py that confirms all components are correctly installed

**Independent Test**: Run `python .claude/skills/installing-skill-tracker/scripts/verify.py` after setup and confirm exit code 0

### Implementation for User Story 6

- [x] T017 [P] [US6] Create verify.py skeleton with imports and path constants at .claude/skills/installing-skill-tracker/scripts/verify.py
- [x] T018 [US6] Add check_directories() function to verify .claude/hooks/ and .claude/activity-logs/ exist in verify.py
- [x] T019 [US6] Add check_hook_scripts() function to verify all scripts exist and are executable in verify.py
- [x] T020 [US6] Add check_jq() function to verify jq command is available with actionable error if missing in verify.py
- [x] T021 [US6] Add check_settings() function to verify .claude/settings.json has hook configurations in verify.py
- [x] T022 [US6] Add main() function that runs all checks and exits 0/1 with appropriate message in verify.py

**Checkpoint**: verify.py complete - US1 + US6 form complete MVP for skill tracker installation

---

## Phase 5: User Stories 2+3 - Activation & Verification Tracking (Priority: P2)

**Goal**: Validate that skill activation and verification tracking work correctly

**Independent Test**:
- US2: Activate any skill, check .claude/activity-logs/skill-usage.jsonl for "start" event
- US3: Run any skill's verify.py, check skill-usage.jsonl for "verify" event with status

### Validation for User Stories 2+3

- [x] T023 [US2] Validate track-skill-start.sh regex pattern correctly extracts skill name from /skills/[name]/SKILL.md paths
- [x] T024 [US3] Validate track-skill-end.sh regex pattern correctly extracts skill name from /skills/[name]/scripts/verify.py paths
- [x] T025 [US3] Validate track-skill-end.sh correctly reads exit_code from tool_response JSON variants (exit_code, exitCode, code)

**Checkpoint**: Skill activation and verification tracking validated

---

## Phase 6: User Stories 4+5 - Prompt Logging & Analysis (Priority: P3)

**Goal**: Validate prompt logging and weekly analysis work correctly

**Independent Test**:
- US4: Submit any prompt, check .claude/activity-logs/prompts.jsonl for entry
- US5: Run `python .claude/hooks/analyze-skills.py` with sample data, verify report output

### Validation for User Stories 4+5

- [x] T026 [US4] Validate track-prompt.sh correctly handles prompts with special characters and newlines
- [x] T027 [US5] Validate analyze-skills.py correctly calculates success rate (success / (success + failure)) for procedural skills only
- [x] T028 [US5] Validate analyze-skills.py correctly identifies unused skills (in .claude/skills/ but zero invocations)
- [x] T029 [US5] Validate analyze-skills.py correctly flags high failure rate skills (>30%) for procedural skills only
- [x] T030 [US5] Validate analyze-skills.py correctly detects skill type by checking for scripts/verify.py existence
- [x] T031 [US5] Validate analyze-skills.py shows "N/A" for success rate of content skills (no verify.py)
- [x] T032 [US5] Test analyze-skills.py with internal-comms skill (content type) to verify correct handling

**Checkpoint**: All user stories validated

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup

- [x] T033 [P] Validate SKILL.md is under 300 tokens per constitution requirement
- [x] T034 [P] Validate verify.py output is under 100 characters per constitution requirement
- [x] T035 Run setup.py twice to verify idempotency (no duplicate hooks in settings)
- [x] T036 Test with missing jq to verify actionable error message
- [x] T037 Update .gitignore to exclude .claude/activity-logs/ if not already present
- [x] T038 Run quickstart.md validation (setup → verify → check logs)

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1: Setup ──────────────────────────────────────────►
                                                          │
Phase 2: Foundational (SKILL.md) ────────────────────────►
                                                          │
                                    ┌─────────────────────┘
                                    ▼
Phase 3: US1 (setup.py) ─────────────────────────────────►
                                                          │
Phase 4: US6 (verify.py) ────────────────────────────────►
                                                          │
                    ┌─────────────────────────────────────┘
                    ▼
Phase 5: US2+US3 (Validation) ───────────────────────────►
                                                          │
Phase 6: US4+US5 (Validation) ───────────────────────────►
                                                          │
Phase 7: Polish ─────────────────────────────────────────►
```

### User Story Dependencies

| Story | Depends On | Delivers |
|-------|------------|----------|
| US1 (P1) | Phase 2 | Creates all hook scripts, directories, settings |
| US6 (P1) | US1 | Verifies US1 worked correctly |
| US2 (P2) | US1 | track-skill-start.sh functionality (created by US1) |
| US3 (P2) | US1 | track-skill-end.sh functionality (created by US1) |
| US4 (P3) | US1 | track-prompt.sh functionality (created by US1) |
| US5 (P3) | US1 | analyze-skills.py functionality (created by US1) |

### Within Each Phase

- T001-T002: Can run in parallel (different directories)
- T003-T006: Sequential (building SKILL.md incrementally)
- T007-T016: Sequential (building setup.py incrementally)
- T017-T022: T017 first, then T018-T021 can run in parallel, T022 last
- T023-T029: All validation tasks can run in parallel
- T030-T035: T030-T031 parallel, T32-T35 sequential

### Parallel Opportunities

```bash
# Phase 1: Create directories in parallel
Task T001 and T002 can run in parallel (different paths)

# Phase 4: Create verification checks in parallel
Task T018, T019, T020, T021 can run in parallel (different functions)

# Phase 5+6: All validation tasks in parallel
Tasks T023-T029 can run in parallel (independent validations)

# Phase 7: Initial polish tasks in parallel
Tasks T030 and T031 can run in parallel (different files)
```

---

## Implementation Strategy

### MVP First (US1 + US6 Only)

1. Complete Phase 1: Setup (2 tasks)
2. Complete Phase 2: Foundational (4 tasks)
3. Complete Phase 3: US1 setup.py (10 tasks)
4. Complete Phase 4: US6 verify.py (6 tasks)
5. **STOP and VALIDATE**: Run setup.py then verify.py
6. **MVP COMPLETE**: Skill tracker is installed and verified

### Incremental Delivery

1. After MVP: Validate US2+US3 (skill tracking works)
2. Then: Validate US4+US5 (prompt logging and analysis work)
3. Finally: Polish phase

### Task Count Summary

| Phase | Tasks | Cumulative |
|-------|-------|------------|
| Phase 1: Setup | 2 | 2 |
| Phase 2: Foundational | 4 | 6 |
| Phase 3: US1 | 10 | 16 |
| Phase 4: US6 | 6 | 22 |
| Phase 5: US2+US3 | 3 | 25 |
| Phase 6: US4+US5 | 7 | 32 |
| Phase 7: Polish | 6 | 38 |
| **Total** | **38** | |

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story
- US1 is the core story - it creates ALL hook scripts
- US2-US5 are delivered BY US1, validated in later phases
- Commit after each phase or logical group
- MVP = Phase 1-4 (22 tasks)
