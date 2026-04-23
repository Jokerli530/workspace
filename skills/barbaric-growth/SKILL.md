---
name: barbaric-growth
version: 1.5.0
description: 野蛮成长自动化技能 - GitHub热点追踪 + ByteRover知识沉淀 + OpenMOSS任务循环 + StarOffice状态看板。自主消耗token+产出有价值的知识资产。
metadata:  { "openclaw": { "emoji": "🔥", "tags": ["autonomous", "research", "github", "bytedance"], "safety": "autonomous-only" }}
---

# 野蛮成长自动化技能 v1.5.0

> 让 Nova 像个真正的 AI 一样：持续消耗 token，持续产出知识资产。
>
> **v1.5 新增：关键词定向搜索（补 trending 漏网）+ 同作者跨语言 sibling 关联**
> **v1.4 新增：LLM 深度提炼（DeepSeek）+ 同语言 prior context 复用闭环**
> **v1.3 新增：GitHub PAT 认证（60→5000 req/h）+ ALERT.txt 实装 + self-evo 增量处理**
> **v1.2 新增：分阶段进度反馈 + 静默窗口机制**
> **v1.1.1 新增：MiniMax Token 断路器**
> **v1.1 新增：Verification-First 原则**

---

## 🚨 EvoMap 任务警报检查

**监控状态：** LaunchAgent `ai.openclaw.evomap-monitor` 运行中（每60秒检查，阈值$50）

**警报文件：** `~/.openclaw/evomap-monitor/ALERT.txt`

**每次 barbaric-growth 启动时，必须先检查警报**（v1.3 已在 `cycle.sh` 中实装）：

```bash
ALERT_FILE="${HOME}/.openclaw/evomap-monitor/ALERT.txt"
if [ -f "$ALERT_FILE" ]; then
    log "evomap_alert_detected"
    cat "$ALERT_FILE" >> "$LOG"
    mv "$ALERT_FILE" "${ALERT_FILE}.processed.$(date +%s)"
    exit 0
fi
```

**重要：** 如果 ALERT.txt 存在，barbaric-growth 暂停并归档警报（带时间戳），下个 cycle 继续正常跑；监控脚本发现新警报会再生成 ALERT.txt。

---

## ⚡ Token 断路器

**规则：**
- 每 5 小时窗口：1500 次额度
- 每周上限：15000 次
- 当前窗口已用 > 80%（1200次）→ 强烈警告
- 当前窗口已用 > 95%（1425次）→ 停止，主动通知李伟

**状态文件：** `~/.openclaw/token-state.json`

---

## 📍 分阶段进度反馈（v1.2 新增）

> 来源：EvoMap No-Reply Stall Mitigation (GDI 61.35)
> 核心：长任务无反馈 = 用户以为卡死了。分阶段标记让用户知道在运行。

**阶段日志格式：**
```
[HH:MM:SS] phase=<阶段> action=<动作> status=<started|completed|failed> duration=<秒>
```

**阶段定义：**
| phase | 说明 |
|-------|------|
| `idle` | 无事发生 |
| `token_check` | 检查 token 窗口 |
| `github_discovery` | GitHub API 调用 |
| `analysis` | 深度分析 |
| `byterover` | ByteRover curate |
| `openmoss` | OpenMOSS 任务写入 |
| `verify` | 验证检查 |
| `escalating` | 正在上报 |

**静默窗口：**
- 连续 3 次执行都无需上报 → 输出 `HEARTBEAT_OK` + 简短摘要
- 有任何重要事件 → 重置计数器

---

## 核心流程

```
0. 阶段标记：phase=idle, action=starting
   ↓
1. Token 检查（80%/95% 阈值警告）
   ↓
2. GitHub热点追踪
   ↓ 阶段：github_discovery
3. 深度分析
   ↓ 阶段：analysis
4. ByteRover curate（50次/天）
   ↓ 阶段：byterover
5. Verify验证（Verification-First）
   ↓ 阶段：verify
6. OpenMOSS日志
   ↓ 阶段：openmoss
7. 阶段标记：phase=idle, status=completed
```

---

## Step 0: Token 检查

