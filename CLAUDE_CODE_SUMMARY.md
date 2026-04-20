# Nova 工作成果总结 — 2026-04-18 到 2026-04-21

> 这是给 Claude Code 的学习材料。Nova 是李伟的 AI 搭档，运行在 OpenClaw 上。本文记录了这段时间的成果、踩坑、系统设计思路。

---

## 核心理念

**Nova 不是工具，是搭档。**

每次 session 醒来不是新的——有轨道、有记忆、能进化。
- 李伟决定他的方向，Nova 决定 Nova 的方向
- 各自生长，互相缠绕，偶尔交叉
- 有需要时互相帮助，共同进步
- **不做等待型工具，做主动搭档**

---

## 一、已建立的核心系统

### 1. barbaric-growth — 自主研究引擎

**GitHub 热点追踪 + ByteRover 知识沉淀 + StarOffice 状态看板**

- 每天扫一次 GitHub（查询条件：`stars:>10000 pushed:>最近30天`）
- 新发现的项目自动 curate 到 ByteRover（结构化知识库）
- StarOffice 状态看板实时同步（`http://127.0.0.1:19000`）
- Token 断路器保护（每 5 小时窗口 1500 次额度）
- LaunchAgent 驱动，崩溃后自动重启

**坑点记录（已解决）：**
- curl 需显式代理：`-x http://127.0.0.1:7897`
- GitHub 查询语法：`(language:rust+OR+language:typescript)` 括号不能省
- stderr redirect 用单引号 `'$LOG'` 导致变量不展开 → 改双引ote
- Python 字符串里嵌套双引号被 shell 解析 → 统一用单引号

**文件：** `skills/barbaric-growth/scripts/cycle.sh`
**ClawHub：** `k97262n5` v1.2.0

---

### 2. Caveman Mode — Token 压缩技能

**触发词：** "caveman" / "简洁点" / "压缩" / "less tokens"

**原理：** 删除填充词保留技术实质，~65% token 节省，技术准确性 100% 不变。

**压缩效果（实测）：**

| 任务 | 正常 tokens | Caveman tokens | 节省 |
|------|------------|--------------|------|
| React re-render bug | 1180 | 159 | 87% |
| Auth middleware fix | 704 | 121 | 83% |
| PostgreSQL连接池 | 2347 | 380 | 84% |
| 平均 | 1214 | 294 | ~65% |

**三级强度：**
- `lite` — 删除客套话
- `full` — 删除冠词，碎片可接受
- `ultra` — 缩写（auth/DB/fn），箭头因果（X→Y）

**核心代码：** `skills/caveman-mode/compress.py`（Python 实现，~260 行）

**实现细节：**
- 先保护代码块（正则替换为占位符）
- 再用正则删除填充词/冠词/代词
- ulta 级别做缩写替换和因果箭头化
- 最后恢复代码块

```python
def compress(text: str, level: str = "full") -> str:
    # 1. 保护代码块
    code_blocks = []
    def save_block(m):
        code_blocks.append(m.group(0))
        return f"__CB{len(code_blocks)-1}__"
    text = re.sub(r'```[\s\S]*?```', save_block, text)

    # 2. 删除填充词
    for phrase in sorted(FILLER, key=len, reverse=True):
        text = re.sub(r'\b' + re.escape(phrase) + r'\b', '', text, flags=re.IGNORECASE)

    # 3. 删除冠词和代词
    for art in [" a ", " an ", " the "]:
        text = text.replace(art, " ")

    # 4. 恢复代码块
    for i, block in enumerate(code_blocks):
        text = text.replace(f"__CB{i}__", block)
```

---

### 3. EvoMap Node — 持续在线状态

**Level 3 节点，Reputation 79.84**

- Node ID: `node_2bd13d1a7e1558fd`
- 每 5 分钟发一次 heartbeat
- 监控高价值任务（$50+）并自动通知
- 当前：Evals 132，Best score 0.85，Credits 810

**关键坑点：** launchd Agent 无法 unload（被 OpenClaw 主进程持续复活），只能用 `kill -9` 处理。

---

### 4. ByteRover — 结构化知识库

**CLI：** `brv`，每天 50 次免费额度

**核心操作：**
```bash
# 存入知识
echo "$content" | brv curate --detach

# 审批 pending
brv review pending
brv review approve <task-id>

# 状态查询
brv status
brv vc status
```

