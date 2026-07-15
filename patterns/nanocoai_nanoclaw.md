# Pattern: nanocoai/nanoclaw

## 元信息
- repo: nanocoai/nanoclaw
- stars: 28972
- language: TypeScript
- discovered: 2026-05-18
- pattern_id: 20260518091618
- content_source: llm

## 特征
- description: A lightweight alternative to OpenClaw that runs in containers for security. Conn

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
  - thedotmack/claude-mem
  - upstash/context7

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-05-18

## 深度分析（LLM 提炼）

## 核心定位
NanoClaw 是一个轻量级、容器化、AI-native 的个人 AI 助手，旨在通过 OS 级隔离（Linux 容器）安全运行 Claude 代理，替代臃肿且安全薄弱的 OpenClaw。

## 技术栈
- **运行时:** Node.js, pnpm, Docker
- **AI 模型:** Anthropic Claude (通过 Claude Agent SDK)，支持 OpenAI Codex、OpenRouter、Google、DeepSeek、Ollama 等（通过技能模块添加）
- **消息通道:** WhatsApp, Telegram, Discord, Slack, Microsoft Teams, iMessage, Matrix, Google Chat, Webex, Linear, GitHub, WeChat, Email (Resend)
- **关键依赖:** 无（强调极简依赖，核心代码仅一个进程和少量文件）

## 独特机制
1.  **容器级隔离而非应用级权限检查:** 每个 Claude 代理运行在独立的 Linux 容器中，拥有文件系统隔离，Bash 访问安全（命令在容器内执行），而非像 OpenClaw 那样仅依赖应用层的允许列表和配对码。
2.  **AI-native 混合安装与定制:** 安装流程是确定性脚本（快速），当脚本失败或需要定制时，自动将控制权交给 Claude Code 进行诊断和修复。定制不是通过配置，而是直接修改代码（代码库足够小，修改安全）。
3.  **技能（Skills）而非功能（Features）:** 核心仓库只提供注册表和基础设施。通道适配器（Discord、Telegram 等）和替代模型提供者（OpenCode、Ollama 等）作为“技能”存在于长期分支上，用户通过 `/add-<skill>` 命令按需复制到自己的 fork 中，避免臃肿。
4.  **作者生态定位:** 该作者围绕 NanoClaw 构建了一个微型生态，包括独立的通道适配器仓库（nanoclaw-telegram, nanoclaw-whatsapp, nanoclaw-discord）、一个技能仓库（nanoclaw-skills）和一个监控仪表盘（nanoclaw-dashboard）。NanoClaw 本身是核心引擎，其他仓库是其可插拔的组件。

## 与 OpenClaw 集成可能
**不可行。** NanoClaw 的核心理念是作为 OpenClaw 的轻量级、安全替代品，其设计哲学（容器隔离、极简代码、AI-native 定制）与 OpenClaw 的架构（单体进程、应用级安全、配置驱动）完全相反。强行集成会破坏其核心价值。更合理的做法是将其视为一个独立的、可借鉴其安全模型和安装流程的参考实现。

## 值得深入的点
1.  **AI-native 混合安装流程:** 研究其 `nanoclaw.sh` 脚本如何将确定性脚本（安装依赖、构建容器）与 Claude Code 的自主诊断和修复能力无缝结合。这种“脚本 + AI”的模式对于构建自主 agent 的引导和自愈流程非常有启发。
2.  **基于容器的安全隔离模型:** 深入分析其如何利用 Docker 为每个 agent 创建独立的 Linux 容器，包括文件系统挂载、网络隔离、以及如何安全地暴露 Bash 访问。这为 agent 研究提供了一个比应用层权限控制更 robust 的安全范式。
3.  **“技能”式模块化架构:** 研究其如何通过 `/add-<skill>` 命令和长期分支（`channels`, `providers`）实现按需、零配置地添加功能。这种设计避免了框架的膨胀，并允许用户 fork 后自由修改，对于构建可扩展、用户可定制的 agent 系统有重要参考价值。

_extracted_by: deepseek-chat · 2026-05-18 09:16_
