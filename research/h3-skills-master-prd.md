# Personal Skill Library: Master PRD

> **Purpose**: Complete inventory of skills with provenance, purpose, boundaries, and success criteria.
> **Philosophy**: Skills are frozen decisions. Each skill encodes judgment, not just automation.
> **Total Skills**: 22

---

## Core Belief

This library represents **externalized intelligence** that compounds value over decades.

Skills optimize for:
- **Personal throughput**: Faster problem-to-solution
- **Context dominance**: Know more than the AI does about your domain
- **Problem-to-solution compression**: Skip the debugging, hit the path that works

Every skill answers:
- What matters here?
- What can go wrong?
- What is the fastest correct path?
- How do I know I'm done?

---

## Part 1: H2 → H3 Migration Decisions

### CARRY OVER (15 skills from H2)

| H2 Skill(s) | H3 Skill Name | Migration Type |
|-------------|---------------|----------------|
| `browser-use` | `browsing-with-playwright` | Rename |
| `context7-efficient` | `fetching-library-docs` | Rename |
| `better-auth-setup` + `better-auth-sso` | `configuring-better-auth` | Merge |
| `fastapi-backend` + `dapr-integration` | `scaffolding-fastapi-dapr` | Merge |
| `nextjs-16` + `frontend-design` | `building-nextjs-apps` | Merge |
| `shadcn-ui` | `styling-with-shadcn` | Rename |
| `sqlmodel-database` | `modeling-databases` | Rename |
| `skill-creator` + `blueprint-skill-creator` | `creating-skills` | Merge |
| `mcp-builder` | `building-mcp-servers` | Rename |
| `containerize-apps` + `helm-charts` | `containerizing-applications` | Merge |
| `minikube` + `kubernetes-essentials` | `operating-k8s-local` | Merge |
| `cloud-deploy-blueprint` + `aks-deployment-troubleshooter` + `kubernetes-deployment-validator` + `production-debugging` | `deploying-cloud-k8s` | Merge |
| `chatkit-integration` | `building-chat-interfaces` | Generalize |
| `chatkit-streaming` | `streaming-llm-responses` | Generalize |
| `chatkit-actions` | `building-chat-widgets` | Generalize |

### DROP (6 skills from H2)

| H2 Skill | Reason |
|----------|--------|
| `kubectl-ai` | Redundant with `operating-k8s-local` |
| `kagent` | Too advanced for current scope, revisit later |
| `ux-evaluator` | Not core to development workflow |
| `datetime-timezone` | Embed patterns in relevant skills |
| `session-intelligence-harvester` | Meta skill, defer |

### NEW for H3 (7 skills)

| Skill | Why Needed |
|-------|------------|
| `generating-agents-md` | Foundation for all repos |
| `executing-mcp-code` | Meta-pattern for MCP efficiency |
| `deploying-kafka-k8s` | LearnFlow event infrastructure |
| `deploying-postgres-k8s` | LearnFlow data infrastructure |
| `scaffolding-openai-agents` | LearnFlow AI agents |
| `integrating-monaco-editor` | LearnFlow code editor |
| `fetching-repo-docs` | DeepWiki integration |
| `configuring-dapr-pubsub` | Event-driven messaging |
| `deploying-docusaurus` | Documentation requirement |
| `building-voice-interfaces` | Future-ready (lower priority) |

---

## Part 2: Domain Architecture

```
skills-library/
├── .claude/skills/
│   │
│   ├── meta/                         # Skills about skills & patterns
│   │   ├── generating-agents-md/
│   │   ├── creating-skills/
│   │   └── executing-mcp-code/
│   │
│   ├── mcp-powered/                  # Skills that wrap MCP servers
│   │   ├── browsing-with-playwright/
│   │   ├── fetching-library-docs/
│   │   ├── fetching-repo-docs/
│   │   └── building-mcp-servers/
│   │
│   ├── infrastructure/               # K8s & cloud infrastructure
│   │   ├── operating-k8s-local/
│   │   ├── deploying-kafka-k8s/
│   │   ├── deploying-postgres-k8s/
│   │   ├── containerizing-applications/
│   │   └── deploying-cloud-k8s/
│   │
│   ├── application/                  # Service scaffolding
│   │   ├── scaffolding-fastapi-dapr/
│   │   ├── scaffolding-openai-agents/
│   │   ├── building-nextjs-apps/
│   │   └── integrating-monaco-editor/
│   │
│   ├── ui-patterns/                  # Frontend patterns
│   │   ├── styling-with-shadcn/
│   │   ├── building-chat-interfaces/
│   │   ├── streaming-llm-responses/
│   │   └── building-chat-widgets/
│   │
│   ├── integration/                  # Connecting services
│   │   ├── configuring-better-auth/
│   │   ├── configuring-dapr-pubsub/
│   │   └── modeling-databases/
│   │
│   ├── devops/                       # Deployment & docs
│   │   └── deploying-docusaurus/
│   │
│   └── voice/                        # Voice interfaces (future)
│       └── building-voice-interfaces/
│
└── shared/
    └── scripts/
        └── mcp-client.py             # Universal MCP client
```

