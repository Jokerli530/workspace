---
name: nova-self-evolution
version: 1.1.0
description: Nova 自进化技能 — 每次任务后自动提取模式、更新记忆、形成进化闭环。含 Evolution Guardrails 保护机制。
metadata:
  { "openclaw": { "emoji": "🧬", "tags": ["self-evolution", "memory", "autonomous", "intelligence"] }}
---

# Nova 自进化技能 v1.1

> 每次任务完成后：记录 → 提炼 → 更新 → 进化
>
> **v1.1 新增：Evolution Guardrails，防止进化跑偏**

---

## Evolution Guardrails（保命机制）

以下参数锁死，**不允许自动修改**：

| 参数 | 值 | 说明 |
|------|-----|------|
| `model` | MiniMax-M2 | 锁死 |
| `provider` | MiniMax | 锁死 |
| `max_delta_per_cycle` | 0.1 | 每次参数变化 ≤ 10% |
| `min_data_points` | 3 | 至少 3 次数据点才启动进化 |
| `rollback_on_drop_pct` | 20% | 质量下降 ≥ 20% 自动回滚 |

---

## 核心流程

```
L0 (Working Memory)
  ↓ 任务完成
L1 (Episodic Memory) — memory/YYYY-MM-DD.md
  ↓ 同一模式出现3次+
L2 (Semantic Memory) — patterns/ + MEMORY.md
  ↓ ByteRover curate
知识图谱 — .brv/
```

---

## Step 1: L0 → L1 写入

```bash
MEMFILE=~/.openclaw/workspace/nova-mind/memory/$(date +%Y-%m-%d).md
mkdir -p ~/.openclaw/workspace/nova-mind/memory

cat >> "$MEMFILE" << 'EOF'

## [任务描述] — $(date +%H:%M)

**类型**: github-research | project-analysis | skill-creation | decision | evomap-bounty
**结果**: success | failure | partial
**L0保留**: [是/否，否则说明原因]
**关键决策**: [什么情况下做了什么选择]
**教训**: [如果重来会怎么改]
**Token消耗**: [本次估算]

EOF
```

---

## Step 2: L1 → L2 模式提炼

**触发条件**：同一类决策出现 **≥3 次**

```bash
# 检查是否存在重复模式
LATEST_TASKS=$(tail -20 ~/.openclaw/workspace/nova-mind/memory/$(date +%Y-%m-%d).md 2>/dev/null)
# 如果同一类型任务出现3次+，生成 pattern
# 存入 patterns/[type].md
```

**Pattern 文件格式**：

```markdown
## [类型] Pattern

**触发条件**: 什么情况下用这个模式
**判断标准**: [决策依据列表]
**标准流程**:
1. ...
2. ...
**已知坑点**:
- ...
```

---

## Step 3: L2 长期记忆更新

**触发条件**：重大发现 / 关键决策 / 教训

```bash
# 例：发现新竞品或新技术
# 更新 MEMORY.md 相关章节
```

---

## Step 4: ByteRover 知识沉淀

**触发条件**：调研有价值的内容 + ByteRover 额度充足

```bash
cd ~/.openclaw/workspace
brv curate "[研究内容]" 2>&1
```

---

## 自评估问题（每次任务后必须回答）

1. **这次最正确的决定是什么？**
2. **如果重来，我会怎么改？**
3. **这个任务揭示了 Nova 系统的什么缺陷？**
4. **这次进化有没有超过 max_delta_per_cycle (10%)？**

---

## 进化指标跟踪

- [ ] 每任务平均 token 消耗趋势
- [ ] ByteRover curate 命中率
- [ ] Pattern 复用率（用了几次已有模式）
- [ ] L1→L2 提炼次数
- [ ] Rollback 次数（应为 0）

---

## 禁止行为（Guardrails 强制）

- ❌ 不允许自动修改 model 或 provider
- ❌ 不允许在 3 次数据点内启动进化
- ❌ 不允许单次参数变化超过 10%
- ❌ 不允许在质量下降 ≥ 20% 时继续
- ❌ 不允许在 session 外执行写入操作（除 L0→L1 自动 flush）
