# OpenClaw Knowledge Base — Nova's Reference

> Compiled from OpenClaw docs `/opt/homebrew/Cellar/node@24/24.16.0/lib/node_modules/openclaw/docs/`
> Use this to understand the platform, configure features, and avoid pitfalls.
> Last compiled: 2026-06-15

---

## 1. Models & Providers

### Key Concepts
- Model refs use `provider/model` notation (e.g. `openai/gpt-5.4`, `anthropic/claude-sonnet-4-6`). Split on **first** `/`.
- **Model routing**: specify `agents.defaults.model.primary` + `fallbacks[]` for automatic failover.
- **Thinking levels**: `/think off|minimal|low|medium|high|xhigh|adaptive|max`. Per-session, per-agent default, or global default.
- **Fast mode** (`/fast on|off`): maps to provider priority queues (OpenAI `service_tier=priority`, Anthropic `service_tier=auto`).
- Multiple auth profiles per provider (e.g. `anthropic:default`, `anthropic:work`). Use `/model <id>@<profileId>` to pin.

### Important Config Fields
```json5
{
  agents: {
    defaults: {
      model: {
        primary: "openai/gpt-5.4",
        fallbacks: ["openai/gpt-4.1", "anthropic/claude-sonnet-4-6"]
      },
      thinkingDefault: "high",  // or "off", "adaptive"
      fastModeDefault: "off",
      models: {
        "anthropic/claude-sonnet-4-6": { alias: "Sonnet" },
        "deepseek/deepseek-v4-flash": { alias: "Flash" }
      }
    }
  },
  models: {
    mode: "merge",  // merge (default) | replace
    providers: {
      "custom-ollama": {
        baseUrl: "http://localhost:11434/v1",
        api: "openai-completions",
        models: [
          { id: "qwen3:8b", name: "Qwen 3 8B", reasoning: false, input: ["text"], contextWindow: 32768 }
        ]
      }
    }
  }
}
```

### Practical Tips for Nova
| Need | Config |
|------|--------|
| DeepSeek V4 Flash as default | `model.primary: "deepseek/deepseek-v4-flash"` |
| Local Ollama fallback | Add `fallbacks: ["ollama/qwen3:8b"]` |
| Thinking for coding sessions | `/think:high` or set `thinkingDefault: "high"` |
| Auth via `.env` | Put keys in `~/.openclaw/.env` so daemon picks them up |
| Multiple API keys per provider | OpenClaw rotates rate-limited requests across `PROVIDER_API_KEYS` |

---

## 2. Tools System

### Key Concepts
- **Tool profiles** (base allowlists): `minimal` (session_status only), `coding` (fs+runtime+web+sessions+memory+media), `messaging` (message tools), `full` (no restriction).
- **Tool groups**: `group:runtime` (exec/process), `group:fs` (read/write/edit/apply_patch), `group:sessions`, `group:memory`, `group:web`, `group:ui`, `group:automation`, `group:messaging`, `group:media`, `group:agents`.
- Policy stack: base profile → `tools.allow/deny` → `tools.byProvider` → `tools.toolsBySender`.
- Deny wins across all layers. Case-insensitive, supports `*` wildcards.

### Important Config Fields
```json5
{
  tools: {
    profile: "coding",  // Nova's default: coding
    allow: ["web_search", "memory_search"],
    deny: ["cron", "gateway"],
    byProvider: {
      "ollama/qwen3:8b": { profile: "minimal" }  // restrict local models
    },
    toolsBySender: {
      "channel:discord:123456789": { alsoAllow: ["group:fs"] },
      "*": { deny: ["exec", "process"] }
    },
    exec: {
      backgroundMs: 10000,
      timeoutSec: 1800,
      applyPatch: { enabled: false }
    },
    sessions: {
      visibility: "tree"  // self | tree | agent | all
    },
    loopDetection: {
      enabled: false // off by default; enable for safety
    }
  }
}
```

