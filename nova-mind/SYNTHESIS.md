# 2026-04-18 深度调研最终报告

> "AI Agent 的自驱动智能 — 从观察到进化，6个顶级系统的共同揭示"

---

## 6大深度分析：核心发现

| # | 系统 | Stars | 核心理念 |
|---|------|-------|----------|
| 1 | **ECC** | 159,805 | Hooks 100%可靠 observation + Instinct confidence scoring |
| 2 | **GoClaw** | 2,801 | 3-tier memory + Evolution Guardrails |
| 3 | **ARIS** | 6,943 | Meta-optimize: reviewer-gated 自进化 |
| 4 | **MemPalace** | 47,614 | Verbatim storage > LLM extraction |
| 5 | **prax-agent** | 50 | Verification-First (not "prompt and hope") |
| 6 | **HiClaw** | 4,165 | Manager-Workers + Human-in-the-Loop by Default |

---

## 共同揭示的 6 个最佳实践

### 1. 可靠观察（Reliable Observation）

| 系统 | 方法 | 可靠性 |
|------|------|--------|
| **ECC v1** | Skill 触发 | 50-80% |
| **ECC v2** | PreToolUse/PostToolUse hooks | **100%** |

**结论**：用 hooks 代替 skill 触发，是 learning system 的关键。Skills 是概率性的，hooks 是确定性的。

### 2. 原子单位 + 置信度（Atomic Units + Confidence）

```
ECC Instinct 格式：
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
scope: project
---

Confidence scoring:
- 0.3 = tentative
- 0.5 = moderate
- 0.7 = strong (auto-approved)
- 0.9 = near-certain
```

**结论**：比"skill"更小的原子单位，有置信度，有 scope，可以 promote。

### 3. 外部审核的自进化（Reviewer-Gated Evolution）

```
ARIS Meta-Optimize:
日志记录 (.aris/meta/events.jsonl)
    ↓
Usage Pattern Analysis
    ↓
Patch Proposals (concrete diffs)
    ↓
Cross-Model Review (GPT-5.4 adversarial)
    ↓
User Approval → Apply
```

**关键**：自进化必须有外部审核，不能让 agent 自己随意改自己。

### 4. 逐字存储优于提取（Verbatim > Extraction）

```
MemPalace 发现：
- Mem0: LLM 提取"用户偏好 PostgreSQL" → 丢失 why
- Mastra: GPT-mini 观察对话 → 丢失上下文
- MemPalace: 直接存原文 + ChromaDB → 96.6% R@5 (无需 API key)

原文保留了：
- 为什么
- 考虑了哪些替代方案
- 讨论了哪些权衡
```

**结论**：过度工程化的记忆提取反而更差。简单存储 + 好搜索 = 足够好。

### 5. 验证优先（Verification-First）

```
prax-agent:
Most tools: Prompt → Hope → Done
Prax: Test → Verify → Fix → Test (loop)

Benchmark: 10/10 @ 29.56s (vs 8/10 @ 58.44s baseline)

关键机制：
- CircuitBreaker (25 iter max)
- LoopDetection
- QualityGate
```

**结论**：不做"prompt and hope"，做"verify until pass"。

### 6. Human-in-the-Loop by Default

```
HiClaw Matrix Rooms:
Every room = You + Manager + Relevant Workers

所有 agent-to-agent 调用可见，人类随时可干预。

Nova 的 Star Office = 类似理念的可视化
```

---

## Nova-Orbit 的设计原则

基于 6 大发现，Nova-Orbit 应该：

```
1. 可靠观察 → 用 OpenClaw hooks（如果支持）
2. 原子单位 → Instinct-style 的 pattern 记录
3. 外部审核 → ARIS 的 reviewer-gated 机制
4. 逐字优先 → MEMORY.md 就是 verbatim storage
5. 验证闭环 → barbaric-growth 的 OpenMOSS cycle
6. 可见可干预 → Star Office 状态可视化
```

---

## 记忆系统的演进规律

| 时代 | 系统 | 记忆方式 |
|------|------|----------|
| 1.0 | 矢量数据库 | 嵌入向量 |
| 2.0 | LLM 提取 | 提取"重要事实" |
| 3.0 | MemPalace | 逐字存储 + 层级 |
| Nova | ByteRover + MEMORY.md | 混合（verbatim + 搜索）|

---

## 行动优先级

### 🔴 本周（立刻做）
- [ ] 在 barbaric-growth 里加入 Verification-First 原则
- [ ] 设计 Nova 版本的 instinct pattern 格式
- [ ] ByteRover curate 额度今消耗完（明日继续）

### 🟠 本月（规划做）
- [ ] 实现 Nova 版本的 reviewer-gated evolution
- [ ] 设计 CircuitBreaker 防止死循环
- [ ] 研究 HiClaw 部署可能性

### 🟡 后续（观察）
- [ ] weft — AI 系统编程语言
- [ ] dify — 138k stars workflow 平台
- [ ] skills.sh 80k skills 对 ClawHub 的竞争

---

## 今日总产出

| 类别 | 数量 |
|------|------|
| Deep Dives | 6 个完整分析 |
| Cycles 验证 | 2 个（BuilderPulse + prax-agent） |
| 技能发布 | 3 个（barbaric-growth / nova-orbit / nova-self-evolution）|
| Commits | 14 次（15:00-16:00）|
| 发现项目 | 60+ |

---

*报告生成：2026-04-18 16:00*
