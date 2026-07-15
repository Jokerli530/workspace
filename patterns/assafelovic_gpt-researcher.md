# Pattern: assafelovic/gpt-researcher

## 元信息
- repo: assafelovic/gpt-researcher
- stars: 26677
- language: Python
- discovered: 2026-04-25
- pattern_id: 20260425091536
- content_source: llm

## 特征
- description: An autonomous agent that conducts deep research on any data using any LLM provid

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
- updated: 2026-04-25

## 深度分析（LLM 提炼）

## 核心定位
GPT Researcher 是一个开源的深度研究智能体，能够针对任意任务，利用任何 LLM 自动进行网络和本地文档的深度研究，生成带有引用来源的详细、客观、事实性的研究报告。

## 技术栈
- **运行时**: Python 3.11+
- **LLM 框架**: 支持 OpenAI、Anthropic、Google Gemini 等多种 LLM
- **搜索工具**: Tavily API（默认）、可选集成 DuckDuckGo、Bing、Google 等
- **Web 爬取**: JavaScript 启用的网页抓取
- **文档处理**: 本地文档（PDF、Word 等）解析
- **前端**: 轻量版（HTML/CSS/JS）和生产版（NextJS + Tailwind）
- **部署**: Docker、PyPI 包、Google Colab
- **其他**: 支持 MCP 协议、可安装为 Claude Skill

## 独特机制
1. **规划-执行分离架构**: 采用“规划器”和“执行器”双智能体设计。规划器生成研究问题，执行器并行收集信息，最后发布器聚合为报告。这与传统单智能体顺序搜索不同，大幅提升速度和可靠性。
2. **多源聚合与引用追踪**: 自动聚合超过 20 个来源，对每个资源进行摘要和来源追踪，最终生成带有完整引用的报告，解决信息偏误和深度不足问题。
3. **AI 生成内联图像**: 使用 Google Gemini 在报告中智能生成和插入内联图像（称为“Nano Banana”），增强报告的可视化表达能力。
4. **作者生态定位**: 作者 assafelovic 还开发了 `gptr-mcp`（MCP 服务器，让 LLM 通过 MCP 协议进行深度研究）、`skyll`（自主技能学习工具）和 `tovana`（记忆管理系统）。GPT Researcher 是其生态的核心研究引擎，`gptr-mcp` 是其 MCP 接口层，`skyll` 和 `tovana` 则分别提供技能发现和记忆增强能力。

## 与 OpenClaw 集成可能
**切入点明确**：通过 `gptr-mcp` 项目提供的 MCP 服务器接口，OpenClaw 可以直接调用 GPT Researcher 的深度研究能力。OpenClaw 作为智能体框架，可通过 MCP 协议向 GPT Researcher 发送研究任务并获取结构化报告，将其作为 OpenClaw 的“研究工具”使用。此外，GPT Researcher 已支持安装为 Claude Skill，OpenClaw 可借鉴此模式，将其封装为 OpenClaw 的插件或技能模块。

## 值得深入的点
1. **规划-执行并行化机制**: 研究如何将复杂任务分解为可并行执行的子问题，以及如何协调多个执行智能体的结果。这对 Nova 设计多智能体协作架构有直接参考价值。
2. **来源追踪与引用生成**: 系统如何确保每个信息片段都有可追溯的来源，并在最终报告中自动生成引用。这对构建可验证、可信赖的 agent 输出至关重要。
3. **与 MCP 协议的集成模式**: 通过 `gptr-mcp` 项目，GPT Researcher 展示了如何将复杂能力封装为 MCP 服务供其他智能体调用。这种“能力即服务”的模式对 Nova 的模块化扩展设计有重要启发。

_extracted_by: deepseek-chat · 2026-04-25 09:15_
