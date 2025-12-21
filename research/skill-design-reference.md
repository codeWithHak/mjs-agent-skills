# Personal Skill Library: Design Reference

> **Purpose**: Design principles for building a lifetime skill library that compounds personal value.
> **Philosophy**: Skills are not tools. They are frozen decisions. Each skill encodes:
> - What matters here?
> - What can go wrong?
> - What is the fastest correct path?
> - How do I know I'm done?

This library represents externalized intelligence that compounds value over decades. The bar is higher than MIT, OpenAI, or Google—because this optimizes for **personal throughput**, **context dominance**, and **problem-to-solution compression**, not coordination, publication, or scale.

---

## Part 0: Core Principles (From Anthropic Best Practices)

### Principle 1: Concise is Key

The context window is a public good. Your Skill shares it with:
- The system prompt
- Conversation history
- Other Skills' metadata
- The actual request

**Default assumption: Claude is already very smart.**

Only add context Claude doesn't already have. Challenge each piece:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

**Good (50 tokens):**
```markdown
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
```

**Bad (150 tokens):**
```markdown
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available...
```

The concise version assumes Claude knows what PDFs are.

### Principle 2: Set Appropriate Degrees of Freedom

Think of Claude as a robot exploring a path:
- **Narrow bridge with cliffs**: Only one safe way → exact instructions
- **Open field**: Many paths work → general direction

### Principle 3: Test With All Models

| Model | Consideration |
|-------|---------------|
| Claude Haiku | Does skill provide enough guidance? |
| Claude Sonnet | Is skill clear and efficient? |
| Claude Opus | Does skill avoid over-explaining? |

What works for Opus might need more detail for Haiku.

---

## Part 1: What Is a Skill?

### Definition
A Skill is a **reusable unit of intelligence** - a folder containing instructions, scripts, and resources that teach AI coding agents how to perform specific tasks autonomously.

### The Mental Shift
```
Traditional: You write code → Code runs → Application works
Agentic:     You write Skills → AI learns patterns → AI writes code → Application works
```

**Key insight**: Skills are the product. The application built with skills is the demo.

### Core Components
```
skill-name/
├── SKILL.md              # Required: YAML frontmatter + instructions (~100-500 tokens)
├── scripts/              # Optional: Executable code (0 tokens until executed)
│   ├── deploy.sh         # Does the work
│   └── verify.py         # Proves it worked
├── references/           # Optional: Deep docs (loaded on-demand)
│   └── REFERENCE.md
└── templates/            # Optional: Reusable scaffolds
    └── Dockerfile
```

---

## Part 2: The Token Economics Problem

### Why This Matters
The context window is a shared resource. Every token consumed by tool definitions or intermediate results leaves less room for actual work.

### The Problem: Direct MCP
```
MCP Servers Connected    Token Cost BEFORE Conversation
1 server (5 tools)       ~10,000 tokens
3 servers (15 tools)     ~30,000 tokens
5 servers (25 tools)     ~50,000+ tokens (25% of context gone)
```

**Worse**: Intermediate results flow through context twice:
```
TOOL CALL: gdrive.getDocument(documentId: "abc123")
        → returns full transcript (25,000 tokens into context)

TOOL CALL: salesforce.updateRecord(data: { Notes: [full transcript] })
        → model writes transcript again (25,000 more tokens)
  
Total: 50,000 tokens for a simple copy operation
```

### The Solution: Skills + Code Execution

