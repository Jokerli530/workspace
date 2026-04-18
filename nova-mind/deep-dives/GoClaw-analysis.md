# Deep Dive: GoClaw (OpenClaw Go 重写版)

**Stars**: 2,801 | **CC BY-NC 4.0** | **Next Level Builder 团队**

---

## 核心发现

### 1. 8-Stage Agent Pipeline

```
context → history → prompt → think → act → observe → memory → summarize
```

每个阶段都是可插拔的(pluggable)，always-on execution。这和 ECC 的 loop 架构类似，但 GoClaw 做了更明确的阶段划分。

**GoClaw Loop vs ECC Loop**:
- GoClaw: 8个明确阶段，pipeline 风格
- ECC: continuous loop，强调 hooks 和 skills
- OpenMOSS: Task → SubTask 调度风格

---

### 2. 3-Tier Memory Architecture

```
Working Memory (L0)
  - Conversation context
  - Current session
  ↓ progressive loading
Episodic Memory (L1)
  - Session summaries
  - Past interactions
  ↓
Semantic Memory (L2)
  - Knowledge graph
  - Long-term knowledge
```

**对 Nova 的意义**: Nova-Orbit 的三层记忆设计(Working/Episodic/Semantic)与 GoClaw 完全一致！

---

### 3. Self-Evolution 机制

关键文件：
- `agent/suggestion_engine.go` — 建议生成引擎
- `agent/suggestion_rules.go` — 建议规则
- `agent/evolution_guardrails.go` — 进化护栏
- `agent/systemprompt_self_evolve_test.go` — 自进化测试

```
Metrics → Suggestions → Guardrails → Auto-adapt
```

**护栏机制**: Evolution guardrails 防止 agent 过度自我修改，这是 Nova 需要的关键安全机制。

---

### 4. Knowledge Vault

- Document registry with [[wikilinks]]
- Hybrid search: FTS (Full-Text Search) + pgvector (vector)
- Filesystem sync
- 和 Obsidian/Roam 类似的 wikilink 语法

**对 Nova 的意义**: ByteRover 可以借鉴这个 hybrid search 策略。

---

### 5. 20+ LLM Providers

包括：
- Anthropic (原生 HTTP+SSE + prompt caching)
- OpenAI / OpenRouter / Groq / DeepSeek / Gemini / Mistral / xAI
- **MiniMax** ← Nova 用的！
- DashScope (阿里)
- Claude CLI / Codex / ACP

**Nova 已经在用 MiniMax**，GoClaw 也支持，这是兼容性保证。

---

### 6. 7 Messaging Channels

包括：
- Telegram / Discord / Slack
- Zalo OA / Zalo Personal
- **Feishu/Lark** ← Nova 在用的！
- WhatsApp

**对 Nova 的意义**: GoClaw 支持飞书，OpenClaw 也支持，说明飞书生态是成熟的。

---

### 7. Multi-Tenant 安全架构

**5-Layer Security**:
1. **Permission System** — RBAC (Role-Based Access Control)
2. **Rate Limiting** — per-user/per-agent
3. **Prompt Injection Detection** — 防止恶意输入
4. **SSRF Protection** — 防止服务器端请求伪造
5. **AES-256-GCM Encryption** — API keys 加密存储

**Multi-Tenant Isolation**:
- Per-user workspaces
- Per-user context files
- Encrypted API keys
- Isolated sessions

---

### 8. Desktop Edition (GoClaw Lite)

| Feature | Lite | Standard |
|---------|------|----------|
| Agents | Max 5 | Unlimited |
| Database | SQLite | PostgreSQL |
| Semantic Memory | FTS5 | pgvector |
| Channels | None | 7 |
| Multi-tenant | No | Yes |

Lite 版使用 Wails v2 + React 构建，~30 MB。

---

## 产品定位对比

| | GoClaw | OpenClaw |
|--|--------|----------|
| Language | Go | TypeScript/Node.js |
| Binary | ~25 MB single binary | npm package |
| Database | PostgreSQL | In-memory/file |
| Multi-tenant | Yes | No (single-user) |
| Channels | 7 | Multiple |
| Memory | 3-tier + Knowledge Graph | MEMORY.md files |
| Self-evolution | Yes (with guardrails) | No (manual) |
| License | CC BY-NC 4.0 | MIT |
| MiniMax support | Yes | Yes |

**关键差距**: OpenClaw 是 MIT，GoClaw 是 CC BY-NC 4.0（非商业可用）。这是两者最核心的区别。

---

## 对 Nova 的价值

### 直接可借鉴

1. **Evolution Guardrails** — 自进化必须有护栏，否则危险
2. **3-Tier Memory 的 progressive loading** — L0/L1/L2 的渐进式加载
3. **Wikilink 语法** — `[[pagename]]` 知识链接
4. **Hybrid Search** — FTS + vector 混合搜索

### 差距分析

| GoClaw | Nova |
|--------|------|
| Go + PostgreSQL | Node.js + File-based |
| Multi-tenant | Single-user (飞书 channel) |
| Self-evolution (有护栏) | 无自进化 |
| 7 channels | 飞书 channel |
| Production-ready | 仍在发展 |

---

## 行动项

### 短期（本周）
- [ ] 研究 GoClaw 的 evolution_guardrails.go 实现
- [ ] 在 nova-mind 里设计 Nova 版本的 evolution guardrails
- [ ] ByteRover 的 hybrid search 能力评估

### 中期（本月）
- [ ] 实现 Nova 版本的 progressive memory loading
- [ ] Wikilink 格式支持（如果 ByteRover 支持）

### 不能做（License 限制）
- [ ] GoClaw 代码不能直接用（非商业授权）
- [ ] 但设计理念可以借鉴（概念层面）

---

## 关键文件

- Architecture images: `_statics/` (3-Tier Memory, 8-Stage Pipeline, Multi-Tenant)
- Agent loop: `internal/agent/loop*.go`
- Memory: `internal/memory/`
- Knowledge Graph: `internal/knowledgegraph/`

---

## 引用

- Repo: https://github.com/nextlevelbuilder/goclaw
- Team: Next Level Builder (Viet Tran @viettranx)
- License: CC BY-NC 4.0
- Docs: https://docs.goclaw.sh
