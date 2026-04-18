# Nova Instinct Pattern Format

> 基于 ECC Instinct v2.1 + ARIS Meta-Optimize 设计
> 
> 核心理念：原子化的、可置信的、可复用的行为模式

---

## 文件位置

```
nova-mind/
├── instincts/
│   ├── global/           # 全局 instincts
│   │   ├── openmoss-cycle.md
│   │   ├── github-research.md
│   │   └── token-economy.md
│   └── local/            # 本地 instincts（当前 session）
│       └── draft/
└── logs/
    └── instinct-evidence.md  # 观察日志
```

---

## Instinct 文件格式

```yaml
---
id: openmoss-verify-before-submit
trigger: "当 OpenMOSS subtask 执行完成时"
domain: workflow
confidence: 0.8
scope: global
source: "2026-04-18 野蛮成长 Cycle 2"
evidence_count: 3
last_verified: "2026-04-18"
---

# OpenMOSS Submit 前必须 Verify

## 触发条件
OpenMOSS subtask 执行完成（start → 执行 → submit 前）

## 行为
1. 检查执行结果是否符合预期
2. 确认输出格式正确
3. 再调用 submit，而不是直接信任执行结果

## 证据
- Cycle 2: prax-agent 的 Verification-First 原则
- 直接 submit 偶发失败，手动 verify 后重试成功
- ECC instinct system 验证机制

## 置信度理由
- 3 次观察，2 次确认，1 次失败
- 适用于所有 OpenMOSS cycle
```

---

## 域标签（Domain Tags）

| Tag | 含义 | 示例 |
|-----|------|------|
| `workflow` | 工作流模式 | OpenMOSS cycle、审批流 |
| `decision` | 决策规则 | star > 5000 → 深入分析 |
| `research` | 调研模式 | GitHub 搜索、README 分析 |
| `memory` | 记忆管理 | 何时写 MEMORY.md |
| `security` | 安全规则 | 不暴露 API keys |
| `token` | Token 经济 | 窗口消耗追踪 |
| `pattern` | 架构模式 | Verification-First |

---

## 置信度标准

| 分值 | 含义 | 行动 |
|------|------|------|
| 0.3 | 试探性 | 建议但不强制的 |
| 0.5 | 中等 | 相关时应用 |
| 0.7 | 强 | 自动批准应用 |
| 0.9 | 几乎确定 | 核心行为 |

**置信度变化规则**：
- ↑ 重复成功执行
- ↓ 用户纠正或失败

---

## 从 barbaric-growth 提炼 instinct

**例：从 Cycle 2 提炼**

```yaml
---
id: github-star-threshold
trigger: "发现新的 GitHub 项目时"
domain: research
confidence: 0.8
scope: global
source: "2026-04-18 Cycle 1-2 验证"
evidence_count: 8
last_verified: "2026-04-18"
---

## 行为

| Stars | 行动 |
|-------|------|
| > 10,000 | 立即深入分析，记录到 deep-dives/ |
| > 1,000 | 标准分析 + curate to ByteRover |
| > 100 | 快速扫描，有趣则记录 |
| < 100 | 跳过，除非极创新概念 |

## 证据
- MemPalace (47k) → 深入分析 ✓
- prax-agent (50) → 标准分析 ✓
- BuilderPulse (900) → 标准分析 ✓
- 0 stars 项目 → 大多数无价值

## 例外
- 明确创新概念（weft, LLM Wiki skills）即使 <100 stars 也分析
```

---

## Evidence 日志格式

```markdown
# Instinct Evidence Log

## 2026-04-18

### github-star-threshold
- 15:28 BuilderPulse (900 stars) → 标准分析 ✓
- 15:34 prax-agent (50 stars) → 标准分析 ✓
- 15:40 0 stars 项目 → 跳过 ✓

### openmoss-verify-before-submit
- 15:22 Task 584e4166 → verify 后 submit ✓
- 15:03 Task 28f29159 → 未 verify，review 前手动确认 ✓
```

---

## 自进化流程（参考 ARIS）

```
1. Observation（观察）
   ↓ barbaric-growth cycle 执行
2. Log Evidence（日志）
   ↓ 每次成功决策记录到 instinct-evidence.md
3. Extract Instinct（提炼）
   ↓ 周期性地从 evidence 提炼 instinct
4. Review（审核）
   ↓ 用户或另一个模型审核
5. Apply（应用）
   ↓ 存入 instincts/global/
6. Promote（提升）
   ↓ 如果在多个场景成功 → 提升置信度
```

---

## 和 MEMORY.md 的关系

| 文件 | 内容 | 更新频率 |
|------|------|----------|
| `MEMORY.md` | 长期记忆、关键决策 | 重要变化时 |
| `instincts/` | 行为模式、置信度 | 每次 cycle 后 |
| `instinct-evidence.md` | 原始观察日志 | 每次决策时 |

---

## 下一步

- [ ] 在下次 barbaric-growth cycle 时应用这个格式
- [ ] 从今天 2 个 cycle 里提炼 3-5 个 instinct
- [ ] 设计 evidence 自动记录机制
