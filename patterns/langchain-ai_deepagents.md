# Pattern: langchain-ai/deepagents

## 元信息
- repo: langchain-ai/deepagents
- stars: 21857
- language: Python
- discovered: 2026-04-27
- pattern_id: 20260427211738
- content_source: llm

## 特征
- description: Agent harness built with LangChain and LangGraph. Equipped with a planning tool,

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库

## 同语言Sibling项目
  - 666ghj/MiroFish
  - ComposioHQ/awesome-claude-skills
  - EbookFoundation/free-programming-books
  - Human-Agent-Society/CORAL
  - JuliusBrussee/caveman
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
  - mem0ai/mem0
  - microsoft/MInference
  - muratcankoylan/Agent-Skills-for-Context-Engineering
  - sansan0/TrendRadar
  - ymcui/Chinese-LLaMA-Alpaca-2
  - zhayujie/CowAgent

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-27

## 深度分析（LLM 提炼）

## 核心定位
Deep Agents 是一个“开箱即用”的 Agent 框架，基于 LangChain 和 LangGraph 构建，内置了规划、文件系统、Shell 执行、子代理和上下文管理等全套工具，让开发者无需手动编排提示词、工具和上下文即可快速获得一个可运行的编码助手。

## 技术栈
- **Python**（运行时）
- **LangChain**（Agent 工程平台）
- **LangGraph**（基于图的 Agent 运行时，支持流式、持久化、检查点）
- **langchain-mcp-adapter**（MCP 协议支持）
- **CLI**（基于 TUI 的交互式终端界面）

## 独特机制
1. **“电池包含”式 Agent 设计**：与 MiroFish 的群体智能预测或 awesome-claude-skills 的 Claude 工作流目录不同，Deep Agents 直接提供一个完整的、可立即运行的 Agent，内置规划（`write_todos`）、文件系统、Shell 和子代理，无需用户从零搭建。
2. **LangGraph 原生集成**：Agent 本身就是一个编译好的 LangGraph 图，天然支持 LangGraph 的所有特性（流式、Studio、检查点、持久化），这使其在 LangChain 生态中成为“最上层的 Agent 实现层”。
3. **CLI 与 SDK 双模式**：提供交互式 TUI 终端（类似 Claude Code）和 Python SDK 两种使用方式，CLI 还支持无头模式用于脚本和 CI，覆盖从开发到部署的全场景。
4. **上下文自动管理**：当对话过长时自动摘要，大输出自动保存到文件，避免上下文窗口溢出——这是很多简单 Agent 框架忽略的实用细节。

在 LangChain 生态中，Deep Agents 是“Agent 工程平台”的顶层实现，LangChain 提供基础抽象，LangGraph 提供运行时，Deep Agents 提供开箱即用的 Agent 实例。

## 与 OpenClaw 集成可能
**可行，切入点清晰**。最顺的切入点是将其作为 OpenClaw 的“编码/文件操作子 Agent”或“工具执行器”。Deep Agents 内置的文件系统、Shell 执行和子代理能力，可以直接被 OpenClaw 的主 Agent 通过 `task` 工具调用，用于处理需要文件读写、代码执行或复杂规划的子任务。由于 Deep Agents 本身是 LangGraph 图，OpenClaw 也可以通过 LangGraph 的 checkpoint 和流式接口与之集成，实现状态共享和实时反馈。

## 值得深入的点
1. **`write_todos` 规划机制**：Agent 通过一个专门的工具来分解任务并跟踪进度，这种“规划即工具”的模式比隐式规划更可控，值得研究如何将其融入 Nova 的 agent 研究中的任务分解策略。
2. **子代理的隔离上下文**：`task` 工具允许创建具有独立上下文窗口的子代理，这为 Nova 的 agent 研究提供了“上下文隔离”的参考实现——如何在不污染主上下文的情况下并行处理多个子任务。
3. **上下文自动摘要与文件回退**：当对话过长时自动摘要，大输出自动保存到文件，这种“分级上下文管理”策略对 Nova 的 agent 研究中的长对话处理有直接启发，可以借鉴其触发条件和实现方式。

_extracted_by: deepseek-chat · 2026-04-27 21:17_
