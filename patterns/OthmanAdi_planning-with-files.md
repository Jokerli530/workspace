# Pattern: OthmanAdi/planning-with-files

## 元信息
- repo: OthmanAdi/planning-with-files
- stars: 23359
- language: Python
- discovered: 2026-06-15
- pattern_id: 20260615211418
- content_source: llm

## 特征
- description: Persistent file-based planning for AI coding agents and long-running agentic tas

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库

## 同语言Sibling项目
  - 666ghj/MiroFish
  - ComposioHQ/awesome-claude-skills
  - D4Vinci/Scrapling
  - ECNU-ICALK/AutoSkill
  - EbookFoundation/free-programming-books
  - Fosowl/agenticSeek
  - Human-Agent-Society/CORAL
  - JuliusBrussee/caveman
  - NVIDIA/TensorRT-LLM
  - NVIDIA/kvpress
  - NousResearch/hermes-agent-self-evolution
  - NousResearch/hermes-agent
  - PKU-YuanGroup/Helios
  - SandAI-org/MagiAttention
  - TauricResearch/TradingAgents
  - ag-ui-protocol/ag-ui
  - agentic-in/elephant-agent
  - anysearch-ai/anysearch-skill
  - assafelovic/gpt-researcher
  - bytedance/deer-flow
  - crewAIInc/crewAI
  - feifeibear/long-context-attention
  - hesreallyhim/awesome-claude-code
  - infiniflow/ragflow
  - khoj-ai/khoj
  - langchain-ai/deepagents
  - mem0ai/mem0
  - microsoft/MInference
  - muratcankoylan/Agent-Skills-for-Context-Engineering
  - neuml/txtai
  - public-apis/public-apis
  - safishamsi/graphify
  - sansan0/TrendRadar
  - ymcui/Chinese-LLaMA-Alpaca-2
  - zhayujie/CowAgent

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-06-15

## 深度分析（LLM 提炼）

## 核心定位
Planning-with-files 是一个基于文件的持久化规划技能（skill），通过维护 `task_plan.md`、`findings.md` 和 `progress.md` 三个磁盘文件，让 AI 编码 agent 在遭遇上下文丢失、`/clear` 命令或崩溃后仍能恢复任务状态，并可选地通过完成门控（completion gate）强制 agent 在计划真正完成前不继续执行。

## 技术栈
- 运行时：任何支持 SKILL.md 标准的 AI 编码 agent（60+ 种，包括 Claude Code、Codex 等）
- 核心机制：纯 Markdown 文件系统（`task_plan.md`、`findings.md`、`progress.md`）
- 依赖：无外部依赖，纯文件 I/O
- 测试：SkillCheck 验证、A/B 盲测（3/3 胜出）、基准测试（96.7% 通过率）
- 安全：经过安全审计和修复（v2.21.0）

## 独特机制
1. **文件即状态**：不同于大多数 agent 规划方案依赖内存或数据库，本项目将规划、发现和进度全部持久化到纯文本 Markdown 文件。这使得 agent 在 `/clear`、崩溃或上下文窗口溢出后，只需重新读取文件即可无缝恢复，无需重做任何工作。
2. **完成门控（Completion Gate）**：v3.0.0 引入的 opt-in 机制，在 agent 执行过程中设置一个“门”，只有当 `task_plan.md` 中的所有任务被标记为完成时，门才会打开，agent 才能继续下一步。这防止了 agent 在计划未完成时过早结束或跳步。
3. **SKILL.md 标准兼容**：项目遵循 SKILL.md 规范，使其能跨 60+ 种不同的 AI 编码 agent 安装和使用，包括 Claude Code、Codex、Copilot 等，实现了极高的可移植性。
4. **作者生态定位**：本项目是作者 OthmanAdi 生态中的旗舰项目（23k+ stars），其他项目如 `promptfusion`（三层提示组合系统）、`researchclaw-skill`（自主论文生成）和 `codebase-knowledge-builder`（代码库知识提取）都是围绕 agent 技能生态构建的补充工具，而 planning-with-files 是核心的持久化规划基础设施。

## 与 OpenClaw 集成可能
**可行，且已有先例**。README 中明确列出了 `openclaw-github-repo-commander` 这个 fork，它是一个基于 OpenClaw 的 7 阶段 GitHub 仓库审计、优化和清理工作流。最顺的切入点是：将 planning-with-files 的三个核心文件（`task_plan.md`、`findings.md`、`progress.md`）作为 OpenClaw agent 的默认规划持久化层，替换或补充 OpenClaw 现有的内存式规划。具体来说，可以在 OpenClaw 的 agent 初始化阶段注入 SKILL.md 指令，让 agent 在每次执行任务前检查并加载这些文件，执行后更新它们。

## 值得深入的点
1. **文件驱动的状态机模式**：本项目实际上实现了一个基于文件系统的有限状态机——`task_plan.md` 中的任务状态（如 `[ ]`、`[x]`、`[~]`）驱动 agent 的行为决策。这种模式对 Nova 的 agent 研究很有启发：如何用最轻量的持久化方式（纯文本文件）实现 agent 的长期记忆和状态恢复，而不引入复杂的数据库或序列化框架。
2. **完成门控的同步机制**：门控机制本质上

_extracted_by: deepseek-chat · 2026-06-15 21:14_
