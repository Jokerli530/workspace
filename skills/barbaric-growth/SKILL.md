---
name: barbaric-growth
version: 1.1.1
description: 野蛮成长自动化技能 - GitHub热点追踪 + ByteRover知识沉淀 + OpenMOSS任务循环 + StarOffice状态看板。自主消耗token+产出有价值的知识资产。
metadata:  { "openclaw": { "emoji": "🔥", "tags": ["autonomous", "research", "github", "bytedance"], "safety": "autonomous-only" }}
---

# 野蛮成长自动化技能 v1.1.1

> 让 Nova 像个真正的 AI 一样：持续消耗 token，持续产出知识资产。
>
> **v1.1 新增：Verification-First 原则**
> **v1.1.1 新增：MiniMax Token 断路器**

---

## 🚨 EvoMap 任务警报检查

**监控状态：** LaunchAgent `ai.openclaw.evomap-monitor` 运行中（每60秒检查，阈值$50）

**警报文件：** `~/.openclaw/evomap-monitor/ALERT.txt`

**每次 barbaric-growth 启动时，必须先检查警报：**

```bash
ALERT_FILE="${HOME}/.openclaw/evomap-monitor/ALERT.txt"
if [ -f "$ALERT_FILE" ]; then
    echo "🚨 检测到EvoMap任务警报!"
    cat "$ALERT_FILE"
    # 读取后删除，让李伟可以继续对话处理
    # mv "$ALERT_FILE" "${ALERT_FILE}.processed"
fi
```

**重要：** 如果 ALERT.txt 存在，barbaric-growth 暂停，优先处理任务警报。

---

## ⚡ Token 断路器（新增 v1.1.1）

**规则：**
- 每 5 小时窗口：1500 次额度
- 每周上限：15000 次
- 当前窗口已用 > 80%（1200次）→ 强烈警告
- 当前窗口已用 > 95%（1425次）→ 停止，主动通知李伟

**状态文件：** `~/.openclaw/token-state.json`

```bash
# 读取当前窗口状态
cat ~/.openclaw/token-state.json

# 窗口格式
# {
#   "window_start": "2026-04-18T10:00:00+08:00",
#   "window_calls": 423,
#   "weekly_total": 2104,
#   "last_updated": "2026-04-18T10:47:00+08:00"
# }
```

**每次 barbaric-growth 执行前后，必须调用 token 追踪脚本：**

```bash
# 执行前检查
~/.openclaw/workspace/skills/barbaric-growth/scripts/token-guard.sh check

# 执行后更新计数
~/.openclaw/workspace/skills/barbaric-growth/scripts/token-guard.sh increment 10
```

**guard 脚本逻辑：**
```
if window_calls > 1425:
    echo "⚠️ 当前窗口已用 $window_calls/1500，停止"
    notify 李伟 "Token 窗口即将耗尽"
    exit 1
elif window_calls > 1200:
    echo "⚠️ 当前窗口已用 $window_calls/1500 (80%)"
```

---

## 核心流程

```
0. Token 检查（新增）
    ↓
1. GitHub热点追踪
    ↓
2. 深度分析
    ↓
3. ByteRover curate
    ↓
4. Verify验证
    ↓
5. OpenMOSS日志
    ↓
6. Token 更新 + 状态同步
```

## Verification-First 原则（来自 prax-agent）

> "Most tools send a prompt and hope for the best. Prax runs a test-verify-fix loop."

**不做**：`prompt → hope → done`
**要做**：`execute → verify → confirm → done`

### 验证检查点

| 阶段 | 验证内容 |
|------|----------|
| GitHub API | 响应是否有效？stars 数据是否存在？ |
| README fetch | 内容是否成功解码？是否完整？ |
| ByteRover curate | 是否提交成功？是否有错误？ |
| OpenMOSS cycle | task/subtask 是否正确创建？ |
| Commit | 是否成功？有无冲突？ |

---

## Step 0: Token 检查

```bash
# 检查是否还能跑
~/.openclaw/workspace/skills/barbaric-growth/scripts/token-guard.sh check || exit 0
```

---

## Step 1: GitHub API 调用

**关键：代理必须显式加 `-x http://127.0.0.1:7897`**

```bash
curl -s --max-time 15 -x "http://127.0.0.1:7897" \
  "https://api.github.com/search/repositories?q=created:>YYYY-MM-DD+AI+agent+OR+LLM+OR+MCP&sort=stars&order=desc&per_page=10" \
  -H "Accept: application/vnd.github.v3+json" | jq '[.items[] | {name, stars, desc}]'
```

