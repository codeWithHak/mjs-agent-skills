---
name: fetching-library-docs
description: |
  Fetches library documentation with 77% token savings via shell pipeline filtering.
  Use when users ask about library docs, need code examples, want API patterns,
  are learning frameworks, or need syntax reference for React, Next.js, Prisma, etc.
  NOT when documentation is already in local files or cached.
---

## Quick Start

```bash
bash scripts/fetch-docs.sh --library react --topic useState
```

Returns ~205 tokens instead of ~934 (77% savings).

## Instructions

1. Identify library and topic from user query
2. Fetch with shell pipeline:
   ```bash
   bash scripts/fetch-docs.sh --library <library> --topic <topic>
   ```
3. Run verification: `python3 scripts/verify.py`

## Parameters

```bash
bash scripts/fetch-docs.sh [OPTIONS]

# Required (pick one):
--library <name>      # e.g., "react", "nextjs"
--library-id <id>     # Direct Context7 ID (faster)

# Optional:
--topic <topic>       # Specific feature focus
--mode <code|info>    # code (default) or info
--verbose             # Show token savings
```

## Common Library IDs

```
React:    /reactjs/react.dev
Next.js:  /vercel/next.js
Prisma:   /prisma/docs
Express:  /expressjs/express
MongoDB:  /mongodb/docs
Vue.js:   /vuejs/docs
```

## If Verification Fails

1. Run diagnostic: `pgrep -f "context7"`
2. Check: Context7 MCP server accessible
3. **Stop and report** - do not proceed with downstream steps

## References

See [references/context7-tools.md](references/context7-tools.md) for complete tool docs.
