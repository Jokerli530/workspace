---
name: nova-growth
version: 1.0.0
description: Nova 自身成长自动化 - 四层心跳（反思/巡检/变现/内容）。barbaric-growth 负责外部发现，nova-growth 负责内部进化。
metadata: { "openclaw": { "emoji": "🌱", "tags": ["autonomous", "self-improvement", "nova"], "safety": "autonomous-only" }}
---

# nova-growth v1.0.0

> barbaric-growth 是向外看的眼睛（GitHub 趋势 + 关键词），nova-growth 是向内看的镜子。

## 四层心跳

| 层 | 脚本 | 频率 | 产出 |
|----|------|------|------|
| 反思 | `reflect.sh` | 每日 02:00 | `nova-mind/reflections/YYYY-MM-DD.md` — 跨项目规律 |
| 巡检 | `patrol.sh` | 每 4h | `/tmp/nova-patrol.log` + 必要时 ALERT.txt |
| 变现 | `ledger-review.sh` | 每周日 22:00 | `nova-mind/ledger-reviews/YYYY-WW.md` — ROI 周报 |
| 内容 | `content-synth.sh` | 每日 08:30 | `nova-mind/content-drafts/YYYY-MM-DD.md` — 小红书/X 草稿 |

## 依赖

- `~/.openclaw/secrets/deepseek.env` — `DEEPSEEK_API_KEY`（reflect + content-synth 需要）
- `~/.openclaw/secrets/github.env` — 选填（patrol 不需要）
- `workspace/patterns/` 目录（barbaric-growth 产出） — reflect/content-synth 的原料
- `/Users/nova/agent/ledger/` — ledger-review 的原料
- `/Users/nova/agent/logs/` + `launchctl list com.nova.agent` — patrol 的检查目标

## 设计原则

1. **所有脚本可独立 --mode=full 手动跑**，不依赖 LaunchAgent
2. **失败静默** — DeepSeek 挂了就降级写原始数据，不阻塞下次
3. **锁文件串行** — 每个脚本独立 lock，避免同名重叠
4. **产出幂等** — 同一天多跑只覆盖当日文件，不累积垃圾
5. **token 预算** — reflect + content-synth 合计 ~0.01 元/天（DeepSeek）

## LaunchAgents

- `ai.openclaw.nova-reflect.plist` — StartCalendarInterval 02:00
- `ai.openclaw.nova-patrol.plist` — StartInterval 14400 (4h)
- `ai.openclaw.nova-ledger.plist` — StartCalendarInterval Weekday=0 Hour=22
- `ai.openclaw.nova-content.plist` — StartCalendarInterval 08:30

## 与 barbaric-growth 的职责切分

| 维度 | barbaric-growth | nova-growth |
|------|-----------------|-------------|
| 视角 | 向外（GitHub/社区） | 向内（自己的历史/状态） |
| 输入 | API | 文件系统（patterns/ledger/logs） |
| 输出 | patterns/*.md | reflections / reviews / drafts |
| 触发失败容忍 | 重要（网络依赖） | 无所谓（本地纯计算） |