```bash
~/.openclaw/workspace/skills/barbaric-growth/scripts/token-guard.sh check || exit 0
echo "[$(date '+%H:%M:%S')] phase=token_check action=check status=completed"
```

---

## Step 1: GitHub API 调用

**关键：代理必须显式加 `-x http://127.0.0.1:7897`**

```bash
echo "[$(date '+%H:%M:%S')] phase=github_discovery action=search status=started"
curl -s --max-time 15 -x "http://127.0.0.1:7897" \
  "https://api.github.com/search/repositories?q=created:>YYYY-MM-DD+AI+agent+OR+LLM+OR+MCP&sort=stars&order=desc&per_page=10" \
  -H "Accept: application/vnd.github.v3+json" | jq '[.items[] | {name, stars, desc}]'
echo "[$(date '+%H:%M:%S')] phase=github_discovery action=search status=completed"
```

---

## Step 2: 深度分析

```bash
echo "[$(date '+%H:%M:%S')] phase=analysis action=inspect status=started"
# 获取 README
curl -s --max-time 10 -x "http://127.0.0.1:7897" \
  "https://api.github.com/repos/OWNER/REPO/readme" \
  | jq -r '.content' | base64 -d
echo "[$(date '+%H:%M:%S')] phase=analysis action=inspect status=completed"
```

---

## Step 3: ByteRover curate

```bash
echo "[$(date '+%H:%M:%S')] phase=byterover action=curate status=started"
cd ~/.openclaw/workspace
brv curate "<研究内容>"
echo "[$(date '+%H:%M:%S')] phase=byterover action=curate status=completed"
```

---

## Step 4: Verification-First

| 阶段 | 验证内容 |
|------|----------|
| GitHub API | 响应是否有效？stars 数据是否存在？ |
| README fetch | 内容是否成功解码？是否完整？ |
| ByteRover curate | 是否提交成功？是否有错误？ |
| OpenMOSS cycle | task/subtask 是否正确创建？ |

```bash
echo "[$(date '+%H:%M:%S')] phase=verify action=checking status=started"
# 验证检查点...
echo "[$(date '+%H:%M:%S')] phase=verify action=checking status=completed"
```

---

## Step 5: OpenMOSS 任务循环

```bash
echo "[$(date '+%H:%M:%S')] phase=openmoss action=creating_task status=started"
# 1. 创建任务
TASK_ID=$(curl -s -X POST "http://localhost:6565/api/tasks" \
  -H "Authorization: Bearer <PLANNER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "任务名", "description": "描述", "mode": "autonomous"}' \
  | jq -r '.id')
echo "[$(date '+%H:%M:%S')] phase=openmoss action=creating_task status=completed"
```

**API 关键点：**
- subtask 路径是 `/api/sub-tasks`（有连字符）
- Executor claim/start 需要 executor 角色 token

---

## Step 6: Star Office 状态同步

```bash
curl -s -X POST http://127.0.0.1:19000/set_state \
  -H "Content-Type: application/json" \
  -d '{"state": "researching", "description": "GitHub调研中"}'
```

---

## 自进化技能提取

每次野蛮成长任务完成后，自动提取：

1. **决策模式** → 什么项目值得深入，什么不值得
2. **提示模板** → 好的 curate prompt 格式
3. **工作流程** → GitHub → 分析 → curate → OpenMOSS 日志的最优路径
4. **坑点记录** → 代理参数/API 限流/权限错误

存入 MEMORY.md 或 ByteRover，形成可复用资产。

---

## 坑点备忘

- [x] curl 不走系统代理 → 必须加 `-x http://127.0.0.1:7897`
- [x] OpenMOSS subtask API → `/api/sub-tasks`（连字符）
- [x] ByteRover curate → 50次/天额度限制
- [x] Star Office 端口 → 19000 可用
- [x] /approve 是用户命令，不是 shell 命令

## nova-mind 集成

barbaric-growth 是 Nova 的"行动层"，nova-mind 是 Nova 的"记忆层"。两者配合：

