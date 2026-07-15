# Pattern: katanemo/plano

## 元信息
- repo: katanemo/plano
- stars: 6407
- language: Rust
- discovered: 2026-04-30
- pattern_id: 20260430212046
- content_source: llm

## 特征
- description: Plano is an AI-native proxy and data plane for agentic apps — with built-in orch

## 调研要点（Rust）
- 所有权系统 + 生命周期
- 并发模型（async/await、channel）
- crates.io生态
- 性能优化手段

## 同语言Sibling项目
  - farion1231/cc-switch

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-30

## 深度分析（LLM 提炼）

## 核心定位
Plano 是一个 AI 原生代理和数据面，用于将智能体应用从演示阶段安全、可靠、可重复地推向生产环境，通过一个统一的、进程外的数据面来集中处理路由、编排、护栏和可观测性等核心交付问题。

## 技术栈
- **Rust**（主语言）
- **Envoy**（底层代理，由核心贡献者构建）
- **OpenAI 兼容 API**（智能体通信协议）
- **YAML**（配置声明）
- **OTEL**（OpenTelemetry 追踪/指标）
- **Docker**（部署方式）

## 独特机制
1. **声明式 YAML 编排**：用户只需在 YAML 中定义智能体 URL 和自然语言描述，Plano 自动处理意图分类、路由逻辑、模型回退和提供者适配，无需在应用代码中编写这些“隐藏中间件”。
2. **内置专用路由模型**：使用自研的 4B 参数 `plano_orchestrator_v1` 模型进行智能体路由，而非依赖通用 LLM 或硬编码规则，实现低延迟、高精度的意图分发。
3. **零代码 Agentic Signals™**：自动捕获每个智能体的信号（Signals）和 OTEL 追踪/指标，无需在应用代码中手动埋点，直接用于持续改进和评估。
4. **Filter Chain 机制**：通过可配置的过滤器链统一实现越狱防护、内容审核和记忆策略，而非在每个智能体中重复实现。

**作者生态定位**：Plano 是 Katanemo 的核心产品，与 `Arch-Function`（高级函数调用模型）和 `katanemo-aaa`（API 身份与细粒度授权）形成互补，共同构建 AI 应用的全栈基础设施。

## 与 OpenClaw 集成可能
**可行，切入点明确**：将 Plano 作为 OpenClaw 的智能体编排和数据面层。OpenClaw 的 agent 可注册为 Plano 的 YAML 配置中的智能体（HTTP 端点），Plano 负责路由用户请求到正确的 OpenClaw agent、管理 LLM 模型切换、统一应用护栏和可观测性。这样 OpenClaw 可以专注于 agent 核心逻辑，而将生产化所需的“管道”工作交给 Plano。

## 值得深入的点
1. **基于专用小模型的路由策略**：Plano 使用 4B 参数的 `plano_orchestrator_v1` 进行智能体路由，而非通用大模型。这种“小模型+特定任务”的设计思路对 Nova 的 agent 研究很有启发——在 agent 系统中，路由/意图分类这类高频低复杂度任务可以用更轻量的模型实现，降低延迟和成本。
2. **Filter Chain 的模块化安全设计**：将越狱防护、内容审核、记忆等横切关注点抽象为可组合的过滤器链，而非嵌入每个 agent 代码。这种架构模式值得 Nova 借鉴，用于统一管理 agent 的安全策略和上下文记忆。
3. **零代码可观测性（Agentic Signals）**：Plano 自动捕获 agent 交互信号和 OTEL 追踪，无需开发者手动埋点。这种“数据面自动采集”的思路对 Nova 的 agent 研究有参考价值——如何在不侵入 agent 代码的前提下，获得足够丰富的运行时信号用于调试和评估。

_extracted_by: deepseek-chat · 2026-04-30 21:21_
