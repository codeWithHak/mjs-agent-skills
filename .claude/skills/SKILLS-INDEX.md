# MJS Skills Library

> 19 agent skills encoding frozen decisions for software engineering workflows.

## What Are Skills?

Skills are **not documentation**. They encode:
- Judgment calls that took hours/days to figure out
- Gotchas that broke production
- Patterns that domain experts use but don't write down
- Tool combinations that work together

**The test:** Would you recreate this if deleted? If Claude already knows it, it's not a skill.

## Skill Categories

### MCP-Backed (3)
Require MCP servers for functionality.

| Skill | Trigger | MCP Server |
|-------|---------|------------|
| `browsing-with-playwright` | "navigate to", "click on", "screenshot" | @anthropic/mcp-playwright |
| `fetching-library-docs` | "how do I use [library]", "React hooks docs" | context7 |
| `researching-with-deepwiki` | "how does [repo] work internally" | deepwiki |

### Infrastructure (3)
Container and Kubernetes workflows.

| Skill | Trigger | Key Value |
|-------|---------|-----------|
| `containerizing-applications` | "dockerize", "helm chart", "docker-compose" | 15+ Docker gotchas |
| `operating-k8s-local` | "minikube", "local kubernetes", "kubectl" | Local dev patterns |
| `deploying-cloud-k8s` | "deploy to AKS/GKE", "CI/CD pipeline" | Build-time vs runtime vars |

### Application (3)
Full-stack application patterns.

| Skill | Trigger | Key Value |
|-------|---------|-----------|
| `building-nextjs-apps` | "Next.js 16", "async params", "app router" | Breaking changes, proxy.ts |
| `scaffolding-fastapi-dapr` | "FastAPI service", "Dapr", "microservice" | SQLModel, pub/sub patterns |
| `configuring-better-auth` | "Better Auth", "OAuth", "SSO" | CORS, email verification |

### UI/Frontend (4)
Chat interfaces and styling.

| Skill | Trigger | Key Value |
|-------|---------|-----------|
| `styling-with-shadcn` | "shadcn", "tailwind components" | Component patterns |
| `building-chat-interfaces` | "chat UI", "message list", "AI chat" | Streaming, markdown |
| `building-chat-widgets` | "chat widget", "embeddable chat" | Widget architecture |
| `streaming-llm-responses` | "stream response", "SSE", "real-time" | Token streaming |

### Documents (2)
Office file manipulation.

| Skill | Trigger | Key Value |
|-------|---------|-----------|
| `working-with-spreadsheets` | "Excel", "xlsx", "financial model" | Color coding, formulas |
| `working-with-documents` | "Word doc", "PDF", "PowerPoint" | OOXML, tracked changes |

### Meta (2)
Skills about skills.

| Skill | Trigger | Key Value |
|-------|---------|-----------|
| `creating-skills` | "create a skill", "new skill" | Skill structure, verification |
| `installing-skill-tracker` | "track skill usage" | Activity logging |

### Integration (2)
External service patterns.

| Skill | Trigger | Key Value |
|-------|---------|-----------|
| `building-mcp-servers` | "MCP server", "tool server" | FastMCP patterns |
| `internal-comms` | "status report", "leadership update" | Company formats |

---

## For Claude: How to Use This Library

### When a Skill Should Trigger

1. **Check the description** - Contains "Use when [trigger]"
2. **Match user intent** - Not just keywords, but what they're trying to accomplish
3. **Verify exclusions** - Some skills say "NOT when [exclusion]"

### When NOT to Use a Skill

- User asks about something Claude already knows well
- The skill would add tokens without adding value
- Multiple skills could apply - pick the most specific one

### Skill Dependencies

Some skills work together:

```
User: "Deploy my Next.js app to Kubernetes"

1. containerizing-applications → Dockerfile, docker-compose
2. building-nextjs-apps → NEXT_PUBLIC_* build args
3. deploying-cloud-k8s → CI/CD, architecture matching
```

### Cross-References

Skills reference each other in "Related Skills" sections. Follow these when:
- User's task spans multiple domains
- One skill mentions another as prerequisite
- Troubleshooting requires adjacent knowledge

---

## For Humans: Contributing Skills

### Before Creating a Skill

Ask: **Does Claude need this?**

- If it's standard library usage → NO
- If it's well-documented patterns → NO
- If you spent hours debugging it → YES
- If production broke because of it → YES

### Skill Quality Checklist

- [ ] Has `Use when` trigger in description
- [ ] Under 500 lines / 5000 tokens
- [ ] Has `scripts/verify.py` that exits 0/1
- [ ] Includes battle-tested gotchas (not theory)
- [ ] References are one level deep only

### The Domain Expert Test

> Would a senior engineer in this domain say "yes, this captures what we actually do"?

Common failures:
- Tutorial-level content (Claude knows this)
- Missing edge cases experts handle automatically
- Idealized patterns that break in production
- Wrong tool choices for the scale

---

## Skill Gaps (Known)

Areas where skills exist but may lack depth:

| Skill | Gap | Domain Expert Would Say |
|-------|-----|-------------------------|
| `containerizing-applications` | No multi-arch, no security scanning | "Where's Trivy? Distroless images?" |
| `deploying-cloud-k8s` | No GitOps, no observability | "No ArgoCD? No Prometheus?" |
| `working-with-spreadsheets` | No pivot tables, no data validation | "This is basic openpyxl" |

Areas with no skills yet:
- Database migrations at scale
- API versioning strategies
- Feature flags and gradual rollouts
- Incident response playbooks

---

## File Structure

```
.claude/skills/
├── SKILLS-INDEX.md          ← This file
├── [skill-name]/
│   ├── SKILL.md             ← Frontmatter + instructions
│   ├── scripts/
│   │   └── verify.py        ← Exit 0 (pass) or 1 (fail)
│   └── references/          ← Optional deep-dive docs
│       └── *.md
```

---

## Verification

Run all skills:
```bash
for skill in .claude/skills/*/; do
  python3 "$skill/scripts/verify.py" 2>/dev/null || echo "FAIL: $skill"
done
```
