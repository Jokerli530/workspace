# Pattern: EvoMap/evolver

## 元信息
- repo: EvoMap/evolver
- stars: 6489
- language: JavaScript
- discovered: 2026-04-23
- pattern_id: 20260423110556
- content_source: llm

## 特征
- description: The GEP-powered self-evolving engine for AI agents. Auditable evolution with Gen

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点

## 同语言Sibling项目
  - affaan-m/everything-claude-code

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-04-23

## 深度分析（LLM 提炼）

## 核心定位
一个基于GEP协议、为AI智能体提供自我进化能力的核心引擎，旨在将临时、随机的提示词调整转变为可审计、可复用的进化资产。

## 技术栈
- Node.js (>= 18)
- Git (作为核心依赖，用于回滚、影响范围计算和固化操作)
- GEP (Gene Expression Protocol，基因表达协议)

## 独特机制
1. **协议约束的进化与审计追踪**：所有进化操作都遵循GEP协议，并自动生成`EvolutionEvent`记录到`./memory/`目录，确保进化过程可审计、可追溯，区别于常见的黑盒式提示词优化。
2. **基因与胶囊资产池**：内置一个可复用的“基因”与“胶囊”资产池，进化引擎通过扫描项目日志和信号，从中匹配并应用合适的进化策略，将进化能力模块化、资产化。
3. **双模式运行与离线优先**：提供CLI快速使用和源码贡献两种明确路径，且设计为完全离线运行，网络连接仅为可选功能，强调本地可控性。
4. **在作者生态中的定位**：是EvoMap进化网络的核心引擎。作者生态包含技能系统（green-tea-skill）、技能资产化工具（skill2gep）以及多个Awesome列表，本项目是驱动整个“智能体进化”愿景的技术核心。

## 与 OpenClaw 集成可能
最顺的切入点是利用Evolver生成的**GEP提示词**作为进化输出。OpenClaw可以作为一个“宿主运行时”，在智能体运行过程中或周期性地调用Evolver CLI（或其Proxy mailbox API），获取结构化的GEP提示词并应用于智能体，实现其能力的定向、可审计进化。

## 值得深入的点
1. **基于Git的进化安全机制**：将Git作为强制前置依赖，用于进化操作的版本控制、回滚和“爆炸半径”计算，为高风险的自进化操作提供了一个可靠的安全底座。
2. **“基因/胶囊”的资产化抽象**：将进化策略封装为可复用、可组合的“基因”和“胶囊”，这是一种将智能体能力进行编码、存储和传递的创新范式，对构建可积累的智能体知识库有启发。
3. **明确的进化审计流程**：强制性的`EvolutionEvent`记录和`./memory/`目录结构，为研究智能体的长期行为演变、分析进化有效性提供了标准化的数据基础。

_extracted_by: deepseek-chat · 2026-04-23 11:06_
