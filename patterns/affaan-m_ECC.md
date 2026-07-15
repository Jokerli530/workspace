# Pattern: affaan-m/ECC

## 元信息
- repo: affaan-m/ECC
- stars: 186960
- language: JavaScript
- discovered: 2026-05-19
- pattern_id: 20260519211729
- content_source: llm

## 特征
- description: The agent harness performance optimization system. Skills, instincts, memory, se

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - EvoMap/evolver
  - affaan-m/everything-claude-code

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-05-19

## 深度分析（LLM 提炼）

## 核心定位
ECC 是一个“工具链原生操作员系统”，为 AI 智能体（如 Claude Code、Cursor、Codex）提供一套完整的技能、本能、记忆优化、持续学习和安全扫描能力，将临时提示词工程转变为可复用、可审计的生产级工作流。

## 技术栈
- **运行时**：Shell、TypeScript、Python、Go、Java、Perl、Markdown
- **关键依赖**：npm 包 `ecc-universal`、`ecc-agentshield`；GitHub App（ecc-tools）
- **框架/平台**：Claude Code、Codex、Cursor、OpenCode、Gemini、Zed、GitHub Copilot 等 AI agent 工具链
- **其他**：MCP 配置、GitHub Actions、Hooks、Rules

## 独特机制
1. **跨工具链统一操作层**：ECC 不是绑定单一 AI 工具的配置集，而是通过一套“技能、本能、记忆、规则”抽象层，在 Claude Code、Cursor、Codex 等 7 个以上不同工具链间提供一致的操作体验，解决了 agent 工作流碎片化问题。
2. **记忆持久化与持续学习**：通过 Hooks 自动保存/加载跨会话上下文，并从每次会话中自动提取模式为可复用的技能，实现 agent 的“持续学习”而非一次性提示。
3. **内置安全扫描（AgentShield）**：项目自带 `ecc-agentshield` 包，专门检测 agent 配置、MCP 服务器中的漏洞，将安全审计直接嵌入 agent 工作流，而非事后检查。
4. **作者生态定位**：ECC 是 affaan-m 生态的核心基础设施层，其他项目如 `agentshield`（安全扫描）、`claude-swarm`（多 agent 编排）、`JARVIS`（情报收集）都构建在 ECC 提供的技能/本能/记忆系统之上。

## 与 OpenClaw 集成可能
**切入点**：将 ECC 的“技能”和“本能”抽象层作为 OpenClaw agent 的标准化行为模块库。OpenClaw 可以引入 ECC 的 `ecc-universal` 包，让 agent 直接调用预定义的技能（如代码审查、记忆持久化、安全扫描），而不需要为每个工具链单独实现。最顺的集成点是“技能注册与调用接口”——ECC 的技能定义格式（Markdown/JSON）可以作为 OpenClaw 的插件规范。

## 值得深入的点
1. **“本能” vs “技能”的层次设计**：ECC 区分了“本能”（instincts，即 agent 默认行为规则）和“技能”（skills，即可复用的任务模块）。这种分层让 agent 既有默认的“人格”又能按需加载能力，对 Nova 的 agent 行为控制系统设计有直接参考价值。
2. **跨会话记忆持久化机制**：ECC 通过 Hooks 实现自动保存/加载上下文，而非依赖工具链自带的记忆功能。研究其 Hook 接口设计（如何拦截会话开始/结束、如何序列化/反序列化记忆）可以为 OpenClaw 提供一种与工具链无关的记忆管理方案。
3. **安全扫描与工作流融合**：`ecc-agentshield` 将安全扫描作为 agent 工作流的一个步骤（而非独立工具），这种“内嵌式安全”模式值得 Nova 在 agent 编排中借鉴，尤其是在处理外部 MCP 服务器时。

_extracted_by: deepseek-chat · 2026-05-19 21:17_
