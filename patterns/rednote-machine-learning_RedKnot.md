# Pattern: rednote-machine-learning/RedKnot

## 元信息
- repo: rednote-machine-learning/RedKnot
- stars: 1218
- language: Python
- discovered: 2026-07-20
- pattern_id: 20260720211016
- content_source: llm

## 特征
- description: Efficient Long-Context LLM Serving with Head-Aware KV Reuse and SegPagedAttentio

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
  - NVIDIA/RULER
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
- updated: 2026-07-20

## 深度分析（LLM 提炼）

## 核心定位
RedKnot 是一个基于 SGLang 的长上下文 LLM 推理加速集成方案，核心解决长上下文场景下预填充阶段计算量过大、首 token 生成时间（TTFT）过长的问题，通过头感知的 KV 缓存复用和弹性稀疏 FFN 实现近无损加速。

## 技术栈
- **框架**: SGLang（作为注意力层扩展集成）
- **运行时**: Python, NVIDIA L20Y GPU
- **关键依赖**: FlashAttention-2/3, transformers 5.x（部分模型）
- **支持模型**: Qwen3, Mistral, Llama3.3, Qwen3.5-MoE, DeepSeek-V4
- **硬件适配**: 华为 Ascend NPU（进行中）

## 独特机制
1. **头分类（Head Classification）**: 将每个 `(layer, kv_head)` 分为 global/local/retrieval/dense 四类，每类采用不同的 KV 存储和复用策略，而非对所有注意力头一视同仁。
2. **离线 KV 复用 + RoPE 重定位**: 对可复用段离线存储 KV，服务时仅选择性重计算必要 token，并通过 RoPE 重定位保证数值对齐，避免全量预填充。
3. **弹性稀疏 FFN（Elastic Sparsity）**: 基于注意力重要性对 token 进行选择，跳过低贡献 token 的前馈计算，进一步减少计算量。
4. **SegPagedAttention 运行时**: 每头独立页表 + 分段 KV 存储，不同头类可拥有不同的可见窗口，突破传统 PagedAttention 的全局窗口限制。

## 与 OpenClaw 集成可能
**可行，切入点明确**。RedKnot 作为 SGLang 的注意力层扩展（位于 `python/sglang/srt/layers/attention/redknot/`），可直接作为 OpenClaw 推理引擎的注意力模块替换。最顺的路径是：将 RedKnot 的头分类配置和 SegPagedAttention 运行时封装为 OpenClaw 的注意力后端插件，通过配置开关启用长上下文加速，无需改动 OpenClaw 整体架构。

## 值得深入的点
1. **头分类策略的自动化**: 项目通过 `head_profiler.py` 自动对头进行分类，这种基于 profiling 的离线分类方法对 agent 研究很有启发——agent 的注意力模式也可通过类似方式离线分析，实现推理时动态资源分配。
2. **RoPE 重定位的数值对齐机制**: 在 KV 复用中保证位置编码数值一致性是关键技术难点，`rope_helper.py` 的实现思路可迁移到 agent 的长对话历史压缩场景，解决位置编码漂移问题。
3. **稀疏 FFN 的 token 选择策略**: 基于注意力重要性跳过 FFN 计算，这种 token 级稀疏化思路可应用于 agent 的思维链压缩——只对关键推理步骤进行完整计算，非关键步骤跳过或简化。

_extracted_by: deepseek-chat · 2026-07-20 21:10_
