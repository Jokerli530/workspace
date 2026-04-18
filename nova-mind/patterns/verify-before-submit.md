# Instinct: verify-before-submit

```yaml
---
id: verify-before-submit
trigger: "当执行结果需要确认时（API调用、文件写入、状态修改）"
domain: workflow
confidence: 0.8
scope: global
source: "2026-04-18 Cycle 1-2 实际验证"
evidence_count: 4
last_verified: "2026-04-18"
---

## 行为

不做：`execute → done`（赌成功）
要做：`execute → verify response → confirm → done`

## 验证检查表

| 操作类型 | 验证方式 |
|----------|----------|
| curl API 调用 | 检查 HTTP status、JSON 结构 |
| ByteRover curate | 确认提交成功、无 error |
| OpenMOSS task 创建 | 确认返回 id |
| 文件写入 | 确认文件存在、内容正确 |
| git commit | 确认无冲突、有 hash 返回 |

## 证据

- Cycle 1: curl GitHub API 后用 `jq` 验证 JSON 结构 ✓
- Cycle 2: OpenMOSS task 创建后检查返回 id ✓
- 之前踩坑：API 报错但没验证就继续 → 后来才发现失败
- prax-agent Verification-First 原则验证了这个模式

## 置信度理由

- 4次实际执行，4次都用了验证
- 2次发现潜在问题（ByteRover 50次限制、API 超时）
- 适用于所有外部操作
