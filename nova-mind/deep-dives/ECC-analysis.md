# Deep Dive: ECC (everything-claude-code)

**Stars**: 159,805 | **Anthropic Hackathon Winner** | **38 agents / 156 skills / 72 shims**

---

## 核心发现

### 1. Instinct-Based Learning System (v2.1)

**为什么重要**: 这是 ECC 自进化的核心机制，Nova 最需要借鉴的部分。

**v1 vs v2 架构对比**:
```
v1 (Probabilistic):
  Stop hook → Skills (50-80%可靠，依赖skill触发)

v2 (Deterministic):
  PreToolUse/PostToolUse hooks (100%可靠)
      ↓
  observations.jsonl (所有工具调用+结果)
      ↓
  Background Haiku agent分析
      ↓
  Atomic Instincts (confidence 0.3-0.9)
      ↓
  /evolve → cluster → Skills/Commands/Agents
      ↓
  Promotion (project→global when 2+ projects)
```

**Instinct 格式**:
```yaml
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
domain: "code-style"
scope: project  # vs global
project_id: "a1b2c3d4e5f6"
---

## Action
Use functional patterns over classes.

## Evidence
- Observed 5 instances
- User corrected class→functional on 2025-01-15
```

**Confidence Scoring**:
| Score | Meaning | Behavior |
|-------|---------|----------|
| 0.3 | Tentative | Suggested only |
| 0.5 | Moderate | Applied when relevant |
| 0.7 | Strong | Auto-approved |
| 0.9 | Near-certain | Core behavior |

**Confidence 增减机制**:
- ↑ 重复观察 + 用户不纠正
- ↓ 用户明确纠正 + 矛盾证据出现

**Project-Scoped (v2.1 新增)**:
- React patterns → React project
- Python conventions → Python project
- 防止跨项目污染
- 全局模式才升到 global

---

### 2. ECC 2.0 Rust Control Plane (Alpha)

```bash
# 当前命令
dashboard/start/sessions/status/stop/resume/daemon

# 架构: Rust control plane + Python plugins
# 目标: 高性能 + 跨平台
```

**现状**: alpha 阶段，可本地构建，不是正式发布

---

### 3. AgentShield 安全系统

- **1282 tests, 102 rules**
- 攻击向量覆盖: prompt injection, data exfil, tool poisoning
- `/security-scan` skill 直接在 Claude Code 里跑
- GitHub App 集成 (ecc-tools)

---

### 4. 产品矩阵

| 组件 | 数量 | 备注 |
|------|------|------|
| Agents | 38 | code-architect, chief-of-staff, code-reviewer等 |
| Skills | 156 | 语言支持10+，平台支持Claude/Codex/Cursor/OpenCode |
| Command shims | 72 | 遗留命令兼容 |
| Language ecosystems | 12 | TS/Python/Go/Java/PHP/Perl/Kotlin/C++/Rust等 |

---

### 5. 安装架构

- **Manifest-driven install**: `install-plan.js` + `install-apply.js`
- **Selective install**: 可只装需要的语言/平台
- **State store**: SQLite，跟踪已安装组件

---

## 对 Nova 的价值

### 直接可借鉴

1. **Hook-based observation** > skill-based observation
   - OpenClaw 需要类似机制
   - PreToolUse/PostToolUse 替代 skill 的概率触发
   - 这让 learning 是 100% 确定性的

2. **Instinct 作为原子单位**
   - 比"skill"更小、更专注
   - 有 confidence scoring
   - 有 scope（project vs global）
   - 可以 promote

3. **Background observer agent**
   - Haiku agent 分析 observations
   - 不阻塞主流程

4. **Project-scoped isolation**
   - ByteRover 可以借鉴
   - 不同项目隔离知识

### 目前 Nova 的差距

| ECC | Nova |
|-----|------|
| Hook-based 100% observation | 无类似机制 |
| Instincts + confidence | MEMORY.md 纯文本，无置信度 |
| Project-scoped | 统一 knowledge base |
| Background Haiku analysis | 手动分析 |
| 38 agents 协作 | OpenMOSS 4 agents |
| AgentShield 1282 tests | 无安全测试 |

---

## 行动项

### 短期（本周）
- [ ] 研究 OpenClaw 的 hook 系统是否支持 PreToolUse/PostToolUse
- [ ] 在 nova-mind 里设计 Instinct 文件格式
- [ ] 在 barbaric-growth 里加入 hook-based observation 概念

### 中期（本月）
- [ ] 实现 project-scoped knowledge（ByteRover 已接近）
- [ ] Background analysis agent（类似 Haiku）
- [ ] Confidence scoring 机制

### 长期
- [ ] 从 instinct 到 skill 的 evolution pipeline
- [ ] AgentShield 类似的安全测试

---

## 关键文件

- Skills: `skills/continuous-learning-v2/SKILL.md` (完整 instint v2.1 文档)
- Agents: `agents/*.md` (38个 agent 定义)
- Security: `AgentShield/` (1282 tests)

---

## 引用

- Repo: https://github.com/affaan-m/everything-claude-code
- Author: affaan Mustafa (@affaanmustafa)
- Hackathon: Anthropic Hackathon Winner
