# Pattern: garrytan/gstack

## 元信息
- repo: garrytan/gstack
- stars: 81572
- language: TypeScript
- discovered: 2026-04-24
- pattern_id: 20260424091334
- content_source: llm

## 特征
- description: Use Garry Tan's exact Claude Code setup: 23 opinionated tools that serve as CEO,

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
gstack 是一个将 Claude Code 转化为虚拟工程团队的 23 个定制化工具集，让单人在 AI 辅助下实现传统团队级别的软件交付速度。

## 技术栈
- Claude Code（运行时）
- Git
- Bun v1.0+
- Node.js（Windows 仅）
- Markdown（所有工具定义格式）
- Bash（setup 脚本）

## 独特机制
1. **角色化工具矩阵**：将 AI 对话拆分为 23 个独立角色（CEO、工程经理、设计师、QA、安全官等），每个角色有专属的 slash 命令和提示模板，而非单一通用 prompt。
2. **团队模式自动分发**：通过 `--team` 模式将 gstack 配置嵌入仓库的 CLAUDE.md，队友无需手动安装，每次 Claude Code 会话自动检查更新（限频 1 次/小时，静默失败）。
3. **OpenClaw 原生兼容**：明确支持 OpenClaw 通过 ACP 协议派生 Claude Code 会话，所有 gstack 技能可直接复用，无需额外适配。
4. **作者生态定位**：与作者的另一项目 `garrytan/gbrain`（OpenClaw/Hermes Agent Brain）互补——gstack 是面向 Claude Code 的工程交付工具链，gbrain 是面向 OpenClaw 的智能体大脑逻辑。

## 与 OpenClaw 集成可能
**高度可行**。README 已明确给出集成方案：在 OpenClaw 的 AGENTS.md 中添加“Coding Tasks”节，指示派生 Claude Code 会话时先安装 gstack。最顺的切入点是：在 OpenClaw 的 agent 定义中，将 gstack 的 `/plan-ceo-review`、`/review`、`/qa` 等命令作为 coding 子任务的默认工具链，实现“OpenClaw 决策 → gstack 执行”的流水线。

## 值得深入的点
1. **角色化 prompt 工程**：23 个角色各自有独立的 Markdown 提示模板，这种“多专家系统”设计比单一大 prompt 更可控，可研究如何动态组合角色以适配不同任务复杂度。
2. **团队模式与版本同步机制**：通过仓库内嵌配置 + 限频静默更新，解决了 AI 工具链在团队协作中的版本漂移问题，这种“基础设施即代码”的思路可推广到 agent 配置管理。
3. **LOC 争议的量化方法论**：项目附带了完整的生产力度量脚本（`docs/ON_THE_LOC_CONTROVERSY.md`），用逻辑代码变更而非原始行数衡量 AI 辅助效率，这种度量方式对 agent 研究中的效能评估有参考价值。

_extracted_by: deepseek-chat · 2026-04-24 09:13_
