# Pattern: NVIDIA/RULER

## 元信息
- repo: NVIDIA/RULER
- stars: 1568
- language: Python
- discovered: 2026-06-28
- pattern_id: 20260628092144
- content_source: llm

## 特征
- description: This repo contains the source code for RULER: What’s the Real Context Size of Yo

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库

## 同语言Sibling项目
  - 666ghj/MiroFish
  - ComposioHQ/awesome-claude-skills
  - D4Vinci/Scrapling
  - ECNU-ICALK/AutoSkill
  - EbookFoundation/free-programming-books
  - Fosowl/agenticSeek
  - Human-Agent-Society/CORAL
  - JuliusBrussee/caveman
  - NVIDIA/TensorRT-LLM
  - NVIDIA/kvpress
  - NousResearch/hermes-agent-self-evolution
  - NousResearch/hermes-agent
  - OthmanAdi/planning-with-files
  - PKU-YuanGroup/Helios
  - SandAI-org/MagiAttention
  - TauricResearch/TradingAgents
  - ag-ui-protocol/ag-ui
  - agentic-in/elephant-agent
  - anysearch-ai/anysearch-skill
  - assafelovic/gpt-researcher
  - bytedance/deer-flow
  - crewAIInc/crewAI
  - feifeibear/long-context-attention
  - hesreallyhim/awesome-claude-code
  - infiniflow/ragflow
  - khoj-ai/khoj
  - langchain-ai/deepagents
  - mem0ai/mem0
  - microsoft/MInference
  - muratcankoylan/Agent-Skills-for-Context-Engineering
  - neuml/txtai
  - public-apis/public-apis
  - safishamsi/graphify
  - sansan0/TrendRadar
  - ymcui/Chinese-LLaMA-Alpaca-2
  - zhayujie/CowAgent

## EvoMap Capsule
- capsule_id: 待发布
- category: 待定
- updated: 2026-06-28

## 深度分析（LLM 提炼）

## 核心定位
RULER 是一个长上下文语言模型的评测基准，通过生成可配置序列长度和任务复杂度的合成样本，系统性地评估模型在超过简单上下文召回能力之外的“真实有效上下文长度”。

## 技术栈
- Python
- PyTorch（推断依赖）
- HuggingFace Transformers（模型加载）
- 合成数据生成脚本（无外部数据依赖）

## 独特机制
1. **多任务分层评测**：涵盖 4 大类共 13 个任务（如多键检索、变量追踪、聚合计数等），不仅测“能不能找到”，还测“能不能推理”，比单任务 needle-in-haystack 更全面。
2. **可配置复杂度**：支持控制序列长度和任务难度（如插入的干扰信息数量），能系统性地找出模型性能从“稳定”到“崩溃”的临界点，从而定义“有效长度”而非“宣称长度”。
3. **标准化对比框架**：已对 17+ 个开源模型进行统一评测，输出表格可直接横向对比，结果可复现。该项目是 NVIDIA 在 LLM 评测生态中的一环，与 NeMoClaw（agent 安全运行）、SkillSpector（技能安全扫描）等形成互补——RULER 提供底层模型的长上下文能力评估，为上层 agent 应用（如 OpenClaw）选择合适的基础模型提供依据。

## 与 OpenClaw 集成可能
**可行，切入点明确**：OpenClaw 在构建 agent 时，常需要处理长上下文（如多轮对话、长文档分析）。RULER 的评测框架可直接作为 OpenClaw 的“模型选型工具”——在集成新模型前，先用 RULER 跑一遍，获取其在不同长度和复杂度下的真实表现，从而决定该模型是否适合 OpenClaw 的特定任务场景（如 32K 上下文内的多工具调用 vs 128K 的长文档问答）。

## 值得深入的点
1. **任务复杂度与有效长度的关系**：RULER 发现模型在不同任务上的有效长度差异显著（如某些模型在检索任务上表现好，但在聚合推理任务上提前崩溃）。这对 agent 研究意味着：不能仅凭单一指标（如“支持 128K”）判断模型能力，需根据 agent 实际任务类型（检索 vs 推理）选择模型。
2. **干扰信息密度的影响**：RULER 通过插入无关文本控制任务难度，揭示了模型对“噪声”的鲁棒性。这对 agent 的上下文管理有启发——如何设计 prompt 结构以减少干扰、提升模型在长上下文中的实际表现。
3. **合成数据生成方法**：RULER 完全依赖合成数据，无需人工标注，且能精确控制变量。这种范式可被 agent 研究借鉴，用于生成特定场景的评测数据（如多工具调用、多步推理），从而系统性地测试 agent 系统的能力边界。

_extracted_by: deepseek-chat · 2026-06-28 09:21_
