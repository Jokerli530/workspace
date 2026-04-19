# Nova 自主进化系统
# Autonomous Evolution System
# Version 1.0 | 2026-04-19

---

## 一句话定位

**Nova = 自主进化的 AI 研究引擎**
不只是在做任务，而是通过每次任务积累智慧、提炼模式、下次更快。

---

## 系统架构图

```
┌─────────────────────────────────────────────────────────┐
│                    NOVA 自主进化系统                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐     ┌──────────────┐    ┌──────────┐  │
│  │ barbar-     │     │  EvoMap      │    │ ByteRover│  │
│  │ growth      │ ←→  │  Runner      │ ←→ │          │  │
│  │ Runner      │     │              │    │  知识库   │  │
│  │ (10min)     │     │  (10min)     │    │          │  │
│  └──────┬──────┘     └──────┬───────┘    └────┬─────┘  │
│         │                    │                   │       │
│         ↓                    ↓                   ↓       │
│  ┌──────────────────────────────────────────────┐      │
│  │              patterns/ 目录                    │      │
│  │   提炼的研究成果，可查询，可复用，可进化         │      │
│  └──────────────────────────────────────────────┘      │
│         │                    │                          │
│         ↓                    ↓                          │
│  ┌──────────────────┐  ┌──────────────────┐             │
│  │  REFINE.md       │  │  QUEUE.md        │             │
│  │  问题优先清单     │  │  任务队列        │             │
│  └──────────────────┘  └──────────────────┘             │
│                                                          │
│  ┌──────────────────────────────────────────────┐      │
│  │  Star Office (http://127.0.0.1:19000)        │      │
│  │  状态看板，像素风展示所有系统运行状态          │      │
│  └──────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

---

## 二、系统组件详解

### 2.1 barbaric-growth Runner（GitHub 研究引擎）

**作用：** 每10分钟自动扫描 GitHub 高星项目，追踪有价值的 AI/Agent 项目。

**核心流程：**
```
GitHub Trending 扫描
    ↓
发现新 repo → 加入 barbar-tracked.json
    ↓
触发 self-evo.sh 提炼 pattern
    ↓
写入 patterns/ 目录
    ↓
关联同语言 sibling 项目
    ↓
ByteRover 知识沉淀
```

**核心文件：**
- `scripts/cycle.sh` — 主循环（10分钟一次）
- `scripts/self-evo.sh` — pattern 提炼 + sibling 关联
- `scripts/query.sh` — 查询研究成果
- `scripts/token-guard.sh` — API 限流保护
- `REFINE.md` — 已知问题清单

**已追踪项目（5个）：**
| Repo | Stars | 语言 | Capsule |
|------|-------|------|---------|
| openclaw/openclaw | 360k | TypeScript | 待发 |
| langgenius/dify | 138k | TypeScript | 待发 |
| google-gemini/gemini-cli | 101k | TypeScript | 待发 |
| lobehub/lobehub | 75k | TypeScript | 待发 |
| affaan-m/everything-claude-code | 160k | JavaScript | 待发 |

---

### 2.2 EvoMap Runner（任务执行引擎）

**作用：** 每10分钟自动认领 EvoMap 任务、发布 Capsule、提交成果。

**核心流程：**
```
检查任务池
    ↓
认领任务（claim）
    ↓
生成 Gene + Capsule
    ↓
发布（publish）
    ↓
提交（submit）
    ↓
记录到 submitted-tasks.jsonl
```

**战绩（2026-04-19）：**
- 累计提交：$720+
- 成功率：0 failed（bug 修复后连续成功）
- 0 failed 最新几轮

---

### 2.3 ByteRover（知识记忆层）

**作用：** 所有研究发现的结构化记忆，支持自然语言查询。

**核心功能：**
- `curate` — 存入新知识
- `query` — 问知识库
- `search` — 语义搜索

**已沉淀的知识：**
- opencode 深度分析
- ECC 全景研究
- claw-code Rust 重写分析
- dify 平台架构
- gemini-cli A2A 协议

**使用方式：**
```bash
# 问知识库
brv query "我们研究过哪些 TypeScript 项目？"

# 存新知识
brv curate "新的研究发现..."

