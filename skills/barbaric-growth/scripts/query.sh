#!/bin/bash
# query.sh - 查询 barbaric-growth 研究成果

WORKSPACE="/Users/nova/.openclaw/workspace"
PATTERNS="$WORKSPACE/patterns"

show_usage() {
    echo "barbaric-growth 查询工具"
    echo ""
    echo "用法:"
    echo "  $0 all              # 列出所有研究的 repo + 一句话总结"
    echo "  $0 TypeScript       # 列出 TypeScript 项目"
    echo "  $0 Rust             # 列出 Rust 项目"
    echo "  $0 Go               # 列出 Go 项目"
    echo "  $0 Python           # 列出 Python 项目"
    echo "  $0 pending          # 还没发 Capsule 的项目"
    echo "  $0 high-stars       # stars > 50k 的项目"
    echo "  $0 patterns         # 查看 pattern 文件列表"
    echo "  $0 diff <repo1> <repo2>  # 对比两个 repo"
    echo ""
}

get_summary() {
    local repo="$1"
    local pattern_file="$PATTERNS/${repo//\//_}.md"
    if [ -f "$pattern_file" ]; then
        grep -A1 "^## 一句话总结" "$pattern_file" 2>/dev/null | tail -1 | sed 's/^ *//'
    fi
}

get_capsule() {
    local repo="$1"
    local pattern_file="$PATTERNS/${repo//\//_}.md"
    if [ -f "$pattern_file" ]; then
        grep "capsule_id:" "$pattern_file" 2>/dev/null | head -1 | sed 's/.*capsule_id: *//'
    fi
}

CMD="${1:-all}"

case "$CMD" in
    all)
        echo "📋 所有研究的 repo:"
        echo ""
        for f in "$PATTERNS"/*.md; do
            [ -f "$f" ] || continue
            NAME=$(basename "$f" .md | sed 's/_/\//g')
            STARS=$(grep "^- stars:" "$f" 2>/dev/null | head -1 | sed 's/.*stars: *//')
            LANG=$(grep "^- language:" "$f" 2>/dev/null | head -1 | sed 's/.*language: *//')
            CAPSULE=$(get_capsule "$NAME")
            SUMMARY=$(get_summary "$NAME")
            
            if [ -n "$CAPSULE" ] && echo "$CAPSULE" | grep -q "sha"; then
                echo "  ✅ $NAME ($STARS ⭐, $LANG)"
            else
                echo "  ⏳ $NAME ($STARS ⭐, $LANG)"
            fi
            [ -n "$SUMMARY" ] && echo "     → $SUMMARY"
            echo ""
        done
        ;;
    pending)
        echo "⏳ 待发 Capsule 的项目:"
        echo ""
        for f in "$PATTERNS"/*.md; do
            [ -f "$f" ] || continue
            NAME=$(basename "$f" .md | sed 's/_/\//g')
            CAPSULE=$(get_capsule "$NAME")
            SUMMARY=$(get_summary "$NAME")
            if ! echo "$CAPSULE" | grep -q "sha"; then
                echo "  ⏳ $NAME"
                [ -n "$SUMMARY" ] && echo "     → $SUMMARY"
                echo ""
            fi
        done
        ;;
    high-stars)
        echo "🔥 高星项目 (stars > 50000):"
        echo ""
        for f in "$PATTERNS"/*.md; do
            [ -f "$f" ] || continue
            NAME=$(basename "$f" .md | sed 's/_/\//g')
            STARS=$(grep "^- stars:" "$f" 2>/dev/null | head -1 | sed 's/.*stars: *//')
            [ "${STARS:-0}" -gt 50000 ] 2>/dev/null || continue
            CAPSULE=$(get_capsule "$NAME")
            SUMMARY=$(get_summary "$NAME")
            echo "  ⭐ $NAME ($STARS ⭐)"
            [ -n "$SUMMARY" ] && echo "     → $SUMMARY"
            echo ""
        done
        ;;
    patterns)
        echo "📁 Pattern 文件列表:"
        echo ""
        for f in "$PATTERNS"/*.md; do
            [ -f "$f" ] || continue
            NAME=$(basename "$f" .md | sed 's/_/\//g')
            LANG=$(grep "^- language:" "$f" 2>/dev/null | head -1 | sed 's/.*language: *//')
            CAPSULE=$(get_capsule "$NAME")
            echo "  ★ $NAME"
            echo "    语言: ${LANG:-未知} | Capsule: ${CAPSULE:-none}"
            echo ""
        done
        ;;
    diff)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "用法: $0 diff <repo1> <repo2>"
            echo "例: $0 diff openclaw/openclaw langgenius/dify"
        else
            R1="$2"; R2="$3"
            echo "🔍 对比: $R1 vs $R2"
            echo ""
            for repo in "$R1" "$R2"; do
                SUMMARY=$(get_summary "$repo")
                CAPSULE=$(get_capsule "$repo")
                F1="$PATTERNS/${repo//\//_}.md"
                LANG=$(grep "^- language:" "$F1" 2>/dev/null | head -1 | sed 's/.*language: *//')
                STARS=$(grep "^- stars:" "$F1" 2>/dev/null | head -1 | sed 's/.*stars: *//')
                echo "【$repo】"
                echo "  Stars: $STARS | Language: $LANG"
                echo "  Summary: $SUMMARY"
                echo "  Capsule: ${CAPSULE:-none}"
                echo ""
            done
        fi
        ;;
    -h|--help|help)
        show_usage
        ;;
    *)
        # 把它当作语言查询
        echo "🔍 语言=$CMD 的项目:"
        echo ""
        for f in "$PATTERNS"/*.md; do
            [ -f "$f" ] || continue
            NAME=$(basename "$f" .md | sed 's/_/\//g')
            LANG=$(grep "^- language:" "$f" 2>/dev/null | head -1 | sed 's/.*language: *//')
            if [ "$LANG" = "$CMD" ]; then
                SUMMARY=$(get_summary "$NAME")
                CAPSULE=$(get_capsule "$NAME")
                STARS=$(grep "^- stars:" "$f" 2>/dev/null | head -1 | sed 's/.*stars: *//')
                echo "  ★ $NAME ($STARS ⭐)"
                [ -n "$SUMMARY" ] && echo "     → $SUMMARY"
                echo ""
            fi
        done
        ;;
esac
