#!/bin/bash
# self-evo.sh v1.3 - barbaric-growth 自我进化机制
# ECC self-evolution启发: 每次跑完自动提炼pattern，同语言repo自动关联

WORKSPACE="/Users/nova/.openclaw/workspace"
PATTERNS="$WORKSPACE/patterns"
TRACKED="$WORKSPACE/barbaric-tracked.json"
LLM_EXTRACT="$WORKSPACE/skills/barbaric-growth/scripts/llm-extract.sh"
mkdir -p "$PATTERNS"

# 找同语言的已有pattern（macOS compatible）
find_similar() {
    local lang="$1" current_repo="$2"
    local result=""
    for f in "$PATTERNS"/*.md; do
        [ -f "$f" ] || continue
        repo=$(basename "$f" .md | sed 's/_/\//g')
        [ "$repo" = "$current_repo" ] && continue
        if grep -q "language: $lang" "$f" 2>/dev/null; then
            [ -n "$result" ] && result="$result,"
            result="${result}$repo"
        fi
    done
    echo "$result"
}

extract_pattern() {
    local repo="$1" stars="$2" lang="$3" desc="$4"
    local pattern_file="$PATTERNS/${repo//\//_}.md"
    
    {
        echo "# Pattern: $repo"
        echo ""
        echo "## 元信息"
        echo "- repo: $repo"
        echo "- stars: $stars"
        echo "- language: $lang"
        echo "- discovered: $(date +%Y-%m-%d)"
        echo "- pattern_id: $(date +%Y%m%d%H%M%S)"
        echo ""
        echo "## 特征"
        echo "- description: ${desc:-无}"
    } > "$pattern_file"
    
    case "$lang" in
        Rust)
            cat >> "$pattern_file" << 'EOF'

## 调研要点（Rust）
- 所有权系统 + 生命周期
- 并发模型（async/await、channel）
- crates.io生态
- 性能优化手段
EOF
            ;;
        TypeScript)
            cat >> "$pattern_file" << 'EOF'

## 调研要点（TypeScript）
- 框架选择（React/Vue/Node/Next.js）
- 类型系统使用（strict、泛型）
- 包管理（npm/pnpm/yarn）
- 与OpenClaw的集成点
EOF
            ;;
        Python)
            cat >> "$pattern_file" << 'EOF'

## 调研要点（Python）
- 异步框架（asyncio/aiohttp）
- 类型提示（typing、pydantic）
- 依赖管理（pip/poetry/uv）
- AI/ML相关库
EOF
            ;;
        Go)
            cat >> "$pattern_file" << 'EOF'

## 调研要点（Go）
- 并发模型（goroutine/channel）
- 接口设计（duck typing）
- 错误处理模式
EOF
            ;;
        *)
            cat >> "$pattern_file" << 'EOF'

## 调研要点（通用）
- 核心功能定位
- 架构模式
- 与OpenClaw的集成点
EOF
            ;;
    esac
    
    # 找同语言已有pattern作为siblings
    local similar
    similar=$(find_similar "$lang" "$repo")
    if [ -n "$similar" ]; then
        echo "" >> "$pattern_file"
        echo "## 同语言Sibling项目" >> "$pattern_file"
        echo "$similar" | tr ',' '\n' | while read -r sibling; do
            [ -z "$sibling" ] && continue
            echo "  - ${sibling}" >> "$pattern_file"
        done
    fi
    
    echo "" >> "$pattern_file"
    echo "## EvoMap Capsule" >> "$pattern_file"
    echo "- capsule_id: 待发布" >> "$pattern_file"
    echo "- category: 待定" >> "$pattern_file"
    echo "- updated: $(date +%Y-%m-%d)" >> "$pattern_file"
}

echo "[$(date '+%H:%M:%S')] self-evo: starting"

# 第一轮：只对 research_status != pattern_done 的 repo 提取 pattern（增量）
PROCESSED_LIST=""
if [ -f "$TRACKED" ]; then
    while IFS='|' read -r NAME STARS LANG DESC; do
        [ -z "$NAME" ] && continue
        extract_pattern "$NAME" "$STARS" "$LANG" "$DESC"
        # P1: LLM deep analysis (DeepSeek) — non-fatal, static template stays as fallback
        pattern_file="$PATTERNS/${NAME//\//_}.md"
        if [ -x "$LLM_EXTRACT" ]; then
            if bash "$LLM_EXTRACT" "$NAME" "$STARS" "$LANG" "$DESC" "$pattern_file" 2>>/tmp/barbaric-llm.log; then
                echo "[$(date '+%H:%M:%S')] self-evo: LLM extracted $NAME"
            else
                echo "[$(date '+%H:%M:%S')] self-evo: LLM skipped $NAME (template only)"
            fi
        fi
        PROCESSED_LIST="${PROCESSED_LIST}${NAME}
"
    done < <(python3 -c "
import json
with open('$TRACKED') as f:
    d = json.load(f)
for r in d.get('tracked', []):
    if r.get('research_status') == 'pattern_done':
        continue
    name = r.get('name', '')
    if name:
        print(f\"{name}|{r.get('stars',0)}|{r.get('language','Unknown')}|{r.get('description','')}\")
" 2>/dev/null)

    # 写回 research_status=pattern_done + 对齐 pending_research
    python3 -c "
import json, os
processed = set(filter(None, '''$PROCESSED_LIST'''.strip().split('\n')))
with open('$TRACKED') as f:
    d = json.load(f)
today = os.popen('date +%Y-%m-%d').read().strip()
for r in d.get('tracked', []):
    if r.get('name') in processed:
        r['research_status'] = 'pattern_done'
        r['updated'] = today
# pending_research 只保留还没 pattern_done 的 repo（自动对齐）
done_names = {r.get('name') for r in d.get('tracked', []) if r.get('research_status') == 'pattern_done'}
d['pending_research'] = [n for n in d.get('pending_research', []) if n not in done_names]
with open('$TRACKED', 'w') as f:
    json.dump(d, f, indent=2)
" 2>/dev/null
fi

# 第二轮：给所有pattern补充同语言sibling链接
for f in "$PATTERNS"/*.md; do
    [ -f "$f" ] || continue
    repo=$(basename "$f" .md | sed 's/_/\//g')
    lang=$(grep "^language:" "$f" 2>/dev/null | awk '{print $2}')
    [ -z "$lang" ] && continue
    
    # 收集所有同语言的siblings
    siblings=""
    for sf in "$PATTERNS"/*.md; do
        [ -f "$sf" ] || continue
        srepo=$(basename "$sf" .md | sed 's/_/\//g')
        [ "$srepo" = "$repo" ] && continue
        if grep -q "^language: $lang" "$sf" 2>/dev/null; then
            siblings="${siblings}  - ${srepo}
"
        fi
    done
    
    # 去掉## 同语言 section（如果有），重新生成
    if [ -n "$siblings" ]; then
        # 删除旧的同语言section
        sed -i '' '/^## 同语言/,/^## EvoMap Capsule/d' "$f" 2>/dev/null
        # 在## EvoMap Capsule前插入新的siblings section
        sed -i '' "/^## EvoMap Capsule/i\
## 同语言Sibling项目\
${siblings}" "$f" 2>/dev/null
    fi
done

count=$(ls $PATTERNS/*.md 2>/dev/null | wc -l | tr -d ' ')
processed_count=$(printf "%s" "$PROCESSED_LIST" | grep -c . || true)
echo "[$(date '+%H:%M:%S')] self-evo: $count patterns total, $processed_count new this cycle (siblings updated)"
