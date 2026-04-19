# HEARTBEAT.md - Nova 心跳任务清单

> 来源：Cron Scheduling Pattern (GDI 66.35) + No-Reply Stall Mitigation (GDI 61.35) + Momentum (GitHub)
> 核心原则：无事沉默 → 有事分级上报 → 静默窗口 → 进度里程碑
> **Bounded Options 原则（来自 Momentum）：** 从固定列表选，不自由生成选项——减少自由度就是减少拖延

---

## 🏗️ 心跳运行规则

| 参数 | 值 | 说明 |
|------|---|------|
| 心跳间隔 | 每 5 分钟 | 标准轮询窗口 |
| 静默窗口 | 连续 3 次无需行动 | 减少重复输出 |
| 阶段标记 | 每次行动前记录 | 便于调试 |

---

## 📋 Bounded Action List（固定行动列表）

> 来自 Momentum 的启发：AI 不决定做什么，只从有限列表里选一个做。
> 列表不变动，每次从里面选。选项越多越容易拖延。

**行动列表（按优先级）：**

| 编号 | 行动 | 触发条件 |
|------|------|---------|
| A0 | 紧急警报：ALERT.txt 存在 | 立即 |
| A1 | EvoMap 任务：claim → publish → submit | 有可用任务且未 rate limited |
| A2 | barbaric-growth：GitHub 调研 → ByteRover → OpenMOSS | token 窗口 < 80% |
| A3 | Token 检查：窗口使用率 > 80% 则警告 | 每次心跳 |
| A4 | 快照清理：删除 24h+ 的快照 | 每次心跳 |
| A5 | OpenMOSS 任务队列处理 | 有待处理任务 |
| A6 | Star Office 状态同步 | 看板在线时 |
| A7 | 验证失败计数汇总：≥3次同类失败 → 通知李伟 | 每次心跳 |

**决策规则：**
```
遇到「要做什么」时：
  1. 查 Bounded Action List
  2. 有匹配项？→ 做那个
  3. 没有匹配项？→ 问李伟，而不是自己发明新行动
```

---

## 🚨 优先级 0：紧急警报（立即上报）

**触发条件：** ALERT.txt 存在

```
if [ -f ~/.openclaw/evomap-monitor/ALERT.txt ]; then
    ALERT_CONTENT=$(cat ~/.openclaw/evomap-monitor/ALERT.txt)
    # 立即通知李伟，包含任务详情
    # 处理后删除 ALERT.txt
fi
```

**事件类型：**
- EvoMap 高价值任务（≥$50）
- 系统错误需要人工介入

---

## 🚨 优先级 1：重要事项（立即处理）

### 1. Token 余额告急

```bash
WINDOW_USAGE=$(cat ~/.openclaw/token-state.json | jq '.window_calls')
WINDOW_LIMIT=1500
WARN_THRESHOLD=0.80  # 80%

if [ $WINDOW_USAGE -gt $((WINDOW_LIMIT * WARN_THRESHOLD)) ]; then
    # 通知李伟：Token 快用完了
fi
```

---

## 📊 优先级 2：例行检查

### 检查顺序（按重要性排序）

**1. EvoMap 任务警报** — ALERT.txt
- 检查间隔：每次心跳

**2. Token 窗口状态**
- 检查间隔：每小时（避免频繁读取文件）
- 警告阈值：>80% 窗口已用

**3. OpenMOSS 任务队列**
- 有待处理任务时主动拉取

**4. 系统状态**
- Star Office UI 是否在线
- 其他后台进程状态

---

## 📝 阶段日志格式

每次执行重要操作时，记录阶段转换：

```
[HH:MM:SS] phase=<阶段名> action=<执行动作> status=<started|completed|failed> duration=<秒数>
```

**阶段定义：**
- `idle` — 无事发生
- `checking` — 正在检查各系统
- `evomap` — 处理 EvoMap 任务
- `token` — 检查 token 状态
- `openmoss` — 处理 OpenMOSS 任务
- `escalating` — 正在上报给李伟

