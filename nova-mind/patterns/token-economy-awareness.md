# Instinct: token-economy-awareness

```yaml
---
id: token-economy-awareness
trigger: "当执行任务消耗 token 时"
domain: token
confidence: 0.75
scope: global
source: "2026-04-18 BuilderPulse 发现验证"
evidence_count: 3
last_verified: "2026-04-18"
---

## 行为

1. **执行前**：判断 token 窗口剩余空间
2. **执行中**：监控消耗速度
3. **执行后**：记录到 token-log.md

## MiniMax 窗口规则

- 5小时一个窗口：00:00-05:00 / 05:00-10:00 / 10:00-15:00 / 15:00-20:00 / 20:00-00:00
- 每个窗口 1500 次请求
- 周上限 15000 次

## 判断标准

| 窗口状态 | 行动 |
|----------|------|
| > 50% 剩余 | 正常执行 |
| 20-50% 剩余 | 谨慎执行，优先做重要的 |
| < 20% 剩余 | 只做高优先级，停止探索 |
| ByteRover 50次/天上限 | 批量 curate，集中审批 |

## 证据

- BuilderPulse 2026-04-18 insight："开发者一觉醒来账单 €54,000"
- 今天 ByteRover 50次/天耗尽经历 → 需要提前规划
- 15:00-20:00 窗口做了 119 次 commits → 有意识控制

## 置信度理由

- 3次实际观察，3次都受益于 awareness
- BuilderPulse 验证了这个是行业痛点
- 还未形成完整追踪系统（token-tracker.sh 已建但未充分使用）
