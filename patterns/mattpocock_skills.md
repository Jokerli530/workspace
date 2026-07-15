# Pattern: mattpocock/skills

## 元信息
- repo: mattpocock/skills
- stars: 47646
- language: Shell
- discovered: 2026-04-30
- pattern_id: 20260430212101
- content_source: llm

## 特征
- description: Skills for Real Engineers. Straight from my .claude directory.

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - SimoneAvogadro/android-reverse-engineering-skill
  - a2aproject/A2A
  - anthropics/claude-code

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-30

## 深度分析（LLM 提炼）

## 核心定位
一套轻量、可组合的 Claude Code 技能（Skills）集合，旨在解决 AI 编码代理在真实工程中常见的“沟通偏差”、“过度冗长”和“代码不可靠”三大失败模式，让代理像资深工程师一样工作。

## 技术栈
- **运行时**：Claude Code / Codex 等终端编码代理
- **安装方式**：`npx skills@latest add`（基于 npm 生态）
- **配置格式**：Markdown 技能文件（`SKILL.md`），纯文本指令
- **依赖**：无外部框架，仅依赖代理自身的指令解析能力

## 独特机制
1. **“盘问式”对齐（/grill-me & /grill-with-docs）**：在代理开始编码前，强制它向用户提出详细问题，确保双方对需求理解一致。这与常见的“直接执行”模式形成鲜明对比，从源头减少返工。
2. **共享语言构建（/grill-with-docs 内置）**：通过引导用户创建 `CONTEXT.md` 和 ADR（架构决策记录），为代理建立项目特有的领域术语表。这直接解决了代理用词冗长、命名不一致的问题，并节省 token 消耗。
3. **TDD 循环（/tdd）**：强制代理先写失败测试再修复，形成红-绿-重构的反馈闭环。这比单纯让代理“写测试”更严格，确保测试驱动开发而非事后补测。
4. **极简可组合性**：每个技能是一个独立的 Markdown 文件，用户可自由选择、修改、组合。这与 GSD、BMAD 等“全流程框架”不同，作者强调“小、易适配、可组合”，把控制权还给开发者。

**在作者生态中的定位**：mattpocock 是 TypeScript 生态知名人物（`ts-reset` 作者），本仓库是其“AI 代理工程实践”的核心输出，与 `sandcastle`（编排沙盒代理）、`evalite`（评估 LLM 应用）形成互补——`skills` 提供日常编码指令，`sandcastle` 提供更复杂的多代理编排能力。

## 与 OpenClaw 集成可能
**可行，切入点明确**。OpenClaw 的 agent 研究可直接复用其技能文件格式（Markdown 指令）和安装机制。最顺的切入点是：
- 将 `/grill-with-docs` 的“盘问+共享语言”流程适配为 OpenClaw 的“需求澄清”模块，在 agent 执行任务前自动触发。
- 将 `/tdd` 的“红-绿-重构”指令封装为 OpenClaw 的“测试驱动开发”工作流模板。
- 利用其 `npx skills@latest add` 安装机制，作为 OpenClaw 技能市场的分发方式。

## 值得深入的点
1. **“共享语言”的 token 经济学**：作者指出，通过建立 `CONTEXT.md` 中的领域术语表，代理“花费更少 token 思考”。这为 agent 研究提供了量化优化方向——如何通过前置的术语压缩，降低推理成本并提升输出质量。
2. **盘问式对齐的 prompt 设计**：`/grill-me` 的具体提问策略（如何引导用户暴露隐含假设）值得拆解。这种“主动提问”而非“被动执行”的模式，是提升 agent 任务成功率的通用技巧。
3. **技能的可组合性设计**：每个技能是独立的 Markdown 文件，通过 `npx` 安装器组合。这种“微指令”架构比大型 prompt 模板更灵活，适合 OpenClaw 构建模块化的 agent

_extracted_by: deepseek-chat · 2026-04-30 21:21_
