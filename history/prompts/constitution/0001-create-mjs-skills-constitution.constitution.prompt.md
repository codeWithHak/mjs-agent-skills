---
id: 0001
title: Create MJS Skills Constitution
stage: constitution
date: 2025-12-21
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: main
user: mjs
command: /sp.constitution
labels: ["constitution", "governance", "skills-library", "principles"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .specify/memory/constitution.md
tests:
  - N/A
---

## Prompt

```text
# CLAUDE.md

> Operational directives for AI agents working in mjs-skills

---

## What This Repo Is

A personal Agent Skills library. Skills are frozen decisions—not tools, not utilities, not helpers. Each skill encodes judgment about what matters, what fails, and what works.

---

## Before You Do Anything

1. **Read the constitution**: `cat CONSTITUTION.md`
2. **Check existing skills**: `ls .claude/skills/`
3. **Understand the PRD**: `cat research/h3-skills-master-prd.md` for skill specifications

---

## When Creating a Skill

### Required Structure

```
.claude/skills/[skill-name]/
├── SKILL.md           # YAML frontmatter + instructions
└── scripts/
    └── verify.py      # Exit 0 (success) or 1 (failure)
```

[... full CLAUDE.md content specifying all rules for skill creation, naming conventions,
token discipline, MCP output discipline, verification requirements, failure escalation,
commit message format, routing evaluation, and the ultimate value test ...]
```

## Response snapshot

Created the MJS Skills Constitution v1.0.0, then amended to v1.1.0 to integrate Agent Skills standard.

### v1.0.0 - Initial ratification
7 core principles derived from CLAUDE.md operational directives:
1. **Skills Over Tools** - Skills encode judgment, not automation
2. **Gerund Naming** - Use `deploying-*`, `scaffolding-*` form
3. **Trigger-Based Descriptions** - Include "Use when [trigger]"
4. **Token Discipline** - SKILL.md ≤500 tokens, verify.py <100 chars
5. **Verification Required** - verify.py returning 0/1 with actionable messages
6. **MCP Output Discipline** - Never inject raw MCP output into context
7. **Failure Escalation** - Stop after 2 failures, request human intervention

### v1.1.0 - Agent Skills standard integration
- Added "Authoritative Standard" section referencing `agentskills-standard/docs/specification.mdx`
- Enhanced Principle IV with Progressive Disclosure pattern from spec (3 layers: metadata→instructions→resources)
- Added spec constraints to Principle II (64 char max, naming rules)
- Added `skills-ref validate` as first step in shipping workflow
- Added optional fields (license, compatibility, metadata) to SKILL.md template
- Added File References section with one-level-deep rule
- Updated Governance to defer to Agent Skills spec where applicable

## Outcome

- ✅ Impact: Constitution v1.1.0 ratified at `.specify/memory/constitution.md`
- 🧪 Tests: N/A (governance document)
- 📁 Files: 1 created/amended (.specify/memory/constitution.md)
- 🔁 Next prompts: Create first skill using constitution + Agent Skills spec; Run `/sp.adr` if architectural decisions needed
- 🧠 Reflection: Integration with Agent Skills standard adds authoritative backing. Progressive disclosure pattern clarifies when different resources load.

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): N/A (constitution creation)
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Validate constitution against first skill creation to identify gaps
