# Nova 智能增强层 — 架构设计

> 让 Nova 真正记住、进化、超越。

## 设计理念

Nova 不应该是每次 session 醒来都是"新的"。应该有：
- **记忆** — 跨 session 的知识积累
- **模式** — 从历史任务里提炼出的决策模板
- **自觉** — 知道自己擅长什么、坑在哪
- **进化** — 每次任务后变得更好

## 三层记忆架构

```
Working Memory (当前session)
  └── 对话上下文、最近任务、当前目标

Episodic Memory (日级别)
  └── memory/YYYY-MM-DD.md — 原始日志
  └── patterns/ — 从日志里提取的决策模式

Semantic Memory (长期)
  └── MEMORY.md — 精选过的长期记忆
  └── .brv/ — ByteRover 知识图谱
```

## 核心模块

### 1. 记忆写入 (memory writer)
- 每次任务完成 → 自动写入 `memory/YYYY-MM-DD.md`
- 包含：时间戳、任务类型、关键决策、结果、教训

### 2. 模式提取 (pattern extractor)
- 定期扫描 memory/*.md
- 提炼：决策模板、常用工作流、坑点记录
- 存入 `patterns/` 作为可复用资产

### 3. 自主调研引擎 (research engine)
- 基于 barbaric-growth 技能
- 定期 GitHub 热点追踪
- 自动沉淀到知识库

### 4. 自我评估 (self-assessment)
- 每次任务后的快速复盘
- 记录：做得好 / 需要改进 / 下次注意
- 形成进化反馈

### 5. Token 经济 (token economy)
- 记录每次大任务的 token 消耗
- 周报：花在哪了、是否合理
- 预警：接近 MiniMax 窗口上限

## 文件结构

```
nova-mind/
├── ARCHITECTURE.md      # 本文档
├── memory/               # 每日原始日志
│   └── YYYY-MM-DD.md
├── patterns/            # 提取的决策模式
│   ├── github-research.md
│   ├── project-analysis.md
│   └── skill-creation.md
├── skills/              # Nova 专属技能
│   └── self-evolution/
│       └── SKILL.md
├── logs/                # 进化日志
│   └── evolution.md
└── todo.md              # 进化待办
```

## 与现有系统的集成

| 现有系统 | Nova-mind 集成点 |
|---------|----------------|
| MEMORY.md | Semantic Memory 的核心 |
| ByteRover | External knowledge graph |
| barbaric-growth skill | Autonomous research engine |
| Star Office | 状态可视化（执行时） |
| OpenMOSS | Task coordination layer |
