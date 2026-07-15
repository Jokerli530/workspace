# Pattern: Fosowl/agenticSeek

## 元信息
- repo: Fosowl/agenticSeek
- stars: 26355
- language: Python
- discovered: 2026-05-16
- pattern_id: 20260516212621
- content_source: llm

## 特征
- description: Fully Local Manus AI. No APIs, No $200 monthly bills. Enjoy an autonomous agent

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
  - safishamsi/graphify
  - sansan0/TrendRadar
  - ymcui/Chinese-LLaMA-Alpaca-2
  - zhayujie/CowAgent

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-05-16

## 深度分析（LLM 提炼）

## 核心定位
AgenticSeek 是一个完全本地化、零 API 依赖的自主 AI 代理，作为 Manus AI 的开源替代品，能在用户硬件上自主执行网页浏览、代码编写和复杂任务规划，确保数据隐私。

## 技术栈
- Python 3.10.x
- Docker & Docker Compose（运行 SearxNG 搜索引擎和 Redis）
- Ollama / LM Studio / 自定义 LLM（本地推理模型）
- 可选：OpenAI、DeepSeek、OpenRouter、Together、Google、Anthropic API
- Redis（任务队列/状态管理）
- SearxNG（本地元搜索引擎）

## 独特机制
1. **全本地化多代理架构**：无需任何外部 API 密钥即可运行，通过 Docker 容器化部署 SearxNG 和 Redis，实现完全离线的网页搜索和任务编排，与 Manus AI 等依赖云 API 的方案形成根本区别。
2. **智能代理选择器**：用户输入任务后，系统自动判断并分配最合适的子代理（如浏览、编码、规划），无需手动指定工作流，类似“专家团队”自动分工。
3. **语音交互支持**：集成语音输入/输出功能，允许用户以自然语音对话方式操控代理，增强人机交互的科幻感（仍在开发中）。
4. **作者生态定位**：作者其他项目多为计算机视觉（单目 SLAM）、音频生成（GAN）和游戏引擎等底层技术，AgenticSeek 是其首个面向终端用户的自主代理产品，标志着从底层算法向完整 AI 应用层的跃迁。

## 与 OpenClaw 集成可能
**可行，切入点明确**：AgenticSeek 的 Docker 化服务（SearxNG、Redis）和本地 LLM 接口（Ollama/LM Studio）可直接作为 OpenClaw 的“本地工具执行层”。最顺的集成方式是：将 AgenticSeek 的智能代理选择器封装为 OpenClaw 的一个 Skill，使其能调用本地推理模型执行网页搜索、代码生成等任务，同时保持数据不出设备。其多代理调度逻辑也可作为 OpenClaw 工作流引擎的一个参考实现。

## 值得深入的点
1. **零 API 依赖下的多代理调度策略**：研究其如何在无云端 API 的情况下，通过本地模型（如 DeepSeek、Qwen）实现代理选择、任务分解和子代理协调，这对构建完全自主的本地 agent 有直接参考价值。
2. **Docker 容器化工具链的集成模式**：SearxNG（搜索）+ Redis（状态）+ 本地 LLM 的组合，展示了如何用轻量容器封装外部工具，使 agent 获得搜索、持久化等能力而不牺牲隐私，这种“工具即服务”的架构值得借鉴。
3. **语音交互与自主代理的融合设计**：虽然语音功能尚在开发，但其将语音作为主要交互通道的思路，为 agent 研究提供了“多模态输入”的实践案例，可探索如何将语音指令映射到复杂任务规划。

_extracted_by: deepseek-chat · 2026-05-16 21:26_
