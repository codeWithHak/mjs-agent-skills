# mjs-skills

> Personal skill library that compounds value over decades.
> Skills are not tools. They are frozen decisions.
> Each skill encodes judgment about what matters, what fails, and what works.

---

## What This Is

A curated collection of [Agent Skills](https://agentskills.io) — reusable units of intelligence that teach AI coding agents how to perform specific tasks autonomously.

Each skill encodes:
- **What matters here?** (focus)
- **What can go wrong?** (guardrails)
- **What is the fastest correct path?** (judgment)
- **How do I know I'm done?** (verification)

---

## Philosophy

```
Traditional: You write code → Code runs → Application works
Agentic:     You write Skills → AI learns patterns → AI writes code → Application works
```

**The bar is higher than MIT, OpenAI, or Google** — because this optimizes for personal throughput, context dominance, and problem-to-solution compression, not coordination, publication, or scale.

### Core Rule

> **If two skills plausibly trigger on the same query, at least one is incorrectly designed.**

---

## Structure

```
mjs-skills/
├── .claude/
│   ├── skills/                    # The actual skills (22 total)
│   │   ├── meta/                  # Skills about skills
│   │   ├── mcp-powered/           # MCP server wrappers
│   │   ├── infrastructure/        # K8s & cloud
│   │   ├── application/           # Service scaffolding
│   │   ├── ui-patterns/           # Chat & frontend
│   │   ├── integration/           # Connecting services
│   │   ├── devops/                # Deployment & docs
│   │   └── voice/                 # Voice interfaces
│   │
│   ├── hooks/                     # Evaluation & tracking
│   │   ├── track-prompt.sh        # Log user prompts
│   │   ├── track-skill-start.sh   # Detect skill activation
│   │   ├── track-skill-end.sh     # Capture verify.py results
│   │   └── analyze-skills.py      # Weekly usage analysis
│   │
│   └── activity-logs/             # Passive data collection
│       ├── prompts.jsonl
│       └── skill-usage.jsonl
│
├── research/                      # Design documents
│   ├── skill-design-reference.md  # How to build skills
│   ├── h3-skills-master-prd.md    # What skills to build
│   └── skills-evaluation-prd.md   # How to measure value
│
├── spec/                          # Agent Skills Specification
│   └── ...                        # (cloned from agentskills.io)
│
├── CONSTITUTION.md                # Governance principles
└── README.md                      # You are here
```

---

## Skill Anatomy

```
skill-name/
├── SKILL.md              # YAML frontmatter + instructions (~300 tokens)
├── scripts/
│   ├── verify.py         # Returns 0 (success) or 1 (failure)
│   └── deploy.sh         # Optional: execution script
├── references/           # Optional: deep docs (loaded on-demand)
└── templates/            # Optional: reusable scaffolds
```

### SKILL.md Format

```yaml
---
name: deploying-kafka-k8s
description: |
  Deploys Apache Kafka on Kubernetes using Helm.
  Use when setting up event streaming or pub/sub messaging.
---

## Quick Start
[Immediate action - the 80% case]

## Instructions
1. [Step with command]
2. [Validation step]

## If Verification Fails
[Diagnostic commands + escalation]
```

---

## Hooks: Zero-Overhead Measurement

Claude Code hooks automatically track skill usage without manual intervention.

### How Skills Get Detected

When Claude activates a skill, it reads the SKILL.md:

```bash
cat /path/to/.claude/skills/deploying-kafka-k8s/SKILL.md
```

`PreToolUse` hook detects this pattern → logs to `skill-usage.jsonl`

### Data Flow

```
User prompt 
    → UserPromptSubmit hook logs prompt
    → Claude reads SKILL.md (via cat/view)
    → PreToolUse hook detects skill activation
    → Skill executes
    → verify.py runs
    → PostToolUse hook captures success/failure
    → skill-usage.jsonl contains full trace
```

### What You Get (Free)

| Metric | Source |
|--------|--------|
| Prompt-to-skill correlation | Session ID tracking |
| Skill invocation counts | PreToolUse events |
| Success/failure rates | verify.py exit codes |
| Unused skill detection | Weekly analysis |

---

## Quick Start

### 1. Clone

```bash
git clone https://github.com/mshaukat/mjs-skills.git
cd mjs-skills
```

### 2. Install Hooks

```bash
chmod +x .claude/hooks/*.sh
# Add hook config to ~/.claude/settings.json (see research/skills-evaluation-prd.md)
```

### 3. Use a Skill

In Claude Code:
```
Deploy Kafka on my local Kubernetes cluster
```

Claude will:
1. Find `deploying-kafka-k8s` skill
2. Load SKILL.md into context
3. Execute the deployment
4. Run `verify.py` to confirm success

### 4. Analyze (Weekly)

```bash
python .claude/hooks/analyze-skills.py
```

---

## Routing Evaluation

Before shipping any skill, test routing:

| Test | Query | Expected |
|------|-------|----------|
| **Positive** | "I need event streaming" | `deploying-kafka-k8s` fires |
| **Negative** | "Set up REST APIs" | `deploying-kafka-k8s` does NOT fire |
| **Collision** | "messaging for microservices" | Only ONE skill fires |

---

## The Ultimate Value Test

> **Would you recreate this skill if it were deleted?**

If no → delete it.

---

## Research Documents

| Document | Purpose |
|----------|---------|
| [skill-design-reference.md](research/skill-design-reference.md) | How to build skills |
| [h3-skills-master-prd.md](research/h3-skills-master-prd.md) | What skills to build (22 skills with PRDs) |
| [skills-evaluation-prd.md](research/skills-evaluation-prd.md) | How to measure skill value |

---

## Compatibility

Skills work across:
- Claude Code
- Goose (AAIF Standard)
- OpenAI Codex
- Any agent supporting the [Agent Skills Specification](https://agentskills.io)

---

---

*Skills are frozen decisions. The goal is not to do less work, but to do the right work faster—and know why it works.*