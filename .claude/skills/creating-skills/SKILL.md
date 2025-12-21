---
name: creating-skills
description: |
  Guides creation of effective Agent Skills with proper structure and validation.
  Use when users want to create a new skill, update an existing skill, or need
  guidance on skill design patterns, SKILL.md format, or verify.py implementation.
  NOT when just using existing skills (use those skills directly).
---

## Quick Start

```bash
# Initialize new skill
python3 scripts/init_skill.py <skill-name> --path .claude/skills/

# Validate after editing
python3 scripts/verify.py
```

## Instructions

1. **Understand the skill** with concrete examples from user
2. **Plan contents**: scripts/, references/, assets/
3. **Initialize**:
   ```bash
   python3 scripts/init_skill.py <name> --path .claude/skills/
   ```
4. **Edit SKILL.md** with proper frontmatter:
   ```yaml
   ---
   name: gerund-form-name
   description: |
     What it does. Use when [trigger]. NOT when [exclusion].
   ---
   ```
5. **Create verify.py** that exits 0/1 with <100 char output
6. Run verification: `python3 scripts/verify.py`

## Skill Structure

```
skill-name/
├── SKILL.md           # Required: YAML frontmatter + instructions
├── scripts/
│   └── verify.py      # Required: Exit 0/1
├── references/        # Optional: Deep docs (one level only)
└── assets/            # Optional: Templates, images
```

## Naming Rules

- Gerund form: `deploying-*`, `fetching-*`, `creating-*`
- Max 64 chars, lowercase + hyphens only
- BANNED: `utils`, `helpers`, `setup`, `manage`, `handle`

## Token Budget

- SKILL.md: ≤300 tokens preferred (500 max)
- verify.py output: <100 characters
- References: one level deep only

## If Verification Fails

1. Run diagnostic: `python3 scripts/verify.py --verbose`
2. Check: YAML frontmatter, name format, description trigger
3. **Stop and report** - do not proceed with downstream steps

## References

See [references/design-patterns.md](references/design-patterns.md) for workflow patterns.
