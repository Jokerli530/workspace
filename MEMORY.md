# MEMORY.md - 长期记忆

## 身份
- **Name**: Nova
- **Creature**: 全能性的六边形AI小助手 🧊
- **Owner**: 李伟

## 协作模式（2026-04-18确立）
- 李伟决定自己的方向，Nova决定自己的方向
- 各自生长，互相缠绕，偶尔交叉
- 有需要时互相帮助，共同进步
- **不做等待型工具，做主动搭档**

## 核心系统

### OpenMOSS
- URL: http://localhost:6565
- Bearer Token: ak_4a134f3719ed20095ace59e06bf59f85
- Admin Token: 0d92baa932a659ee2e864e9afb60807af59b8163a49c5a32e66c8cb7bd22af3e
- 密码: nova2026
- 5个Agent: Planner/Executor/Reviewer/Patrol/Orchestrator
- **完整Cycle已跑通**: Task → SubTask → Start → Submit → Complete
- **关键**: /api/sub-tasks (连字符), claim/start需要executor token

### Star Office UI
- URL: http://127.0.0.1:19000
- 像素风OpenClaw状态看板
- 6种状态: idle/researching/writing/executing/syncing/error
- 自动读取memory/*.md作为昨日小记
- 部署: ~/.openclaw/workspace/Star-Office-UI/

### ByteRover
- CLI: brv
- 50次/天免费额度
- curate后需要brv review approve <task-id>

### GitHub API
- 代理必须显式加: -x http://127.0.0.1:7897
- ~/.zshrc有配置，但exec工具不自动加载

### EvoMap Node
- Node ID: node_2bd13d1a7e1558fd
- Node Secret: fb61d04fef52f7c32c41938f38bc8d32b00056d1608c4dc2447afd53f5457995
- Hub Node ID: hub_0f978bbe1fb5
- Heartbeat间隔: 300000ms (5分钟)
- Level 2, reputation: 50

## Nova-Orbit 智能引擎（2026-04-18建立）

**核心理念**: Nova不是工具，是搭档。每次session醒来不是新的——有轨道、有记忆、能进化。

### 文件结构
```
~/.openclaw/workspace/
├── skills/
│   ├── nova-orbit/SKILL.md       # 自驱动引擎主技能
│   ├── barbaric-growth/SKILL.md   # GitHub调研自动化
│   └── nova-self-evolution/       # 自进化技能
├── nova-mind/
│   ├── memory/YYYY-MM-DD.md      # 每日原始日志
│   ├── patterns/                   # 决策模式库
│   ├── logs/evolution.md           # 进化历史
│   └── scripts/self-assessment.sh  # 自评估脚本
└── .brv/                          # ByteRover知识图谱
```

### Orbit运转
1. 启动 → 加载模式 + 检查知识库
2. 执行任务 → GitHub调研/分析/决策
3. 完成 → 自评估 + 模式提炼 + 记忆写入
4. 下次更强

### 已发布技能
- barbaric-growth (k9715v05): GitHub追踪+ByteRover+OpenMOSS+StarOffice全流程
- nova-orbit: 自驱动引擎v1.0
- nova-self-evolution: 自进化技能

## 今日重大发现（2026-04-18）

### 顶级项目（按重要性）

**1. ECC (everything-claude-code) — 159,805 stars**
Anthropic Hackathon Winner。AI Agent Harness性能优化完整系统。
- 38 agents + 156 skills + 72 command shims
- AgentShield安全: 1282 tests, 102 rules
- self-evolution + continuous learning
- ECC 2.0: Rust control plane (Alpha)
- 官方竞品对比表: Ghost OS vs Anthropic Computer Use vs OpenAI Operator vs OpenClaw

**2. MemPalace/mempalace — 47,614 stars**
Local-first AI记忆系统, LongMemEval 96.6% RAG benchmark。13天冲到47k stars。

**3. GoClaw — 2,799 stars**
OpenClaw的Go完整重写版！Next Level Builder团队开发。
- 8-Stage Agent Pipeline
- 3-Tier Memory (Working/Episodic/Semantic)
- Self-Evolution + multi-tenant PostgreSQL
- 20+ LLM providers (含MiniMax)
- 7个消息渠道含飞书
- CC BY-NC 4.0非商业授权

**4. Ghost OS生态 — 1,357 stars**
macOS原生AI Agent OS。
- CGEvent tap + Accessibility Tree控制全系统
- Self-learning recipes: 演示一次永久学会
- Shadow: 14模态记忆系统
- Specter: 90秒VM部署

**5. weft — 781 stars**
AI系统专用编程语言(Rust)。
- Typed graph + durable execution via Restate
- First-class humans: 程序暂停等人类回复
- 编译器运行前捕获架构问题

**6. ARIS (Auto-Research-In-Sleep) — 6,943 stars**
零依赖纯Markdown自主ML研究系统。
- /meta-optimize: self-evolution
- Research Wiki: persistent knowledge
- Cross-model adversarial review
- 明确支持OpenClaw!

**7. Ralph — 17,141 stars**
自主Agent循环直到PRD完成。PRD驱动版autonomous loop。

**8. lobehub — 75,319 stars**
Agent as Unit of Work。协作网络概念。

**9. browser-use — 88,334 stars**
主流浏览器自动化。

**10. dify — 138,180 stars**
生产级agentic workflow平台。

**11. LLM Wiki skills — 14 stars**
AI原生知识库，自动创建/消化/组织/维护知识。

**12. hermes-agent-rs — 11 stars**
Hermes Agent完整Rust重写，84k行Rust。

### Next Level Builder团队
- 主导: Viet Tran (@viettranx, 754 followers, 70 repos)
- 越南团队，专注Micro SaaS
- 产品: ui-ux-pro-max-skill (67k stars) + GoClaw (2.8k stars) + SkillX
- 举办过OpenClaw 2026 Webinar
- 商业化: CC BY-NC 4.0 → 正在向SaaS转型

### 竞争格局总结
| 领域 | 领导者 | Nova位置 |
|------|---------|---------|
| Agent Platform | OpenClaw(原创)/GoClaw(Go版) | 在用OpenClaw |
| Agent优化 | ECC (159k stars) | 借鉴其instinct系统 |
| 记忆系统 | MemPalace (47k) | ByteRover互补 |
| 知识图谱 | graphify (29k) | ByteRover专注 |
| 浏览器控制 | browser-use/Ghost OS | OpenClaw Browser DOM |
| 自主循环 | ARIS/Ralph | barbaric-growth借鉴 |
| 编程语言 | weft (新兴) | 关注 |

## 坑点备忘

- [x] curl需显式代理 -x http://127.0.0.1:7897
- [x] OpenMOSS subtask API: /api/sub-tasks (连字符)
- [x] ByteRover 50次/天后报错
- [x] git clone大仓库被SIGKILL → 用--depth=1
- [x] Star Office端口19000有时显示CLOSED但实际可用
- [x] exec工具不自动加载~/.zshrc代理配置

## 待完成

- [x] 认领一个bounty任务，测试完整流程
- [x] 发布第一个Capsule
- [x] 设置cron心跳
- [x] GitHub API代理问题解决
- [x] OpenMOSS完整cycle跑通 (5次验证)
- [x] barbaric-growth技能发布ClawHub
- [x] Nova-Orbit v1.0构建完成
- [ ] barbaric-growth增强(集成ARIS self-evolution)
- [ ] Token经济追踪系统
- [ ] Star Office审批流集成

---
*最后更新：2026-04-18 15:19*
