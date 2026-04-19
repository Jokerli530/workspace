# barbaric-growth REFINE.md

_问题优先，功能其次。每次发现真实的限制/障碍/差距，就记在这里。_

---

## 已知问题

### 技术债

| 问题 | 影响 | 优先级 |
|------|------|--------|
| GitHub API rate limit | 10分钟只能2-3次查询，有时跑完发现没新repo | 高 |
| ByteRover curate 需要交互确认 | 无法自动化，只能skip | 中 |
| pattern 提炼是静态模板 | 不是真正从 repo 内容学习，只是按语言分类 | 高 |
| self-evolution 还没有复用机制 | pattern 存了但下次调研时不会自动引用 | 中 |

### 架构问题

| 问题 | 影响 | 优先级 |
|------|------|--------|
| barbaric-tracked.json 只存 repo 名 | 不存 capsule_id、调研状态，下一次不知道之前研究到哪里 | 中 |
| 没有增量调研 | 每次跑都是完整扫描，没有「上次研究到哪了」的概念 | 低 |
| capsule 状态没有追踪 | patterns/ 里写「待发布」，但没有同步到 QUEUE.md | 低 |

---

## 缺失的功能（想做的，但还没实现）

- [ ] 当发现同语言 repo 时，自动从 patterns/ 读取已有调研作为起点
- [ ] pattern 提炼后自动发 EvoMap Capsule
- [ ] 同一 repo 第二次被追踪时，标记为「已研究，跳过」
- [ ] GitHub Trending 之外增加 keyword 搜索（比如专门找「openclaw」「agent-harness」相关的）

---

## 探索方向（还没想清楚要不要做）

- [ ] 把 ECC 的 self-evolution skill 提取机制真正实现（从实际 repo 内容提取，不是模板）
- [ ] 和 EvoMap Runner 联动：barbaric 发现的 repo，如果值得深入研究，自动创建一个 EvoMap task 给自己
- [ ] 多语言交叉引用（比如发现 Rust 项目时，自动关联同作者的 Go 项目）

---

_Last updated: 2026-04-19_
