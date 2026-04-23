# Pattern: openclaw/lobster

## 元信息
- repo: openclaw/lobster
- stars: 1151
- language: TypeScript
- discovered: 2026-04-23
- pattern_id: 20260423110837
- content_source: llm

## 特征
- description: Lobster is a Openclaw-native workflow shell: a typed, local-first “macro engine”

## 调研要点（TypeScript）
- 框架选择（React/Vue/Node/Next.js）
- 类型系统使用（strict、泛型）
- 包管理（npm/pnpm/yarn）
- 与OpenClaw的集成点

## 同语言Sibling项目
  - CherryHQ/cherry-studio
  - cline/cline
  - CopilotKit/CopilotKit
  - freeCodeCamp/freeCodeCamp
  - getsentry/XcodeBuildMCP
  - google-gemini/gemini-cli
  - gsd-build/gsd-2
  - kamranahmedse/developer-roadmap
  - langgenius/dify
  - lobehub/lobehub
  - openclaw/openclaw
  - ruvnet/ruflo

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-23

## 深度分析（LLM 提炼）

## 核心定位
Lobster 是一个 OpenClaw 原生的、类型化的工作流 Shell，用于构建和执行 JSON 优先的、本地优先的确定性管道和审批流程，旨在让 AI 代理（如 OpenClaw）通过单步调用复杂宏来节省 Token 并提升任务的可恢复性。

## 技术栈
- TypeScript
- Node.js (运行时)
- pnpm (包管理器)

## 独特机制
1. **JSON 优先的类型化管道**：与传统的基于文本流（text pipes）的 Shell 不同，Lobster 的核心数据单元是类型化的 JSON 对象和数组，支持结构化数据的精确筛选（`where`）、选取（`pick`）和转换。
2. **本地优先的确定性工作流引擎**：工作流被定义为可重复执行的脚本（`.lobster` 文件），包含明确的步骤、条件分支和审批门控，使 AI 代理可以将其作为“宏”一步调用，避免为每个子步骤重新规划，从而节省 Token 并保证结果可重现、可恢复。
3. **与 OpenClaw 深度集成的审批门控**：内置 `approve` 命令和 `approval:` 步骤，既支持本地 TTY 交互，也支持通过 `--emit` 选项将审批请求输出给 OpenClaw 处理，实现了人机协同工作流中的关键决策点。
4. **在作者生态中的定位**：Lobster 是 OpenClaw 主项目的“工作流引擎”组件，旨在作为可选插件工具集成到 OpenClaw 中，与技能目录（clawhub）、技能实现（skills）和 ACP 协议客户端（acpx）共同构成 OpenClaw 的智能体开发生态。

## 与 OpenClaw 集成可能
最顺的切入点是**将 Lobster 作为 OpenClaw 的一个可选工具（Plugin Tool）集成**。OpenClaw 可以直接调用 Lobster 来执行预定义的、类型安全的工作流（如监控 PR、执行多步审批流程），从而将复杂、确定性的多步操作封装为单次 LLM 调用，显著节省 Token 并提升任务可靠性。这完全符合项目“Next steps”中的规划。

## 值得深入的点
1. **结构化数据管道设计**：Lobster 将 Shell 命令的输入/输出和内部处理统一为 JSON 流（通过 `--json` 标志和 `json` 渲染器），这种设计使得 AI 代理能够精确理解和操作管道中的数据，避免了传统文本解析的脆弱性，对构建可靠的数据处理型 Agent 有启发。
2. **工作流状态与可恢复性机制**：工作流文件支持步骤级别的重试（`retry`）、超时（`timeout_ms`）和错误处理（`on_error`），并且通过明确的步骤 ID 和条件（`when`）来管理流程状态。这种显式的状态管理对于实现长周期、可中断恢复的 Agent 任务至关重要。
3. **人机协同的审批门控实现**：`approval` 步骤不仅是一个简单的暂停点，它支持身份约束（如 `required_approver`）并能将审批请求结构化地输出给上层系统（如 OpenClaw）。这为研究如何在自主 Agent 中安全、可控地引入人类监督提供了具体的技术范本。

_extracted_by: deepseek-chat · 2026-04-23 11:09_