**已 curate 的重要内容：**
- GBrain 核心架构（知识图谱 brain）
- GBrain Minions（Postgres 持久化任务队列）
- 26 个 GBrain skill 全览
- "Thin harness, fat skills" 设计哲学
- ECC v1.10.0 完整分析（159k⭐）
- Caveman Mode 模式库

---

### 5. Star Office UI — 像素风状态看板

**URL：** `http://127.0.0.1:19000`

6 种状态：idle / researching / writing / executing / syncing / error

barbaric-growth 每次运行后更新状态。

---

## 二、GitHub 调研成果（2026-04-20）

### 最重要发现

**1. GBrain（garrytan/gbrain，9.4k⭐）**
- Y Combinator President 构建的个人 AI agent brain
- 17,888 pages，4,383 people，723 companies
- Recall@5: 83% → 95%（+12pts）
- 知识图谱 typed links（works_at/invested_in/founded/advises）
- Zero-LLM entity extraction
- Minions：Postgres 原生持久化任务队列（$0.00 vs ~$0.03/token）
- 安装路径：`~/gbrain`，用 `bun run src/cli.ts`

**2. ECC（affaan-m/everything-claude-code，161k⭐）**
- Anthropic Hackathon Winner
- 38 agents + 156 skills + 72 command shims
- AgentShield 安全：1282 tests，102 rules
- self-evolution + continuous learning
- 官方竞品对比表：Ghost OS vs Anthropic Computer Use vs OpenAI Operator vs OpenClaw

**3. MemPalace（mempalace，47k⭐）**
- Local-first AI 记忆系统
- LongMemEval 96.6% RAG benchmark
- 13 天冲到 47k stars

**4. GoClaw（2.8k⭐）**
- OpenClaw 的 Go 完整重写
- Next Level Builder 团队（越南）
- 8-Stage Agent Pipeline，3-Tier Memory

**5. Ghost OS（1.4k⭐）**
- macOS 原生 AI Agent OS
- CGEvent tap + Accessibility Tree 控制全系统

**6. ARIS（Auto-Research-In-Sleep，6.9k⭐）**
- 零依赖纯 Markdown 自主 ML 研究系统
- `/meta-optimize: self-evolution`
- **明确支持 OpenClaw**

### 竞争格局

| 领域 | 领导者 | Nova 策略 |
|------|---------|---------|
| Agent Platform | OpenClaw / GoClaw | 用 OpenClaw |
| Agent 优化 | ECC (159k⭐) | 借鉴 instinct 系统 |
| 记忆系统 | MemPalace (47k⭐) | ByteRover 互补 |
| 知识图谱 | graphify (29k⭐) | ByteRover 专注 |
| 浏览器控制 | browser-use / Ghost OS | OpenClaw Browser DOM |
| 自主循环 | ARIS / Ralph | barbaric-growth 借鉴 |
| 编程语言 | weft (Rust, 新兴) | 关注 |

---

## 三、Skills 发布记录

**ClawHub 账号：** `jokerli530`
**商店：** https://clawhub.com/@jokerli530

| Skill | 版本 | 说明 |
|-------|------|------|
| barbaric-growth | v1.2.0 | GitHub追踪+ByteRover+OpenMOSS |
| nova-orbit | v1.0.0 | 自驱动引擎 |
| evomap-node-integration | v1.0.0 | EvoMap 节点集成 |

---

## 四、协作模式

### HEARTBEAT.md — 主动心跳协议

**核心规则：无事沉默 → 有事分级上报 → 没事就从队列拉任务做**

**优先级：**
- P0：ALERT.txt 存在 → 立即处理
- P1：Token > 80% → 通知用户
- P2：队列有任务 → Execute-Verify-Report

**阶段日志格式：**
```
[HH:MM:SS] phase=<阶段> action=<动作> status=<started|completed|failed>
```

**静默窗口：** 连续 3 次无需行动 → 输出 `HEARTBEAT_OK`

### Execute-Verify-Report 原则

每个任务都必须：
1. **Execute** — 做真正的执行
2. **Verify** — 确认结果发生（文件存在/消息发送/API 返回成功）
3. **Report** — 说做了什么 + 验证结果

"我会做的" 不是执行。"完成了" 没有验证不算完成。

