# Pattern: code-yeongyu/oh-my-openagent

## 元信息
- repo: code-yeongyu/oh-my-openagent
- stars: 54455
- language: TypeScript
- discovered: 2026-04-27
- pattern_id: 20260427211724
- content_source: llm

## 特征
- description: omo; the best agent harness - previously oh-my-opencode

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
- updated: 2026-04-27

## 深度分析（LLM 提炼）

## 核心定位
oh-my-openagent（曾用名 oh-my-opencode）是一个开源的、多模型编排的 AI 编码代理框架，旨在打破单一模型锁定，通过动态路由和任务分解，让代理在复杂软件工程任务中自主工作直至完成。

## 技术栈
- TypeScript（主要语言）
- Node.js（运行时）
- 支持多种 LLM API：Claude、GPT、Kimi、GLM、Minimax、Gemini 等
- npm（发布与安装）
- Discord（社区与实时开发）

## 独特机制
1. **多模型编排而非单一模型**：不依赖单一 LLM（如 Claude Code），而是根据任务阶段动态选择最优模型（Claude 做编排、GPT 做推理、Minimax 做速度、Gemini 做创意），实现模型间的协同工作。
2. **“Sisyphus”式自主代理循环**：项目背后的核心理念是“Sisyphus”——一个像纪律严明的代理一样持续工作直到任务完成，而非一次性对话。它通过循环反馈和任务分解，将人类数周的工作压缩到数小时。
3. **对抗平台锁定**：明确声明对抗 Anthropic 等公司的封闭生态，通过开源和多模型支持，让用户不被任何单一提供商绑定，这是其社区和设计哲学的核心。
4. **作者生态定位**：作者 code-yeongyu 围绕 AI 代理构建了一系列工具，从 `AiShell`（自然语言 Shell）到 `saneagent`（基础代理框架），再到 `perplexity-advanced-mcp`（MCP 工具）。`oh-my-openagent` 是其生态中最成熟、最受关注的旗舰项目，代表了作者对“纪律性自主代理”的最高实践。

## 与 OpenClaw 集成可能
**直接集成可行且高度契合**。README 明确提到作者使用基于 OpenClaw 高度定制的 AI 助手 Jobdori 来实时维护本项目。最顺的切入点是：将 oh-my-openagent 的“多模型编排”和“Sisyphus 循环”作为 OpenClaw 的一个高级代理工作流插件或工具集。OpenClaw 可以调用 oh-my-openagent 的 API 或核心逻辑，让用户通过 OpenClaw 界面触发一个“Sisyphus 任务”，由 oh-my-openagent 自主完成复杂编码任务并返回结果。这比从头实现一个自主代理循环要快得多。

## 值得深入的点
1. **多模型路由策略**：项目如何根据任务类型（推理、速度、创意）动态选择模型？其路由逻辑和模型切换的触发条件是什么？这对 Nova 研究“如何为不同子任务分配最优模型”有直接启发。
2. **“Sisyphus”循环的实现细节**：代理如何定义“任务完成”？循环中的反馈机制（如错误恢复、进度追踪、自我修正）是如何设计的？这比简单的“对话式”代理更接近真正的自主工作流。
3. **对抗锁定的架构设计**：项目如何抽象不同 LLM 的 API 差异，使其可互换？其插件或适配器模式的设计，对 Nova 构建一个模型无关的代理框架有重要参考价值。

_extracted_by: deepseek-chat · 2026-04-27 21:17_
