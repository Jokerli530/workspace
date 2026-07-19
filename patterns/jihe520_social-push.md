# Pattern: jihe520/social-push

## 元信息
- repo: jihe520/social-push
- stars: 491
- language: Shell
- discovered: 2026-07-19
- pattern_id: 20260719090915
- content_source: llm

## 特征
- description: 🤖 AI social-media automation skill | Self-evolution workflows | AI 社交媒体自动化 skill

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - SimoneAvogadro/android-reverse-engineering-skill
  - a2aproject/A2A
  - anthropics/claude-code
  - mattpocock/skills

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-07-19

## 深度分析（LLM 提炼）

## 核心定位
Social Push 是一个 Claude Code Skill，让 AI 编程助手通过自然语言指令（如 `/social-push 把这篇文章发到小红书`）自动将内容发布到多个社交媒体平台，解决手动跨平台发布内容的重复劳动问题。

## 技术栈
- Claude Code（Anthropic 的 AI 编程助手）
- agent-browser（Vercel 的 AI 驱动浏览器自动化 CLI 工具）
- Playwright（底层浏览器自动化框架）
- Shell（Skill 定义和 workflow 脚本）
- Markdown（平台发布流程配置）
- Chromium（浏览器运行时）

## 独特机制
1. **Self-Evolution（自我进化）**：当目标网页改版导致自动化流程失效时，AI 可自动检测并修复 workflow，无需手动维护代码——这是其与固定脚本或 Playwright MCP 方案的核心区别。
2. **Markdown 即配置**：添加新平台只需创建一个 Markdown 文件描述发布流程，无需编写复杂脚本或选择器，大幅降低扩展门槛。
3. **agent-browser 替代 Playwright MCP**：使用 agent-browser 的 `--help` 提示和交互 ref 机制，相比 Playwright MCP 消耗更少 tokens、运行更快，且能更好应对页面变化。
4. **安全设计**：仅暂存草稿，不自动发布，由用户最终确认，避免 AI 误操作风险。

在作者生态中，Social Push 是其社交媒体运营 Agent 生态的组成部分，与 MathModelAgent（数学建模 Agent）、mindpocket（AI Agent 集成个人主页）等共同构成其 Agent 产品矩阵，而 Gutchain（信息排泄链）则作为其内容分发渠道。

## 与 OpenClaw 集成可能
**可行，切入点明确**：Social Push 可作为 OpenClaw 的“内容发布工具”集成。OpenClaw 的 agent 在生成内容（如报告、分析结果、对话摘要）后，可调用 Social Push Skill 自动将内容发布到指定社交平台。集成方式为：在 OpenClaw 的 tool registry 中注册 Social Push 的 CLI 命令，agent 通过 `/social-push` 指令触发发布流程。由于 Social Push 本身是 Claude Code Skill，OpenClaw 需提供类似 Skill 执行环境或直接调用其底层 agent-browser 命令。

## 值得深入的点
1. **Self-Evolution 的实现机制**：研究其如何检测自动化流程失效（如页面元素变化），以及 AI 如何自动修复 workflow——这对构建自适应 agent 系统至关重要，可借鉴到 OpenClaw 的 agent 容错和自修复能力中。
2. **Markdown 作为 agent 配置 DSL**：用 Markdown 文件定义复杂自动化流程（如多步骤浏览器操作），而非传统脚本或 JSON 配置。这种“人类可读、AI 可执行”的配置方式，对 agent 的灵活扩展和用户自定义能力有启发。
3. **agent-browser 的 token 优化策略**：通过 `--help` 提示和交互 ref 减少 tokens 消耗，对比 Playwright MCP 的差异——这对设计 token 高效的 agent 工具调用接口有参考价值，尤其适合资源受限的 agent 运行环境。

_extracted_by: deepseek-chat · 2026-07-19 09:09_
