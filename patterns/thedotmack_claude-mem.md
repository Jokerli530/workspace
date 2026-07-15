# Pattern: thedotmack/claude-mem

## 元信息
- repo: thedotmack/claude-mem
- stars: 76301
- language: TypeScript
- discovered: 2026-05-17
- pattern_id: 20260517211548
- content_source: llm

## 特征
- description: Persistent Context Across Sessions for Every Agent –  Captures everything your a

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
  - code-yeongyu/oh-my-openagent
  - danny-avila/LibreChat
  - freeCodeCamp/freeCodeCamp
  - garrytan/gstack
  - getsentry/XcodeBuildMCP
  - ghostwright/phantom
  - google-gemini/gemini-cli
  - gsd-build/gsd-2
  - holaboss-ai/holaOS
  - kamranahmedse/developer-roadmap
  - labring/FastGPT
  - langgenius/dify
  - lobehub/lobehub
  - n8n-io/n8n
  - nilbuild/developer-roadmap
  - openclaw/lobster
  - openclaw/openclaw
  - qwibitai/nanoclaw
  - ruvnet/ruflo
  - shareAI-lab/learn-claude-code
  - upstash/context7

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-05-17

## 深度分析（LLM 提炼）

## 核心定位
Claude-Mem 是一个为 Claude Code 设计的持久化记忆压缩系统，自动捕获跨会话的工具使用观察，生成语义摘要，使 AI 代理在会话结束后仍能保持项目知识的连续性。

## 技术栈
- **运行时**: Node.js (>=18.0.0)
- **语言**: TypeScript
- **关键依赖**: Model Context Protocol (MCP) 服务器
- **集成目标**: Claude Code、Gemini CLI、OpenCode
- **安装方式**: npx 一键安装、插件市场安装

## 独特机制
1. **自动捕获与压缩**：自动记录会话中的工具使用观察，并生成语义摘要，而非简单存储原始日志，实现高效记忆压缩。
2. **跨会话上下文桥接**：无需手动保存/加载，新会话自动继承之前会话的压缩记忆，实现真正的“无感”持久化。
3. **MCP 搜索工具集成**：提供基于 MCP 的搜索工具，允许代理在会话中主动检索历史记忆，增强上下文检索能力。
4. **作者生态定位**：该项目是作者 Claude Code 工具链的核心记忆层，与 `mcp-client-cli`（MCP 客户端）、`sequential-thinking-skill`（结构化思考技能）等形成互补，共同构建完整的代理工作流。

## 与 OpenClaw 集成可能
**可行，切入点明确**。Claude-Mem 本质是一个 MCP 服务器，OpenClaw 若支持 MCP 协议，可直接将其作为外部记忆服务接入。最顺的切入点是：在 OpenClaw 的代理生命周期中，将 Claude-Mem 作为可选的记忆后端，在会话结束时调用其压缩接口，在新会话启动时加载摘要，实现跨会话记忆。

## 值得深入的点
1. **语义摘要生成策略**：研究其如何从工具使用观察中提取关键信息并压缩为语义摘要，这对 Nova 的 agent 记忆管理机制设计有直接启发。
2. **MCP 搜索工具的实现**：如何设计搜索接口使代理能高效检索历史记忆，这关系到记忆的可用性和检索效率。
3. **零配置安装与自动检测**：`npx claude-mem install` 如何自动检测并配置 Claude Code/Gemini CLI 环境，这种无感集成模式值得 Nova 在插件化设计中借鉴。

_extracted_by: deepseek-chat · 2026-05-17 21:16_
