# Pattern: feifeibear/long-context-attention

## 元信息
- repo: feifeibear/long-context-attention
- stars: 668
- language: Python
- discovered: 2026-05-24
- pattern_id: 20260524091112
- content_source: llm

## 特征
- description: USP: Unified (a.k.a. Hybrid, 2D) Sequence Parallel Attention for Long Context Tr

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库

## 同语言Sibling项目
  - 666ghj/MiroFish
  - ComposioHQ/awesome-claude-skills
  - ECNU-ICALK/AutoSkill
  - EbookFoundation/free-programming-books
  - Fosowl/agenticSeek
  - Human-Agent-Society/CORAL
  - JuliusBrussee/caveman
  - NVIDIA/TensorRT-LLM
  - NVIDIA/kvpress
  - NousResearch/hermes-agent-self-evolution
  - NousResearch/hermes-agent
  - PKU-YuanGroup/Helios
  - SandAI-org/MagiAttention
  - TauricResearch/TradingAgents
  - ag-ui-protocol/ag-ui
  - agentic-in/elephant-agent
  - assafelovic/gpt-researcher
  - bytedance/deer-flow
  - crewAIInc/crewAI
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
- updated: 2026-05-24

## 深度分析（LLM 提炼）

## 核心定位
YunChang（USP）是一个统一序列并行注意力机制，融合 DeepSpeed-Ulysses-Attention 和 Ring-Attention 两种分布式注意力方法，解决长上下文 LLM 训练和推理中单一方法在头数敏感性和通信效率上的缺陷。

## 技术栈
- **运行时**：Python, PyTorch, CUDA
- **核心依赖**：FlashAttention (v2/v3), torch.distributed
- **通信原语**：NCCL (collective + P2P)
- **参考项目**：zhuzilin/ring-flash-attention, DeepSpeed-Ulysses, NVIDIA/TransformerEngine

## 独特机制
1. **混合序列并行（Hybrid SP）**：将 Ulysses（沿头维度切分，集体通信）与 Ring（沿序列维度切分，P2P 通信）组合，支持 `sp_ulysses_degree × sp_ring_degree` 的二维并行度，突破单一方法在 GQA/MQA 场景下的头数限制。
2. **因果注意力负载均衡**：提供 `zigzag` 和 `stripe` 两种 token 重排策略，解决因果掩码下 Ring-Attention 的负载不均问题，避免传统 Ring 中因因果性导致的空闲计算。
3. **无 FlashAttention 回退**：支持 `AttnType.TORCH_EFFICIENT`，可在 NPU 等不支持 FA 的硬件上运行（仅前向），降低硬件依赖门槛。

**作者生态定位**：本项目是 feifeibear 序列并行系列的核心产出，与其早期项目 `Odysseus-Transformer`（LLM 序列并行实验场）一脉相承，但更聚焦于生产级注意力层实现；与 `LLMSpeculativeSampling`（投机解码）和 `LLMRoofline`（硬件性能建模）共同构成其 LLM 系统优化工具链。

## 与 OpenClaw 集成可能
**可行，切入点明确**：OpenClaw 的 agent 若需处理超长上下文（如多轮对话历史、长文档推理），可将 `LongContextAttention` 作为分布式注意力后端替换现有实现。最顺的集成路径是：
- 在 agent 的 transformer 层中，用 `set_seq_parallel_pg` 配置并行度，调用 `LongContextAttention` 替代原生 attention。
- 若 OpenClaw 运行在单机多卡环境，可直接利用其 `zigzag` 模式实现因果注意力的负载均衡，无需修改数据流。

## 值得深入的点
1. **二维并行度动态组合**：`sp_ulysses_degree` 和 `sp_ring_degree` 的乘积等于总 GPU 数，但如何根据模型头数、序列长度、硬件拓扑自动选择最优组合？这为 agent 的自动并行策略搜索提供了具体案例。
2. **因果注意力的 token 重排策略**：`zigzag` 和 `stripe` 的具体实现细节（如如何保证每个 rank 计算量均衡且通信模式可预测），对 agent 在异构设备上调度计算-通信重叠有直接参考价值。
3. **无 FA 回退路径**：`AttnType.TORCH_EFFICIENT` 的实现方式（纯 PyTorch 算子组合），展示了如何在不依赖专用 kernel 的情况下保持分布式语义，这对 agent 在受限环境（如边缘设备）部署长上下文模型有启发。

_extracted_by: deepseek-chat · 2026-05-24 09:11_
