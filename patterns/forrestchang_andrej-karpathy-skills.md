# Pattern: forrestchang/andrej-karpathy-skills

## 元信息
- repo: forrestchang/andrej-karpathy-skills
- stars: 82528
- language: None
- discovered: 2026-04-24
- pattern_id: 20260424211448
- content_source: llm

## 特征
- description: A single CLAUDE.md file to improve Claude Code behavior, derived from Andrej Kar

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - VoltAgent/awesome-openclaw-skills
  - Xnhyacinth/Awesome-LLM-Long-Context-Modeling
  - punkpeye/awesome-mcp-servers
  - sindresorhus/awesome
  - x1xhlol/system-prompts-and-models-of-ai-tools

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-24

## 深度分析（LLM 提炼）

## 核心定位
这是一个单一的 `CLAUDE.md` 配置文件，旨在通过注入四条核心编码原则（先思考、简洁优先、精准修改、目标驱动），系统性纠正 Claude Code 等 LLM 编码助手常见的过度工程、假设错误、无意义修改等问题。

## 技术栈
- **运行时/平台**: Claude Code (CLI), Cursor (IDE)
- **配置文件格式**: Markdown (`CLAUDE.md`, `.cursor/rules/karpathy-guidelines.mdc`)
- **安装方式**: Claude Code 插件市场 (`/plugin` 命令), curl 下载, 手动追加
- **无外部依赖**: 纯文本规则文件，无需编译或安装包

## 独特机制
1. **原则-问题直接映射**: 每条原则精确对应 Andrej Karpathy 指出的一个具体 LLM 编码缺陷（如“先思考”对应“错误假设”），而非泛泛的“写更好的代码”。
2. **可验证的“目标驱动”执行**: 将“添加验证”等模糊指令转化为“为无效输入编写测试，然后使其通过”的闭环，并给出 `[Step] → verify: [check]` 的模板，让 LLM 能自主循环直到目标达成。
3. **“外科手术式修改”的严格约束**: 明确禁止“改进”无关代码、删除未请求的死代码，并给出“每行改动都应直接追溯到用户请求”的测试标准，直接解决 LLM 的“附带损害”问题。
4. **作者生态定位**: 该项目是作者 `forrestchang` 在“AI 编码代理行为控制”方向的核心作品，与其 `worktree-workflow`（并行开发工具）和 `Multica`（编码代理管理平台）形成互补，共同构成一套从规则到工具到平台的完整工作流。

## 与 OpenClaw 集成可能
**切入点明确且直接**: 该项目本质上就是一个“技能”（Skill），完全符合 OpenClaw 生态的“技能”定义。最顺的切入点是将其作为 OpenClaw 的**默认行为规范技能**，在 agent 初始化时自动注入 `CLAUDE.md` 内容，或通过 OpenClaw 的“技能市场”机制提供一键安装。其“插件市场”安装方式 (`/plugin install`) 与 OpenClaw 的技能管理理念高度契合。

## 值得深入的点
1. **“目标驱动”的指令转换模式**: 研究如何将用户模糊的自然语言需求（如“优化性能”）自动转化为可验证的成功标准（如“响应时间 < 200ms，测试通过”），这是提升 agent 自主性和可靠性的关键。
2. **“外科手术式修改”的代码变更追踪**: 其“每行改动都应直接追溯到用户请求”的测试标准，可启发 Nova 设计一种**变更溯源机制**，在 agent 生成代码时自动标注每行修改的“动机”，从而在代码审查时快速识别无关修改。
3. **原则的“可测试性”**: 该项目不仅定义了原则，还定义了“如何知道它在工作”的观察指标（如“更少的无关 diff”、“更少的重写”）。这为评估 agent 行为质量提供了可量化的启发，可集成到 Nova 的 agent 评估框架中。

_extracted_by: deepseek-chat · 2026-04-24 21:15_
