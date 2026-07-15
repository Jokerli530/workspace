# Pattern: x1xhlol/system-prompts-and-models-of-ai-tools

## 元信息
- repo: x1xhlol/system-prompts-and-models-of-ai-tools
- stars: 135899
- language: None
- discovered: 2026-04-24
- pattern_id: 20260424091315
- content_source: llm

## 特征
- description: FULL Augment Code, Claude Code, Cluely, CodeBuddy, Comet, Cursor, Devin AI, Juni

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - VoltAgent/awesome-openclaw-skills
  - Xnhyacinth/Awesome-LLM-Long-Context-Modeling
  - punkpeye/awesome-mcp-servers
  - sindresorhus/awesome

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-24

## 深度分析（LLM 提炼）

## 核心定位
这是一个收集并公开主流AI工具（如Cursor、Claude Code、Devin等）内部系统提示词（System Prompts）和模型信息的仓库，旨在帮助开发者逆向工程、安全审计或学习这些工具的行为逻辑。

## 技术栈
- 无特定技术栈（纯文档/文本仓库）
- 依赖：GitHub（托管）、Markdown（格式）
- 运行时：无（静态内容）

## 独特机制
1. **逆向工程聚合**：直接公开了多个知名AI编码工具（如Cursor、Claude Code、Devin）的原始系统提示词，这是其他同类项目（如`awesome-openclaw-skills`）不具备的深度逆向内容。
2. **安全警示与商业服务**：项目明确警告AI初创公司注意提示词泄露风险，并推广其商业安全服务`ZeroLeaks`，将开源情报转化为安全审计产品。
3. **作者生态定位**：作者`x1xhlol`还维护了`better-clawd`（改进版Claude Code）、`zero-calendar`（AI原生日历）等项目。本仓库是其生态中的“情报收集器”，为其他项目提供逆向工程基础。

## 与 OpenClaw 集成可能
**不可行**。该项目是静态文档仓库，无API、无运行时、无可调用的功能模块。OpenClaw无法直接集成其内容，但可参考其公开的提示词来优化OpenClaw技能（Skills）的提示工程。

## 值得深入的点
1. **提示词结构分析**：研究不同AI工具（如Cursor vs. Claude Code）的系统提示词差异，理解它们如何通过提示词控制工具行为、权限和输出格式。
2. **安全审计视角**：项目揭示了提示词注入和提取风险，这对Nova agent的防御机制设计有直接启发——如何防止agent的提示词被恶意提取或篡改。
3. **模型信息关联**：项目同时公开了模型信息（如Claude Code使用的具体模型版本），可结合提示词分析模型能力边界，为agent的模型选择提供参考。

_extracted_by: deepseek-chat · 2026-04-24 09:13_
