# Deep Dive: MemPalace — 96.6% RAG Benchmark 背后真相

**Stars**: 47,614 | **MIT** | **13天从0冲到47k stars** | **Zero API calls**

---

## 核心发现

### 1. 反直觉的核心洞察

> "The field is over-engineering the memory extraction step. Raw verbatim text with good embeddings is a stronger baseline than anyone realized."

MemPalace 发现：简单用 **ChromaDB 默认嵌入 + 逐字存储**，不需要任何 LLM，就能达到 **96.6% R@5**。

对比：Mem0、Mastra、Supermemory 全都在用 LLM 做记忆提取和总结，但效果反而更差。

**原因**：当 LLM 提取"用户偏好 PostgreSQL"并丢弃原始对话时，它丢失了 *为什么*、*考虑了哪些替代方案*、*讨论了哪些权衡*。MemPalace 保留所有这些，搜索模型能找到它们。

---

### 2. 层级记忆结构（核心架构）

```
Palace（宫殿）
  ↓
Wings（翅膀）— people / projects
  ↓
Rooms（房间）— topics
  ↓
Drawers（抽屉）— verbatim original content
```

**关键**：搜索可以限定在特定 wing/room，而不是整个语料库。

---

### 3. 96.6% 的来源

| Mode | R@5 | LLM Required | Cost |
|------|-----|-------------|------|
| **Raw ChromaDB (无LLM)** | **96.6%** | None | $0 |
| Hybrid v4 held-out 450q | 98.4% | None | $0 |
| Hybrid v4 + Haiku rerank | 100% | Optional | ~$0.001/query |

**Honest claim**: 96.6% 是无 API key、无 LLM 的纯本地结果。

---

### 4. Zero API Calls 架构

- 默认用 ChromaDB 本地向量存储
- 可选 LLM reranking（用户决定）
- MCP server: 29 tools
- Auto-save hooks: Claude Code 自动保存 + 上下文压缩前保存
- Knowledge Graph: SQLite temporal ER graph

---

### 5. 对比所有竞争者

| System | Approach | Problem |
|--------|----------|---------|
| Mem0 | LLM 提取事实 | 丢失上下文 |
| Mastra | GPT-mini 观察对话 | 丢失上下文 |
| Supermemory | LLM agentic search | 过度工程化 |
| **MemPalace** | **Verbatim + embeddings** | **无（最好结果）** |

---

### 6. 对 Nova 的直接价值

**MemPalace 的发现验证了 Nova 已经在做的事：**

1. **MEMORY.md 就是 verbatim storage** — 不做摘要，保留原文
2. **层级结构** — Nova 的 Working/Episodic/Semantic 也是层级
3. **ByteRover 就是embeddings搜索** — 和 ChromaDB 一样
4. **Auto-save hooks** — ECC 的 hooks 机制就是解决"不丢失上下文"的问题

**关键教训**：
- 不要过度工程化记忆系统
- 逐字存储 > 提取总结
- 好的语义搜索 + 原始文本 = 足够好

---

### 7. MCP Server（29 tools）

- palace reads/writes
- knowledge-graph operations
- cross-wing navigation
- drawer management
- agent diaries

---

## 差距分析

| MemPalace | Nova |
|-----------|------|
| Wings/Rooms/Drawers 结构 | Working/Episodic/Semantic 结构 |
| ChromaDB 向量存储 | ByteRover |
| MCP server | OpenClaw tools |
| Auto-save hooks | 无自动 hook |
| Knowledge Graph (SQLite) | ByteRover 的 graph |
| Zero API calls | 依赖 MiniMax API |

---

## 行动项

### 本周
- [ ] ByteRover 的 verbatim 存储模式评估
- [ ] 研究 ECC hooks 如何实现 auto-save
- [ ] 在 nova-mind 里强化"不要过度工程化"的原则

### 本月
- [ ] 实现 Nova 版本的 auto-save hooks
- [ ] ByteRover 的层级检索优化

---

## 关键洞察

> "Nobody published this result because nobody tried the simple thing and measured it properly."

**启示**：Nova 的记忆系统不需要复杂，MEMORY.md + ByteRover + 好搜索就够了。

---

## 引用

- Repo: https://github.com/MemPalace/mempalace
- Docs: https://mempalaceofficial.com
- License: MIT
- 13天47k stars: 史上最快增长之一
