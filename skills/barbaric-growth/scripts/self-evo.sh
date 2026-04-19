#!/bin/bash
# self-evo.sh - barbaric-growth 自我进化机制
# ECC self-evolution 启发：完成任务后自动提炼 pattern，积累到 patterns/ 目录

set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
PATTERNS="$WORKSPACE/patterns"
TRACKED="$WORKSPACE/barbaric-tracked.json"

mkdir -p "$PATTERNS"

# 从 tracked 获取最新研究过的 repo，提取 pattern
extract_pattern() {
    local repo="$1"
    local stars="$2"
    local lang="$3"
    local desc="$4"
    
    # 跳过已提取过 pattern 的
    if [ -f "$PATTERNS/${repo//\//_}.md" ]; then
        return
    fi
    
    # 根据语言和 stars 生成 pattern 文件
    cat > "$PATTERNS/${repo//\//_}.md" << EOF
# Pattern: $repo

## 元信息
- repo: $repo
- stars: $stars
- language: $lang
- discovered: $(date +%Y-%m-%d)
- pattern_id: $(date +%Y%m%d%H%M%S)

## 特征
- description: ${desc:-无}

## 提炼的 Pattern
EOF
    
    # 根据语言标签生成对应的调研提示
    case "$lang" in
        Rust)
            echo "## 调研要点（Rust项目）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 所有权系统 + 生命周期" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 并发模型（async/await、channel）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 生态依赖（crates.io）" >> "$PATTERNS/${repo//\//_}.md"
            ;;
        TypeScript)
            echo "## 调研要点（TypeScript项目）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 框架选择（React/Vue/Node）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 类型系统使用方式" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 包管理（npm/pnpm/yarn）" >> "$PATTERNS/${repo//\//_}.md"
            ;;
        Python)
            echo "## 调研要点（Python项目）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 异步框架（asyncio/aiohttp）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 类型提示（typing）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 依赖管理（pip/poetry）" >> "$PATTERNS/${repo//\//_}.md"
            ;;
        Go)
            echo "## 调研要点（Go项目）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 并发模型（goroutine/channel）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 接口设计" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 错误处理模式" >> "$PATTERNS/${repo//\//_}.md"
            ;;
        *)
            echo "## 调研要点（通用）" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 核心功能定位" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 架构模式" >> "$PATTERNS/${repo//\//_}.md"
            echo "- 差异化特点" >> "$PATTERNS/${repo//\//_}.md"
            ;;
    esac
    
    echo "" >> "$PATTERNS/${repo//\//_}.md"
    echo "## EvoMap Capsule" >> "$PATTERNS/${repo//\//_}.md"
    echo "- capsule_id: 待发布" >> "$PATTERNS/${repo//\//_}.md"
    echo "- category: 待定" >> "$PATTERNS/${repo//\//_}.md"
}

# 对所有新发现的 repo 提取 pattern
if [ -f "$TRACKED" ]; then
    python3 -c "
import json
with open('$TRACKED') as f:
    d = json.load(f)
for r in d.get('tracked', []):
    name = r.get('name', '')
    stars = r.get('stars', 0)
    lang = r.get('language', 'Unknown')
    desc = r.get('description', '')
    if name:
        print(f'{name}|{stars}|{lang}|{desc}')
" 2>/dev/null | while IFS='|' read -r NAME STARS LANG DESC; do
        extract_pattern "$NAME" "$STARS" "$LANG" "$DESC"
    done
fi

echo "Self-evolution: $(ls $PATTERNS/*.md 2>/dev/null | wc -l | tr -d ' ') patterns extracted"
