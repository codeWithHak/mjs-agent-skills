---
id: 0001
title: Upgrade CLAUDE.md with Skill Governance
stage: general
date: 2025-12-21
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: main
user: mjs
command: /sp.specify
labels: ["claude-md", "governance", "skills", "documentation"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - CLAUDE.md
tests:
  - N/A
---

## Prompt

```text
Let's upgrade our @CLAUDE.md to now include constitution governance and skill development rules from the provided content. It may also include skill ref utility usage as this will be done a lot of times.
```

## Response snapshot

Updated CLAUDE.md to merge SDD workflow with skill governance. Key additions:

### New Sections Added
1. **Before You Do Anything** - Added constitution and Agent Skills spec references
2. **Skill Development Rules** - Complete section with:
   - Authoritative Standard reference
   - Required structure (SKILL.md + verify.py)
   - SKILL.md and verify.py templates
   - Naming rules (gerund form, 64 char max, banned words)
   - Description rules (trigger-based, 1024 char max)
   - Token Discipline with Progressive Disclosure table
   - MCP Output Discipline with banned patterns
   - Verification and Failure Escalation rules
3. **Before Shipping Any Skill** - 5-step validation workflow including `skills-ref validate`
4. **Routing Evaluation** - Positive/negative/collision test table
5. **Skill Commit Messages** - Format and examples
6. **Modifying Existing Skills** - 5-step backward compatibility check
7. **The Ultimate Test** - "Would you recreate this skill if deleted?"

### Consolidated Sections
- Merged PHR creation into streamlined Development Guidelines
- Kept ADR suggestions and Human as Tool Strategy
- Retained Default Policies and Execution Contract
- Updated Project Structure to show full tree

### References Added
- `agentskills-standard/docs/specification.mdx` in Research Documents table
- Constitution path updated to `.specify/memory/constitution.md`

## Outcome

- ✅ Impact: CLAUDE.md now includes complete skill governance from constitution
- 🧪 Tests: N/A (documentation update)
- 📁 Files: 1 modified (CLAUDE.md)
- 🔁 Next prompts: Create first skill using new governance; Run `/sp.adr` if skill architecture decisions needed
- 🧠 Reflection: Merged two distinct concerns (SDD workflow + skill governance) into cohesive document. Progressive disclosure table from constitution is now prominently featured.

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): N/A
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Test CLAUDE.md with first skill creation to verify agent follows governance
