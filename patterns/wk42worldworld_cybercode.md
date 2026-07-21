# Pattern: wk42worldworld/cybercode

## 元信息
- repo: wk42worldworld/cybercode
- stars: 375
- language: TypeScript
- discovered: 2026-07-21
- pattern_id: 20260721091046
- content_source: llm

## 特征
- description: 整合 Claude Code 编程能力与 Hermes Agent 自进化能力的智能体 / An AI agent combining Claude Code

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
  - nexu-io/open-design
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
- updated: 2026-07-21

## 深度分析（LLM 提炼）

## 核心定位
CyberCode 是一个开源的本地编程智能体，结合了 Claude Code 的工作流和 Hermes Agent 的自进化能力，提供持久记忆、上下文优化和桌面/终端双界面，旨在成为用户的 AI 编程伙伴。

## 技术栈
- **运行时**: Bun
- **前端**: Electron (桌面应用)
- **语言**: TypeScript
- **关键依赖**: 未明确列出，但涉及 Claude Code 风格工作流、Hermes Agent 自进化机制、本地代码图 (Code Graph)、多模型提供商桥接

## 独特机制
1. **自进化记忆系统**: 不仅恢复聊天历史，还从交互中提取通信偏好、协作习惯和项目知识，形成“技能候选”，使后续会话从更好的起点开始。记忆透明可编辑，桌面应用展示学习来源和提炼方法。
2. **多层上下文优化**: 提供 Lite 清理、Smart Pruning、Lazy Programmer、Caveman、RTK 和 Code Graph 六层独立优化，每层有全局开关，可压缩重复指令、陈旧上下文、工具输出等，将上下文视为资源管理。
3. **本地代码图 (Code Graph)**: 索引文件、符号、引用、调用和包含关系，自动为结构编码请求选择紧凑的图排名预检，暴露原生 `CodeGraph` 工具，支持多文件搜索映射回符号和影响关系，帮助理解不熟悉的仓库和跨文件重构。
4. **知识空间**: 桌面应用中的图形视图支持符号搜索、架构布局、节点检查、缩放和索引重建，同时支持用户管理本地文件/文件夹作为知识源，拖拽添加，全文搜索，二进制文件仅处理元数据。

**作者生态定位**: 本项目是作者 `wk42worldworld` 的核心作品，与其 ClawWin 系列（OpenClaw 桌面客户端）形成互补——CyberCode 专注于编程智能体，而 ClawWin 提供通用 AI 聊天界面。

## 与 OpenClaw 集成可能
**可行，切入点明确**: 将 CyberCode 的“自进化记忆系统”和“本地代码图”作为 OpenClaw 的插件或工具模块。OpenClaw 作为 AI 聊天客户端，可集成 CyberCode 的记忆提取和上下文优化能力，增强其编程相关对话的连续性和效率。具体可通过 OpenClaw 的插件系统调用 CyberCode 的 CLI 或本地服务器接口。

## 值得深入的点
1. **记忆系统的透明化设计**: 如何将隐式的学习过程（如通信偏好、协作习惯）显式展示给用户，并允许编辑和删除，这为 Nova 的 agent 研究提供了可解释性设计的参考。
2. **多层上下文优化策略**: 每层优化（如 Caveman 压缩重复响应、RTK 压缩工具输出）的独立开关和预估节省范围，展示了如何在不牺牲质量的前提下管理 token 成本，对 Nova 的上下文窗口管理有启发。
3. **代码图的自动预检机制**: 在读取文件前自动选择紧凑的图排名预检，而非直接读取整个文件，这种“先看地图再走路”的策略可显著减少不必要的上下文消耗，适用于 Nova 的代码理解场景。

_extracted_by: deepseek-chat · 2026-07-21 09:10_
