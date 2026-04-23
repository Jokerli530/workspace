# Pattern: Human-Agent-Society/CORAL

## 元信息
- repo: Human-Agent-Society/CORAL
- stars: 514
- language: Python
- discovered: 2026-04-23
- pattern_id: 20260423121006
- content_source: llm

## 特征
- description: CORAL is a robust, lightweight infrastructure for multi-agent autonomous self-ev

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库

## 同语言Sibling项目
  - EbookFoundation/free-programming-books
  - NousResearch/hermes-agent-self-evolution
  - NousResearch/hermes-agent
  - PKU-YuanGroup/Helios
  - TauricResearch/TradingAgents
  - ag-ui-protocol/ag-ui
  - bytedance/deer-flow
  - crewAIInc/crewAI
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
一个用于多智能体自主自我演化的轻量级基础设施，通过为智能体提供隔离的工作空间、安全评估、持久化共享知识和多智能体协作，实现给定代码库和评分脚本下的自动化研究与持续改进。

## 技术栈
*   Python 3.11+
*   uv (包管理器)
*   支持的智能体运行时：Claude Code、Codex、OpenCode

## 独特机制
1.  **基于 Git Worktree 的隔离与实时共享**：每个智能体运行在独立的 Git worktree 分支中，实现环境隔离；同时通过符号链接将共享状态（`.coral/public/`）实时同步到所有工作树，实现零开销的知识共享。
2.  **管理器驱动的协调与中断**：一个中央管理器监控智能体的“尝试”，并能通过心跳机制触发提示（如“反思”、“整合技能”）来中断和引导智能体，实现有组织的协作而非完全放任。
3.  **面向“自动化研究”的流程设计**：明确以“给定代码库和评分脚本”为输入，输出持续改进的解决方案，流程内置“研究阶段”（如文献回顾），定位更偏向系统性的实验与发现，而非简单的代码生成。

## 与 OpenClaw 集成可能
最顺的切入点是将其作为 OpenClaw 生态中一个**专用的、可复用的多智能体研究子模块**。OpenClaw 可以调用 CORAL 的基础设施来管理一组编码智能体，针对特定复杂任务（如工具发现、策略优化）进行并行的、有状态的自我演化实验，并利用其共享知识机制加速收敛。

## 值得深入的点
1.  **符号链接共享状态机制**：`.coral/public/` 目录通过符号链接实现跨隔离工作空间的实时、零复制数据同步，这是一种在保证进程隔离前提下实现高效、低延迟协作的工程实践。
2.  **管理器的心跳中断与引导策略**：管理器并非被动监控，而是能主动向智能体发送结构化提示（如触发反思），这种“受控自治”的协调机制对设计稳定、可导向的多智能体系统有参考价值。
3.  **以“尝试”为核心的工作流抽象**：将智能体的每次代码执行视为一个“尝试”，并由管理器统一评估和归档，这种抽象便于追踪演化过程、比较不同版本，并可能支持更复杂的进化算法。

_extracted_by: deepseek-chat · 2026-04-23 12:10_
