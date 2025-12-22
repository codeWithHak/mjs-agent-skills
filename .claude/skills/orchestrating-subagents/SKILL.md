---
name: orchestrating-subagents
description: |
  Patterns for dispatching and coordinating Claude Code subagents.
  Use when executing multi-task plans, parallelizing independent work, or coordinating agent outputs.
  NOT for single-step tasks or tightly coupled sequential work.
---

# Orchestrating Subagents

## When to Parallelize

```
Task has multiple items?
        │
        ▼
   ┌────────────┐
   │ Dependencies│──YES──► Sequential (chain results)
   │ between them?│
   └────────────┘
        │ NO
        ▼
   ┌────────────┐
   │ Shared state│──YES──► Sequential (avoid conflicts)
   │ mutations?  │
   └────────────┘
        │ NO
        ▼
   ┌────────────┐
   │ Order      │──YES──► Sequential (preserve order)
   │ matters?   │
   └────────────┘
        │ NO
        ▼
    PARALLELIZE
```

## Agent Prompt Structure

```
[FOCUS]: What exactly to accomplish (one clear goal)
[CONTEXT]: Relevant background from parent conversation
[CONSTRAINTS]: What NOT to do, boundaries, scope limits
[OUTPUT]: Expected format and what to return
```

**Example:**

```
[FOCUS]: Implement the UserService class based on the interface in types.ts

[CONTEXT]:
- Project uses SQLModel for database
- Auth handled by Better Auth (see auth.ts)
- Follow patterns in existing ProductService

[CONSTRAINTS]:
- Do NOT modify the database schema
- Do NOT add new dependencies
- Keep methods under 50 lines

[OUTPUT]:
- Modified user_service.py file
- Summary of what was implemented
```

## Dispatch Patterns

### Independent Tasks (Parallel)

```python
# All tasks can run simultaneously
tasks = [
    "Implement UserService",
    "Implement ProductService",
    "Implement OrderService"
]
# Each gets own agent, results merged at end
```

### Dependent Chain (Sequential)

```python
# Each step needs previous result
chain = [
    "1. Design database schema",      # Must complete first
    "2. Generate migrations",          # Needs schema
    "3. Implement models",             # Needs migrations
]
# Pass output of each to next agent
```

### Fan-Out/Fan-In

```python
# Parallel work → aggregation step
parallel = ["Review auth", "Review API", "Review DB"]
aggregate = "Synthesize reviews into action plan"
# Run parallel, collect results, then aggregate
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Parallelizing dependent tasks | Race conditions, missing data | Check dependency graph first |
| Vague focus statements | Agent wanders, does wrong thing | One specific goal per agent |
| Missing constraints | Agent over-engineers | Explicit "do NOT" list |
| No output format | Hard to integrate results | Specify exact format expected |
| Too much context | Slower, confused agent | Only relevant background |

## Integration Verification

After subagents complete:

1. **Check for conflicts**: Did parallel agents modify same files?
2. **Validate outputs**: Do results match expected format?
3. **Test integration**: Do pieces work together?
4. **Handle failures**: If one fails, can others proceed?

```bash
# Quick conflict check after parallel file edits
git diff --name-only | sort | uniq -d
# If duplicates, manual merge needed
```

## Anti-Patterns

- **Over-parallelization**: 2-3 parallel agents max, more causes coordination overhead
- **Under-specification**: "Fix the tests" → agent guesses which tests, how to fix
- **Context dumping**: Sending entire codebase → slow, confused
- **No failure handling**: One agent fails → entire workflow stuck

## Verification

Run: `python scripts/verify.py`
