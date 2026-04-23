# Pattern: Ed1s0nZ/CyberStrikeAI

## 元信息
- repo: Ed1s0nZ/CyberStrikeAI
- stars: 3427
- language: Go
- discovered: 2026-04-23
- pattern_id: 20260423110731
- content_source: llm

## 特征
- description: CyberStrikeAI is an AI-native security testing platform built in Go. It integrat

## 调研要点（Go）
- 并发模型（goroutine/channel）
- 接口设计（duck typing）
- 错误处理模式

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-23

## 深度分析（LLM 提炼）

## 核心定位
一个用 Go 语言构建的、原生集成 MCP 协议和 AI 代理的自动化安全测试平台，旨在通过对话式指令实现从漏洞发现、攻击链分析到结果可视化的端到端安全测试流程。

## 技术栈
*   Go (主要编程语言)
*   OpenAI 兼容模型 (GPT, Claude, DeepSeek 等)
*   MCP (Model Context Protocol) 协议
*   SQLite (数据持久化)
*   CloudWeGo Eino (多智能体框架)

## 独特机制
1.  **原生 MCP 协议集成与联邦**：不仅实现了 MCP 的 HTTP/stdio/SSE 等多种传输方式，还支持与外部 MCP 服务器联邦，为核心 AI 引擎提供了强大的、标准化的工具扩展与上下文管理能力。
2.  **基于 CloudWeGo Eino 框架重构的多智能体编排**：在单智能体 ReAct 循环之外，提供了深度（coordinator + task agents）、计划执行（planner/executor/replanner）、监督（supervisor）三种多智能体编排模式，可通过请求参数动态选择，实现了更复杂的任务分解与协作。
3.  **为多智能体设计的渐进式技能（Skills）系统**：技能包遵循特定布局，在多智能体会话中通过 Eino ADK 的 `skill` 工具按需加载（渐进式披露），并可选集成主机文件系统/Shell访问，增强了工具的模块化与动态调用能力。
4.  **在作者生态中的定位**：此项目是作者安全 AI 化探索的集大成者。相较于其之前的单点工具（如免杀平台 `cool`、越权检测 `PrivHunterAI`），CyberStrikeAI 定位为一个统一的、平台化的“AI原生安全测试操作系统”，整合了工具链、智能体、知识库和协作界面。

## 与 OpenClaw 集成可能
最顺的切入点是其**原生支持的 MCP 协议**。OpenClaw 可以将其视为一个功能强大的外部 MCP 服务器进行联邦，直接利用其内建的 100+ 安全工具、知识库检索以及多智能体编排能力，作为 OpenClaw 生态中专门负责安全测试的“工具子域”。

## 值得深入的点
1.  **多智能体编排模式的请求级切换机制**：通过单个 API 请求参数（`orchestration`）动态在 deep、plan_execute、supervisor 等不同多智能体架构间切换，这种设计为研究不同任务类型下智能体组织形式的有效性提供了灵活的实验接口。
2.  **基于 Eino ADK 的渐进式技能加载**：技能不是一次性全部暴露给智能体，而是通过 `skill` 工具按名称动态加载。这种“渐进式披露”机制能有效管理智能体的工具使用范围，防止干扰，对构建具有复杂工具集的实用型智能体有重要参考价值。
3.  **攻击链图谱与可重放的风险步骤**：平台能够将漏洞发现过程构建成可视化的攻击链图并进行风险评分，同时支持步骤回放。这对研究 AI 智能体的决策过程可解释性、以及将安全测试过程转化为可审计、可复现的知识具有启发意义。

_extracted_by: deepseek-chat · 2026-04-23 11:08_
