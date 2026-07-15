# Pattern: safishamsi/graphify

## 元信息
- repo: safishamsi/graphify
- stars: 45611
- language: Python
- discovered: 2026-05-10
- pattern_id: 20260510092427
- content_source: llm

## 特征
- description: AI coding assistant skill (Claude Code, Codex, OpenCode, Cursor, Gemini CLI, and

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库

## 同语言Sibling项目
  - 666ghj/MiroFish
  - ComposioHQ/awesome-claude-skills
  - ECNU-ICALK/AutoSkill
  - EbookFoundation/free-programming-books
  - Human-Agent-Society/CORAL
  - JuliusBrussee/caveman
  - NVIDIA/TensorRT-LLM
  - NousResearch/hermes-agent-self-evolution
  - NousResearch/hermes-agent
  - PKU-YuanGroup/Helios
  - TauricResearch/TradingAgents
  - ag-ui-protocol/ag-ui
  - assafelovic/gpt-researcher
  - bytedance/deer-flow
  - crewAIInc/crewAI
  - hesreallyhim/awesome-claude-code
  - infiniflow/ragflow
  - khoj-ai/khoj
  - langchain-ai/deepagents
  - mem0ai/mem0
  - microsoft/MInference
  - muratcankoylan/Agent-Skills-for-Context-Engineering
  - neuml/txtai
  - public-apis/public-apis
  - sansan0/TrendRadar
  - ymcui/Chinese-LLaMA-Alpaca-2
  - zhayujie/CowAgent

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-05-10

## 深度分析（LLM 提炼）

## 核心定位
Graphify 是一个 AI 编程助手技能（Skill），通过在 Claude Code、Codex、Cursor 等主流 AI 编程助手中输入 `/graphify` 命令，将整个项目（代码、文档、PDF、图片、视频）自动映射为可查询的知识图谱，替代传统 grep 式的文件搜索。

## 技术栈
- Python 3.10+
- PyPI 包名：`graphifyy`（CLI 命令仍为 `graphify`）
- 安装工具：`uv`、`pipx`、`pip`
- 输出格式：HTML（交互式图谱）、Markdown（报告）、JSON（完整图谱数据）
- 支持平台：Claude Code、Codex、OpenCode、Cursor、Gemini CLI、GitHub Copilot CLI、VS Code Copilot Chat、Aider、OpenClaw、Factory Droid、Trae、Hermes、Kimi Code、Kiro、Pi、Google Antigravity

## 独特机制
1. **多模态知识图谱构建**：不仅处理代码和文档，还能解析 PDF、图片、视频等非结构化数据，将其统一映射为知识图谱节点和关系，远超传统代码索引工具。
2. **零配置一键式集成**：用户只需在任意支持的 AI 编程助手中输入 `/graphify .`，即可自动完成项目扫描、图谱构建和输出，无需手动配置解析规则或数据库。
3. **三文件输出范式**：输出固定为 `graph.html`（可交互浏览）、`GRAPH_REPORT.md`（关键概念与连接摘要）、`graph.json`（可重复查询的完整图谱），兼顾可视化、可读性和可编程性。
4. **跨平台 Skill 生态**：通过 `graphify install --platform <name>` 命令，可一键安装到 15+ 种主流 AI 编程助手，形成统一的“项目理解层”Skill。

在作者生态中，Graphify 是其核心项目（45611 stars），远高于其其他项目（如 `mycetoma-kg-rag` 26 stars），定位为通用 AI 编程助手知识图谱技能，而其他项目多聚焦于特定领域（如医学诊断、急救指导、知识图谱 RAG 系统）。

## 与 OpenClaw 集成可能
**可行，且已有直接支持**。README 明确列出 `graphify install --platform claw` 命令，可直接将 Graphify 安装为 OpenClaw 的 Skill。集成后，OpenClaw 用户可通过 `/graphify` 命令一键将项目映射为知识图谱，增强 OpenClaw 的项目理解和上下文感知能力。

## 值得深入的点
1. **多模态知识图谱的自动构建机制**：研究 Graphify 如何从代码、文档、PDF、图片、视频中提取实体和关系，并统一表示为知识图谱。这对 Nova 的 agent 研究如何让智能体自主理解复杂项目结构有直接启发。
2. **Skill 的跨平台标准化接口**：Graphify 定义了统一的 `/graphify` 命令和 `graphify install --platform <name>` 安装流程，使其能无缝嵌入 15+ 种 AI 编程助手。这种“Skill 即插件”的设计模式，为 Nova 的 agent 技能跨平台复用提供了参考架构。
3. **三文件输出范式的信息分层设计**：交互式 HTML、可读 Markdown、可编程 JSON 三种输出形式，分别满足不同使用场景（浏览、阅读、查询）。这种分层输出策略，可借鉴到 Nova agent 的结果呈现和知识持久化设计中。

_extracted_by: deepseek-chat · 2026-05-10 09:24_
