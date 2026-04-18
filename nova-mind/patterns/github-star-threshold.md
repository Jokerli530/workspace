# Instinct: github-star-threshold

```yaml
---
id: github-star-threshold
trigger: "发现新的 GitHub 项目时"
domain: research
confidence: 0.85
scope: global
source: "2026-04-18 Cycle 1-2 验证"
evidence_count: 8
last_verified: "2026-04-18"
---

## 行为

根据 stars 数量决定分析深度：

| Stars | 行动 | 分析深度 |
|--------|------|----------|
| > 10,000 | 立即深入分析，存入 deep-dives/ | 完整（README + 架构 + 对比） |
| > 1,000 | 标准分析 + curate to ByteRover | 中等（README + 关键发现） |
| > 100 | 快速扫描，有趣则记录 | 轻量（README 前100行） |
| < 100 | 跳过 | 无（除非极创新概念） |

## 例外条件

以下情况即使 <100 stars 也分析：
1. **创新概念**（编程语言、新协议、新架构）
   - 例：weft（typed graph 编程语言，781 stars）
   - 例：LLM Wiki skills（14 stars）
2. **创建 < 30 天**且 **stars > 50** → 爆发期
3. **与 OpenClaw/Nova 直接相关**

## 证据

| 项目 | Stars | 行动 | 结果 |
|------|-------|------|------|
| MemPalace | 47,614 | 深入分析 → deep-dives | ✓ 发现 96.6% RAG 真相 |
| prax-agent | 50 | 标准分析 | ✓ 发现 Verification-First |
| BuilderPulse | 900 | 标准分析 → Token 经济 | ✓ 验证需求 |
| 0 stars 项目 | 0 | 跳过 | ✓ 大多数无价值 |
| the_surrounding_system | 5 | 快速浏览（创新概念） | ✓ 发现 Harness Engineering |

## 置信度理由

- 8次实际判断，7次有效，1次例外（有理由）
- MemPalace 13天47k stars 验证了 stars 的预测力
- ECC 159k stars 验证了顶级项目的持续价值