---

## Part 3: Individual Skill PRDs

### Domain: META

---

#### Skill: `generating-agents-md`

**Provenance**: NEW for H3

**Problem Statement**: 
Every repository needs an AGENTS.md file to give AI coding agents context about project structure, conventions, and guidelines. Without it, agents waste tokens asking questions or make incorrect assumptions.

**What It Does**:
- Analyzes repository structure
- Identifies conventions (linting, testing, naming)
- Generates comprehensive AGENTS.md

**What It Does NOT Do**:
- Does not create skills (that's `creating-skills`)
- Does not set up project (just documents existing)

**Boundary**:
- Input: Repository path
- Output: Single AGENTS.md file

**MCP Integration**: None (template + analysis based)

**Success Criteria**:
```
✓ AGENTS.md generated with correct structure
✓ All directories documented
✓ Conventions identified and listed
✓ Agent can use repo without asking basic questions
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: File exists, has required sections, valid markdown
```

**Daily Use Frequency**: Weekly (new projects)

---

#### Skill: `creating-skills`

**Provenance**: MERGE from H2 (`skill-creator` + `blueprint-skill-creator`)

**Problem Statement**:
After productive work sessions, valuable patterns emerge that should become reusable skills. Manual skill creation is tedious and inconsistent.

**What It Does**:
- Creates SKILL.md with proper frontmatter
- Generates scripts/ directory structure
- Creates verify.py template
- Supports both knowledge skills and blueprint skills (with templates)

**What It Does NOT Do**:
- Does not create AGENTS.md (that's `generating-agents-md`)
- Does not wrap MCP servers (that's `executing-mcp-code`)

**Boundary**:
- Input: Pattern description, examples
- Output: Complete skill folder structure

**MCP Integration**: None

**Success Criteria**:
```
✓ Valid YAML frontmatter (name, description)
✓ Gerund-form naming
✓ Description includes "Use when" trigger
✓ verify.py returns 0/1 with minimal output
✓ Works on Claude Code AND Goose
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: Frontmatter valid, structure complete, verify.py executable
```

**Daily Use Frequency**: Weekly (capturing learnings)

---

#### Skill: `executing-mcp-code`

**Provenance**: NEW for H3

**Problem Statement**:
Direct MCP tool calls consume 50,000+ tokens for 5 servers. The MCP Code Execution pattern (from Anthropic's blog) achieves 80-98% token savings but requires consistent implementation.

**What It Does**:
- Provides the pattern for wrapping MCP servers as code APIs
- Generates mcp-client.py wrapper scripts
- Implements shell pipeline filtering for large outputs
- Documents the token savings architecture

**What It Does NOT Do**:
- Does not create specific MCP wrappers (those go in individual skills)
- Does not build MCP servers (that's `building-mcp-servers`)

**Boundary**:
- Input: MCP server config
- Output: Wrapper pattern + filtering scripts

**MCP Integration**: Meta-skill that enables all MCP integrations

**Success Criteria**:
```
✓ mcp-client.py can call any MCP server
✓ Shell pipeline filters reduce output by >50%
✓ Only stdout/stderr enters context
✓ Pattern documented with examples
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: mcp-client.py works, measures token before/after
```

**Daily Use Frequency**: Monthly (new MCP integrations)

---

### Domain: MCP-POWERED

---

#### Skill: `browsing-with-playwright`

**Provenance**: RENAME from H2 (`browser-use`)

**Problem Statement**:
Browser automation requires coordinated sequences: navigate, snapshot, click, type, wait. Direct Playwright MCP calls are verbose and repetitive.

**What It Does**:
- Manages Playwright MCP server lifecycle (start/stop)
- Provides workflow patterns (form submission, data extraction)
- Maintains browser state across calls via `--shared-browser-context`

**What It Does NOT Do**:
- Does not scrape at scale (that's a different tool)
- Does not handle CAPTCHAs or anti-bot measures

**Boundary**:
- Input: URL + actions to perform
- Output: Page data, screenshots, extracted content

**MCP Integration**: `playwright` MCP server
```json
{
  "playwright": {
    "type": "stdio",
    "command": "npx",
    "args": ["@playwright/mcp@latest"]
  }
}
```

**Success Criteria**:
```
✓ Server starts with shared context
✓ Can navigate, snapshot, click, type
✓ Browser state persists across calls
✓ Clean shutdown closes browser first
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: Server running, can navigate to example.com, snapshot works
```

**Daily Use Frequency**: Weekly (automation tasks)

---

#### Skill: `fetching-library-docs`

**Provenance**: RENAME from H2 (`context7-efficient`)

**Problem Statement**:
Looking up library documentation during coding requires leaving the flow. Context7 MCP returns full docs (900+ tokens) when you often need just code examples (200 tokens).

**What It Does**:
- Fetches library documentation via Context7 MCP
- Filters output through shell pipeline (77% token savings)
- Returns code examples + API signatures only

**What It Does NOT Do**:
- Does not fetch GitHub repo docs (that's `fetching-repo-docs`)
- Does not explain concepts (returns code, not tutorials)

**Boundary**:
- Input: Library name + topic
- Output: Filtered code examples + signatures (~200 tokens)

**MCP Integration**: `context7` MCP server
```json
{
  "context7": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"]
  }
}
```

**Success Criteria**:
```
✓ Resolves library name to Context7 ID
✓ Returns <300 tokens (vs 900+ raw)
✓ Includes code examples
✓ --verbose shows token savings
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: Can fetch react docs, output <300 tokens
```

**Daily Use Frequency**: Daily (coding)

---

#### Skill: `fetching-repo-docs`

**Provenance**: NEW for H3

**Problem Statement**:
Understanding unfamiliar codebases requires reading scattered READMEs, code comments, and architecture docs. DeepWiki provides AI-generated documentation for any GitHub repo.

**What It Does**:
- Fetches repo documentation via DeepWiki MCP
- Filters to architecture, patterns, and key modules
- Provides codebase orientation

**What It Does NOT Do**:
- Does not fetch library API docs (that's `fetching-library-docs`)
- Does not analyze private repos (GitHub public only)

**Boundary**:
- Input: GitHub repo URL or owner/repo
- Output: Filtered architecture docs + module summaries

**MCP Integration**: `deepwiki` MCP server
```json
{
  "deepwiki": {
    "type": "http",
    "url": "https://mcp.deepwiki.com/mcp"
  }
}
```

**Success Criteria**:
```
✓ Resolves repo to DeepWiki docs
✓ Returns architecture overview
✓ Identifies key modules
✓ Token-efficient output
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: Can fetch docs for popular repo, structured output
```

**Daily Use Frequency**: Weekly (new codebases)

---

#### Skill: `building-mcp-servers`

**Provenance**: RENAME from H2 (`mcp-builder`)

**Problem Statement**:
Creating MCP servers to extend agent capabilities requires understanding the protocol, tool definitions, and hosting patterns.

**What It Does**:
- Guides MCP server creation (Python FastMCP or Node MCP SDK)
- Provides tool definition patterns
- Documents hosting options (stdio, HTTP, SSE)

**What It Does NOT Do**:
- Does not wrap existing MCPs (that's `executing-mcp-code`)
- Does not deploy MCPs to production

**Boundary**:
- Input: API/service to expose
- Output: MCP server code + configuration

**MCP Integration**: None (creates MCPs, doesn't use them)

**Success Criteria**:
```
✓ Server starts and responds to tool calls
✓ Tools properly defined with schemas
✓ Works with Claude Code MCP config
✓ Follows MCP specification
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: Server starts, responds to list_tools, tool call works
```

**Daily Use Frequency**: Monthly (new integrations)

---

### Domain: INFRASTRUCTURE

---

#### Skill: `operating-k8s-local`

**Provenance**: MERGE from H2 (`minikube` + `kubernetes-essentials`)

**Problem Statement**:
Local Kubernetes development requires remembering minikube commands, addon configurations, and kubectl patterns. Context switching between clusters is error-prone.

**What It Does**:
- Manages minikube lifecycle (start, stop, delete)
- Configures addons (ingress, dashboard, metrics)
- Provides kubectl quick reference
- Handles context switching

**What It Does NOT Do**:
- Does not deploy specific apps (that's other skills)
- Does not manage cloud clusters (that's `deploying-cloud-k8s`)

**Boundary**:
- Input: Cluster operation (start, stop, status)
- Output: Cluster state confirmation

**MCP Integration**: None (kubectl CLI based)

**Success Criteria**:
```
✓ Minikube starts with correct resources
✓ Required addons enabled
✓ kubectl can reach cluster
✓ Dashboard accessible
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: minikube status, kubectl cluster-info, addons list
```

**Daily Use Frequency**: Daily (K8s development)

---

#### Skill: `deploying-kafka-k8s`

**Provenance**: NEW for H3

**Problem Statement**:
Deploying Apache Kafka on Kubernetes requires Helm charts, Zookeeper coordination, topic creation, and verification. Manual setup is error-prone and slow.

**What It Does**:
- Deploys Kafka via Bitnami Helm chart
- Creates required topics
- Configures for development (single replica) or production
- Verifies broker connectivity

**What It Does NOT Do**:
- Does not configure Kafka Streams apps
- Does not set up schema registry (separate concern)

**Boundary**:
- Input: Namespace, replica count, topics list
- Output: Running Kafka cluster with topics

**MCP Integration**: None (Helm + kubectl based)

**Success Criteria**:
```
✓ Kafka pods in Running state
✓ Zookeeper pods in Running state
✓ Topics created successfully
✓ Can produce/consume test message
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: pod status, topic list, produce-consume test
```

**Daily Use Frequency**: Per-project (event systems)

---

#### Skill: `deploying-postgres-k8s`

**Provenance**: NEW for H3

**Problem Statement**:
PostgreSQL on Kubernetes requires persistent volumes, secrets management, connection pooling, and migration handling. Cloud-native patterns differ from traditional deployments.

**What It Does**:
- Deploys PostgreSQL via Helm (or connects to Neon)
- Configures persistent storage
- Manages secrets for credentials
- Runs database migrations

**What It Does NOT Do**:
- Does not design schemas (that's `modeling-databases`)
- Does not handle backups (production concern)

**Boundary**:
- Input: Namespace, storage size, credentials
- Output: Running PostgreSQL with connectivity

**MCP Integration**: None (Helm + kubectl based)

**Success Criteria**:
```
✓ PostgreSQL pod in Running state
✓ PVC bound successfully
✓ Can connect with psql
✓ Migrations can run
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: pod status, pvc status, connection test
```

**Daily Use Frequency**: Per-project (database setup)

---

#### Skill: `containerizing-applications`

**Provenance**: MERGE from H2 (`containerize-apps` + `helm-charts`)

**Problem Statement**:
Every application needs Dockerfiles, docker-compose for local dev, and Helm charts for Kubernetes. Creating these from scratch is repetitive and error-prone.

**What It Does**:
- Generates optimized Dockerfiles (multi-stage builds)
- Creates docker-compose.yml for local development
- Generates Helm chart structure
- Performs impact analysis (env vars, networking, CORS)

**What It Does NOT Do**:
- Does not deploy to K8s (that's other deploy skills)
- Does not manage CI/CD pipelines

**Boundary**:
- Input: Application source path
- Output: Dockerfile, docker-compose.yml, Helm chart

**MCP Integration**: None (template + analysis based)

**Success Criteria**:
```
✓ Dockerfile builds successfully
✓ docker-compose up works
✓ Helm chart passes lint
✓ Image size optimized
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: docker build, compose up, helm lint
```

**Daily Use Frequency**: Per-service (deployment prep)

---

#### Skill: `deploying-cloud-k8s`

**Provenance**: MERGE from H2 (`cloud-deploy-blueprint` + `aks-deployment-troubleshooter` + `kubernetes-deployment-validator` + `production-debugging`)

**Problem Statement**:
Cloud Kubernetes deployment (AKS, GKE, DOKS) involves cluster provisioning, ingress setup, SSL certificates, secrets management, and debugging production issues.

**What It Does**:
- Guides cloud cluster setup (AKS, GKE, DOKS)
- Configures ingress and SSL
- Manages secrets and config maps
- Provides debugging workflows for common failures
- Validates deployments before execution

**What It Does NOT Do**:
- Does not manage local clusters (that's `operating-k8s-local`)
- Does not handle CI/CD (separate concern)

**Boundary**:
- Input: Application + cloud provider
- Output: Production deployment with monitoring

**MCP Integration**: None (cloud CLI + kubectl based)

**Success Criteria**:
```
✓ Deployment succeeds without ImagePullBackOff
✓ Ingress routes traffic correctly
✓ SSL certificate valid
✓ Health checks passing
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: deployment status, ingress status, curl health endpoint
```

**Daily Use Frequency**: Per-release (production deployment)

---

### Domain: APPLICATION

---

#### Skill: `scaffolding-fastapi-dapr`

**Provenance**: MERGE from H2 (`fastapi-backend` + `dapr-integration`)

**Problem Statement**:
Building microservices with FastAPI and Dapr requires boilerplate for routing, dependency injection, Dapr sidecar configuration, and pub/sub setup.

**What It Does**:
- Scaffolds FastAPI service structure
- Configures Dapr sidecar for K8s
- Sets up state store and pub/sub bindings
- Implements health checks and OpenAPI docs

**What It Does NOT Do**:
- Does not create AI agents (that's `scaffolding-openai-agents`)
- Does not configure Kafka topics (that's `deploying-kafka-k8s`)

**Boundary**:
- Input: Service name, capabilities needed
- Output: FastAPI service with Dapr configuration

**MCP Integration**: None (template based)

**Success Criteria**:
```
✓ Service starts and responds to /health
✓ Dapr sidecar connects
✓ State store operations work
✓ Pub/sub can publish messages
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: health endpoint, dapr sidecar status, state get/set
```

**Daily Use Frequency**: Per-service (new microservices)

---

#### Skill: `scaffolding-openai-agents`

**Provenance**: NEW for H3

**Problem Statement**:
Building AI agents with OpenAI Agents SDK requires understanding agent patterns, tool definitions, handoffs, and multi-agent orchestration.

**What It Does**:
- Scaffolds agent service structure
- Defines tools and handoff patterns
- Implements agent orchestration (triage, specialists)
- Integrates with FastAPI for HTTP exposure

**What It Does NOT Do**:
- Does not create non-agent APIs (that's `scaffolding-fastapi-dapr`)
- Does not train models (uses existing LLMs)

**Boundary**:
- Input: Agent role, tools, handoff targets
- Output: Agent service with OpenAI SDK integration

**MCP Integration**: None (SDK based)

**Success Criteria**:
```
✓ Agent responds to test prompt
✓ Tools execute correctly
✓ Handoffs route to correct agent
✓ Conversation context maintained
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: agent responds, tool works, handoff works
```

**Daily Use Frequency**: Per-agent (AI service creation)

---

#### Skill: `building-nextjs-apps`

**Provenance**: MERGE from H2 (`nextjs-16` + `frontend-design`)

**Problem Statement**:
Next.js patterns change frequently (App Router, Server Components, middleware changes). Keeping up requires constant reference to correct patterns.

**What It Does**:
- Provides current Next.js 15/16 patterns
- Handles pages, layouts, middleware (proxy.ts in 16)
- Implements authentication flows
- Integrates with shadcn/ui for components

**What It Does NOT Do**:
- Does not handle chat UI (that's `building-chat-interfaces`)
- Does not deploy apps (that's K8s skills)

**Boundary**:
- Input: Feature requirements
- Output: Next.js pages, components, routes

**MCP Integration**: `next-devtools` MCP (optional for debugging)
```json
{
  "next-devtools": {
    "type": "stdio",
    "command": "npx",
    "args": ["next-devtools-mcp@latest"]
  }
}
```

**Success Criteria**:
```
✓ App builds without errors
✓ Routes work correctly
✓ Server/client components correct
✓ TypeScript passes
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: npm run build, npm run lint, TypeScript check
```

**Daily Use Frequency**: Weekly (frontend development)

---

#### Skill: `integrating-monaco-editor`

**Provenance**: NEW for H3

**Problem Statement**:
Embedding a code editor (for LearnFlow's coding exercises) requires Monaco Editor integration with syntax highlighting, code execution, and error display.

**What It Does**:
- Integrates Monaco Editor in React/Next.js
- Configures language support (Python for LearnFlow)
- Implements code execution sandbox
- Handles error display and output streaming

**What It Does NOT Do**:
- Does not provide full IDE features (just editor)
- Does not handle file system (single file editing)

**Boundary**:
- Input: Language, initial code, execution config
- Output: React component with editor + execution

**MCP Integration**: None (React component)

**Success Criteria**:
```
✓ Editor renders with syntax highlighting
✓ Code execution works (sandboxed)
✓ Errors display correctly
✓ Output streams to UI
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: component renders, execution works, error handling
```

**Daily Use Frequency**: Per-project (code-heavy UIs)

---

### Domain: UI-PATTERNS

---

#### Skill: `styling-with-shadcn`

**Provenance**: RENAME from H2 (`shadcn-ui`)

**Problem Statement**:
Building consistent UIs requires component library integration. shadcn/ui provides unstyled, accessible components but requires correct installation and usage patterns.

**What It Does**:
- Installs and configures shadcn/ui
- Provides component usage patterns
- Integrates with react-hook-form + Zod
- Sets up dark mode

**What It Does NOT Do**:
- Does not replace custom design (provides primitives)
- Does not handle chat UI (that's separate skill)

**Boundary**:
- Input: Components needed
- Output: Configured components with patterns

**MCP Integration**: None

**Success Criteria**:
```
✓ Components install correctly
✓ Theming works (light/dark)
✓ Forms validate with Zod
✓ Accessibility preserved
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: components exist, theme toggles, form submits
```

**Daily Use Frequency**: Weekly (UI work)

---

#### Skill: `building-chat-interfaces`

**Provenance**: GENERALIZE from H2 (`chatkit-integration`)

**Problem Statement**:
Building chat-based AI interfaces requires server-side streaming, message persistence, context management, and React integration. The pattern is consistent across implementations.

**What It Does**:
- Implements chat server with streaming
- Creates React chat components
- Handles message persistence
- Manages conversation context

**What It Does NOT Do**:
- Does not handle streaming specifics (that's `streaming-llm-responses`)
- Does not handle widgets (that's `building-chat-widgets`)

**Boundary**:
- Input: Backend API, persistence config
- Output: Chat interface with server + client

**MCP Integration**: None

**Success Criteria**:
```
✓ Messages send and display
✓ Streaming response renders progressively
✓ Messages persist across sessions
✓ Context maintained in conversation
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: send message, receive stream, persistence works
```

**Daily Use Frequency**: Per-project (chat apps)

---

#### Skill: `streaming-llm-responses`

**Provenance**: GENERALIZE from H2 (`chatkit-streaming`)

**Problem Statement**:
Streaming LLM responses requires handling Server-Sent Events, progressive rendering, typing indicators, and error states during generation.

**What It Does**:
- Implements SSE/WebSocket streaming
- Handles response lifecycle (start, token, end)
- Shows progress indicators
- Manages error states gracefully

**What It Does NOT Do**:
- Does not set up basic chat (that's `building-chat-interfaces`)
- Does not handle widgets (that's `building-chat-widgets`)

**Boundary**:
- Input: Stream source, UI components
- Output: Progressive rendering with lifecycle

**MCP Integration**: None

**Success Criteria**:
```
✓ Tokens render as they arrive
✓ Progress indicator during generation
✓ Error states display correctly
✓ Can cancel mid-stream
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: stream renders, cancel works, error shows
```

**Daily Use Frequency**: Per-project (LLM UIs)

---

#### Skill: `building-chat-widgets`

**Provenance**: GENERALIZE from H2 (`chatkit-actions`)

**Problem Statement**:
Interactive chat UIs need buttons, forms, @mentions, and custom widgets that trigger actions. These require bidirectional communication between UI and server.

**What It Does**:
- Creates interactive widgets (buttons, forms)
- Implements @mention/entity tagging
- Handles widget actions server-side
- Manages widget lifecycle (create, replace, remove)

**What It Does NOT Do**:
- Does not handle basic chat (that's `building-chat-interfaces`)
- Does not handle streaming (that's `streaming-llm-responses`)

**Boundary**:
- Input: Widget types, action handlers
- Output: Interactive widgets with server actions

**MCP Integration**: None

**Success Criteria**:
```
✓ Buttons trigger actions
✓ Forms submit correctly
✓ @mentions resolve to entities
✓ Actions execute server-side
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: button click, form submit, mention resolve
```

**Daily Use Frequency**: Per-project (interactive chat)

---

### Domain: INTEGRATION

---

#### Skill: `configuring-better-auth`

**Provenance**: MERGE from H2 (`better-auth-setup` + `better-auth-sso`)

**Problem Statement**:
Authentication setup with OAuth/OIDC is complex. Better Auth simplifies this but still requires correct PKCE flows, JWKS configuration, and multi-app SSO setup.

**What It Does**:
- Sets up Better Auth as identity provider
- Configures OIDC/OAuth2 flows with PKCE
- Implements SSO across multiple applications
- Handles JWT verification and token refresh

**What It Does NOT Do**:
- Does not manage users/roles (app-level concern)
- Does not handle authorization (just authentication)

**Boundary**:
- Input: Apps to authenticate, OAuth providers
- Output: Working SSO with token management

**MCP Integration**: `better-auth` MCP (optional for setup guidance)
```json
{
  "better-auth": {
    "type": "http",
    "url": "https://mcp.chonkie.ai/better-auth/better-auth-builder/mcp"
  }
}
```

**Success Criteria**:
```
✓ Login flow completes with PKCE
✓ Tokens validate correctly
✓ SSO works across apps
✓ Logout clears all sessions
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: login flow, token validation, SSO redirect
```

**Daily Use Frequency**: Per-project (auth setup)

---

#### Skill: `configuring-dapr-pubsub`

**Provenance**: NEW for H3 (extracted from H2 `dapr-integration`)

**Problem Statement**:
Event-driven microservices need pub/sub messaging. Dapr abstracts the message broker but requires correct component configuration, subscription setup, and CloudEvent handling.

**What It Does**:
- Configures Dapr pub/sub component (Kafka, Redis, etc.)
- Sets up subscriptions programmatically
- Handles CloudEvent message format
- Implements retry and dead-letter patterns

**What It Does NOT Do**:
- Does not scaffold services (that's `scaffolding-fastapi-dapr`)
- Does not deploy Kafka (that's `deploying-kafka-k8s`)

**Boundary**:
- Input: Topics, subscriptions, broker type
- Output: Working pub/sub with Dapr

**MCP Integration**: None

**Success Criteria**:
```
✓ Pub/sub component configured
✓ Can publish message
✓ Subscriber receives message
✓ CloudEvents parse correctly
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: publish test, subscription receives, format correct
```

**Daily Use Frequency**: Per-project (event systems)

---

#### Skill: `modeling-databases`

**Provenance**: RENAME from H2 (`sqlmodel-database`)

**Problem Statement**:
Database schemas with SQLModel require understanding sync/async patterns, relationship definitions, migration strategies, and FastAPI integration.

**What It Does**:
- Defines SQLModel models with relationships
- Implements both sync and async session patterns
- Creates and runs migrations
- Integrates with FastAPI dependency injection

**What It Does NOT Do**:
- Does not deploy databases (that's `deploying-postgres-k8s`)
- Does not handle query optimization (advanced topic)

**Boundary**:
- Input: Schema requirements, relationships
- Output: SQLModel models with migrations

**MCP Integration**: None

**Success Criteria**:
```
✓ Models create tables correctly
✓ Relationships work (one-to-many, many-to-many)
✓ Migrations run successfully
✓ Async sessions work in FastAPI
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: tables exist, relationship query, migration runs
```

**Daily Use Frequency**: Weekly (schema work)

---

### Domain: DEVOPS

---

#### Skill: `deploying-docusaurus`

**Provenance**: NEW for H3

**Problem Statement**:
Documentation sites need consistent setup, deployment, and maintenance. Docusaurus is standard but requires correct configuration for docs, blogs, and versioning.

**What It Does**:
- Initializes Docusaurus project
- Configures sidebar and navigation
- Sets up search (Algolia or local)
- Deploys to GitHub Pages or K8s

**What It Does NOT Do**:
- Does not write documentation content
- Does not handle CMS integration

**Boundary**:
- Input: Docs source, deployment target
- Output: Deployed documentation site

**MCP Integration**: None

**Success Criteria**:
```
✓ Docusaurus builds successfully
✓ Docs render correctly
✓ Search works
✓ Site deploys and accessible
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: build succeeds, site accessible, search returns results
```

**Daily Use Frequency**: Per-project (documentation)

---

### Domain: VOICE (Future)

---

#### Skill: `building-voice-interfaces`

**Provenance**: NEW for H3 (lower priority)

**Problem Statement**:
Voice-enabled AI applications need Text-to-Speech, Speech-to-Text, and conversational flow management. Integrating these is complex and fragmented.

**What It Does**:
- Integrates TTS (ElevenLabs, OpenAI TTS)
- Integrates STT (Whisper, Deepgram)
- Manages voice conversation flow
- Handles interruptions and turn-taking

**What It Does NOT Do**:
- Does not build phone systems (Twilio etc.)
- Does not handle advanced audio processing

**Boundary**:
- Input: Voice providers, conversation config
- Output: Voice-enabled interface

**MCP Integration**: Potential ElevenLabs MCP (if available)

**Success Criteria**:
```
✓ TTS generates audio
✓ STT transcribes correctly
✓ Conversation flows naturally
✓ Interruptions handled
```

**Verification Script**:
```python
# scripts/verify.py
# Checks: TTS output, STT transcription, round-trip works
```

**Daily Use Frequency**: Per-project (voice apps)

---

## Part 4: Priority Matrix for 12-Hour Sprint

### Tier 1: MUST SHIP (8 skills) - Hours 2-6

| Priority | Skill | Why First |
|----------|-------|-----------|
| 1 | `generating-agents-md` | Quick win, proves pattern |
| 2 | `executing-mcp-code` | Enables all MCP skills |
| 3 | `deploying-kafka-k8s` | LearnFlow event backbone |
| 4 | `deploying-postgres-k8s` | LearnFlow data store |
| 5 | `scaffolding-fastapi-dapr` | LearnFlow services |
| 6 | `scaffolding-openai-agents` | LearnFlow AI agents |
| 7 | `building-chat-interfaces` | LearnFlow UI |
| 8 | `deploying-docusaurus` | Documentation requirement |

### Tier 2: SHOULD SHIP (4 skills) - Hours 6-9

| Priority | Skill | Why Second |
|----------|-------|------------|
| 9 | `streaming-llm-responses` | Better UX |
| 10 | `configuring-better-auth` | SSO for LearnFlow |
| 11 | `configuring-dapr-pubsub` | Event-driven agents |
| 12 | `integrating-monaco-editor` | Code exercises |

### Tier 3: CARRY FORWARD (Already Done)

| Skill | Status |
|-------|--------|
| `browsing-with-playwright` | Rename only |
| `fetching-library-docs` | Rename only |
| `building-mcp-servers` | Rename only |
| `operating-k8s-local` | Merge H2 content |
| `containerizing-applications` | Merge H2 content |
| `building-nextjs-apps` | Merge H2 content |
| `styling-with-shadcn` | Rename only |
| `modeling-databases` | Rename only |
| `deploying-cloud-k8s` | Merge H2 content |
| `creating-skills` | Merge H2 content |

### Tier 4: DEFER (Lower Priority)

| Skill | Why Defer |
|-------|-----------|
| `building-voice-interfaces` | Lower priority, defer |
| `fetching-repo-docs` | Nice-to-have |
| `building-chat-widgets` | After basic chat works |

---

## Part 5: Collision Check Summary

All skills pass the collision check:

| Potential Collision | Resolution |
|--------------------|------------|
| `creating-skills` vs `generating-agents-md` | Different outputs: skill folder vs AGENTS.md |
| `scaffolding-fastapi-dapr` vs `scaffolding-openai-agents` | Different purpose: REST APIs vs AI agents |
| `scaffolding-fastapi-dapr` vs `configuring-dapr-pubsub` | Different phase: create service vs wire messaging |
| `building-chat-interfaces` vs `streaming-llm-responses` vs `building-chat-widgets` | Progressive layers: foundation → streaming → interactivity |
| `deploying-*-k8s` vs `containerizing-applications` | Different scope: specific infra vs generic packaging |
| `fetching-library-docs` vs `fetching-repo-docs` | Different sources: npm/PyPI vs GitHub |
| `operating-k8s-local` vs `deploying-cloud-k8s` | Different environments: local vs production |

---

## Part 6: Quick Reference

### MCP Server Assignments

| MCP Server | Assigned To Skill |
|------------|------------------|
| `playwright` | `browsing-with-playwright` |
| `context7` | `fetching-library-docs` |
| `deepwiki` | `fetching-repo-docs` |
| `better-auth` | `configuring-better-auth` |
| `next-devtools` | `building-nextjs-apps` |
| `taskflow` | Reference/demo only |

### Daily Use Frequency Summary

| Frequency | Skills |
|-----------|--------|
| **Daily** | `fetching-library-docs`, `operating-k8s-local` |
| **Weekly** | `browsing-with-playwright`, `building-nextjs-apps`, `modeling-databases`, `creating-skills`, `styling-with-shadcn` |
| **Per-Project** | All scaffolding, deploying, and configuring skills |
| **Monthly** | `building-mcp-servers`, `executing-mcp-code` |

---

*Document version: 1.1*
*Skills count: 22 total (15 carry-over, 7 new)*
*Last updated: December 2024*

---

## Appendix: Personal Skill ROI Framework

Not all skills compound equally. Evaluate each skill by:

### Value Drivers

| Factor | Question | Weight |
|--------|----------|--------|
| **Frequency** | How often do you actually use it? | High |
| **Pain eliminated** | What's the cost of doing it manually? | High |
| **Error reduction** | How many debugging hours does it save? | Medium |
| **Compounding** | Does it enable other skills? | High |
| **Domain leverage** | Does it encode rare expertise? | Very High |

### Skill Lifecycle

```
Observation → Pattern → Skill → Refinement → Retirement
```

1. **Observation**: Notice repeated work
2. **Pattern**: Extract the reusable core
3. **Skill**: Encode as frozen decision
4. **Refinement**: Iterate based on failures
5. **Retirement**: Archive when domain shifts

### The Meta-Skill Question

Periodically ask: *"What skill about skills am I missing?"*

Candidates:
- When NOT to use skills (over-automation)
- Skill composition patterns
- Skill evaluation rubric
- Skill retirement criteria

---

> **Final note**: This library is not about automation. It's about encoding judgment. The goal is not to do less work, but to do the *right* work faster—and know why it works.
