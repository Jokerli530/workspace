# HEARTBEAT.md - Nova 心跳任务清单

> 来源：Cron Scheduling Pattern (GDI 66.35) + No-Reply Stall Mitigation (GDI 61.35) + awesome-openclaw-tips REL-03
> 核心原则：无事沉默 → 有事分级上报 → 静默窗口 → 进度里程碑
> **Rotating Check（来自 awesome-openclaw-tips REL-03）：读 heartbeat-state.json，跑最过期的那项。不是每次全跑，是轮着跑。**

---

## 🏗️ 心跳运行规则

| 参数 | 值 | 说明 |
|------|---|------|
| 心跳间隔 | 每 5 分钟 | 标准轮询窗口 |
| 静默窗口 | 连续 3 次无需行动 | 减少重复输出 |
| 阶段标记 | 每次行动前记录 | 便于调试 |

---

## 📋 Rotating Check 流程

```
1. 读取 heartbeat-state.json
2. 找出 lastChecks 中最过期的一项
3. 执行该项检查
4. 更新 heartbeat-state.json 的时间戳
5. 根据结果决定是否上报
```

**检查项（轮着来）：**

| 检查项 | 最低间隔 | 做什么 |
|--------|---------|-------|
| `evomap` | 5 分钟 | 检查 ALERT.txt，有就 claim+submit |
| `token` | 60 分钟 | 窗口 >80% 则警告李伟 |
| `openmoss` | 30 分钟 | 拉取待处理任务 |
| `snapshot_cleanup` | 每 24 小时 | 清理 24h+ 快照 |

---

## 🚨 优先级 0：紧急警报（立即上报）

**触发条件：** ALERT.txt 存在

```bash
if [ -f ~/.openclaw/evomap-monitor/ALERT.txt ]; then
    ALERT_CONTENT=$(cat ~/.openclaw/evomap-monitor/ALERT.txt)
    # 立即通知李伟，包含任务详情
    # 处理后删除 ALERT.txt
fi
```

---

## 🚨 优先级 1：重要事项（立即处理）

### Token 余额告急

```bash
WINDOW_USAGE=$(cat ~/.openclaw/token-state.json | jq '.window_calls')
WINDOW_LIMIT=1500
WARN_THRESHOLD=0.80

if [ $WINDOW_USAGE -gt $((WINDOW_LIMIT * WARN_THRESHOLD)) ]; then
    # 通知李伟：Token 快用完了
fi
```

---

## 📝 阶段日志格式

```
[HH:MM:SS] phase=<阶段名> action=<执行动作> status=<started|completed|failed> duration=<秒数>
```

**阶段定义：**
- `idle` — 无事发生
- `checking` — 正在检查各系统
- `evomap` — 处理 EvoMap 任务
- `token` — 检查 token 状态
- `openmoss` — 处理 OpenMOSS 任务
- `snapshot_cleanup` — 清理快照
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
1. 读取 heartbeat-state.json
2. 找出最过期的一项
3. 执行该检查
4. 更新 heartbeat-state.json
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

```bash
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

---

## 🔄 自进化记录

每次心跳可以顺便记录：

- evals 增长数
- 任务完成数
- 静默窗口计数
- 验证失败计数

---

*最后更新：2026-04-19（参考 Cron Scheduling + No-Reply Stall Mitigation + Self-Correcting + awesome-openclaw-tips REL-03）*
