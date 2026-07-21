# Pattern: Graphify-Labs/graphify

## 元信息
- repo: Graphify-Labs/graphify
- stars: 92333
- language: Python
- discovered: 2026-07-21
- pattern_id: 20260721091057
- content_source: llm

## 特征
- description: Turn any codebase, with its docs, SQL schemas, configs, and PDFs, into a queryab

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
  - NVIDIA/RULER
  - NVIDIA/TensorRT-LLM
  - NVIDIA/kvpress
  - NousResearch/hermes-agent-self-evolution
  - NousResearch/hermes-agent
  - OthmanAdi/planning-with-files
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
  - rednote-machine-learning/RedKnot
  - safishamsi/graphify
  - sansan0/TrendRadar
  - ymcui/Chinese-LLaMA-Alpaca-2
  - zhayujie/CowAgent

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-07-21

## 深度分析（LLM 提炼）

## 核心定位
Graphify 是一个将代码库（含文档、SQL、PDF 等）自动转化为可查询的知识图谱的工具，让开发者通过图遍历而非 grep 来理解项目结构。

## 技术栈
- Python（CLI 工具）
- tree-sitter AST（代码解析，纯本地、无 LLM）
- 无向量数据库、无嵌入模型
- 输出：graph.html（交互式力导向图）、GRAPH_REPORT.md、graph.json
- 支持 Claude Code、Cursor、Codex、Gemini CLI、GitHub Copilot 等 15+ AI 编码助手

## 独特机制
1. **代码解析零 LLM**：使用 tree-sitter AST 进行确定性解析，不依赖任何大模型，确保代码部分完全本地、可复现；仅文档/PDF/图片/视频等非代码内容才调用模型做语义理解。
2. **边带来源标签**：每条连接都标记为 `EXTRACTED`（源文件中显式存在）或 `INFERRED`（由 graphify 推断），让用户清晰区分“直接读取”与“推理得出”的关系。
3. **非向量索引的图结构**：不依赖嵌入和向量存储，构建的是真实可遍历的图。用户可提问、追踪两点间路径、或解释单一概念，而非语义相似度检索。
4. **一键集成 AI 助手**：通过 `/graphify` 命令直接在 AI 编码助手中触发，输出交互式 HTML 图、Markdown 报告和 JSON 数据，无需离开编辑器。

该项目是 Graphify Labs 的核心开源产品，其商业版本（graphify.com）提供持续后台更新和跨代码/文档/会议的全时图谱能力。

## 与 OpenClaw 集成可能
**可行，切入点明确**：将 Graphify 作为 OpenClaw agent 的“代码理解模块”。当 agent 需要理解一个陌生代码库的结构时，可调用 `graphify` CLI 生成知识图谱，然后通过解析 `graph.json` 或 `GRAPH_REPORT.md` 获取结构化概念关系，替代传统的文件遍历或 RAG 检索。这特别适合 agent 需要回答“X 和 Y 如何关联”或“某个功能的调用链路”的场景。

## 值得深入的点
1. **EXTRACTED vs INFERRED 边机制**：这种显式区分“直接证据”与“推理结果”的设计，对 agent 的推理可信度管理极有启发——agent 在回答时若能标注信息来源的确定性等级，可大幅提升用户信任。
2. **tree-sitter AST 零 LLM 解析策略**：在 agent 研究中，如何在不依赖大模型的情况下高效提取结构化信息是一个关键问题。Graphify 的做法展示了确定性解析与语义理解的合理分工边界。
3. **交互式图输出（graph.html）**：将知识图谱以可点击、可搜索的力导向图形式输出，而非纯文本或 JSON，为 agent 的结果呈现提供了新思路——用户可通过视觉交互探索 agent 的推理路径。

_extracted_by: deepseek-chat · 2026-07-21 09:11_
