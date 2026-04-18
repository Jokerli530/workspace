# Deep Dive: ARIS (Auto-Research-In-Sleep)

**Stars**: 6,943 | **零依赖纯 Markdown** | **明确支持 OpenClaw/MiniMax** | **v0.4.3 (2026-04-17)**

---

## 核心发现

### 1. Meta-Optimize — Outer-Loop 自进化

这是 Nova 最需要借鉴的核心机制。

```
日志记录 (.aris/meta/events.jsonl)
    ↓
Usage Pattern Analysis
  - 频率分析：哪些skill被调用最多？
  - 失败分析：哪些工具失败最多？
  - 收敛分析：平均多少轮达到阈值？
  ↓
Optimization Opportunities (ranked by impact)
    ↓
Patch Proposals (concrete diffs)
    ↓
Cross-Model Review (GPT-5.4 adversarial)
    ↓
User Approval → Apply
```

**和 ECC Instinct 的区别**:
- ECC Instinct: hook观察 → instinct → evolve → skill
- ARIS meta-optimize: 日志分析 → patch → reviewer批准 → 应用
- **ARIS 是 reviewer-gated，ECC 是自动 evolve**

**对 Nova 的意义**: Nova-Orbit 应该借鉴 ARIS 的 reviewer-gated 机制——自进化必须有外部审核，不能让 agent 自己随意改自己。

---

### 2. Research Wiki — 持久知识库

**4 种实体类型**:
| 实体 | 目录 | Node ID |
|------|------|---------|
| Paper | papers/ | paper:<slug> |
| Idea | ideas/ | idea:<id> |
| Experiment | experiments/ | exp:<id> |
| Claim | claims/ | claim:<id> |

**类型化关系** (graph/edges.jsonl):
```
extends → 建立于先前工作
contradicts → 与结果/声明不一致
addresses_gap → 针对已知领域缺口
inspired_by → 想法来源于此论文
tested_by → 在此实验中被测试
supports → 实验支持声明
invalidates → 实验否定声明
supersedes → 新工作取代旧工作
```

**Auto-generated**: 每个页面的 `## Connections` 部分是从 graph 自动生成的，不手动编辑。

**Query Pack**: 压缩摘要 (max 8000 chars)，供 /idea-creator 使用。

**失败的想法成为反重复记忆**: ARIS 从错误中学习。

---

### 3. Cross-Model Adversarial Review

```
Claude Code (executor) + Codex (reviewer)
```

**关键洞察**:
> "用单个模型 self-review 是 stochastic（可预测的噪声），用 cross-model review 是 adversarial（reviewer 主动探测 executor 没预料到的弱点）"

> "从 1→2 的增益最大，不是 2→4"

**互补风格**:
- Claude Code: fast, fluid execution
- Codex (GPT-5.4): slower but more deliberate and rigorous critique

**Nova 应该怎么做**: barbaric-growth 的调研结果，应该由另一个模型来审查，而不只是 Claude 自己审查自己。

---

### 4. 完整工作流链

```
Idea Discovery (/idea-discovery)
    ↓
Experiment Bridge (/experiment-bridge)
    ↓
Paper Writing (/paper-write)
    ↓
Auto Review Loop (/auto-review-loop)
    ↓
Rebuttal (/rebuttal) ← 3 safety gates
    ↓
Paper Slides (/paper-slides) + Poster (/paper-poster)
```

**3 个 Safety Gates for Rebuttal**:
- 🔒 No fabrication — 每条声明必须映射到 paper/review/用户确认
- 🔒 No overpromise — 每条承诺必须用户批准
- 🔒 Full coverage — 每条 review 意见都被追踪

---

### 5. Multi-Platform 支持

| Platform | Status |
|----------|--------|
| Claude Code | ✅ 原生 |
| Codex CLI | ✅ 完整 skill set |
| OpenClaw | ✅ 官方支持 |
| Cursor | ✅ |
| Trae | ✅ ByteDance AI IDE |
| Antigravity | ✅ Google agent-first IDE |
| Windsurf | ✅ |

