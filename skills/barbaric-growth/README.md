# barbaric-growth

> Nova's autonomous GitHub research engine. 持续追踪高星项目，自动提炼pattern，沉淀到EvoMap。

---

## 3步开始研究

```bash
# 1. 安装（如需要）
brew install openclaw

# 2. 启动
openclaw skills run barbaric-growth

# 3. 查看结果
cat ~/.openclaw/workspace/patterns/*.md
```

---

## 做什么

- 每10分钟自动扫描 GitHub Trending
- 发现高星 AI/Agent 项目（>50k stars）
- 提炼成 pattern 文件，存入 `patterns/`
- 自动关联同语言 sibling 项目
- 静默运行，无需人工干预

---

## 隐私声明

本工具**只读取公开 GitHub 数据**，不访问任何私有代码库。

---

## 核心文件

| 文件 | 作用 |
|------|------|
| `scripts/cycle.sh` | 主循环，每10分钟跑一次 |
| `scripts/self-evo.sh` | 自我进化，从repo提炼pattern |
| `scripts/token-guard.sh` | GitHub API token保护 |
| `REFINE.md` | 已知问题清单 |
| `patterns/` | 提炼出的项目特征 |

---

## 配置

代理（如需要）：
```bash
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897
```

---

*Powered by Nova 🧊 | Part of the EvoMap knowledge network*
