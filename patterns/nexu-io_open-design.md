# Pattern: nexu-io/open-design

## 元信息
- repo: nexu-io/open-design
- stars: 65473
- language: TypeScript
- discovered: 2026-06-16
- pattern_id: 20260616091448
- content_source: llm

## 特征
- description: 🎨 Local-first, open-source Claude Design alternative. 🖥️ Native desktop app. ⚡ 2

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
  - nanocoai/nanoclaw
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
- updated: 2026-06-16

## 深度分析（LLM 提炼）

## 核心定位
Open Design 是一个本地优先、开源的原生桌面应用，旨在替代 Claude Design，让用户通过本地编码智能体（如 Claude Code、OpenClaw 等）和设计系统文件（`DESIGN.md`），将 CLI 变成设计引擎，直接从文本描述生成可运行的 HTML/PDF/PPTX/MP4 原型、仪表盘和动效。

## 技术栈
- **运行时**: 原生桌面应用（macOS / Windows）
- **核心框架**: 基于 Web 技术栈（Electron 或类似），支持 iframe 沙盒预览
- **关键依赖**: 支持 20+ 模型（GPT、Claude、Gemini、DeepSeek）的 Agentic Model Router (AMR)
- **集成对象**: Claude Code、OpenClaw、Codex、Cursor、OpenCode、Qwen、Copilot、Amp、Hermes、Kimi、Antigravity 等 22 个本地 CLI，以及任何 OpenAI 兼容端点
- **输出格式**: HTML、PDF、PPTX、MP4
- **扩展机制**: 150 个品牌级 `DESIGN.md` 系统、261 个即用插件、100+ 技能

## 独特机制
1. **Agent-native 设计循环**: 将 Claude Design 的封闭循环（发现需求→锁定方向→流式生成工件→批评→交付）开放为本地文件系统，编码智能体可直接读写和混编技能、设计系统和插件，而非依赖单一云端服务。
2. **`DESIGN.md` 作为品牌契约**: 团队通过一个 Markdown 文件定义设计系统，所有输出自动遵循该契约，实现从品牌到工件的端到端一致性，无需手动调整像素。
3. **并行会话与全流程集成**: 0.10.0 版本支持并行会话，将灵感发现、素材收集、交互编辑、评论排队、动效打磨到交付给编辑器或代码智能体的全流程整合在一个窗口内，模拟本地设计团队协作。
4. **作者生态定位**: 该项目是 nexu-io 生态的核心产品，与 `html-anything`（智能体驱动的 HTML 编辑器）、`html-video`（HTML 转视频）和 `nexu`（OpenClaw 桌面客户端）形成互补，共同构建从设计生成到交付的完整工具链。

## 与 OpenClaw 集成可能
**切入点明确**: Open Design 已原生支持 OpenClaw 作为其编码智能体之一，且作者的另一项目 `nexu` 本身就是 OpenClaw 的桌面客户端。最顺的集成路径是：通过 OpenClaw 调用 Open Design 的本地技能和设计系统，将生成的 HTML/PDF/PPTX 工件直接作为 OpenClaw 智能体的输出或工具结果，实现“智能体描述需求 → OpenClaw 调用 Open Design → 返回可交付工件”的闭环。

## 值得深入的点
1. **`DESIGN.md` 作为结构化提示的范式**: 该项目将品牌设计规范编码为 Markdown 文件，并让所有智能体输出自动遵循该规范。这对 Nova 的 agent 研究启发极大——可以用类似方式为智能体定义“行为契约”或“输出风格指南”，实现跨会话的一致性。
2. **并行会话与协作模拟**: 0.10.0 引入的并行会话机制，让多个智能体（或同一智能体的多个实例）同时处理不同设计阶段，模拟团队协作。这为研究多智能体协同工作流提供了具体实现参考。
3. **Agentic Model Router (AMR)**: 该项目提供的统一模型路由服务，允许智能体根据任务类型动态选择最优模型（GPT/Claude/Gemini/DeepSe

_extracted_by: deepseek-chat · 2026-06-16 09:15_
