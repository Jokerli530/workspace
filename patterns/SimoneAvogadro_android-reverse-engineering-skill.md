# Pattern: SimoneAvogadro/android-reverse-engineering-skill

## 元信息
- repo: SimoneAvogadro/android-reverse-engineering-skill
- stars: 5236
- language: Shell
- discovered: 2026-04-27
- pattern_id: 20260427211754
- content_source: llm

## 特征
- description: Claude Code skill to support Android app's reverse engineering

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - a2aproject/A2A
  - anthropics/claude-code

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-27

## 深度分析（LLM 提炼）

## 核心定位
一个 Claude Code 技能（Skill），用于自动反编译 Android APK/XAPK/JAR/AAR 文件，并提取其中使用的 HTTP API（Retrofit 端点、OkHttp 调用、硬编码 URL、认证模式），以便在没有原始源代码的情况下记录和复现这些 API。

## 技术栈
- **运行时**: Claude Code（终端中的 AI 编码代理）
- **核心依赖**: Java JDK 17+, jadx（CLI）
- **可选依赖**: Vineflower / Fernflower（Java 反编译器）、dex2jar
- **脚本语言**: Bash（主）、PowerShell（实验性）
- **插件格式**: Claude Code 的 `.claude-plugin/` 和 `SKILL.md` 规范

## 独特机制
1. **API 语义提取而非通用反编译**: 与通用反编译工具不同，该项目专门聚焦于从反编译的 Java 代码中提取 HTTP API 调用模式（Retrofit 注解、OkHttp 构建器、URL 字符串），并输出结构化文档，而非仅输出源码。
2. **双引擎对比去混淆**: 支持同时运行 jadx 和 Fernflower/Vineflower 两个反编译器，并对比输出，以应对 ProGuard/R8 混淆，提高提取结果的准确性。
3. **调用流追踪**: 能从 Android 的 Activity/Fragment 出发，沿 ViewModel → Repository → HTTP 调用链追踪，还原 API 的完整调用上下文，而不仅仅是孤立地提取端点。
4. **Claude Code 原生集成**: 作为 Claude Code 的 Skill，它通过自然语言指令（如“Decompile this APK”）或 `/decompile` 斜杠命令激活，无缝融入 AI 编码代理的工作流，而非独立的 CLI 工具。在作者生态中，这是其唯一一个专注于逆向工程和 API 提取的 Claude Code Skill，与其其他 Tasker 自动化、MCP 文件访问等项目形成互补。

## 与 OpenClaw 集成可能
**可行，切入点明确**。OpenClaw 可以借鉴其“Skill”架构，将 `SKILL.md` 和脚本目录作为 OpenClaw 的一个“工具”或“插件”集成。最顺的切入点是：将 `scripts/` 目录下的 `decompile.sh`、`find-api-calls.sh` 等脚本封装为 OpenClaw 的 Agent 可调用的工具函数，并利用 `SKILL.md` 中定义的 5 阶段工作流（依赖检查、反编译、API 提取、调用流分析、结构化输出）作为 Agent 执行逆向任务的蓝图。

## 值得深入的点
1. **`api-extraction-patterns.md` 中的模式定义**: 该项目如何定义和匹配 Retrofit 注解（如 `@GET`、`@POST`）、OkHttp 的 `Request.Builder` 以及硬编码 URL 的正则或 AST 模式，这对 Nova 的 agent 研究如何从非结构化代码中提取结构化信息（如 API 端点、认证头）有直接启发。
2. **`call-flow-analysis.md` 中的调用链追踪逻辑**: 该项目如何从 Android 组件（Activity）出发，通过分析类引用和方法调用，构建从 UI 到网络层的调用链。这为 Nova 的 agent 研究如何理解复杂软件系统的运行时行为和数据流提供了具体的技术路线。
3. **双引擎对比去混淆策略**: 该项目如何协调 jadx 和 Fernflower 两个反编译器的输出，并处理结果不一致的情况。这种“多视角交叉验证”的思路，对于 agent 在信息不完整或存在噪声的环境下进行推理和决策具有借鉴意义。

_extracted_by: deepseek-chat · 2026-04-27 21:18_
