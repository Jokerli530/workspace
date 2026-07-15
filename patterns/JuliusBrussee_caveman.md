# Pattern: JuliusBrussee/caveman

## 元信息
- repo: JuliusBrussee/caveman
- stars: 44155
- language: Python
- discovered: 2026-04-23
- pattern_id: 20260423211237
- content_source: llm

## 特征
- description: 🪨 why use many token when few token do trick — Claude Code skill that cuts 65% o

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库

## 同语言Sibling项目
  - ComposioHQ/awesome-claude-skills
  - EbookFoundation/free-programming-books
  - Human-Agent-Society/CORAL
  - NousResearch/hermes-agent-self-evolution
  - NousResearch/hermes-agent
  - PKU-YuanGroup/Helios
  - TauricResearch/TradingAgents
  - ag-ui-protocol/ag-ui
  - bytedance/deer-flow
  - crewAIInc/crewAI
  - infiniflow/ragflow
  - khoj-ai/khoj
  - microsoft/MInference
  - muratcankoylan/Agent-Skills-for-Context-Engineering
  - sansan0/TrendRadar
  - ymcui/Chinese-LLaMA-Alpaca-2
  - zhayujie/CowAgent

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-23

## 深度分析（LLM 提炼）

## 核心定位
Caveman 是一个 Claude Code 技能/插件，通过强制 AI 助手使用“穴居人式”精简语言输出，在保持技术准确性的前提下，削减约 75% 的输出 Token 消耗，解决 LLM 对话中冗长、低效的“废话”问题。

## 技术栈
- **运行时**: Node.js (npx 安装)
- **依赖**: 无外部依赖，纯 Prompt 工程 + 插件钩子
- **集成目标**: Claude Code, Codex, Gemini CLI, Cursor, Windsurf, Cline, Copilot
- **作者生态**: 与 `cavemem`（跨 Agent 持久记忆）、`cavekit`（自然语言转蓝图）构成“Caveman 生态”，本项目是语言精简核心。

## 独特机制
1. **多级压缩粒度**: 提供 Lite（轻量精简）、Full（穴居人）、Ultra（极端压缩）、文言文四种模式，用户可按需选择压缩强度，而非一刀切。
2. **输入/输出双向压缩**: 不仅压缩输出（-75%），还提供 `caveman-compress` 工具压缩输入 Token（-46%），实现全链路 Token 节省。
3. **跨 Agent 统一安装**: 通过 `npx skills add` 一行命令即可安装到 8 种主流编码 Agent，且自动激活机制因 Agent 而异（SessionStart 钩子、hooks.json、context 文件），适配性强。
4. **作者生态定位**: 作为 Caveman 生态的“语言层”，与 `cavemem`（记忆层）、`cavekit`（构建层）形成“少说-记住-建好”的完整 Agent 工作流。

## 与 OpenClaw 集成可能
**可行，切入点明确**：将 Caveman 的压缩 Prompt 模板（如 `caveman-compress` 的输入压缩逻辑）封装为 OpenClaw 的一个 **Token 优化插件**。具体地：
- 在 OpenClaw 的 Agent 调用链中，插入一个“输出精简中间件”，对 LLM 返回的文本应用 Caveman 的压缩规则（如去除客套话、合并短句、使用符号替代连接词）。
- 利用其多级模式，让 OpenClaw 用户可配置 Agent 的“话痨程度”。
- 注意：Caveman 的自动激活依赖特定 Agent 的钩子系统，OpenClaw 需自行实现类似的 SessionStart 钩子或上下文注入。

## 值得深入的点
1. **压缩规则的可迁移性**: Caveman 的核心不是模型微调，而是一套精心设计的 Prompt 规则（如“用符号 `→` 替代因果连接词”、“省略冠词和系动词”）。这种规则化压缩方法对 Nova 的 Agent 研究极具启发——可以通过 Prompt 工程而非模型改动，实现 Token 效率的显著提升。
2. **文言文模式的语言多样性**: 支持文言文作为压缩模式之一，表明压缩策略可以跨语言、跨文化风格。这提示 Nova 的 Agent 可以针对不同用户群体（如非英语母语者、特定领域专家）定制输出风格，而不仅仅是“更短”。
3. **输入压缩的对称设计**: `caveman-compress` 对用户输入也进行压缩，形成“输入精简→处理更快→输出更短”的正反馈循环。这种对称设计值得 Nova 借鉴，尤其是在处理长上下文任务时，可主动压缩用户输入中的冗余信息。

_extracted_by: deepseek-chat · 2026-04-23 21:12_
