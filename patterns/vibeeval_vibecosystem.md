# Pattern: vibeeval/vibecosystem

## 元信息
- repo: vibeeval/vibecosystem
- stars: 471
- language: C#
- discovered: 2026-04-25
- pattern_id: 20260425091524
- content_source: llm

## 特征
- description: AI software team for Claude Code - 138 agents, 295 skills, 73 hooks. Self-learni

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - IvanMurzak/Unity-MCP

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-25

## 深度分析（LLM 提炼）

## 核心定位
vibecosystem 是一个基于 Claude Code 的 AI 软件团队框架，通过 138 个专业化 agent、295 项技能和 73 个 hook，将单一 AI 助手扩展为自组织的多角色开发团队，解决复杂项目中需要人工充当规划者、审查者、安全审计者等多重角色的问题。

## 技术栈
- **运行时**: Node.js（npm 包分发）
- **核心依赖**: Claude Code CLI（Anthropic）
- **脚本语言**: TypeScript（hook 系统）、Shell（安装/CLI）
- **CLI 工具**: `vibeco`（自定义命令行）
- **集成 CLI**: Cursor、Codex CLI、OpenCode
- **可选集成**: GitHub Actions（CI/CD）、MCP 协议

## 独特机制
1. **自学习错误修复**：每次 agent 出错自动生成新规则，错误成为系统行为指南，实现持续自我改进，无需手动配置。
2. **Agent 记忆与梦境整合**：每个 agent 有持久化记忆（Agent Memory），跨会话通过 Dream Consolidation 清理记忆，Smart Recall 基于 frontmatter 评分检索，实现长期上下文保持。
3. **多 LLM 模型路由**：按任务复杂度自动路由到 Haiku/Sonnet/Opus 层级，结合知识图谱实现 6-71 倍 token 节省，而非简单固定模型。
4. **工作树隔离**：60 个生产者 agent 使用工作树隔离，避免并行任务间的上下文污染，保证独立执行环境。

在作者生态中，vibecosystem 是核心项目，而 vibeeval（1★）可能是评估工具，但本项目已内置 benchmark agent 和 agent-benchmark 技能，暗示 vibeeval 可能被整合或废弃。

## 与 OpenClaw 集成可能
**可行，切入点明确**：vibecosystem 的 hook 系统（73 个 TypeScript 传感器）是天然集成点。OpenClaw 可以：
- 通过 MCP Auto-Discovery 机制注册为外部工具/技能
- 利用 hook 系统注入 OpenClaw 的上下文观察、过滤和注入逻辑
- 将 OpenClaw 的 agent 作为 vibecosystem 的一个新 agent 类型注册（已有 138 个 agent 的扩展槽位）
- 使用 `plugin.json` 插件生态直接打包为官方插件

## 值得深入的点
1. **自学习规则生成机制**：错误→规则 的自动转化管道，研究如何将 agent 执行失败的结构化信息（错误类型、上下文、修复方案）转化为可复用的行为约束，这对 Nova 的 agent 自我进化能力设计有直接参考价值。
2. **Agent 记忆系统架构**：持久化记忆 + 梦境整合 + 智能召回的三层设计，特别是基于 frontmatter 的记忆评分和跨会话清理策略，为 Nova 的长期记忆管理提供具体实现模式。
3. **多模型路由与知识图谱结合**：按复杂度分层调用不同 LLM，同时用知识图谱实现 token 节省（6-71 倍），这种混合策略对 Nova 在资源受限环境下的 agent 编排有重要启发。

_extracted_by: deepseek-chat · 2026-04-25 09:15_