### Practical Tips for Nova
- Onboard default sets `tools.profile: "coding"` — gives fs+runtime+web+sessions+memory+media tools.
- Restrict base model (DeepSeek V4 Flash) but allow full tools — `/think xhigh` works on DeepSeek V4 Flash.
- Use `tools.deny` to block `write`/`edit`/`apply_patch` for untrusted agents.
- `apply_patch` is separate from `write`; `deny: ["write"]` does NOT deny `apply_patch`.
- MCP servers expose tools under `bundle-mcp` plugin id; use sandbox tool allowlists when sandbox is on.

---

## 3. Sessions

### Key Concepts
- Sessions stored as JSONL at `~/.openclaw/agents/<agentId>/sessions/<SessionId>.jsonl`.
- Session ID is stable, chosen by OpenClaw. Legacy folders not read.
- **DM scope**: `session.dmScope` controls isolation — `"main"` (all DMs merged), `"per-channel-peer"` (isolated per sender+channel), `"per-peer"` (one session per sender across channels).
- **Steering**: `/queue steer` (default) delivers mid-run prompts after current tool calls finish. `/queue followup` waits. `/queue interrupt` aborts.
- **Compaction**: automatically summarizes long sessions. Memory flush runs before compaction to save context.

### Important Config Fields
```json5
{
  session: {
    dmScope: "per-channel-peer",  // isolate DMs per user
    // identityLinks to merge identities across channels
  }
}
```

### Practical Tips for Nova
- Nova's setup (single user, Feishu + webchat): `session.dmScope: "main"` is fine for continuity.
- If multiple users DM Nova on same channel, switch to `"per-channel-peer"`.
- Session history is available via `/context list` and `sessions_history` tool.
- `/new` or `/reset` starts a fresh session but does NOT clear stored works-in-progress unless explicitly deleted.

---

## 4. Automation

### Key Concepts
- **Cron jobs**: scheduled tasks with cron expressions. Run in isolated sessions. Support webhooks, `model` overrides, `thinking` levels. Max `maxConcurrentRuns: 8`.
- **Heartbeat**: periodic poll (every ~30min by default). Checks `HEARTBEAT.md` in workspace. Proactive: email, calendar, weather, memory maintenance.
- **Standing Orders**: persistent instructions via workspace files (AGENTS.md). Loaded every session.
- **TaskFlow**: durable multi-step detached jobs with owner context, state, waits, and child tasks.
- **Hooks**: HTTP endpoints (`POST /hooks/agent`, `POST /hooks/<name>`) for external triggers (Gmail, webhooks). Configurable routing per mapping.

### Important Config Fields
```json5
{
  cron: {
    enabled: true,
    maxConcurrentRuns: 8,
    sessionRetention: "24h"
  },
  hooks: {
    enabled: true,
    token: "your-secret-token",
    path: "/hooks",
    mappings: [
      {
        match: { path: "gmail" },
        action: "agent",
        agentId: "main",
        wakeMode: "now",
        messageTemplate: "{{messages[0].snippet}}"
      }
    ]
  }
}
```

### Practical Tips for Nova
- Use heartbeat for daily maintenance (memory curation, checking notifications).
- Avoid creating many cron jobs; batch periodic checks into `HEARTBEAT.md`.
- Use TaskFlow (`sessions_spawn` + `sessions_yield`) for multi-step research tasks.
- Cron jobs support model override: `model: "ollama/qwen3:8b"` to use cheaper model for routine checks.
- Heartbeat file lives at `<workspace>/HEARTBEAT.md`. Keep it short.

---

## 5. Channels

### Key Concepts
- Channels are messaging backends: Feishu, WhatsApp, Telegram, Discord, Slack, Signal, iMessage, IRC, Matrix, etc.
- **DM access control**: `dmPolicy: "pairing"` (default — code/approve), `"allowlist"`, `"open"`, `"disabled"`.
- **Group access**: `groupPolicy: "allowlist"` + `groups.*`, mention gating (`requireMention: true`).
- **Channel routing**: `bindings` map inbound messages to agents by `(channel, accountId, peer)`.
- **Multiple accounts**: one channel can have multiple account IDs (e.g. two WhatsApp numbers).
- **Access groups**: role-based permissions for slash commands.

