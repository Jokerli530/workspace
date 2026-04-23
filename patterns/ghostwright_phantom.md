# Pattern: ghostwright/phantom

## 元信息
- repo: ghostwright/phantom
- stars: 1359
- language: TypeScript
- discovered: 2026-04-23
- pattern_id: 20260423120938
- content_source: llm

## 特征
- description: An AI co-worker with its own computer. Self-evolving, persistent memory, MCP ser

## 调研要点（TypeScript）
- 框架选择（React/Vue/Node/Next.js）
- 类型系统使用（strict、泛型）
- 包管理（npm/pnpm/yarn）
- 与OpenClaw的集成点

## 同语言Sibling项目
  - Aas-ee/open-webSearch
  - CherryHQ/cherry-studio
  - CopilotKit/CopilotKit
  - cline/cline
  - danny-avila/LibreChat
  - freeCodeCamp/freeCodeCamp
  - getsentry/XcodeBuildMCP
  - google-gemini/gemini-cli
  - gsd-build/gsd-2
  - holaboss-ai/holaOS
  - kamranahmedse/developer-roadmap
  - langgenius/dify
  - lobehub/lobehub
  - n8n-io/n8n
  - openclaw/lobster
  - openclaw/openclaw
  - ruvnet/ruflo
  - upstash/context7

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-23

## 深度分析（LLM 提炼）

## 核心定位
一个拥有独立计算机、具备自我演进和持久化记忆的AI协工，通过赋予AI专属工作空间来解决传统AI代理会话状态易失、无法积累经验的问题。

## 技术栈
- **运行时/环境**: Docker, Node.js
- **核心框架/库**: TypeScript, MCP (Model Context Protocol) 服务器
- **关键依赖/服务**: ClickHouse, Vigil, 多种通信渠道（Slack, Telegram, Email, Webhook）
- **模型支持**: Anthropic Claude, Z.AI GLM, OpenRouter, Ollama, vLLM, LiteLLM

## 独特机制
1. **赋予AI专属物理/虚拟计算机**：项目核心理念是让AI代理拥有一个完全独立、可持久化的工作环境（VM/容器），使其能自主安装软件、搭建数据库、部署服务并长期运行，实现经验和上下文的真正积累。
2. **自我演进与能力扩展**：AI能主动识别自身能力缺口并实时构建新工具或集成新服务（如案例中自主构建Discord支持、集成监控系统Vigil），并将新能力注册为MCP工具供未来使用。
3. **生产级基础设施自建**：AI能基于任务需求，自主搭建完整的数据分析栈（如安装ClickHouse、加载千万级数据集、构建API和仪表盘），展现出从需求识别到生产部署的端到端执行力。
4. **在作者生态中的定位**：在ghostwright的“AI操作系统”生态中，Phantom是运行在独立环境（如Specter部署的VM）中的核心“协工”应用，与Ghost OS（macOS原生全计算机使用）和Shadow（多模态背景捕获）形成互补，共同实现AI对计算机的深度、持久利用。

## 与 OpenClaw 集成可能
最顺的切入点是**将其作为MCP工具服务器接入**。Phantom自身构建的工具（如案例中的数据分析API）可注册为MCP工具，OpenClaw生态中的其他智能体便能通过MCP协议直接调用这些由Phantom创建和管理的持久化服务，实现能力共享。

## 值得深入的点
1. **“自我演进”的具体实现机制**：其“进化评判流程”如何设计，AI如何评估自身能力缺口、规划并安全地执行代码以扩展新功能（如构建Discord通道），这对构建具备自我改进能力的agent至关重要。
2. **持久化记忆与上下文管理**：在独立的计算机环境中，AI如何结构化地存储、索引和检索长期记忆与工作成果（如已安装的软件、构建的API、数据集），以实现跨会话的连续学习和任务承接。
3. **多模型后端无缝切换架构**：通过统一的Anthropic Messages API兼容层，支持从Claude到GLM、Ollama等众多模型的快速切换，且不改变工具、记忆和演进管道，这为研究不同模型在长期任务中的表现差异提供了绝佳实验平台。

_extracted_by: deepseek-chat · 2026-04-23 12:10_
