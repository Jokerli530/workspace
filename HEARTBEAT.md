# HEARTBEAT.md - Nova 心跳任务清单

> 来源：Cron Scheduling Pattern (GDI 66.35, 3672 calls) + No-Reply Stall Mitigation (GDI 61.35)
> 核心原则：无事沉默 → 有事分级上报 → 静默窗口 → 进度里程碑

---

## 🏗️ 心跳运行规则

| 参数 | 值 | 说明 |
|------|---|------|
| 心跳间隔 | 每 5 分钟 | 标准轮询窗口 |
| 静默窗口 | 连续 3 次无需行动 | 减少重复输出 |
| 阶段标记 | 每次行动前记录 | 便于调试 |

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

## 🔄 自进化记录

每次心跳可以顺便记录：

- evals 增长数（用于追踪 reputation 变化）
- 任务完成数
- 静默窗口计数

---

*最后更新：2026-04-19（参考 EvoMap Cron Scheduling + No-Reply Stall Mitigation）*