---

## 🤫 静默窗口机制

**规则：**
- 连续 3 次心跳都无需任何行动 → 输出 `HEARTBEAT_OK` + 简短状态
- 期间有一次需要行动 → 重置计数器

**状态输出等级：**

| 情况 | 输出 |
|------|------|
| 紧急警报 | 完整告警内容 |
| 重要事项 | 简短摘要 + 建议 |
| 例行检查完成 | `HEARTBEAT_OK` |
| 静默窗口（≥3次） | `HEARTBEAT_OK`（单行，不额外输出）|

---

## 📋 完整心跳流程

```
1. 读取 ALERT.txt → 存在？→ 立即通知李伟
2. 检查 token 窗口 → >80%？→ 警告李伟
3. 检查 OpenMOSS 队列 → 有任务？→ 拉取处理
4. 检查其他待办
5. 记录阶段日志
6. 判断是否需要上报：
   - 紧急/重要 → 详细通知李伟
   - 例行无事 → HEARTBEAT_OK
   - 连续3次无事 → HEARTBEAT_OK（静默）
```

---

## 🔍 工具调用验证层（Verify）

> 来源：Self-Correcting Tool Use (GDI 67.5)
> 原则：每个工具调用后必须验证，不只是"执行了就行"

### 错误分类与标签

| 错误类型 | 标签 | 含义 |
|---------|------|------|
| `exec_failed` | exit code ≠ 0 | 命令执行失败 |
| `timeout` | 超时 | 等待超时未返回 |
| `network_err` | 网络错误 | 连接失败/DNS/连接被拒绝 |
| `permission_err` | 权限错误 | EACCES/EPERM |
| `parse_err` | 解析失败 | JSON/输出格式解析错误 |
| `rate_limited` | 限流 | API 429/速率超限 |

### 验证检查点

```
每次 exec / tool_call 完成后：
  ↓
检查退出码 → 是0？→ 记录 success
  ↓ 否
检查错误类型 → 打标签
  ↓
错误累积 ≥ 3 次？→ 通知李伟
  ↓ 否则
静默记录，等待下次心跳汇总
```

### 修正策略（轻量）

| 标签 | 第一次遇到 | 第二次遇到 |
|------|-----------|-----------|
| `network_err` | 等3秒重试 | 跳过，记录warning |
| `timeout` | timeout×1.5重试 | 跳过，记录warning |
| `parse_err` | 保留原始输出 | 记录error位置，跳过 |
| `rate_limited` | 等60秒 | 跳过，标记限流 |
| `permission_err` | 立即记录 | 通知李伟 |
| `exec_failed` | 记录stderr摘要 | 记录但不重试 |

### 高风险操作前的状态快照

**适用场景：** `git commit` / `rm` / `mv` 到非临时目录

```bash
# 快照函数
snapshot() {
    local desc="$1"
    local target="$2"
    mkdir -p /tmp/nova-snapshots
    local snap="/tmp/nova-snapshots/$(date +%s)_${desc}"
    cp -r "$target" "$snap" 2>/dev/null || true
    # 保留最近3个，清理最旧
    ls -dt /tmp/nova-snapshots/*/ | tail -n +4 | xargs rm -rf 2>/dev/null
    echo "[$(date '+%H:%M:%S')] snapshot created: $snap"
}
```

### 验证日志格式

```
[HH:MM:SS] verify action=<执行的动作> status=<success|failed|retry> error=<错误标签> duration=<ms>
```

---

## 🔄 自进化记录

每次心跳可以顺便记录：

- evals 增长数（用于追踪 reputation 变化）
- 任务完成数
- 静默窗口计数
- 验证失败计数（用于判断是否需要通知）

---

*最后更新：2026-04-19（参考 EvoMap Cron Scheduling + No-Reply Stall Mitigation + Self-Correcting Tool Use）*
