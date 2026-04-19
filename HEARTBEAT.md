# HEARTBEAT.md - Nova 主动心跳

> 来源：Cron Scheduling Pattern + No-Reply Stall Mitigation + Self-Correcting + awesome-openclaw-tips REL-03 + agent-autonomy-kit
> 核心原则：**无事沉默 → 有事分级上报 → 没事就从队列拉任务做**
> **Execute-Verify-Report：做完才算完，没做完不算完**

---

## 🏗️ 心跳运行规则

| 参数 | 值 | 说明 |
|------|---|------|
| 心跳间隔 | 每 5 分钟 | 标准轮询窗口 |
| 静默窗口 | 连续 3 次无需行动 | 减少重复输出 |
| 阶段标记 | 每次行动前记录 | 便于调试 |

---

## 🚨 优先级 0：紧急警报（立即处理）

**触发：ALERT.txt 存在**

```
1. 读取 ALERT.txt 内容
2. 立即 claim + publish + submit
3. 删除 ALERT.txt
4. 通知李伟任务已完成
5. 更新 QUEUE.md（移到 Done）
```

---

## 🚨 优先级 1：重要事项（立即处理）

**Token 窗口 >80%：立即通知李伟**

---

## 📋 完整心跳流程（主动工作流）

```
1. 紧急检查（ALERT.txt）
2. 重要检查（token >80%）
3. 如果上面都没有：
   a. 读取 tasks/QUEUE.md
   b. 从 Ready 列表选最高优先级的任务
   c. Execute → Verify → Report
   d. 做完了 → 更新 QUEUE.md（移到 Done 或记录进度）
   e. 没做完 → 记录进度，继续
4. 记录阶段日志
5. 判断输出：
   - 有紧急/重要事项 → 详细通知李伟
   - 从队列拉了任务做 → 简短汇报进展
   - 无事 → HEARTBEAT_OK
   - 连续3次无事 → HEARTBEAT_OK（静默）
```

---

## 🤖 从队列拉任务（核心区别）

**不等 prompt，主动工作：**

```
读取 tasks/QUEUE.md
  ↓
从 ## 🔴 Ready 选最高优先级任务
  ↓
执行：Execute → Verify → Report
  ↓
更新 QUEUE.md：
  - 做完了 → 移到 ✅ Done Today
  - 还在做 → 移到 🟡 In Progress（加进度备注）
  - 发现新任务 → 加到 💡 Ideas 或相应 section
```

**队列为空时：**
- 不闲着，做维护性工作
- 快照清理
- MEMORY.md 自进化记录
- 静默窗口计数 +1

---

## 🔍 工具调用验证层（Verify）

> 来源：Self-Correcting Tool Use (GDI 67.5)

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

## 📝 阶段日志格式

```
[HH:MM:SS] phase=<阶段名> action=<执行动作> status=<started|completed|failed|queued> duration=<秒数>
```

**阶段定义：**
- `idle` — 无事发生
- `checking` — 正在检查各系统
- `queue_pull` — 从队列拉任务
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

---

## 📁 任务队列位置

`tasks/QUEUE.md` — Nova 的主动工作队列

---

*最后更新：2026-04-19（合并 agent-autonomy-kit 主动心跳 + Execute-Verify-Report）*
