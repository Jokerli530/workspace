# Deep Dive Priorities — 值得深入研究的项目

> 筛选标准：
> - 原创性（不是普通套壳）
> - 对 Nova 的直接价值
> - 社区活跃度 / 可持续发展
> - 技术可行性（Nova 现有资源能否落地）

---

## 🔴 最高优先级（必须深挖）

### 1. ECC (everything-claude-code)
- **Stars**: 159,805 — 今日最高
- **为什么值得**: Anthropic Hackathon Winner，self-evolution + instinct 系统完整
- **对 Nova 的价值**: Nova-Orbit 的自进化机制可以直接借鉴
- **关注点**: self-evolution 怎么实现的？instinct pattern library 如何工作？
- **行动**: 精读 README 和架构文档，clone 下来跑 demo

### 2. GoClaw
- **Stars**: 2,799
- **为什么值得**: OpenClaw 的 Go 重写版，3-tier memory + multi-tenant + self-evolution
- **对 Nova 的价值**: 比 OpenClaw 更完整的功能，可能需要借鉴到 Nova
- **关注点**: 3-tier memory 怎么分层？self-evolution 机制是什么？
- **行动**: GitHub README 精读，了解架构

### 3. HiClaw
- **Stars**: 4,165
- **为什么值得**: 企业级 OpenClaw 多 Agent 协作，Manager-Workers 架构
- **对 Nova 的价值**: 多 Agent 协作模式，enterprise security model
- **关注点**: Manager 和 Worker 如何通信？human-in-the-loop 怎么实现？
- **行动**: 精读 README + 部署体验

---

## 🟠 高优先级（有战略价值）

### 4. ARIS (Auto-Research-In-Sleep)
- **Stars**: 6,943
- **为什么值得**: 零依赖自主 ML 研究，明确支持 OpenClaw，meta-optimize 自进化
- **对 Nova 的价值**: barbaric-growth 的 self-evolution 机制可以完全借鉴
- **关注点**: /meta-optimize 怎么分析日志并生成 SKILL patch？
- **行动**: 精读 README，理解 self-evolution 流程

### 5. prax-agent
- **Stars**: 50（但增长快）
- **为什么值得**: test-verify-fix loop 生产级实现，持久记忆，多模型路由
- **对 Nova 的价值**: barbaric-growth 的验证机制可以直接借鉴
- **关注点**: Verification-First 架构具体怎么实现？
- **行动**: 安装跑 demo，理解 verification loop 机制

### 6. MemPalace
- **Stars**: 47,614（13 天新项目）
- **为什么值得**: LongMemEval 96.6% RAG benchmark，Local-first AI 记忆
- **对 Nova 的价值**: ByteRover 的知识沉淀可以借鉴其 RAG 优化
- **关注点**: 96.6% benchmark 怎么做到的？local-first 架构？
- **行动**: 精读 README，看 benchmark 方法论

### 7. BuilderPulse
- **Stars**: 900
- **为什么值得**: Indie hacker 日报 AI，每日信号源汇总，"2 小时能做什么"
- **对 Nova 的价值**: Token 经济追踪系统的参考实现
- **关注点**: 每日 insight 如何生成？信号源如何加权？
- **行动**: 看 daily report 格式，理解方法论

---

## 🟡 中优先级（值得一看）

### 8. weft (WeaveMindAI)
- **Stars**: 781
- **为什么值得**: AI 系统专用编程语言，typed graph + durable execution
- **对 Nova 的价值**: 长期看，Nova 可能需要自己的 DSL
- **关注点**: first-class humans 怎么实现？durable execution ？
- **行动**: 了解语言设计理念即可，实用还早

### 9. the_surrounding_system
- **Stars**: 5
- **为什么值得**: Harness Engineering 教科书，Anthropic 团队背书
- **对 Nova 的价值**: 理解 harness engineering 的核心概念
- **关注点**: feedback loop 怎么设计？evaluation system ？
- **行动**: 快速浏览，理解概念框架

### 10. dify
- **Stars**: 138,180
- **为什么值得**: 生产级 agentic workflow 平台
- **对 Nova 的价值**: workflow 设计参考
- **关注点**: 多模型编排，RAG pipeline，agent 节点
- **行动**: 有需要时再深入，现在泛泛了解即可

### 11. browser-use
- **Stars**: 88,334
- **为什么值得**: 主流浏览器自动化，Web UI Agent 标杆
- **对 Nova 的价值**: OpenClaw Browser DOM 可以借鉴
- **关注点**: DOM tree 如何序列化？action space 设计？
- **行动**: 有需要时再深入

---

## 🟢 低优先级（观察即可）

### 12. Ralph (17k stars)
- PRD 驱动的自主循环，Nova 是知识驱动的，方向不同

### 13. LLM Wiki skills (14 stars)
- AI 原生知识库，ByteRover 已经在做类似的事

### 14. hermes-agent-rs (11 stars)
- 84k 行 Rust 重写，有野心但太早期

### 15. Skills Marketplaces
- skills.sh (80k+) / pm-skills (10k) / SkillX — Nova 不需要竞争，需要配合

---

## 📋 行动清单

### 本周内完成
- [ ] **ECC** — 精读 README + 架构图
- [ ] **GoClaw** — 3-tier memory 机制分析
- [ ] **ARIS** — meta-optimize 流程分析
- [ ] **prax-agent** — 安装跑 demo

### 本月内完成
- [ ] HiClaw 部署体验
- [ ] MemPalace benchmark 方法论
- [ ] BuilderPulse 日报格式分析
- [ ] Nova-Orbit v1.1: 自评估常态化

---

## 两日发现总量

| 类别 | 数量 | 代表 |
|------|------|------|
| AI Agent 平台 | 20+ | OpenClaw/GoClaw/HiClaw/ECC |
| 记忆系统 | 8+ | MemPalace/MemOS/LedgerMind/ByteRover |
| Skills 市场 | 6+ | skills.sh/pm-skills/ClawHub/SkillX |
| 自主循环 | 5+ | ARIS/Ralph/prax-agent/OpenMOSS |
| 浏览器控制 | 4+ | browser-use/Ghost OS/WebFurl |
| 编程语言 | 2+ | weft/hermes-agent-rs |
| 工具类 | 10+ | codeburn/BuilderPulse/anything-analyzer |