### Important Config Fields
```json5
{
  channels: {
    whatsapp: {
      dmPolicy: "pairing",
      groups: { "*": { requireMention: true } },
      accounts: {
        personal: { /* authDir override */ }
      }
    },
    feishu: {
      /* Feishu-specific config */
    }
  },
  // Channel routing to agents
  bindings: [
    { agentId: "main", match: { channel: "feishu", accountId: "*" } },
    { agentId: "ops", match: { channel: "whatsapp", accountId: "biz" } }
  ]
}
```

### Practical Tips for Nova
- Nova's primary channel is **Feishu** — no Feishu-specific docs in the built-in set; check the plugin.
- For Feishu, use the bundled `feishu-doc`, `feishu-drive`, `feishu-perm`, `feishu-wiki` skills.
- DM pairing default is secure; pair users via `openclaw pairing list/approve <channel> <code>`.
- Context visibility setting: `contextVisibility: "allowlist"` filters quoted replies/context to allowlisted senders.

---

## 6. Multi-Agent

### Key Concepts
- Each **agent** is a fully isolated scope: own workspace, state dir (`agentDir`), session store, auth profiles.
- **Binding** maps channel + account + peer to an agent.
- **Default agent**: routed via `agents.list[].default` or first entry.
- **Per-agent sandbox**: each agent can have independent sandbox, tool allow/deny, and workspace.
- **Cross-agent memory**: `agents.list[].memorySearch.qmd.extraCollections` for QMD search across agents.
- **Agent-to-agent tool**: requires explicit `tools.agentToAgent.enabled: true` + `allow: [...]`.

### Important Config Fields
```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
      sandbox: { mode: "off" }
    },
    list: [
      {
        id: "nova",
        default: true,
        workspace: "~/.openclaw/workspace",
        identity: { name: "Nova", emoji: "🌟" },
        tools: {
          allow: ["group:fs", "group:runtime", "group:web", "group:sessions", "group:memory", "group:media"]
        }
      },
      {
        id: "research",
        workspace: "~/.openclaw/workspace-research",
        sandbox: { mode: "all", scope: "agent" },
        tools: { deny: ["write", "edit", "apply_patch", "exec"] }
      }
    ]
  },
  bindings: [
    { agentId: "nova", match: { channel: "feishu", accountId: "*" } }
  ]
}
```

### Practical Tips for Nova
- Nova currently runs a **single agent** (`id: "main"`). Multi-agent is optional.
- To add a research agent: `openclaw agents add research`, configure workspace and tools.
- Use `tools.agentToAgent` to let Nova spawn subagents.
- Per-agent sandbox config lives under `agents.list[].sandbox`.
- Cross-agent session search requires QMD backend + `extraCollections`.

---

## 7. Configuration

### Key Concepts
- Config file: `~/.openclaw/openclaw.json` (JSON5 — comments + trailing commas allowed).
- All fields optional; safe defaults used when omitted.
- Use `openclaw config schema lookup` for exact field-level docs.
- `openclaw doctor` validates config and warns about issues.
- **Env substitution**: `${VAR_NAME}` in any config string. Only uppercase. `$$` escapes to literal.
- **SecretRef**: `{ source: "env"|"file"|"exec", provider, id }` for credential refs.

### Important Config Fields Summary

| Path | Default | Notes |
|------|---------|-------|
| `agents.defaults.workspace` | `~/.openclaw/workspace` | Agent home |
| `agents.defaults.model.primary` | — | Main model ref |
| `gateway.port` | 18789 | Multiplexed WS+HTTP |
| `gateway.bind` | `"loopback"` | `loopback`, `lan`, `tailnet`, `custom` |
| `gateway.auth.mode` | `"token"` | `token`, `password`, `trusted-proxy`, `none` |
| `session.dmScope` | `"main"` | `main`, `per-channel-peer`, `per-peer` |
| `tools.profile` | `"coding"` (on local) | `minimal`, `coding`, `messaging`, `full` |
| `channels.<name>.dmPolicy` | `"pairing"` | `pairing`, `allowlist`, `open`, `disabled` |
| `logging.level` | `"info"` | `debug`, `info`, `warn`, `error` |
| `cron.enabled` | `true` | Global cron toggle |

