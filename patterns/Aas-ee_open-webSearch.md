# Pattern: Aas-ee/open-webSearch

## 元信息
- repo: Aas-ee/open-webSearch
- stars: 1032
- language: TypeScript
- discovered: 2026-04-23
- pattern_id: 20260423110912
- content_source: llm

## 特征
- description: Multi-engine MCP server, CLI, and local daemon for agent web search and content

## 调研要点（TypeScript）
- 框架选择（React/Vue/Node/Next.js）
- 类型系统使用（strict、泛型）
- 包管理（npm/pnpm/yarn）
- 与OpenClaw的集成点

## 同语言Sibling项目
  - CherryHQ/cherry-studio
  - cline/cline
  - CopilotKit/CopilotKit
  - freeCodeCamp/freeCodeCamp
  - getsentry/XcodeBuildMCP
  - google-gemini/gemini-cli
  - gsd-build/gsd-2
  - kamranahmedse/developer-roadmap
  - langgenius/dify
  - lobehub/lobehub
  - openclaw/lobster
  - openclaw/openclaw
  - ruvnet/ruflo

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-23

## 深度分析（LLM 提炼）

## 核心定位
一个无需API密钥、支持多搜索引擎和内容抓取的开源MCP服务器、CLI与本地守护进程，为智能体提供实时网络搜索和内容检索能力。

## 技术栈
- **运行时/语言**: Node.js, TypeScript
- **核心框架/库**: MCP SDK, Playwright
- **关键依赖**: `@modelcontextprotocol/sdk`, `playwright`, `cheerio`, `express`

## 独特机制
1. **无密钥多引擎聚合搜索**：通过模拟浏览器访问，直接聚合Bing、百度、DuckDuckGo、Brave等近10个搜索引擎的结果，完全规避了商业搜索API的调用限制和费用。
2. **MCP原生与本地守护进程双模式**：既可作为标准MCP服务器接入Claude Desktop等生态，又可作为独立的本地HTTP守护进程（`open-websearch serve`）运行，为自动化智能体脚本提供低延迟、可复用的服务。
3. **技能引导的智能体工作流**：项目配套一个“技能”（skill），能引导智能体完成环境检测、自动安装、守护进程启动与验证的全流程，降低了智能体集成使用的门槛。
4. **在作者生态中的定位**：这是作者Aas-ee在MCP工具生态中的核心项目，其“技能”引导模式与CLI/守护进程架构，旨在为各类AI智能体（如Cherry Studio、Cursor中的代理）提供稳定、易集成的网络信息获取基础能力。

## 与 OpenClaw 集成可能
最顺的切入点是将其作为**独立的本地搜索服务**接入。OpenClaw可以调用其本地守护进程的HTTP API（`POST /search`），或直接集成其CLI命令，为平台内的智能体提供无需配置API密钥的网络搜索工具。其“技能”引导的安装激活流程也可被OpenClaw借鉴，用于管理外部工具依赖。

## 值得深入的点
1. **“技能”作为智能体工具发现与激活层**：其配套的`open-websearch` skill 演示了如何设计一个引导层，让智能体能够自主完成“检测环境->安装/启动->验证->使用”的完整工具调用链，这对设计可自举的智能体工具生态有启发。
2. **Playwright用于规避反爬与内容提取**：项目利用Playwright进行真实浏览器模拟，不仅用于执行搜索，还用于抓取CSDN、GitHub README等特定站点的内容，这种方案在应对现代网页反爬机制和动态内容渲染方面比传统HTTP请求更鲁棒。
3. **安装代理与运行时代理的分离设计**：在README中明确区分了安装依赖时的npm代理配置和守护进程运行时的网络代理配置，这种设计考虑到了企业级网络环境下的复杂代理场景，提升了工具在受限环境下的可用性。

_extracted_by: deepseek-chat · 2026-04-23 11:09_
