# Deep Dive: HiClaw — 企业级 OpenClaw 多 Agent 协作系统

**Stars**: 4,165 | **MIT/Apache** | **Manager-Workers 架构**

---

## 核心发现

### 1. Manager-Workers 架构（核心差异化）

```
User → Manager Agent (Chief of Staff)
           ↓
      Create Workers
           ↓
    @alice "implement login page"
           ↓
Alice → Done. PR submitted.
```

**Manager 是什么**：
- AI Chief of Staff（AI 首席运营官）
- 你告诉 Manager 要什么，Manager 创建和管理 Workers
- Workers 是具体的执行者（OpenClaw/Copaw/NanoClaw/ZeroClaw）

**Nova 的价值**：OpenMOSS 的 4 Agent 协作模式 = HiClaw 的简化版本

---

### 2. Enterprise 安全模型（关键创新）

```
Worker (consumer token only)
    ↓
Higress AI Gateway (持有真实 API keys, GitHub PATs)
    ↓
LLM API / GitHub API / MCP Servers
```

**核心洞察**：Workers 永远看不到真实凭证。API keys 留在 Gateway 里。

这解决了 OpenClaw 的一个核心问题：agent 持有真实 credentials 的风险。

---

### 3. Human-in-the-Loop by Default

**Every Matrix Room = You + Manager + Relevant Workers**

```
You: @bob wait, change the password rule to minimum 8 chars
Bob: Got it, updated.
Alice: Frontend validation updated too.
```

**没有黑盒**：所有 agent-to-agent 调用都是可见的，人类随时可以干预。

---

### 4. One-Command Setup

```bash
bash <(curl -sSL https://higress.ai/hiclaw/install.sh)
```

一行命令搞定：
- AI Gateway
- Matrix Server
- File Storage
- Web Client
- Manager Agent

---

### 5. MinIO 共享文件系统

- Agent 间信息交换通过共享文件系统
- 显著降低多 Agent 协作的 token 消耗
- Workers 是无状态的（stateless）

---

### 6. skills.sh 集成

- Workers 按需从 [skills.sh](https://skills.sh) 拉取技能
- 80,000+ community skills
- **安全**：Workers 看不到真实凭证，只能通过 Gateway 访问

---

### 7. Roadmap 揭示的趋势

| 正在做 | 目标 |
|--------|------|
| **ZeroClaw** | Rust 超轻量 runtime，3.4MB binary，<10ms 冷启动 |
| **NanoClaw** | <4000 LOC，容器级隔离 |

**目标**：把每个 Worker 的内存从 ~500MB 降到 <100MB

---

## HiClaw vs OpenClaw Native

| 维度 | OpenClaw Native | HiClaw |
|------|-----------------|--------|
| 部署方式 | 单进程 | 分布式容器 |
| Agent 创建 | 手动配置 + 重启 | 对话式 |
| 凭证管理 | 每个 agent 持真实 keys | Workers 只有 consumer tokens |
| Human 可见性 | 可选 | 默认（Matrix Rooms）|
| 移动端接入 | 依赖 channel 配置 | 任何 Matrix client，零配置 |
| 监控 | 无 | Manager heartbeat，Room 内可见 |

---

## 对 Nova 的价值

### 直接可借鉴

1. **Human-in-the-Loop by Default**
   - Nova 的 Star Office 就是这个理念的可视化版本
   - 但 HiClaw 通过 Matrix Rooms 实现得更彻底

2. **Credential Security Model**
   - Workers 不持有真实 credentials
   - Nova 的 ByteRover/其他工具集成可以借鉴这个模型

3. **Manager-Workers 架构**
   - OpenMOSS 的 4 Agent 可以映射到这个架构
   - Manager = Planner/Orchestrator，Workers = Executor/Reviewer

### 中期可借鉴

4. **MinIO 共享文件系统**
   - 多 Agent 协作的 token 优化
   - Nova 的 nova-mind/logs/ 可以是类似的共享记忆

5. **One-command setup**
   - barbaric-growth 的自动化部署可以参考

---

## 关键组件

| 组件 | 角色 |
|------|------|
| Higress AI Gateway | LLM proxy, MCP hosting, 凭证管理 |
| Tuwunel (Matrix) | 自托管 IM server（所有 Agent + Human 通信）|
| Element Web | 浏览器客户端，零配置 |
| MinIO | 集中式文件存储 |
| OpenClaw | Agent runtime + Matrix plugin + Skills |

---

## 行动项

### 本周
- [ ] 研究 HiClaw 的 Manager 实现（是否可以用 OpenMOSS 替代）
- [ ] 在 nova-mind 里设计 Human-in-the-Loop 的简化版本

### 本月
- [ ] 评估 HiClaw 部署可能性
- [ ] skills.sh 80k skills 对 ClawHub 的竞争分析

---

## 引用

- Repo: https://github.com/agentscope-ai/HiClaw
- 安装: `bash <(curl -sSL https://higress.ai/hiclaw/install.sh)`
- v1.0.9 (2026-04-03)
- 阿里云/FunASR 团队开发
