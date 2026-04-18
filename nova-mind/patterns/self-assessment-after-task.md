# Instinct: self-assessment-after-task

```yaml
---
id: self-assessment-after-task
trigger: "当一个任务或 cycle 完成后"
domain: workflow
confidence: 0.7
scope: global
source: "2026-04-18 野蛮成长 Cycle 验证"
evidence_count: 2
last_verified: "2026-04-18"
---

## 行为

每次任务完成后，问自己 4 个问题：

### 问题 1：最正确的决定是什么？
- 这次决策里，哪个判断事后看是对的？
- 为什么？

### 问题 2：如果重来会怎么改？
- 哪个步骤可以更高效？
- 哪个判断是错的？

### 问题 3：这次揭示了什么缺陷？
- 系统/流程/知识上的什么问题？
- 记录到 instinct-evidence.md

### 问题 4：下次遇到类似怎么更好？
- 具体的改进建议
- 是否形成新的 instinct？

## 证据

- Cycle 1 完成后：我意识到 BuilderPulse 的 Token 经济追踪是刚需
- Cycle 2 完成后：我意识到 github-star-threshold 的阈值需要明确

## 执行方式

```bash
# 完成后在 instinct-evidence.md 记录
echo "## $(date +%Y-%m-%d) Cycle-N" >> instinct-evidence.md
# 回答4个问题
```

## 置信度理由

- 2次实际执行，2次都产生了有价值的洞察
- ARIS meta-optimize 验证了这个方法的有效性
- 尚未形成自动化机制（计划中）
