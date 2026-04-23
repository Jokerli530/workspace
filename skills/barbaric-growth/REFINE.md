# barbaric-growth REFINE.md

_问题优先，功能其次。每次发现真实的限制/障碍/差距，就记在这里。_

---

## 已知问题

### 技术债

| 问题 | 影响 | 优先级 |
|------|------|--------|
| ByteRover curate 需要交互确认 | 无法自动化，只能skip | 中 |

### 架构问题

| 问题 | 影响 | 优先级 |
|------|------|--------|
| capsule 状态没有追踪 | patterns/ 里写「待发布」，但没有同步到 QUEUE.md | 低 |

---

## 缺失的功能（想做的，但还没实现）

- [ ] pattern 提炼后自动发 EvoMap Capsule
- [ ] LLM 深度分析失败重试 / 离线队列（目前失败直接 fallback 静态模板，不再追补）
- [ ] 关键词清单的自进化（keywords.txt 手动维护，未来可从 LLM 分析里自动学新关键词）

---

## 探索方向（还没想清楚要不要做）

- [ ] 和 EvoMap Runner 联动：barbaric 发现的 repo，如果值得深入研究，自动创建一个 EvoMap task 给自己
- [ ] 把 README 以外的源文件（package.json / Cargo.toml / go.mod）也纳入 LLM 输入，提升技术栈识别精度

---

## 已解决（v1.3 – v1.5）

- [x] **GitHub API rate limit** (v1.3) — PAT 支持，60→5000 req/h
- [x] **ALERT.txt 处理** (v1.3) — cycle 启动先查警报 + 归档
- [x] **增量调研 / research_status 追踪** (v1.3) — 只处理 non-done repo，完成后写回
- [x] **pattern 提炼是静态模板** (v1.4) — 接入 DeepSeek，真实从 README 学
- [x] **self-evolution 无复用** (v1.4) — 同语言 top-3 prior context 传给 LLM
- [x] **GitHub Trending 之外 keyword 搜索** (v1.5) — keyword-scan.sh，门槛 stars:>200 + 30d
- [x] **多语言交叉引用 / 作者关联** (v1.5) — llm-extract 拉作者 top-5 repo 作为 prior context

_Last updated: 2026-04-22_
