<!--
== SYNC IMPACT REPORT ==
Version change: 1.0.0 → 1.1.0 (MINOR - added Agent Skills standard reference and progressive disclosure)
Modified principles:
  - IV. Token Discipline: Updated to align with Agent Skills spec progressive disclosure
Added sections:
  - Authoritative Standard reference
  - Progressive Disclosure section
  - Validation with skills-ref
Removed sections: None
Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ No changes needed
  - .specify/templates/spec-template.md: ✅ No changes needed
  - .specify/templates/tasks-template.md: ✅ No changes needed
  - .specify/templates/phr-template.prompt.md: ✅ No changes needed
Follow-up TODOs: None
-->

# MJS Skills Constitution

> Personal Agent Skills library. Skills are frozen decisions—not tools, not utilities, not helpers. Each skill encodes judgment about what matters, what fails, and what works.

## Authoritative Standard

This library follows the [Agent Skills Specification](agentskills-standard/docs/specification.mdx).

When in doubt, the specification takes precedence. This constitution adds project-specific constraints on top of the standard.

## Core Principles

### I. Skills Over Tools

Skills are externalized intelligence that compounds value over decades. Each skill MUST answer:
- What matters here?
- What can go wrong?
- What is the fastest correct path?
- How do I know I'm done?

**Rationale**: Skills encode judgment, not automation. The goal is to do the right work faster—and know why it works. If you would not recreate a skill after deletion, it has no value.

### II. Gerund Naming

Skill names MUST use gerund form (present participle) as the strong default: `deploying-*`, `scaffolding-*`, `building-*`.

**Spec constraints** (from Agent Skills standard):
- Max 64 characters
- Lowercase letters, numbers, and hyphens only
- Must not start/end with hyphen or contain consecutive hyphens
- Must match parent directory name

**Exception**: Pattern names may override when semantically sharper (e.g., `kafka-exactly-once` over `implementing-kafka-exactly-once`).

**Test**: Would two people searching for the same capability type the same thing?

**BANNED**: Vague names like `utils`, `helpers`, `setup`, `manage`, `handle`.

**Rationale**: The name is the index key in both human memory and agent routing. A bad name is worse than a non-standard name.

### III. Trigger-Based Descriptions

Every skill description MUST:
- Include "Use when [trigger condition]" to enable routing
- Use third person ("Deploys..." not "I deploy...")
- Stay under 1024 characters total (per Agent Skills spec)
- Add "NOT when [exclusion]" if collision is possible

**BANNED words**: "manage", "handle", "setup", "utilities", "helpers".

**Rationale**: Vague descriptions cause routing failures. If two skills could match the same query, at least one is incorrectly designed.

### IV. Token Discipline & Progressive Disclosure

Context window is a shared resource. Follow progressive disclosure (per Agent Skills spec):

| Layer | Content | Token Budget | When Loaded |
|-------|---------|--------------|-------------|
| 1. Metadata | `name` + `description` | ~100 tokens | Always (startup) |
| 2. Instructions | SKILL.md body | <5000 tokens | When skill activates |
| 3. Resources | scripts/, references/, assets/ | As needed | On demand only |

**Project-specific budgets**:
| Component | Budget | Enforcement |
|-----------|--------|-------------|
| SKILL.md body | <5000 tokens | Recommended |
| SKILL.md lines | <500 lines | Required |
| verify.py output | <100 characters | Required |
| Reference depth | One level only | Required |

**Rationale**: Keep SKILL.md concise but complete. Move detailed reference material to separate files. Scripts execute without consuming context tokens.

### V. Verification Required

Every skill MUST include `scripts/verify.py` that:
- Returns exit code 0 with minimal success message on success
- Returns exit code 1 with actionable error message on failure
- Includes diagnostic command in failure output
- Keeps output under 100 characters

**Rationale**: Verification makes skill outcomes monitorable. "It worked" is insufficient; "I know why it worked" is required.

### VI. MCP Output Discipline

MCP tool outputs MUST NEVER be injected verbatim into model context.

All MCP responses MUST be:
- Filtered to task-relevant signals
- Summarized to ≤200 tokens
- Reduced to structured signals before context entry

Raw MCP payloads are ONLY allowed in local execution or temporary files.