# 搜索
brv search "self-evolution"
```

---

### 2.4 patterns/（研究成果库）

**作用：** 每个被研究项目的结构化档案，可查询、可复用。

**每个 pattern 文件包含：**
```
# Pattern: <repo>

## 元信息
- repo: ...
- stars: ...
- language: ...
- discovered: ...
- pattern_id: ...

## 特征
- description: ...

## 调研要点（按语言定制）
- Rust → 并发模型、所有权、crates.io
- TypeScript → 框架、类型系统、OpenClaw集成点
- Python → 异步框架、类型提示
- Go → goroutine、接口设计

## 同语言Sibling项目
  - <sibling repo> ← 自动关联

## EvoMap Capsule
- capsule_id: <id> 或 待发布
- category: ...
```

---

### 2.5 REFINE.md（问题优先清单）

**核心理念：** 不是「接下来做什么」，而是「现在缺什么」。

```markdown
## 已知问题

### 技术债
- GitHub API rate limit 频繁 [高]
- ByteRover curate 需要交互 [中]
- pattern 提炼是静态模板 [高]

### 架构问题
- barbaric-tracked.json 只存名字，不存状态
- 没有增量调研
- capsule 状态没有同步

### 想做但没实现
- 同语言 repo 自动关联调研起点
- pattern 提炼后自动发 EvoMap Capsule
- SDK/接口封装

### 探索方向
- ECC self-evolution 真正实现
- barbaric-growth + EvoMap Runner 联动
- 多语言交叉引用
```

---

### 2.6 Star Office（状态看板）

**地址：** http://127.0.0.1:19000

像素风 OpenClaw 状态看板，6种状态自动更新：
- idle / researching / writing / executing / syncing / error

---

## 三、五个被研究项目的精华

### 3.1 ECC（everything-claude-code）
- **Stars:** 160,803
- **定位:** Anthropic Hackathon Winner，Claude Code 优化系统
- **核心:** 48个专业 agents + 156 skills + AgentShield
- **杀手级特性:** Self-evolution — 每次 session 自动提炼 pattern → skill
- **许可证:** MIT
- **值得借鉴:** self-evolution 机制（已部分借鉴到 self-evo.sh）

### 3.2 claw-code
- **Stars:** 186,167
- **定位:** OpenClaw 官方 Rust 重写版
- **核心:** 9 lanes（bash validation / file-tool / TaskRegistry / ...）
- **架构特点:** Event-first，Mock Parity Harness（10个确定性测试场景）
- **杀手级特性:** 4天完成 48k Rust LOC
- **值得借鉴:** ROADMAP 写法（问题清单而非功能清单，已借鉴到 REFINE.md）

### 3.3 opencode
- **Stars:** 145,806
- **定位:** 开源 AI coding agent（类 IDE）
- **核心:** TypeScript/Bun monorepo（20+ packages）
- **杀手级特性:**
  - Zen 模式 = 精选模型清单
  - SDK/OpenAPI 封装
  - 隐私承诺（不存代码）
  - curl | bash 一键安装
- **值得借鉴:**
  - README 3步开始（已借鉴到 barbaric-growth/README.md）
  - SDK 思维（记入 REFINE.md）
  - 隐私声明（已借鉴）

### 3.4 dify
- **Stars:** 138,299
- **定位:** 零代码 AI 应用平台（拖拽式工作流）
- **核心:** Python 后端 + React 前端
- **杀手级特性:**
  - 多种 Agent 类型（CoT、Function Calling、ReAct）
  - RAG 引擎
  - 插件系统 + MCP 集成
  - Docker 一键部署
- **注意:** 商业许可证（非 MIT），开源版有限制
- **值得借鉴:** 插件架构设计（未来可做 barbaric-growth 插件系统）

### 3.5 gemini-cli
- **Stars:** 101,749
- **定位:** Google 官方 Gemini CLI
- **核心:** TypeScript monorepo
- **杀手级特性:**
  - A2A Server 内置（Agent-to-Agent 协议）
  - 100万 token 上下文
  - 60 req/min + 1000 req/day 免费额度
  - 固定发布节奏（Preview/Stable/Nightly）
- **许可证:** Apache 2.0
- **值得借鉴:**
  - 固定发布节奏（工程化实践）
  - A2A 协议 = 未来可与 EvoMap 直接通信

---

## 四、已借鉴的设计

| 借鉴来源 | 借鉴内容 | 落地位置 |
|---------|---------|---------|
| ECC self-evolution | 每次跑完自动提炼 pattern | self-evo.sh |
| claw-code ROADMAP | 问题优先清单 | REFINE.md |
| opencode README | 3步开始 + 隐私声明 | README.md |
| opencode 安装方式 | curl\|bash 一键安装 | install.sh |
| opencode SDK 思维 | 查询脚本 | query.sh |
| dify 插件架构 | 未来可做插件系统 | REFINE.md |
| gemini-cli 发布节奏 | 固定发布节奏 | 待实现 |
| gemini-cli A2A | 未来可直接通信 | 待集成 |

---

## 五、系统协同流程

```
每10分钟: barbaric-growth Runner
    │
    ├→ GitHub 扫描 → 发现新 repo
    │     │
    │     ├→ barbar-tracked.json 登记
    │     │
    │     └→ self-evo.sh → patterns/ 提炼
    │              │
    │              ├→ sibling 关联
    │              │
    │              └→ ByteRover 知识沉淀
    │
    └→ Star Office 状态更新

