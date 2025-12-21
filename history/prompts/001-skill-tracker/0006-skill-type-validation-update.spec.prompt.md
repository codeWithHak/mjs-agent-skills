---
id: "0006"
title: skill-type-validation-update
stage: spec
date: 2025-12-21
surface: project
model: claude-opus-4-5-20251101
feature: 001-skill-tracker
branch: 001-skill-tracker
user: mjs
command: validation
labels: [skill-tracker, validation, skill-types, content-skills]
links:
  spec: specs/001-skill-tracker/spec.md
  ticket: ""
  adr: ""
  pr: ""
files:
  - path: specs/001-skill-tracker/spec.md
    action: modified
  - path: specs/001-skill-tracker/data-model.md
    action: modified
  - path: specs/001-skill-tracker/tasks.md
    action: modified
  - path: specs/001-skill-tracker/quickstart.md
    action: modified
tests:
  - name: internal-comms skill type detection
    status: pass
---

## Prompt

Why not validate with real skills your @specs/001-skill-tracker/ work to know if it really works. I added a really simple skill .claude/skills/internal-comms

## Response snapshot

Validated skill tracker spec against real `internal-comms` skill. Found critical gap: spec assumed all skills have verify.py (procedural skills only). Real-world skills like internal-comms are content skills with no verification step.

**Updates made**:
- Added FR-019 to FR-022 for skill type handling
- Updated US3 and US5 to differentiate procedural vs content skills
- Added skill type detection logic to data-model.md
- Added 3 new validation tasks (T030-T032) for skill type testing
- Updated quickstart.md analysis output example

**Validation result**: internal-comms correctly detected as content skill (no scripts/verify.py)

## Outcome

- Impact: Spec now handles both procedural and content skills correctly
- Tests: Validated against internal-comms skill - correctly detected as content type
- Files: 4 files modified (spec.md, data-model.md, tasks.md, quickstart.md)
- Next prompts: /sp.implement to execute updated 38 tasks
- Reflection: Real-world validation caught assumption that all skills are procedural

## Evaluation notes (flywheel)

- Failure modes observed: Initial spec assumed all skills have verify.py
- Graders run and results (PASS/FAIL): Skill type detection PASS (internal-comms correctly identified as content)
- Prompt variant (if applicable): n/a
- Next experiment (smallest change to try): n/a