| Component | Tokens | When |
|-----------|--------|------|
| name + description | ~50 | Always (startup) |
| SKILL.md body | ~100-300 | When skill activates |
| scripts/*.py | 0 | Executed, not loaded |
| Final output | ~10-50 | After execution |

**Result**: 80-98% token reduction while maintaining full capability.

### The Pattern
```
SKILL.md tells agent WHAT (~100 tokens, loaded)
scripts/*.py does the WORK (0 tokens, executed)
Only the final result enters context ("✓ Done")
```

---

## Part 3: Skill Anatomy

### YAML Frontmatter (Required)

```yaml
---
name: deploying-kafka-k8s
description: Deploy Apache Kafka on Kubernetes using Helm charts. Use when setting up event streaming, pub/sub messaging, or building event-driven microservices.
---
```

**Rules**:
- `name`: Max 64 chars, lowercase + hyphens only, no "anthropic" or "claude"
- `description`: Max 1024 chars, must include "Use when [trigger]"
- Write in third person ("Deploys..." not "I deploy..." or "You can deploy...")

### Naming Convention: Retrievability > Stylistic Purity

The name is the **index key** in your brain + agent router. A bad name is worse than a non-standard name.

**Core rule**: Gerund form is the strong default, but **semantic sharpness wins**.

```
✓ deploying-kafka-k8s          (gerund + specific)
✓ generating-agents-md         (gerund + concrete output)
✓ kafka-exactly-once-pattern   (pattern name > vague gerund)
✗ provisioning-kafka           (too generic, hides the real value)
✗ utils                        (vague, unfindable)
✗ deploy-kafka                 (imperative - less natural)
```

**The test**: If two people search for the same capability, will they type the same thing?

### Skill Routing & Activation Heuristics

**Why routing fails:**
- Description too generic ("Manage Kafka", "Handle data")
- Trigger overlaps with other skills
- Verb doesn't imply concrete action ("Kafka utilities")
- Keywords don't match user intent

**Routing success patterns:**

| Prefer | Avoid |
|--------|-------|
| Concrete verbs + domain + outcome | Vague verbs: "manage", "handle", "setup" |
| Specific technology names | Generic nouns: "utilities", "helpers" |
| Clear trigger conditions | Overlapping scopes |

**Examples:**
```yaml
# ❌ BAD - Vague, no action implied
description: Kafka setup utilities

# ❌ BAD - Overlaps with everything
description: Helps with Kubernetes deployments

# ✅ GOOD - Concrete verb, domain, trigger
description: Deploys Apache Kafka on Kubernetes using Helm. Use when setting up event streaming or pub/sub messaging.
```

**Disambiguation rule:** If two skills could match, make descriptions mutually exclusive or add negative triggers ("Use when X, NOT when Y").

### SKILL.md Body Structure

```markdown
# [Skill Name]

## Quick Start
[Immediate action - the 80% case]

## Instructions
1. [Step with command]
2. [Step with command]
3. [Validation step]

## Validation
- [ ] [Checkable outcome]
- [ ] [Checkable outcome]

## References
- [REFERENCE.md](./REFERENCE.md) for configuration options
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
```

**Critical rules**:
- Keep under 500 lines, <5000 tokens (per Agent Skills spec)
- References one level deep only
- No time-sensitive information
- Consistent terminology throughout

---

## Part 4: Scripts That Work

### The Verification Pattern

Every skill MUST have a `verify.py` that returns:
- Exit code 0 + minimal success message on success
- Exit code 1 + actionable error on failure

```python
#!/usr/bin/env python3
"""Verify [what this checks]."""
import subprocess
import json
import sys

def main():
    # Do actual verification
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", "kafka", "-o", "json"],
        capture_output=True, text=True
    )
    
    if result.returncode != 0:
        print(f"✗ kubectl failed: {result.stderr}")
        sys.exit(1)
    
    pods = json.loads(result.stdout)["items"]
    running = sum(1 for p in pods if p["status"]["phase"] == "Running")
    total = len(pods)
    
    # Return MINIMAL output - this is all that enters context
    if running == total:
        print(f"✓ All {total} pods running")
        sys.exit(0)
    else:
        print(f"✗ {running}/{total} pods running - check: kubectl get pods -n kafka")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### Script Design Principles

1. **Solve, don't punt**: Handle errors explicitly, don't let Claude figure it out
2. **No magic numbers**: Document every constant
3. **Minimal output**: Only print what's essential for context
4. **Self-contained**: Document dependencies, don't assume packages exist

```python
# BAD - punts to Claude
def process():
    return open(path).read()  # Will crash, Claude has to debug

# GOOD - handles errors
def process():
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        Path(path).touch()
        return ''
```

### MCP Wrapping Pattern

When wrapping MCP servers:

```python
#!/usr/bin/env python3
"""Wrap MCP server calls with filtering."""

async def sync_transcript(doc_id: str, record_id: str):
    # Get data (full transcript, maybe 25K tokens)
    transcript = await gdrive.getDocument(documentId=doc_id)
    
    # Process locally (0 tokens to context)
    summary = extract_key_points(transcript)
    
    # Update target
    await salesforce.updateRecord(
        objectType='Lead',
        recordId=record_id,
        data={'Notes': summary}
    )
    
    # Only this enters context
    print(f"✓ Synced {len(summary)} chars to Lead {record_id}")
```

---

## Part 5: Degrees of Freedom

Match specificity to task fragility:

### High Freedom (Multiple valid approaches)
```markdown
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability
4. Verify adherence to project conventions
```
Use when: Context determines approach, many paths work.

### Medium Freedom (Preferred pattern, some variation OK)
```markdown
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
```
```
Use when: A preferred pattern exists but configuration varies.

### Low Freedom (Exact sequence required)
```markdown
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
```
Use when: Operations are fragile, consistency is critical.

**Analogy**:
- **Narrow bridge**: One safe way forward → exact instructions
- **Open field**: Many paths work → general direction

---

## Part 6: Workflows & Feedback Loops

### The Checklist Pattern

For complex multi-step operations:

```markdown
## Deployment workflow

Copy this checklist and track progress:

```
Deployment Progress:
- [ ] Step 1: Deploy infrastructure (run deploy.sh)
- [ ] Step 2: Verify pods (run verify.py)
- [ ] Step 3: Run smoke tests (run test.py)
- [ ] Step 4: Update documentation
```

**Step 1: Deploy infrastructure**
Run: `./scripts/deploy.sh`
Expected: "✓ Deployed to namespace 'app'"

**Step 2: Verify pods**
Run: `python scripts/verify.py`
Expected: "✓ All pods running"
If failed: Check logs with `kubectl logs -n app`

...
```

### The Validation Loop

```
Run validator → Fix errors → Repeat until pass → Proceed
```

```markdown
## Document editing process

1. Make edits to the document
2. **Validate immediately**: `python scripts/validate.py`
3. If validation fails:
   - Review the error message
   - Fix the issues
   - Run validation again
4. **Only proceed when validation passes**
5. Finalize output
```

### Failure Escalation Rule

Agents don't just succeed. Define what happens when things fail repeatedly.

**The Rule:**
```
If verification fails twice:
1. Stop further automation
2. Surface the minimal diagnostic command
3. Request human intervention explicitly
```

**In SKILL.md, include:**
```markdown
## If Verification Fails

If `verify.py` fails after retry:
1. Run diagnostic: `kubectl describe pods -n kafka`
2. Check events: `kubectl get events -n kafka --sort-by='.lastTimestamp'`
3. **Stop and report**: Do not proceed with downstream steps.
   Ask user to investigate before continuing.
```

This shows maturity and safety - judges notice this.

### Skill Monitorability (From OpenAI Research)

OpenAI's December 2025 research on chain-of-thought monitorability reveals a key insight: **monitors with access to explicit reasoning outperform monitors with only actions/outputs**.

This directly applies to skills:
- `verify.py` makes skill outcomes **monitorable**
- Explicit steps in SKILL.md make agent reasoning **inspectable**
- Commit messages with skill names make provenance **traceable**

**Monitorability pattern:**
```
Skill execution → verify.py → Success/Failure + Reason → Next action or Human escalation
```

**Why this matters**: As agents scale to more complex tasks, monitorability becomes the difference between "it worked" and "I know why it worked." Skills that expose their reasoning path are more trustworthy than black-box automations.

**Skill monitorability checklist:**
- [ ] verify.py emits clear success/failure reason
- [ ] SKILL.md shows explicit decision points
- [ ] Commit messages include skill name used
- [ ] Errors include diagnostic commands

---

## Part 7: Cross-Agent Compatibility

### The Shared Standard

Skills written once work across:
- Claude Code
- Goose (AAIF Standard)
- OpenAI Codex

All read the same `.claude/skills/` or `.github/skills/` directory.

### MCP Tool References

Always use fully qualified names:

```markdown
Use the Google-Drive:getDocument tool to retrieve files.
Use the Salesforce:updateRecord tool to update leads.
```

Format: `ServerName:tool_name`

### MCP Output Discipline

MCP tool outputs must never be injected verbatim into model context.

All MCP responses MUST be:
- filtered,
- summarized, or
- reduced to task-relevant signals

before entering context.

Raw MCP payloads are only allowed in local execution or temporary files, not in prompts or conversation history.

**Implementation pattern:**
```python
# BAD: Raw MCP output enters context
result = mcp_client.call("context7", "getDocumentation", {"lib": "react"})
print(result)  # 900+ tokens dumped into context

# GOOD: Filter before context entry
result = mcp_client.call("context7", "getDocumentation", {"lib": "react"})
# Shell pipeline filters to code examples only
filtered = subprocess.run(
    ["grep", "-A5", "```"],
    input=result,
    capture_output=True
).stdout
print(filtered)  # ~200 tokens, only what's needed
```

### Script Portability Caveats

- Python/Bash widely supported
- Execution behavior varies by agent
- Document dependencies explicitly
- Handle edge cases gracefully
- If agent runtime doesn't support async, provide synchronous wrapper

**Clarification on "0 tokens":** Scripts do not consume model context tokens. Only their stdout/stderr output does. This is why minimal output matters.

### Skill Composition Model

When skills depend on other skills:

```
Agents should:
1. Resolve prerequisites first (check if kafka deployed before deploying services)
2. Verify each layer before proceeding
3. Never assume downstream success if upstream verification failed
```

**Document dependencies in instructions, not frontmatter** (no built-in mechanism):

```markdown
## Prerequisites

Before using this skill:
- Run `deploying-kafka-k8s` skill first
- Verify: `python .claude/skills/deploying-kafka-k8s/scripts/verify.py`
```

---

## Part 8: Evaluation Criteria

From first principles, skills should be evaluated on:

| Criterion | Weight | Gold Standard |
|-----------|--------|---------------|
| Skills Autonomy | 15% | Single prompt → running K8s deployment, zero manual intervention |
| Token Efficiency | 10% | Scripts for execution, MCP calls wrapped efficiently |
| Cross-Agent Compatibility | 5% | Same skill works on Claude Code AND Goose |
| Architecture | 20% | Correct Dapr patterns, Kafka pub/sub, stateless microservices |
| MCP Integration | 10% | MCP server provides rich context for debugging/expansion |
| Documentation | 10% | Comprehensive Docusaurus site deployed via skills |
| Spec-Kit Plus Usage | 15% | High-level specs translate to agentic instructions |
| LearnFlow Completion | 15% | Application built entirely via skills |

### What Judges Will Do

1. **Test skill activation**: Does description trigger correctly?
2. **Test autonomy**: Single prompt → complete execution?
3. **Test cross-agent**: Works on both Claude Code and Goose?
4. **Test verification**: Does verify.py actually prove success?

### Emerging Evaluation Patterns

1. **Discovery checks**: Agent finds skill automatically in correct directory
2. **Description quality**: Router picks it up without explicit forcing
3. **Completeness**: All necessary files to run standalone
4. **Actionability**: Executes without user clarification
5. **Resilience**: Graceful handling of failures
6. **Context efficiency**: Doesn't pollute context window
7. **Tool chaining**: Can be used with other skills in sequence

---

## Part 9: Anti-Patterns to Avoid

### Anti-Pattern 1: Deeply Nested References

Claude may partially read files when referenced from other referenced files.

**Bad (too deep):**
```
SKILL.md → advanced.md → details.md → actual info
```

**Good (one level deep):**
```
SKILL.md → advanced.md (complete info)
         → reference.md (complete info)
         → examples.md (complete info)
```

### Anti-Pattern 2: Too Many Options

**Bad:**
```markdown
You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or...
```

**Good:**
```markdown
Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead.
```

Provide a default with an escape hatch, not a menu.

### Anti-Pattern 3: Windows-Style Paths

**Bad:** `scripts\helper.py`
**Good:** `scripts/helper.py`

Unix-style paths work everywhere.

### Anti-Pattern 4: Assuming Tools Are Installed

**Bad:**
```markdown
Use the pdf library to process the file.
```

**Good:**
```markdown
Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
```
```

### Anti-Pattern 5: Punting Errors to Claude

**Bad:**
```python
def process():
    return open(path).read()  # Crashes, Claude debugs
```

**Good:**
```python
def process():
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"Creating {path}")
        Path(path).touch()
        return ''
```

### Anti-Pattern 6: Voodoo Constants

**Bad:**
```python
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

**Good:**
```python
# HTTP requests typically complete within 30 seconds
REQUEST_TIMEOUT = 30

# Most failures resolve by second retry
MAX_RETRIES = 3
```

---

## Part 10: Skill Quality Checklist

Before shipping any skill, verify:

### Core Quality
- [ ] Name follows gerund form (`deploying-x`, `generating-x`)
- [ ] Description includes "Use when [trigger]"
- [ ] Description is third person
- [ ] SKILL.md under 500 lines
- [ ] References one level deep
- [ ] No time-sensitive information
- [ ] Consistent terminology
- [ ] Clear workflow steps

### Scripts
- [ ] verify.py exists and returns 0/1
- [ ] verify.py output is minimal (<100 chars)
- [ ] Error messages are actionable
- [ ] No magic numbers (all constants documented)
- [ ] Dependencies listed in SKILL.md
- [ ] Handles edge cases gracefully

### MCP Output Discipline (Lint Rules)
- [ ] No raw MCP output is passed directly into model context
- [ ] MCP responses are summarized to ≤200 tokens or reduced to structured signals
- [ ] Scripts handle MCP payloads locally and emit minimal confirmation output
- [ ] No `print(full_response)` patterns
- [ ] No `context += mcp_output` patterns
- [ ] No `return transcript` without filtering

### Testing
- [ ] Works on Claude Code
- [ ] Works on Goose
- [ ] Single prompt → complete execution
- [ ] Verification script proves success
- [ ] Can chain with other skills

---

## Part 11: Skills Inventory for LearnFlow

### The Dependency Graph

```
Foundation Layer
├── generating-agents-md
└── executing-mcp-code (meta-pattern)

Infrastructure Layer (depends on Foundation)
├── deploying-kafka-k8s
├── deploying-postgres-k8s
├── deploying-kong-k8s
└── deploying-redis-k8s

Application Layer (depends on Infrastructure)
├── scaffolding-fastapi-dapr
├── scaffolding-openai-agents
└── deploying-nextjs-k8s

Integration Layer (depends on Application)
├── configuring-dapr-pubsub
├── configuring-dapr-state
└── integrating-mcp-servers

DevOps Layer (depends on all above)
├── deploying-docusaurus
├── configuring-argocd
└── setting-up-github-actions
```

### Skill Template

```yaml
---
name: [gerund-form-name]
description: [What it does]. Use when [trigger condition].
---

# [Skill Name]

## Prerequisites
- [Dependency 1] - run `[skill-name]` first
- [Tool/package requirement]

## Quick Start

```bash
./scripts/deploy.sh [args]
```

## Instructions

1. **Prepare**: [Setup step]
   ```bash
   [command]
   ```

2. **Deploy**: [Main action]
   ```bash
   ./scripts/deploy.sh
   ```

3. **Verify**: [Confirmation]
   ```bash
   python scripts/verify.py
   ```
   Expected: "✓ [success message]"

## Validation Checklist
- [ ] [Checkable outcome 1]
- [ ] [Checkable outcome 2]

## Troubleshooting

**[Common issue]**
- Symptom: [what you see]
- Solution: [what to do]

## References
- [REFERENCE.md](./REFERENCE.md) for advanced configuration
```

---

## Part 12: The Build-Test-Ship Loop

### Evaluation-Driven Development (Build Evaluations First)

**Create evaluations BEFORE writing extensive documentation.**

1. **Identify gaps**: Run Claude on representative tasks without a Skill. Document failures.
2. **Create evaluations**: Build 3 scenarios that test these gaps
3. **Establish baseline**: Measure performance without the Skill
4. **Write minimal instructions**: Just enough to pass evaluations
5. **Iterate**: Execute, compare, refine

**Evaluation structure:**
```json
{
  "skills": ["deploying-kafka-k8s"],
  "query": "Deploy Kafka on my Kubernetes cluster for event streaming",
  "expected_behavior": [
    "Deploys Kafka using Helm to the kafka namespace",
    "Creates required topics for LearnFlow events",
    "Verifies all pods reach Running state"
  ]
}
```

### The Claude A/B Development Pattern

Use one Claude instance ("Claude A") to create skills that another instance ("Claude B") will use.

**Creating a new Skill:**

1. **Complete a task without a Skill**: Work through problem with Claude A. Notice what context you repeatedly provide.

2. **Identify the reusable pattern**: What would be useful for similar future tasks?

3. **Ask Claude A to create the Skill**: 
   > "Create a Skill that captures this Kafka deployment pattern we just used. Include the Helm commands, namespace conventions, and verification steps."

4. **Review for conciseness**: 
   > "Remove the explanation about what Kafka is - Claude already knows that."

5. **Improve information architecture**: 
   > "Move the troubleshooting section to a separate TROUBLESHOOTING.md file."

6. **Test with Claude B**: Use the Skill on a fresh instance with real tasks.

7. **Iterate based on observation**: 
   > "When Claude B used this Skill, it forgot to check pod readiness. Should we make that step more prominent?"

### For Each Skill

```
1. DESIGN (5 min)
   - Write SKILL.md frontmatter
   - Define verify.py signature
   - List dependencies

2. BUILD (15-30 min)
   - Write SKILL.md body
   - Create scripts/
   - Create templates/ if needed

3. TEST (10 min)
   - Run with Claude Code
   - Run with Goose (if available)
   - Verify single-prompt autonomy

4. SHIP (5 min)
   - Commit with agentic message
   - Document in skills library README
```

### Commit Message Convention (Judge Signal)

**Important:** Judges may inspect commit history for agentic provenance. This convention proves skills were used, not manual coding.

```
Claude: deployed kafka-k8s using deploying-kafka-k8s skill
Goose: scaffolded triage-service using scaffolding-fastapi-dapr skill
Human: manual fix for edge case in triage routing
```

Format: `[Agent]: [action] using [skill-name] skill`

This creates an auditable trail showing which agent used which skill to build each component.

### Skill Versioning

Skills should be backward-compatible. Breaking changes require a new skill name (e.g., `deploying-kafka-k8s-v2`).

For metadata tracking (optional):
```yaml
---
name: deploying-kafka-k8s
description: ...
metadata:
  version: "1.0"
  author: panaversity
---
```

---

## Part 13: What We're NOT Building

To stay focused in 12 hours:

### Out of Scope
- Full 6-agent LearnFlow (build 2-3 agents max)
- Production cloud deployment (Minikube is fine)
- Complete ArgoCD pipeline (document, don't implement)
- All curriculum modules (one module demo is enough)

### In Scope (Must Ship)
- 7+ working skills with verification
- Cross-agent compatibility proven
- LearnFlow MVP (2-3 agents, one flow)
- Docusaurus site deployed via skill
- Clear documentation

---

## Quick Reference Card

### Skill Frontmatter
```yaml
---
name: gerund-form-max-64-chars
description: Does X. Use when Y. Max 1024 chars, third person.
---
```

### Folder Structure
```
skill-name/
├── SKILL.md           # <500 lines
├── scripts/
│   ├── deploy.sh      # Does work
│   └── verify.py      # Exit 0/1, minimal output
└── references/
    └── REFERENCE.md   # Deep docs
```

### Verify Script Template
```python
#!/usr/bin/env python3
import sys
# ... do checks ...
if success:
    print("✓ Specific success message")
    sys.exit(0)
else:
    print("✗ Actionable error message")
    sys.exit(1)
```

### MCP Tool Format
```
ServerName:tool_name
```

---

*Document version: 1.0*
*Personal Skill Library: Design Reference*
*A lifetime investment in encoded judgment*
