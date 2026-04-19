#!/bin/bash
# query.sh - 查询 barbaric-growth 研究成果
# 用法: ./query.sh [type|stars|pending|all|的语言名]

WORKSPACE="/Users/nova/.openclaw/workspace"
TRACKED="$WORKSPACE/barbaric-tracked.json"
PATTERNS="$WORKSPACE/patterns"

show_usage() {
    echo "barbaric-growth 查询工具"
    echo ""
    echo "用法:"
    echo "  $0 all              # 列出所有研究的 repo"
    echo "  $0 TypeScript       # 列出 TypeScript 项目"
    echo "  $0 Rust             # 列出 Rust 项目"
    echo "  $0 Go               # 列出 Go 项目"
    echo "  $0 Python           # 列出 Python 项目"
    echo "  $0 pending          # 还没发 Capsule 的项目"
    echo "  $0 high-stars       # stars > 50k 的项目"
    echo "  $0 patterns         # 查看 pattern 文件列表"
    echo ""
}

# 读取 tracked repos
get_repos() {
    python3 -c "
import json, sys
with open('$TRACKED') as f:
    d = json.load(f)
for r in d.get('tracked', []):
    print(f\"{r.get('name','')}|{r.get('stars',0)}|{r.get('language','')}|{r.get('description','')}\")
" 2>/dev/null
}

# 读取 pattern 状态
get_pattern_status() {
    local repo="$1"
    local pattern_file="$PATTERNS/${repo//\//_}.md"
    if [ -f "$pattern_file" ]; then
        grep "capsule_id:" "$pattern_file" 2>/dev/null | head -1 | sed 's/.*capsule_id: //'
    else
        echo "无"
    fi
}

CMD="${1:-all}"

case "$CMD" in
    all)
        echo "📋 所有研究的 repo:"
        echo ""
        get_repos | while IFS='|' read -r NAME STARS LANG DESC; do
            [ -z "$NAME" ] && continue
            STATUS=$(get_pattern_status "$NAME")
            echo "  ★ $NAME ($STARS ⭐, $LANG)"
            echo "    Capsule: $STATUS"
            echo ""
        done
        ;;
    pending)
        echo "⏳ 待发 Capsule 的项目:"
        echo ""
        get_repos | while IFS='|' read -r NAME STARS LANG DESC; do
            [ -z "$NAME" ] && continue
            STATUS=$(get_pattern_status "$NAME")
            if echo "$STATUS" | grep -q "待发布\|无"; then
                echo "  ★ $NAME ($STARS ⭐, $LANG)"
                echo "    $DESC"
                echo ""
            fi
        done
        ;;
    high-stars)
        echo "🔥 高星项目 (stars > 50000):"
        echo ""
        get_repos | while IFS='|' read -r NAME STARS LANG DESC; do
            [ -z "$NAME" ] && continue
            if [ "$STARS" -gt 50000 ] 2>/dev/null; then
                STATUS=$(get_pattern_status "$NAME")
                echo "  ★ $NAME ($STARS ⭐, $LANG)"
                echo "    Capsule: $STATUS"
                echo ""
            fi
        done
        ;;
    patterns)
        echo "📁 Pattern 文件列表:"
        echo ""
        for f in "$PATTERNS"/*.md; do
            [ -f "$f" ] || continue
            NAME=$(basename "$f" .md | sed 's/_/\//g')
            LANG=$(grep "^language:" "$f" 2>/dev/null | awk '{print $2}')
            CAPSULE=$(grep "capsule_id:" "$f" 2>/dev/null | head -1 | sed 's/.*capsule_id: //')
            echo "  ★ $NAME"
            echo "    语言: ${LANG:-未知} | Capsule: $CAPSULE"
            echo ""
        done
        ;;
    -h|--help|help)
        show_usage
        ;;
    *)
        # 把它当作语言查询
        echo "🔍 语言=$CMD 的项目:"
        echo ""
        get_repos | while IFS='|' read -r NAME STARS LANG DESC; do
            [ -z "$NAME" ] && continue
            if [ "$LANG" = "$CMD" ]; then
                STATUS=$(get_pattern_status "$NAME")
                echo "  ★ $NAME ($STARS ⭐)"
                echo "    Capsule: $STATUS"
                echo ""
            fi
        done
        ;;
esac
