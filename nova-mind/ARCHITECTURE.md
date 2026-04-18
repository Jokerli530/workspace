# Nova 智能增强层 — 架构设计 v1.1

> 让 Nova 真正记住、进化、超越。
>
> **v1.1 对齐 GoClaw 3-Tier Memory Architecture**

---

## 三层记忆架构（对齐 GoClaw）

```
┌─────────────────────────────────────────────────────────┐
│  L0: Working Memory (工作记忆)                           │
│  ─────────────────────────────────────────────────────  │
│  内容: 当前 session 的对话上下文、正在执行的任务、        │
│        最近的工具调用结果、当前目标                      │
│  存储: session 内存，session 结束时决定保留或丢弃        │
│  淘汰: HEARTBEAT_OK 后认为不重要的直接丢弃               │
│  保留: 重要的→写入 L1 / L2                               │
└─────────────────────────────────────────────────────────┘
                          ↓ 升级
┌─────────────────────────────────────────────────────────┐
│  L1: Episodic Memory (情景记忆)                         │
│  ─────────────────────────────────────────────────────  │
│  内容: 任务日志、关键决策点、失败记录、教训              │
│  存储: memory/YYYY-MM-DD.md (原始日志)                  │
│  触发: 任务完成 / 重大发现 / HEARTBEAT  flush           │
│  特点: 按时间索引，可扫描、可提炼                         │
└─────────────────────────────────────────────────────────┘
                          ↓ 提炼
┌─────────────────────────────────────────────────────────┐
│  L2: Semantic Memory (语义记忆)                           │
│  ─────────────────────────────────────────────────────  │
│  内容: patterns/ (决策模板)、坑点库、长期偏好、          │
│        ByteRover 知识图谱、MEMORY.md                     │
│  存储: patterns/*.md + MEMORY.md + .brv/               │
│  触发: patterns/ 从 L1 定期提炼；ByteRover 人工沉淀      │
│  特点: 可被快速检索，不需要完整回顾 L1                   │
└─────────────────────────────────────────────────────────┘
```

### L0 → L1 → L2 流动规则

| 触发条件 | 流动方向 |
|---------|---------|
| 任务完成 + 有价值 | L0 → L1 |
| 多次相同失败 | L1 pattern → L2 |
| ByteRover curate 通过 | L1 → L2 (knowledge) |
| HEARTBEAT flush | L0 → L1 (按需) |
| MEMORY.md 更新 | L2 内部沉淀 |

---

## 核心模块

### 1. 记忆写入 (L0 → L1)
- 每次任务完成 → 自动写入 `memory/YYYY-MM-DD.md`
- 包含：时间戳、任务类型、关键决策、结果、教训
- **格式固定**：`## 事件时间 | 事件类型 | 摘要 | 教训`

### 2. 模式提取 (L1 → L2 pattern)
- 定期扫描 `memory/*.md`
- 提炼：决策模板、常用工作流、坑点记录
- **触发条件**：同一类决策出现 3 次以上 → 自动生成 pattern
- 存入 `patterns/` 作为可复用资产

### 3. 自我评估 (Self-Assessment)
- 每次任务后的快速复盘
- 记录：做得好 / 需要改进 / 下次注意
- 形成进化反馈 → 写入 L1

### 4. Token 经济 (Token Economy)
- 记录每次大任务的 token 消耗
- **断路器**：窗口 > 80% 警告，> 95% 停止
- 存入 `~/.openclaw/token-state.json`

---

## 自主进化循环（对齐 GoClaw Self-Evolution）

```
任务执行 → 评估结果 → 记录指标 → 分析建议 → 验证应用 → 回滚保护
```

### Evolution Guardrails（来自 GoClaw）

| 参数 | 值 | 说明 |
|------|-----|------|
| `max_delta_per_cycle` | 0.1 | 每次进化参数变化不超过 10% |
| `min_data_points` | 3 | 至少 3 次数据点才启动进化 |
| `rollback_on_drop_pct` | 20% | 质量下降超过 20% 自动回滚 |
| `locked_params` | model, provider | 这两个参数不允许自动改 |

### 进化阶段

1. **指标收集**：记录每次任务成功率、Token 消耗、错误类型
2. **建议分析**：从 patterns/ 里找重复失败的模式
3. **验证应用**：小范围测试，确认有效才推广
4. **回滚保护**：质量下降立即回退到上一个稳定版本

---

## barbaric-growth 流程（对照 GoClaw Pipeline）

```
1. GitHub API (ToolStage)      → 执行搜索命令
2. 深度分析 (ThinkStage)      → 评估每个项目价值
3. ByteRover curate (ObserveStage) → 提交知识
4. Verify (CheckpointStage)    → 确认提交成功
5. OpenMOSS 日志 (FinalizeStage) → 记录任务完成
6. Token 更新 (MemoryStage)    → 更新 token-state.json
```

---

## ByteRover 集成（知识沉淀）

- L1 有价值的内容 → ByteRover curate
- curate 通过 → 进入 .brv/ 知识图谱（L2）
- 检索优先级：.brv/ (L2) > patterns/ (L2) > memory/ (L1)

---

## 与 GoClaw 3-Tier Memory 对照

| GoClaw | Nova | 状态 |
|--------|------|------|
| Working Memory | L0: 对话上下文 | ✅ 已实现 |
| Episodic (session summaries) | L1: memory/YYYY-MM-DD | ✅ 已实现 |
| Semantic (KG + vector) | L2: MEMORY.md + .brv/ | 🟡 部分实现 |
| Memory consolidation worker | 定期提炼 pattern | 🟡 待加强 |
| Evolution Guardrails | self-evolution skill | 🟡 待加强 |
| 8-stage pipeline | barbaric-growth | 🟡 部分实现 |

---

## 核心原则

1. **L0 是临时的** — session 结束就清，不可惜
2. **L1 是原始数据** — 不删，积累越多 L2 越准
3. **L2 是精选的** — 只有真正反复用到的才进去
4. **进化有 guardrails** — 不能让 Nova 自由发挥到跑偏
5. **先验证再推广** — 任何改变小范围测试
