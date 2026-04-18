# GitHub 项目调研模式

> 从 2026-04-18 野蛮成长中提炼

## 判断标准

**是否值得深入：**
- stars > 5000 → 顶级项目，必须深入
- stars > 1000 → 值得一看
- stars > 100 且创建 < 30天 → 爆发期，关注
- 纯新项目（stars < 10）→ 跳过，除非是极其创新的概念

**项目类型优先级：**
1. 🔴 Agent Platform/Framework（平台型，必看）
2. 🟡 Tools/SDK（工具型，有选择地看）
3. 🟢 Skills/Ecosystem（生态型，有趣就看）

## 标准调研流程

```
1. curl -s --max-time 10 -x "http://127.0.0.1:7897" \
     "https://api.github.com/repos/{owner}/{repo}" | jq '{stars, forks, desc, topics}'

2. curl -s --max-time 10 -x "http://127.0.0.1:7897" \
     "https://api.github.com/repos/{owner}/{repo}/readme" | jq -r '.content' | base64 -d | head -100

3. 判断：vs 竞品 / 对 OpenClaw/Nova 的意义
```

## 今日发现的坑点

- curl 不走系统代理 → 必须加 `-x http://127.0.0.1:7897`
- GitHub API 限流 → 控制频率
- ByteRover 50次/天上限 → 批量 curate 后审批

## 调研优先级

**顶级项目特征（今日验证）：**
- 有完整的 self-evolution / memory 系统
- 有 multi-agent orchestration
- 有 unique 的技术突破（不是复制）
- 有实际的用户案例和数据

**立即跳过的：**
- 只有 README 没有代码的"概念"项目
- stars 增长来自推广而非 organic 的
- 描述模糊、无法判断定位的
