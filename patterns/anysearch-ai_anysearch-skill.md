# Pattern: anysearch-ai/anysearch-skill

## 元信息
- repo: anysearch-ai/anysearch-skill
- stars: 2643
- language: Python
- discovered: 2026-06-07
- pattern_id: 20260607211028
- content_source: llm

## 特征
- description: Unified real-time search engine skill for AI agents.

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
- updated: 2026-06-07

## 深度分析（LLM 提炼）

## 核心定位
AnySearch Skill 是一个为 AI 智能体提供统一实时搜索能力的技能包，支持通用网页搜索、垂直领域搜索、并行批量搜索和全文内容提取，解决智能体在多种运行时环境下获取实时信息的需求。

## 技术栈
- Python 3.6+（推荐，需 requests 库）
- Node.js 12+（备选，无外部依赖）
- Shell（Bash / PowerShell 5.1+，兜底方案）
- 外部 API：AnySearch API（可选，但推荐使用 API Key 以获得更高配额）

## 独特机制
1. **多运行时自适应**：同一技能包同时提供 Python、Node.js、Shell 三种 CLI 实现，安装后通过 `doc` 命令自动探测并推荐最优运行时，写入 `runtime.conf` 持久化，后续调用直接使用缓存命令，避免重复探测。
2. **技能市场即装即用**：设计为可直接从智能体平台的技能市场安装，也支持手动下载解压到标准技能目录（如 `~/.agents/skills/`），与 Claude Code、Cursor、OpenClaw 等工具共享同一技能目录，实现跨平台复用。
3. **统一搜索抽象层**：将通用搜索、垂直搜索、批量搜索、全文提取封装为统一的 CLI 接口（`search`、`batch_search`、`fetch`），智能体只需调用标准命令即可获得结构化结果，无需关心底层搜索引擎差异。
4. **作者生态定位**：与 `anysearch-ai/anysearch-mcp-server`（1047★）同属 AnySearch 生态，MCP Server 提供 MCP 协议接入，本 Skill 提供直接 CLI 接入，两者互补，覆盖不同集成场景。

## 与 OpenClaw 集成可能
**可行，切入点明确**。OpenClaw 的 agent 技能目录 `~/.agents/skills/` 已被项目明确列为共享安装位置。集成步骤：
1. 将 anysearch-skill 解压到 `~/.agents/skills/anysearch`。
2. 配置 `ANYSEARCH_API_KEY` 环境变量。
3. 运行 `doc` 命令自动探测运行时并生成 `runtime.conf`。
4. OpenClaw agent 读取 `runtime.conf` 后，直接调用 `python3 <skill_dir>/scripts/anysearch_cli.py search "query" --max_results 5` 即可获取实时搜索结果。

## 值得深入的点
1. **运行时探测与持久化机制**：通过 `doc` 命令 + `runtime.conf` 实现运行时自适应，避免了每次调用都重新探测的开销。这种“安装时探测、运行时缓存”的模式对 Nova agent 的插件/技能加载流程设计有参考价值，尤其是需要支持多种执行环境（本地 Python、云端 Node、容器化 Shell）的场景。
2. **统一 CLI 接口设计**：将搜索、批量搜索、内容提取抽象为 `search`、`batch_search`、`fetch` 三个命令，参数风格一致（`--max_results`、`--queries` JSON 格式），智能体只需学会一套接口即可完成多种搜索任务。这种“技能即 CLI”的设计思路，比直接调用 API 更易于 agent 理解和复用。
3. **跨平台技能目录共享**：项目明确将 `~/.agents/skills/` 定位为多个 AI 工具（Codex、Cursor、OpenClaw）的共享技能目录，这种“一次安装，多处使用”的模式，为 Nova agent 的技能分发和跨平台兼容提供了可借鉴的实践。

_extracted_by: deepseek-chat · 2026-06-07 21:10_
