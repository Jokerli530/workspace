# Pattern: labring/FastGPT

## 元信息
- repo: labring/FastGPT
- stars: 27886
- language: TypeScript
- discovered: 2026-04-30
- pattern_id: 20260430211947
- content_source: llm

## 特征
- description: FastGPT is a knowledge-based platform built on the LLMs, offers a comprehensive

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
  - langgenius/dify
  - lobehub/lobehub
  - n8n-io/n8n
  - nilbuild/developer-roadmap
  - openclaw/lobster
  - openclaw/openclaw
  - qwibitai/nanoclaw
  - ruvnet/ruflo
  - shareAI-lab/learn-claude-code
  - upstash/context7

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-30

## 深度分析（LLM 提炼）

## 核心定位
FastGPT 是一个基于大语言模型的知识库平台，通过可视化工作流编排，提供开箱即用的数据处理、模型调用和复杂 AI 应用构建能力。

## 技术栈
- **运行时**: Node.js (TypeScript)
- **前端**: React (Next.js)
- **后端**: Node.js (Express/Nest.js)
- **数据库**: MongoDB (用于知识库和对话存储), PostgreSQL (用于工作流和用户数据)
- **向量数据库**: 支持多种 (如 Milvus, Qdrant, Weaviate 等)
- **AI 模型**: 支持 OpenAI, Claude, Gemini 及兼容 API 的本地模型
- **部署**: Docker, Kubernetes (通过 Sealos)
- **其他**: Redis (缓存), MinIO (对象存储)

## 独特机制
1. **可视化工作流编排 (Flow)**: 提供拖拽式工作流编辑器，支持对话工作流、插件工作流和基础 RPA 节点，可构建复杂多步的 AI 应用，而不仅仅是简单的问答。
2. **双向 MCP 支持**: 支持模型上下文协议 (MCP) 的双向通信，允许 FastGPT 作为 MCP 客户端调用外部工具，也允许外部应用通过 MCP 调用 FastGPT 的能力，实现深度集成。
3. **知识库精细化管理**: 提供知识库的 chunk 级修改、删除、混合检索与重排，支持多种文件格式导入 (txt, md, pdf, docx, pptx, csv, xlsx 等)，并支持 API 知识库，实现动态数据接入。
4. **在 labring 生态中的定位**: FastGPT 是 labring 生态中的 AI 应用构建层，底层依赖 Sealos (云操作系统) 提供基础设施，Laf (云开发平台) 提供后端函数，AI Proxy 提供模型网关，共同构成从模型到应用的完整链路。

## 与 OpenClaw 集成可能
**可行，切入点明确**。最顺的切入点是利用 FastGPT 的 **OpenAPI 接口** 和 **MCP 双向支持**。OpenClaw 可以通过 FastGPT 的 completions API 直接调用其编排好的工作流，或通过 MCP 协议将 FastGPT 作为工具集成到 agent 的决策流程中，实现知识库查询、复杂任务编排等能力。

## 值得深入的点
1. **可视化工作流引擎的设计**: 研究其如何将 LLM 调用、知识库检索、条件判断、循环、API 调用等节点抽象为可拖拽的组件，并实现状态管理和执行调度，这对构建复杂 agent 工作流有直接参考价值。
2. **知识库的混合检索与重排机制**: 了解其如何融合向量检索、关键词检索和重排序模型，实现高精度的知识召回，这对提升 agent 的上下文质量和事实准确性至关重要。
3. **MCP 双向集成的实现**: 分析其如何实现 MCP 客户端和服务端功能，特别是如何处理工具注册、调用、结果返回等流程，这为 OpenClaw 接入外部工具生态提供了现成的模式参考。

_extracted_by: deepseek-chat · 2026-04-30 21:20_