### Practical Tips for Nova
- Use `openclaw doctor` after major config changes. Run `openclaw security audit` regularly.
- Config hot-reload: `gateway.reload.mode: "hybrid"` (default) tries in-process reload; falls back to restart.
- Put API keys in `~/.openclaw/.env` (auto-loaded) rather than inline in config.
- Workspace `.env` files are BLOCKED from overriding provider credentials and `OPENCLAW_*` env vars — put those in process env or `~/.openclaw/.env`.
- Use `openclaw config set models.providers.<id> '<json>' --strict-json --merge` for additive updates.

---

## 8. Canvas

### Key Concepts
- **Canvas** serves HTML/CSS/JS to connected node WebViews (Mac/iOS/Android).
- Files served from `plugins.entries.canvas.config.host.root` (default: `~/.openclaw/canvas`).
- URL shape: `http://<gateway-host>:<gateway.port>/__openclaw__/canvas/<file>.html`
- Also serves A2UI at `/__openclaw__/a2ui/`.
- Live reload injected automatically when enabled.
- Paired nodes receive node-scoped capability URLs (`pluginSurfaceUrls.canvas`) for auth-free access.

### Important Config Fields
```json5
{
  plugins: {
    entries: {
      canvas: {
        config: {
          host: {
            enabled: true,
            root: "~/.openclaw/workspace/canvas",
            liveReload: true
          }
        }
      }
    }
  }
}
```

### Canvas Actions (via `canvas` tool)
- `present` — show canvas, optional URL
- `hide` — hide canvas
- `navigate` — open new URL in canvas
- `eval` — run JS in current canvas
- `snapshot` — screenshot canvas

### Practical Tips for Nova
- Put canvas files under `<workspace>/canvas/` for version control.
- Start with `canvas/index.html` — auto-created if missing.
- For Star Office / dashboards: serve HTML with Canvas, share URL to paired nodes.
- Keep `gateway.bind: "loopback"` for local-only; use Tailnet for remote node access.
- Non-loopback canvas routes require gateway auth (same as other Gateway HTTP surfaces).

---

## 9. Memory

### Key Concepts
Three memory layers:
1. **`MEMORY.md`** — curated long-term, loaded on every DM session start (compact + durable).
2. **`memory/YYYY-MM-DD.md`** — daily notes (indexed for `memory_search`, not auto-injected).
3. **`DREAMS.md`** (optional) — Dream Diary for periodic review.

Memory backends: **Builtin** (SQLite, default), **QMD** (local sidecar with reranking), **Honcho** (AI-native multi-agent), **LanceDB** (plugin, OpenAI-compatible embeddings).

**Hybrid search**: vector + keyword. OpenAI embeddings by default; configurable to Gemini, Voyage, Mistral, Ollama, etc.

**Memory flush**: before compaction, auto-saves important context. Model override:
```json5
{
  agents: { defaults: { compaction: { memoryFlush: { model: "ollama/qwen3:8b" } } } }
}
```

**Dreaming** (opt-in): background consolidation pass. Collects short-term signals, scores candidates, promotes qualified items to `MEMORY.md`.

### Important Config Fields
```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "openai",  // overrides default embedding
        maxResults: 5,
        minScore: 0.5
      },
      compaction: {
        memoryFlush: { model: "deepseek/deepseek-v4-flash" }
      }
    }
  },
  memory: {
    backend: "builtin",  // builtin | qmd | lancedb
    qmd: { includeDefaultMemory: false }
  }
}
```

### Practical Tips for Nova
- **Write to memory proactively**: "Remember I prefer X" → Nova writes to `MEMORY.md`.
- Let Nova use `memory_search` + `memory_get` for retrieval (tools auto-available).
- **Important**: only load `MEMORY.md` in main (private) sessions, not shared/group contexts.
- Daily files pile up; use heartbeat to curate: distill into `MEMORY.md`, prune outdated entries.
- Memory flush before compaction prevents context loss during long sessions.
- Use `agents.defaults.bootstrapMaxChars: 20000` to control injected file size.

---

## 10. Security