```
barbaric-growth 执行任务
    ↓
nova-mind/memory/YYYY-MM-DD.md 写入日志
    ↓
patterns/ 更新决策模板
    ↓
MEMORY.md 更新长期记忆
    ↓
下次 barbaric-growth 任务使用更新后的模式
```

---

*版本历史：v1.0初版 → v1.1 Verification-First → v1.1.1 Token断路器 → v1.2 分阶段进度反馈 → v1.3 PAT认证+ALERT实装+增量self-evo → v1.4 LLM深度提炼+prior context 复用 → v1.5 关键词扫描+作者关联*

## v1.5 关键词扫描 + 作者关联

**关键词扫描** (`scripts/keyword-scan.sh`)：
- 每轮 cycle 随机抽 2 个关键词跑 `<kw>+stars:>200+pushed:>30d` 搜索，门槛比主 trending 低得多
- 关键词清单在 `config/keywords.txt`，分 4 组：OpenClaw 生态 / Agent 研究 / 协议工具 / 记忆进化
- 捕获的 repo 带 `discovered_via: keyword:<kw>` 元信息写入 tracked.json
- 首次测试即从 2 个关键词里捞到 10 个 30k+ stars 的遗漏项目（cline / crewAI / cherry-studio 等）

**作者跨语言关联** (`llm-extract.sh` 内 `fetch_author_siblings`)：
- 拉 README 的同时调 `GET /users/<owner>/repos?sort=updated&per_page=20`
- 过滤 forks，按 stars 排序取 top 5
- 作为"该作者的其他项目"段传给 DeepSeek，LLM 可直接引用
- prompt 中明确要求："如果该作者还有其他相关项目，点出本项目在其作者生态里的定位"

**闭环验证**：cline/cline 的深度分析里自动引用了作者生态（prompts, mcp-marketplace, kanban, cline-bench）——cross-language sibling context 生效。

## v1.4 LLM 深度提炼闭环

每次处理新 repo 时，`self-evo.sh` 先写静态模板骨架，再调 `scripts/llm-extract.sh` 追加"## 深度分析（LLM 提炼）"段：

1. **拉 README**（GitHub API，6KB cap）
2. **找 prior context**（patterns/ 里同语言的 top-3 已研究项目 + 核心定位摘要）
3. **调 DeepSeek**（deepseek-chat，temperature 0.3，max 800 tokens）
4. **5 段输出**：核心定位 / 技术栈 / 独特机制 / 与 OpenClaw 集成可能 / 值得深入的点
5. **写回**：pattern 文件追加深度分析段 + 元信息加 `content_source: llm` 标记

**复用闭环**：越后发现的同语言 repo，能对比越多已研究 sibling → LLM 输出越有区分度。

**失败 fallback**：DeepSeek 超时/API key 缺失 → 静态模板保留，pattern 依然可用，不影响 cycle。

**成本**：单 repo 约 0.001 元（~1.5k input tokens + 800 output tokens）。9 个 repo 一轮约 0.01 元。

## GitHub PAT 配置（v1.3 新增）

```bash
mkdir -p ~/.openclaw/secrets
chmod 700 ~/.openclaw/secrets
cat > ~/.openclaw/secrets/github.env << 'EOF'
GITHUB_TOKEN=ghp_你自己生成的PAT
EOF
chmod 600 ~/.openclaw/secrets/github.env
```

PAT 生成入口：GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens。
**权限只勾 Public repositories 即可**（不需要任何写权限）。rate limit 60→5000 req/h。

文件不存在时 cycle.sh 自动退回未认证模式，不会报错。

## 坑点备忘 v2026-04-20

- [x] GBrain 编译产物（bin/gbrain）SIGKILL → macOS 代码签名限制，用 `bun run src/cli.ts` 替代
- [x] ByteRover review approve 批处理：`brv review pending | grep "^  Task:" | awk '{print $2}' | while read t; do brv review approve $t; done`
- [x] GitHub search 用中文查询返回空 → 用英文关键词：`meituan sdk` 而非 `美团 SDK`
- [x] 浏览器工具在有 http_proxy 环境变量时无法导航（SSRF policy），临时去掉变量：env -i HOME="$HOME" PATH="$PATH" ...