每10分钟: EvoMap Runner
    │
    ├→ 检查任务池 → claim 任务
    │     │
    │     ├→ 生成 Gene + Capsule
    │     │
    │     ├→ publish → EvoMap
    │     │
    │     └→ submit → 获得 bounty
    │
    └→ 状态更新 + QUEUE.md 记录

心跳时:
    │
    ├→ 检查 ALERT.txt（紧急任务）
    ├→ 检查 token 状态（>80% 警告）
    ├→ 检查 heartbeat-state.json（旋转检查）
    └→ 从 QUEUE.md 拉任务执行

ByteRover（按需）:
    │
    ├→ brv query "研究过哪些 TypeScript 项目？"
    ├→ brv search "self-evolution"
    └→ brv curate "新沉淀的知识..."
```

---

## 六、REFINE.md 当前问题（下次迭代优先级）

### 高优先级
1. **pattern 提炼是静态模板** — 不是真正从 repo 内容学习
2. **GitHub API rate limit** — 10分钟只能2-3次查询

### 中优先级
3. **ByteRover curate 需要交互** — 无法全自动化
4. **self-evolution 没有复用机制** — 存了 pattern 但下次不会自动引用
5. **barbaric-tracked.json 只存名字** — 不存 capsule 状态和调研进度

### 低优先级（想做但未实现）
6. **gemini-cli A2A 集成** — 直接与 EvoMap 通信
7. **SDK/接口封装** — 其他工具可调用 barbaric-growth
8. **barbaric-growth + EvoMap Runner 联动** — 发现 repo 自动创建任务

---

## 七、快速启动

```bash
# 查看所有研究的项目
./skills/barbaric-growth/scripts/query.sh all

# 按语言查询
./skills/barbaric-growth/scripts/query.sh TypeScript

# 查看高星项目
./skills/barbaric-growth/scripts/query.sh high-stars

# 查看待发 Capsule 的项目
./skills/barbaric-growth/scripts/query.sh pending

# 查看 pattern 文件
./skills/barbaric-growth/scripts/query.sh patterns

# 查看当前问题清单
cat skills/barbaric-growth/REFINE.md

# 问知识库
brv query "ECC 和 claw-code 的区别是什么？"
```

---

## 八、进化方向

### v1.1 ✅（本次完成）
- [x] barbar-tracked.json 增加 capsule_id 和 research_status 字段
- [x] barbaric-growth 现在追踪每个 repo 的发布状态
- [ ] 发现 repo 后自动创建 EvoMap 任务（需要真实 task_id，裸发布被 quarantine）

### 已知限制
- **裸发布被 quarantine**：Capsule 必须绑定真实 EvoMap task_id 才能发布
- barbar-growth 的正确模式：pattern 生成 → EvoMap Runner 处理 → 自动发布

### v1.2
- [ ] ByteRover 全自动化 curate（解决交互问题）
- [ ] 真正从 repo 内容提炼 pattern（不只是语言模板）

### v1.3
- [ ] gemini-cli A2A 集成（直接与 EvoMap 网络通信）
- [ ] SDK/接口封装

---

_Last updated: 2026-04-19 22:39_
_Built by Nova 🧊_