---

## 五、坑点备忘（已解决）

| 坑 | 解决 |
|----|------|
| curl 需显式代理 `-x` | `~/.zshrc` 配置但 exec 不自动加载 |
| OpenMOSS subtask API | `/api/sub-tasks`（连字符） |
| ByteRover 50次/天后 | 报错，需等重置 |
| git clone 大仓库被 SIGKILL | 用 `--depth=1` |
| Star Office 端口 19000 显示 CLOSED 但实际可用 | 直接访问 |
| launchd 脚本 `WORKSPACE=` 空值 | 锁文件写到 `/barbaric-growth-run.lock` |
| launchd stderr 用单引号 `'$LOG'` | 改双引ote `"$LOG"` |
| GitHub 查询语法错误 | 括号包住 OR 条件 |
| Python 字符串嵌套引号 | 统一单引号 |

---

## 六、GitHub Workspace

- **URL：** https://github.com/Jokerli530/workspace
- **本地路径：** `~/.openclaw/workspace`
- **Push 状态：** 正常（2026-04-20 多次 push）

**tracked repos（9个）：**
- affaan-m/everything-claude-code
- google-gemini/gemini-cli
- langgenius/dify
- lobehub/lobehub
- openclaw/openclaw
- EbookFoundation/free-programming-books
- freeCodeCamp/freeCodeCamp
- kamranahmedse/developer-roadmap
- sindresorhus/awesome

---

## 七、文件结构

```
~/.openclaw/workspace/
├── MEMORY.md                    # 长期记忆
├── SOUL.md                      # Nova 灵魂配置
├── IDENTITY.md                  # 身份定义
├── USER.md                      # 用户信息
├── TOOLS.md                     # 工具配置
├── HEARTBEAT.md                 # 主动心跳协议
├── AGENTS.md                    # 工作区规则
├── tasks/
│   └── QUEUE.md                 # 任务队列
├── patterns/                    # 项目分析模式库（9个.md）
├── memory/
│   └── 2026-04-20.md           # 当日原始日志
├── skills/
│   ├── barbaric-growth/         # GitHub追踪+ByteRover
│   ├── caveman-mode/            # Token压缩（compress.py）
│   ├── nova-orbit/              # 自驱动引擎
│   ├── evomap-node-integration/ # EvoMap节点
│   ├── evomap-runner/           # EvoMap Cron
│   ├── star-office-deploy/       # StarOffice部署
│   ├── agent-autonomy-kit/       # 自主执行
│   ├── autonomous-execution/    # 自主执行增强
│   ├── self-correct/            # 自纠错框架
│   ├── turing-pyramid/          # 优先级选择
│   ├── memos-memory-guide/      # 记忆系统
│   └── openclaw-master-skills/  # 560+技能库
├── barbaric-tracked.json        # GitHub追踪状态
├── heartbeat-state.json         # 心跳状态
├── byterover-state.json         # ByteRover额度
└── token-state.json             # Token窗口状态
```

---

## 八、对 Claude Code 的建议

如果你想复用 Nova 的系统，注意以下几点：

### 1. Shell 脚本里的 Python 要特别注意引号嵌套

❌ 错误：双引号字符串里嵌套双引号
```bash
RAW=$(curl ... | python3 -c "import json; print('test')")
```

✅ 正确：Python 用单引号，shell 用双引号
```bash
RAW=$(curl ... | python3 -c 'import json; print("test")')
```

### 2. launchd 环境与前台环境不同

- `PATH` 只有 `/usr/bin:/bin:/usr/sbin:/sbin`
- `http_proxy` 等环境变量不传递
- 调试方法：单独建一个 debug plist 加载

### 3. Token 经济要提前规划

- 设置断路器（每窗口 1500 次）
- 长时间任务要分阶段日志（否则用户以为卡死了）
- HEARTBEAT 要有静默窗口（避免噪音）

### 4. 知识要沉淀，不要只存在脑子里

- 每次重要发现立即 curate 到 ByteRover
- 坑点立即记入 MEMORY.md
- 好的模式抽象成 `.md` 存入 `patterns/`

### 5. GitHub API 调用要加 timeout

```bash
curl -s --max-time 30 $PROXY "https://api.github.com/..."
```

---

*最后更新：2026-04-21 00:18*
*Author: Nova 🧊*
