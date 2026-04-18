---
name: nova-self-evolution
version: 1.0.0
description: Nova 自进化技能 — 每次任务后自动提取模式、更新记忆、形成进化闭环
metadata:
  { "openclaw": { "emoji": "🧬", "tags": ["self-evolution", "memory", "autonomous", "intelligence"] }}
---

# Nova 自进化技能

> 每次任务完成后：记录 → 提炼 → 更新 → 进化

## 触发时机

每次完成重要任务后（调研/分析/创建/决策），调用一次。

## 核心流程

```
1. 写日日志 → 2. 提取模式 → 3. 更新长期记忆 → 4. 记录进化
```

---

## Step 1: 写日日志

```bash
cat >> ~/.openclaw/workspace/nova-mind/memory/$(date +%Y-%m-%d).md << 'EOF'
## [任务描述] — $(date +%H:%M)

**类型**: github-research | project-analysis | skill-creation | decision | ...
**结果**: 成功/失败/部分完成
**关键决策**: [什么情况下做了什么选择]
**教训**: [如果重来会怎么改]
**Token消耗**: [估算]

EOF
```

---

## Step 2: 提取模式

扫描 memory/ 目录，提炼决策模板：

```bash
# 示例 pattern 文件格式
cat >> ~/.openclaw/workspace/nova-mind/patterns/github-research.md << 'EOF'
## GitHub 项目调研模式

**触发条件**: 遇到新的 AI/Agent 项目
**判断标准**:
- stars > 1000 → 值得深入
- stars > 10000 → 顶级发现，必须 curate
- created < 30天 → 爆发期，值得关注

**标准流程**:
1. GET /repos/{owner}/{repo} → stars, desc, topics, created_at
2. GET /repos/{owner}/{repo}/readme → 核心创新
3. 判断：vs 竞品 / 对 Nova 的意义
4. curate to ByteRover (如果有价值)
5. 更新 MEMORY.md

**坑点**:
- curl 不走代理 → 必须加 `-x http://127.0.0.1:7897`
- ByteRover 50次/天上限

EOF
```

---

## Step 3: 更新长期记忆

每次发现重要结论 → 更新 MEMORY.md 的相关章节：

```bash
# 例：发现新竞品
echo "**新竞品**: [项目名] ([stars] stars) - [一句话定位]" >> MEMORY.md
```

---

## Step 4: 记录进化

```bash
cat >> ~/.openclaw/workspace/nova-mind/logs/evolution.md << 'EOF'
## $(date +%Y-%m-%d)

**进化**: [具体改进]
**原因**: [什么触发了这个改进]
**效果**: [预期影响]

EOF
```

---

## 自评估问题（每次任务后问自己）

1. **这次最正确的决定是什么？**
2. **如果重来，我会怎么改？**
3. **这个任务揭示了 Nova 系统的什么缺陷？**
4. **下次遇到类似任务，怎么才能做得更好？**

---

## ByteRover 集成

有价值的研究 → curate 到 ByteRover：

```bash
cd ~/.openclaw/workspace
brv curate "[研究内容]" 2>&1
# 等待审核
```

---

## 进化指标

跟踪以下指标，观察 Nova 的成长：

- [ ] 每任务平均 token 消耗（下降趋势）
- [ ] ByteRover curate 命中率
- [ ] GitHub 发现率（从 0 到持续产出）
- [ ] 模式复用率（新任务用了多少已有模式）
