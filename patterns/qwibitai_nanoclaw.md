# Pattern: qwibitai/nanoclaw

## 元信息
- repo: qwibitai/nanoclaw
- stars: 27822
- language: TypeScript
- discovered: 2026-04-24
- pattern_id: 20260424104423
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
  - danny-avila/LibreChat
  - freeCodeCamp/freeCodeCamp
  - garrytan/gstack
  - getsentry/XcodeBuildMCP
  - ghostwright/phantom
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
- updated: 2026-04-24

## 深度分析（LLM 提炼）

## 核心定位
NanoClaw 是一个轻量级、容器隔离的 AI 助手框架，旨在替代 OpenClaw，让 AI agent 在独立的 Linux 容器中安全运行，代码量小到可被完全理解并定制。

## 技术栈
- **运行时**: Node.js
- **包管理器**: pnpm
- **容器化**: Docker (macOS/Linux/WSL2)，可选 Docker Sandboxes 微虚拟机或 Apple Container
- **AI 模型**: 原生集成 Anthropic Claude Agent SDK (Claude Code)，支持 OpenAI Codex、OpenCode、Ollama 等作为可选 provider
- **凭证管理**: OneCLI Agent Vault
- **消息通道**: Telegram, Discord, WhatsApp, Slack, Microsoft Teams, iMessage, Matrix, Google Chat, Webex, Linear, GitHub, WeChat, email (Resend)

## 独特机制
1. **容器级安全隔离而非应用级权限**：每个 agent 运行在独立的 Linux 容器中，拥有自己的文件系统、内存和挂载点，而非像 OpenClaw 那样仅靠 allowlist 和配对码做应用层防护。Bash 访问安全，因为命令在容器内执行。
2. **“技能即分支”的按需安装机制**：通道适配器（Telegram、Discord 等）和替代 provider 不内置在主分支，而是分别维护在 `channels` 和 `providers` 长期分支上。用户通过 `/add-telegram` 等命令将所需模块精确复制到自己的 fork 中，避免臃肿。
3. **AI 原生的安装与调试流程**：安装脚本 `nanoclaw.sh` 是优化过的确定性路径，但任何步骤失败时（如依赖缺失、配置决策），控制权无缝交给 Claude Code 进行诊断和恢复。整个项目没有监控面板或调试 UI，用户直接在聊天中描述问题，Claude Code 处理。
4. **极简代码库设计**：一个进程、几个源文件、无微服务。作者明确将“小到可以理解”作为哲学，鼓励用户 fork 后让 Claude Code 直接修改代码来定制行为，而非通过配置文件膨胀。

**作者生态定位**：NanoClaw 是核心框架，`nanoclaw-skills` 是技能注册表与基础设施，而 `nanoclaw-telegram`、`nanoclaw-whatsapp`、`nanoclaw-gmail`、`nanoclaw-discord` 是独立的通道适配器模块，通过技能机制按需注入。

## 与 OpenClaw 集成可能
**不可行**。NanoClaw 的核心理念就是替代 OpenClaw，其作者明确批评 OpenClaw 代码量过大（近 50 万行）、安全机制薄弱（应用层而非 OS 层隔离）。两者在架构哲学上完全对立：NanoClaw 追求极简和容器隔离，OpenClaw 是单体 Node 进程。强行集成会破坏 NanoClaw 的设计初衷。更合理的做法是作为 OpenClaw 用户的迁移目标。

## 值得深入的点
1. **容器内 agent 的文件系统隔离模型**：每个 agent 组拥有独立的 `CLAUDE.md`、独立的内存和容器，只有显式挂载的目录才可见。这种“最小权限”的 agent 工作区设计对 Nova 的 agent 安全架构研究有直接参考价值。
2. **“技能即分支”的模块分发模式**：将功能模块（通道、provider）放在长期分支而非主分支，通过 CLI 命令按需复制到用户 fork。这种模式避免了传统插件系统的版本依赖和配置复杂度，对 Nova 的 agent 生态扩展机制有启发

_extracted_by: deepseek-chat · 2026-04-24 10:44_