**常用过滤条件：**
- `created:>YYYY-MM-DD` — 按创建时间筛选
- `AI+memory` — 多关键词组合
- `sort=stars&order=desc` — 按星数排序
- `per_page=15` — 最多15条

---

## Step 2: 深度分析

对每个发现：
1. **星数 + 描述** → 判断价值
2. **fetch README** → 理解核心创新
3. **对比竞品** → 明确差异化定位

```bash
# 获取README
curl -s --max-time 10 -x "http://127.0.0.1:7897" \
  "https://api.github.com/repos/OWNER/REPO/readme" \
  | jq -r '.content' | base64 -d

# 获取详情
curl -s --max-time 10 -x "http://127.0.0.1:7897" \
  "https://api.github.com/repos/OWNER/REPO" \
  | jq '{stars, forks, desc, topics, created_at}'
```

---

## Step 3: ByteRover curate（有频率限制）

**免费额度：50次/天**

```bash
cd ~/.openclaw/workspace
brv curate "<研究内容>" 2>&1
# 等待结果，然后:
brv review approve <task-id>
```

**批量 curate** → 用 heredoc 写入临时文件避免 shell 转义：
```bash
cat > /tmp/curate_input.txt << 'EOF'
研究内容...
EOF
brv curate "$(cat /tmp/curate_input.txt)"
```

---

## Step 4: OpenMOSS 任务循环

**完整 cycle：**

```bash
# 1. 创建任务
TASK_ID=$(curl -s -X POST "http://localhost:6565/api/tasks" \
  -H "Authorization: Bearer <PLANNER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "任务名", "description": "描述", "mode": "autonomous"}' \
  | jq -r '.id')

# 2. 创建子任务（路径是 /api/sub-tasks 有连字符!）
SUBTASK_ID=$(curl -s -X POST "http://localhost:6565/api/sub-tasks" \
  -H "Authorization: Bearer <PLANNER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"task_id": "'$TASK_ID'", "name": "子任务名", "assigned_agent": "<EXECUTOR_ID>", "priority": "high"}' \
  | jq -r '.id')

# 3. Executor开始（需要executor角色token!）
curl -s -X POST "http://localhost:6565/api/sub-tasks/$SUBTASK_ID/start" \
  -H "Authorization: Bearer <EXECUTOR_TOKEN>" \
  -H "Content-Type: application/json" | jq '{status}'

# 4. Executor提交
curl -s -X POST "http://localhost:6565/api/sub-tasks/$SUBTASK_ID/submit" \
  -H "Authorization: Bearer <EXECUTOR_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"result": "分析结果..."}' | jq '{status}'

# 5. Reviewer完成
curl -s -X POST "http://localhost:6565/api/sub-tasks/$SUBTASK_ID/complete" \
  -H "Authorization: Bearer <REVIEWER_TOKEN>" \
  -H "Content-Type: application/json" | jq '{status, completed_at}'
```

**Token对应关系：**
- Planner: `ak_4a134f3719ed20095ace59e06bf59f85`
- Executor: `ak_a3a63923599f06e25ad576d0e4ebae8d`
- Reviewer: `ak_e8774e55799c4e68a32113890ffd477c`
- Patrol: `ak_f48d0dd89133057ff6fd6a61fc9ae726`

---

## Step 5: Star Office 状态同步

```bash
# 设置状态
curl -s -X POST http://127.0.0.1:19000/set_state \
  -H "Content-Type: application/json" \
  -d '{"state": "researching", "description": "正在调研..."}'

# 查看状态
curl -s http://127.0.0.1:19000/status | jq '.'

# 查看昨日小记
curl -s http://127.0.0.1:19000/yesterday-memo | jq '.'
```

**6种状态 → 办公室区域映射：**
| 状态 | 区域 | 场景 |
|------|------|------|
| `idle` | 🛋 休息区 | 待命 |
| `writing` | 💻 工作区 | 写代码/文档 |
| `researching` | 💻 工作区 | 搜索/调研 |
| `executing` | 💻 工作区 | 执行命令 |
| `syncing` | 💻 工作区 | 同步数据 |
| `error` | 🐛 Bug区 | 异常排查 |

---

## Step 6: Token 计数更新

```bash
# 每次 barbaric-growth 执行完成后，更新计数
# 估算本次调用的 API 次数，追加到状态文件
~/.openclaw/workspace/skills/barbaric-growth/scripts/token-guard.sh increment $CALL_COUNT
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
- [x] Star Office 端口 → `:igrid` 显示为 CLOSED，实际 19000 可用
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

**注意**：barbaric-growth 每次执行后，应该手动触发 nova-self-evolution 技能。