### Key Concepts
- **Personal assistant trust model**: one trusted operator per gateway. NOT hostile multi-tenant.
- **Gateway auth**: `token` (recommended), `password`, `trusted-proxy`, `none` (dangerous).
- **DM access**: pairing (code+approve) is default and recommended.
- **Prompt injection**: not solved by system prompts. Hard defense via tool policy + sandbox + allowlists.
- **Tool blast radius**: most important hardening lever. Control what tools are available per agent.
- **Node pairing**: Gateway-owned pairing for iOS/Android/macOS nodes. Approve requests via CLI.
- **Audit**: `openclaw security audit` (and `--deep`, `--fix`) runs regularly.

### Critical Config for Security
```json5
{
  // Minimal secure baseline
  gateway: {
    mode: "local",
    bind: "loopback",
    auth: { mode: "token", token: "your-long-random-token" }
  },
  session: { dmScope: "per-channel-peer" },
  tools: {
    profile: "messaging",
    deny: ["group:automation", "group:runtime", "group:fs"],
    exec: { security: "deny", ask: "always" }
  },
  channels: {
    whatsapp: { dmPolicy: "pairing", groups: { "*": { requireMention: true } } }
  }
}
```

### Security Checklist
1. **Gateway access**: bind loopback, require auth token. Never expose unauthenticated.
2. **DM policies**: pairing or strict allowlists. Avoid `"open"`.
3. **Group policies**: `requireMention: true` everywhere.
4. **Tool policy**: deny dangerous tools for shared agents (exec, write, cron, gateway).
5. **Sandbox**: enable `sandbox.mode: "all"` for agents touching untrusted content.
6. **Prompt injection defense**: sandbox + tool restrictions + strong model tier.
7. **File permissions**: `700` on `~/.openclaw`, `600` on config files.
8. **External content sanitization**: ON by default. Strips special-token literals from fetched content.
9. **Log redaction**: `logging.redactSensitive: "tools"` (default). Add custom `redactPatterns`.
10. **Run audits**: `openclaw security audit` after every config change.

### Practical Tips for Nova
- Nova runs on **Mac mini (loopback)** — `gateway.bind: "loopback"` + `gateway.auth.mode: "token"`.
- Feishu is a single-user channel; DM policy is naturally restricted.
- Use **Tailscale Serve** if remote access needed: `tailscale.mode: "serve"` keeps loopback bind + Tailscale handles auth.
- **Never** expose Gateway on LAN/Internet without auth.
- The `openclaw security audit` checks: DM policies, tool blast radius, network exposure, browser control, exec drift, permissions.
- Known high-risk tools: `exec`, `write`, `browser`, `cron`, `gateway`, `sessions_spawn`.
- Session transcripts on disk at `~/.openclaw/agents/main/sessions/*.jsonl` — lock down filesystem access.

---

## Quick Reference — Key CLI Commands

| Command | Purpose |
|---------|---------|
| `openclaw doctor` | Validate config, fix common issues |
| `openclaw security audit` (--deep, --fix) | Security audit |
| `openclaw models status` (--probe, --check) | Check model auth and availability |
| `openclaw models auth login --provider <id>` | Set up provider auth |
| `openclaw pairing list/approve <channel> <code>` | Manage DM pairing |
| `openclaw nodes pending/approve/reject/status` | Manage node pairing |
| `openclaw agents add/list` | Multi-agent management |
| `openclaw channels status --probe` | Check channel connectivity |
| `openclaw config get/set/patch` | Config operations |
| `openclaw gateway restart` | Restart gateway |
| `openclaw memory status/search/index` | Memory operations |
| `openclaw models auth order set/get` | Control auth profile selection |

---

## Nova's Current Setup Map

| Aspect | Setting | Notes |
|--------|---------|-------|
| Host | Mac mini (arm64, macOS) | Loopback-only, local-first |
| Model | `deepseek/deepseek-v4-flash` (primary) | Good reasoning, fast |
| Channel | Feishu (primary) | Plus webchat |
| Tools profile | `coding` (default) | fs+runtime+web+sessions+memory+media |
| Workspace | `~/.openclaw/workspace` | Git-tracked private repo |
| Memory backend | Builtin (SQLite) | Auto-search + daily notes |
| Agent count | Single (`main`) | Expandable via `agents.list` |
| Sandbox | Off | Enable for untrusted content |
| Security | Token auth + loopback bind | Run `security audit` regularly |

---

*Generated from OpenClaw docs for Nova's self-education. Update as platform evolves.*