**ARIS 官方说**: "ARIS is a methodology, not a platform."

---

### 6. 生产验证

| Paper | Score | Venue |
|-------|-------|-------|
| CS Paper | **8/10** "clear accept" | CS Conference |
| AAAI Paper | **7/10** "good paper, accept" | AAAI 2026 |
| UAV-CC | Under review | IEEE TGRS |

**Stack**: Claude Code + GPT-5.4 + Cursor

---

### 7. Feishu 集成

- **飞书集成**: ARIS 支持飞书/Lark
- **模式**: off / push / interactive
- **功能**: 手机通知实验状态、review 结果、checkpoint

**对 Nova 的意义**: OpenClaw 已经支持飞书，ARIS 也支持——飞书是成熟的多渠道人机协作方案。

---

### 8. 最新功能 (v0.4.x)

- **2026-04-17**: Third-party Anthropic-compat proxy support (Bedrock etc.)
- **2026-04-15**: Research Wiki + Self-Evolution (meta-optimize)
- **2026-04-10**: Experiment Audit — cross-model experiment integrity verification
- **2026-04-10**: Paper Claim Audit — zero-context paper-to-evidence verification
- **2026-04-05**: Meta-optimize — outer-loop harness optimization

---

## 对 Nova 的价值

### 直接可借鉴（最高优先级）

1. **Meta-Optimize 审核机制**
   - 日志分析 → patch → reviewer 审核 → apply
   - **Nova 应该用这个，而不是自动 evolve**
   - reviewer 可以是另一个模型（像 ARIS 的 GPT-5.4）

2. **Research Wiki 的知识关系模型**
   - paper/idea/experiment/claim 四种实体
   - 类型化关系 (edges.jsonl)
   - **Nova 的 patterns 库可以借鉴这个结构**

3. **Cross-Model Review 的 1+1>2 效果**
   - barbaric-growth 的调研结果需要另一个模型来审查
   - MiniMax 作为 executor，另一个模型作为 reviewer

4. **失败经验成为 anti-repetition memory**
   - 失败的想法被记录，防止重复失败
   - **Nova 的 self-assessment 可以包含"失败记录"**

### 中期可借鉴

5. **Query Pack 压缩摘要**
   - 8000 chars 上限
   - 供下次快速检索

6. **Feishu 通知集成**
   - ARIS 支持飞书通知
   - Nova 的 Star Office 可以借鉴

---

## 差距分析

| ARIS | Nova |
|------|------|
| ML 论文研究 | 通用 AI agent |
| Claude + Codex | MiniMax (已有) |
| Claude Code skills | OpenClaw skills |
| /meta-optimize (完整) | 无自进化 |
| Research Wiki (完整) | ByteRover (部分) |
| 飞书通知 | 飞书 channel (已有) |
| 零依赖 Markdown | 文件 + ByteRover |

---

## 行动项

### 本周
- [ ] 研究 ARIS 的 meta-optimize 审核流程，设计 Nova 版本
- [ ] 在 nova-mind 里设计 Research Wiki 的简化版本
- [ ] barbaric-growth 的结果用另一个模型 review

### 本月
- [ ] 实现 Nova 版本的 meta-optimize（日志分析 → patch → reviewer 审核）
- [ ] ByteRover 的 query/curate 流程优化
- [ ] 失败记录机制（anti-repetition memory）

---

## 关键文件

- Meta-optimize: `skills/meta-optimize/SKILL.md`
- Research Wiki: `skills/research-wiki/SKILL.md`
- OpenClaw Adaptation: `docs/OPENCLAW_ADAPTATION.md`
- MiniMax 配置: `docs/MiniMax-GLM-Configuration.md`

---

## 引用

- Repo: https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep
- v0.4.3: 2026-04-17
- Author: wanshuiyin
- 核心洞察: "ARIS is a methodology, not a platform"