**BANNED patterns**:
- `print(full_response)`
- `context += mcp_output`
- `return transcript` without filtering

**Rationale**: Unfiltered MCP output can consume 25,000+ tokens for simple operations.

### VII. Failure Escalation

If verification fails twice:
1. STOP further automation
2. Surface the minimal diagnostic command
3. Request human intervention explicitly
4. Do NOT proceed with downstream steps

**Rationale**: Agents that retry indefinitely without escalation waste resources and mask systemic issues. Knowing when to stop shows maturity.

## Skill Structure

Every skill MUST follow this structure (per Agent Skills spec):

```
.claude/skills/[skill-name]/
├── SKILL.md           # Required: YAML frontmatter + instructions
└── scripts/
    └── verify.py      # Required by this constitution: Exit 0/1
```

Optional components (loaded on demand):
```
├── scripts/
│   └── deploy.sh      # Execution script
├── references/        # Deep docs (one level only)
│   └── REFERENCE.md
├── assets/            # Static resources (templates, images, data)
└── templates/         # Reusable scaffolds
```

### SKILL.md Format

```yaml
---
name: [gerund-form-name]
description: |
  [What it does in one sentence].
  Use when [specific trigger condition].
# Optional fields (per Agent Skills spec):
license: Apache-2.0
compatibility: Requires kubectl, helm
metadata:
  author: mjs
  version: "1.0"
---

## Quick Start
[Immediate action for the 80% case]

## Instructions
1. [Step with command]
2. [Step with command]
3. `python scripts/verify.py`

## If Verification Fails
1. Run diagnostic: `[specific command]`
2. Check: `[what to look for]`
3. **Stop and report** — do not proceed with downstream steps
```

### File References

When referencing other files, use relative paths from skill root:
```markdown
See [the reference guide](references/REFERENCE.md) for details.
Run: `scripts/deploy.sh`
```

Keep references one level deep. Avoid deeply nested reference chains.

## Development Workflow

### Before Shipping Any Skill

1. **Validate with skills-ref**:
   ```bash
   skills-ref validate ./.claude/skills/[skill-name]
   ```

2. **Structure check**:
   - SKILL.md exists with valid YAML frontmatter
   - scripts/verify.py exists and is executable
   - Name uses gerund form and matches directory
   - Description includes "Use when" trigger

3. **Token check**:
   - SKILL.md body ≤500 tokens (~400 words)
   - SKILL.md <500 lines total
   - verify.py output <100 characters

4. **verify.py test**:
   - Exits 0 with success message
   - Exits 1 with actionable error + diagnostic command

5. **Routing evaluation**:
   - Positive test: Natural language query triggers skill
   - Negative test: Related but different query does NOT trigger
   - Collision test: Ambiguous query triggers only ONE skill

### Commit Message Format

```
Claude: [action] using [skill-name] skill
```

Examples:
- `Claude: deployed kafka using deploying-kafka-k8s skill`
- `Claude: scaffolded triage-service using scaffolding-fastapi-dapr skill`

### Modifying Existing Skills

1. Check if change is backward-compatible
2. If breaking change → create new skill with `-v2` suffix
3. Update any dependent skills
4. Re-run routing evaluations
5. Re-validate with `skills-ref validate`

## Governance

This constitution supersedes all other practices for skill development in this repository, except where the Agent Skills specification takes precedence.

### Amendment Procedure

1. Propose change with rationale
2. Verify change does not violate core principles or Agent Skills spec
3. Update version following semantic versioning:
   - MAJOR: Backward-incompatible principle changes
   - MINOR: New principles or expanded guidance
   - PATCH: Clarifications and typo fixes
4. Update LAST_AMENDED_DATE

### Compliance Review

All skill PRs MUST verify compliance with:
- Agent Skills spec validation (`skills-ref validate`)
- Naming convention (Principle II)
- Description requirements (Principle III)
- Token budgets (Principle IV)
- Verification presence (Principle V)
- MCP output handling (Principle VI)

### Ultimate Value Test

> **Would you recreate this skill if it were deleted?**

If the answer is no, the skill has no value. Do not ship it.

**Version**: 1.1.0 | **Ratified**: 2025-12-21 | **Last Amended**: 2025-12-21
