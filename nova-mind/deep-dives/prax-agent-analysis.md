# Deep Dive: prax-agent — Test-Verify-Fix Loop 生产级实现

**Stars**: 50（快速增长中）| **MIT** | **Python 3.10+**

---

## 核心发现

### 1. Verification-First Architecture（核心差异化）

```
Prax: Test → Verify → Fix → Test (loop)
         ↑
Most tools: Prompt → Hope → Done
```

**Prax 的核心洞察**：大多数工具发一个 prompt 然后祈祷成功。Prax 是：
1. 执行测试
2. 分析失败
3. 编辑代码
4. 重新运行
5. 直到测试通过

**Verification layer 是一等的（first-class）**，不是 afterthought。

---

### 2. Benchmark 结果

| Metric | Prax | Framework Baseline | 改进 |
|--------|-------|-------------------|------|
| Success Rate | **10/10 (100%)** | 8/10 (80%) | **+25%** |
| Average Time | **29.56s** | 58.44s | **-49%** |
| Timeouts | **0** | 2 | **-100%** |

驱动因素：
- Verification-First Architecture
- Quality Gate Middleware（循环检测 + 收敛指导）
- Smart Sandbox Downgrade（验证命令绕过沙箱开销）

---

### 3. 核心 Agents

```
Ralph (Planner) — 任务分解
Sisyphus (Executor) — 执行修复
Team (Parallel) — 并行执行
```

这和 OpenMOSS 的 Planner/Executor/Reviewer 架构高度相似！

---

### 4. Middleware Pipeline

```
core/middleware.py:
├── LoopDetection — 检测死循环
├── QualityGate — 质量门禁
├── VerificationGuidance — 验证指导
└── CircuitBreaker — 熔断器（25 iter max）
```

**Circuit Breaker** 是关键：防止无限循环。

---

### 5. 25+ Built-in Tools

- `VerifyCommand` — 运行 pytest/npm test/cargo test/go test
- `SandboxBash` — 自动降级，验证命令绕过沙箱
- `Read/Edit/Write` — 文件操作
- 等等

---

### 6. Pluggable Memory

```
memory/backends/:
├── JSON (零配置)
├── SQLite (全文搜索)
└── OpenViking (向量嵌入)
```

---

### 7. Multi-Model Routing

```yaml
providers:
  anthropic:
    models: [claude-sonnet-4-6, ...]
  openai:
    models: [gpt-4.1, ...]

routing:
  fallback_chains: [claude → gpt-4.1 → glu]
```

---

### 8. Security Permission Modes

| Mode | 允许范围 |
|------|----------|
| `read-only` | 只读，无文件写入，无 shell |
| `workspace-write` | 项目内文件修改（默认）|
| `danger-full-access` | 无限制 |

---

## 对 Nova 的直接价值

### barbaric-growth 的验证闭环

```
ECC:  Hook观察 → Instinct → Evolve → Skill
prax-agent: Test → Verify → Fix → Pass (loop)
ARIS: 日志 → 分析 → Patch → Review → Apply
```

**barbaric-growth 应该借鉴 prax-agent 的 Verification-First 原则**：
- 不只是"做完任务"，要验证"做对了"
- OpenMOSS 的 cycle 就是天然的 test-verify-fix loop

### Circuit Breaker（熔断器）

**25 iter max** — 防止死循环的机制。

Nova 需要类似机制：当某个任务超过 N 次尝试还没完成，主动停止并报告。

### Middleware Pipeline

```
LoopDetection + QualityGate + CircuitBreaker
```

这比 OpenMOSS 的 simple cycle 更robust。

---

## OpenMOSS vs prax-agent

| 维度 | OpenMOSS | prax-agent |
|------|----------|------------|
| 架构 | Task → SubTask → Complete | Test → Verify → Fix → Pass |
| 角色 | Planner/Executor/Reviewer | Ralph/Sisyphus/Team |
| 验证 | 手动审核 | 自动验证命令 |
| 适用 | 通用任务 | 代码修复任务 |
| 循环检测 | 无 | LoopDetection + CircuitBreaker |
| 记忆 | MEMORY.md | JSON/SQLite/OpenViking |

**两者结合**：OpenMOSS 的角色协作 + prax-agent 的验证机制

---

## 行动项

### 本周
- [ ] 在 barbaric-growth 里加 Verification-First 原则
- [ ] 设计 Nova 版本的 Circuit Breaker（防止死循环）

### 本月
- [ ] OpenMOSS cycle 增强：加循环检测和质量门禁
- [ ] prax-agent 的 Claude Code 集成方式研究

---

## 引用

- Repo: https://github.com/ChanningLua/prax-agent
- License: MIT
- 50 stars（快速增长）
- Benchmark: 10/10 @ 29.56s avg
