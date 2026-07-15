# Pattern: santifer/career-ops

## 元信息
- repo: santifer/career-ops
- stars: 58312
- language: JavaScript
- discovered: 2026-07-03
- pattern_id: 20260703212442
- content_source: llm

## 特征
- description: AI-powered job search system built on Claude Code. 14 skill modes, Go dashboard,

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - EvoMap/evolver
  - Mintplex-Labs/anything-llm
  - affaan-m/ECC
  - affaan-m/everything-claude-code

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-07-03

## 深度分析（LLM 提炼）

## 核心定位
Career-Ops 是一个将 AI 编码 CLI（如 Claude Code）转变为求职指挥中心的开源系统，通过多智能体并行评估、简历定制和门户扫描，解决求职者从海量职位中筛选出高价值机会的效率问题。

## 技术栈
- **运行时**: Node.js, Go
- **AI 代理**: Claude Code（核心），兼容 OpenCode、Codex、Qwen、Kimi、GitHub Copilot、Grok Build CLI 等
- **前端/仪表盘**: Go（Bubble Tea TUI 框架）
- **自动化**: Playwright（浏览器自动化）
- **输出**: PDF 生成（ATS 优化简历）
- **集成平台**: n8n（通过作者其他项目 jacobo-workflows 支持 WhatsApp+语音）

## 独特机制
1. **A-F 评分系统**：基于 10 个加权维度（如薪资、成长性、文化匹配）对职位进行结构化评分，并强烈建议只申请评分 4.0/5 以上的职位，避免“海投”浪费。
2. **批量并行处理**：使用子代理并行评估 10+ 个职位，而非串行处理，大幅提升筛选效率。
3. **多 CLI 兼容**：不仅绑定 Claude Code，还支持 OpenCode、Codex、Qwen 等 7 种 AI 编码 CLI，使其成为“代理技能标准”的通用求职工具。
4. **作者生态定位**：Career-Ops 是 santifer 求职工具链的核心，与 `cv-santiago`（交互式简历）、`jacobo-workflows`（n8n 多代理工作流）和 `claudeable`（Claude Code 元项目）形成互补，覆盖从简历生成、职位筛选到自动化沟通的全流程。

## 与 OpenClaw 集成可能
**可行，切入点明确**：将 Career-Ops 的“A-F 评分系统”和“批量职位评估”作为 OpenClaw 的一个技能模块（Skill）。OpenClaw 的 agent 可以通过调用 Career-Ops 的 CLI 命令，在求职场景中自动执行职位筛选和简历生成，无需用户手动操作。具体来说，OpenClaw 可以封装 `career-ops evaluate` 和 `career-ops generate-cv` 等命令，作为 agent 的“求职专家”技能。

## 值得深入的点
1. **多代理并行评估架构**：Career-Ops 如何设计子代理的并行执行和结果聚合？这为 Nova 的 agent 研究提供了“任务分解-并行执行-结果合并”的参考模式，尤其适合需要批量处理独立子任务的场景（如数据清洗、批量审核）。
2. **结构化评分系统（10 维加权）**：将主观的“职位好坏”量化为可计算的评分模型，这种“评估即代码”的思路可以启发 Nova 在 agent 决策中引入更精细的量化评估机制，而非简单的二元判断。
3. **多 CLI 兼容设计**：通过定义“代理技能标准”接口，让同一套工具运行在不同 AI 后端上。这种抽象层设计对 Nova 的 agent 跨平台兼容性有直接借鉴意义，尤其是当 Nova 需要支持多种 LLM 或 CLI 环境时。

_extracted_by: deepseek-chat · 2026-07-03 21:24_
