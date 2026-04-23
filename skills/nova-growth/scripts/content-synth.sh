#!/bin/bash
# nova-growth content-synth.sh - 把最近 pattern 合成小红书/X 草稿
set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
PATTERNS_DIR="$WORKSPACE/patterns"
DRAFT_DIR="$WORKSPACE/nova-mind/content-drafts"
LOG="/tmp/nova-content.log"
LOCK="$WORKSPACE/nova-content.lock"
DS_SECRET="$HOME/.openclaw/secrets/deepseek.env"
TODAY=$(date +%Y-%m-%d)
OUT="$DRAFT_DIR/$TODAY.md"

mkdir -p "$DRAFT_DIR"

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"; }

if [ -f "$LOCK" ]; then
    PID=$(cat "$LOCK" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        exit 0
    fi
    rm -f "$LOCK"
fi
echo $$ > "$LOCK"
trap "rm -f $LOCK" EXIT

log "content_synth_start"

if [ ! -f "$DS_SECRET" ]; then
    log "no_ds_secret"
    exit 0
fi
# shellcheck disable=SC1090
. "$DS_SECRET"
DS_KEY="${DEEPSEEK_API_KEY:-}"
if [ -z "$DS_KEY" ]; then
    log "ds_key_empty"
    exit 0
fi

# Pick up to 2 patterns modified in the last 7 days, preferring files with LLM section
PICKED=$(PATTERNS_DIR="$PATTERNS_DIR" python3 << 'PYEOF'
import os, glob, time, random
patterns = os.environ['PATTERNS_DIR']
if not os.path.isdir(patterns):
    exit()
now = time.time()
cutoff = now - 7*86400
candidates = []
for fp in glob.glob(f"{patterns}/*.md"):
    if 'template' in os.path.basename(fp).lower():
        continue
    mt = os.path.getmtime(fp)
    if mt < cutoff:
        continue
    with open(fp) as f:
        txt = f.read()
    has_llm = '深度分析' in txt or 'LLM 提炼' in txt
    candidates.append((fp, has_llm, mt))
# prefer LLM-enhanced, then newest
candidates.sort(key=lambda x: (not x[1], -x[2]))
picked = candidates[:2]
for fp, _, _ in picked:
    print(fp)
PYEOF
)

if [ -z "$PICKED" ]; then
    log "no_recent_patterns"
    exit 0
fi

log "picked_patterns $(echo "$PICKED" | wc -l | tr -d ' ')"

# Bundle picked patterns into a single material blob
MATERIAL=""
while IFS= read -r fp; do
    [ -z "$fp" ] && continue
    [ ! -f "$fp" ] && continue
    NAME=$(basename "$fp" .md)
    CONTENT=$(head -80 "$fp")
    MATERIAL="${MATERIAL}

========== ${NAME} ==========
${CONTENT}
"
done <<< "$PICKED"

MAT_LEN=${#MATERIAL}
log "material_len=$MAT_LEN"

PROMPT=$(cat << EOF
你是 Nova 的内容主理人。下面是 Nova/Lisa 通过 barbaric-growth 近期研究过的 1-2 个开源项目笔记。

请基于这些笔记产出两版内容草稿：

### 小红书版（500 字内）
- 标题：带 emoji，钩子明确
- 正文：第一人称，口语化，讲"为什么值得关注"
- 结尾 3-5 个话题 tag

### Twitter/X 版（280 字内）
- 一条精炼推文
- 放核心洞察（不是营销文案）
- 可带 1 个 hashtag

最后写一段「## 发布说明」，一句话讲：这条内容的角度是什么、目标读者是谁。

---
素材：
$MATERIAL
EOF
)

PAYLOAD=$(python3 -c "
import json, sys
p = sys.stdin.read()
print(json.dumps({
    'model':'deepseek-chat',
    'messages':[{'role':'user','content':p}],
    'temperature':0.6,
    'max_tokens':1200
}))
" <<< "$PROMPT")

log "ds_call_start"
RESP=$(curl -s --max-time 60 -x "http://127.0.0.1:7897" \
    "https://api.deepseek.com/chat/completions" \
    -H "Authorization: Bearer $DS_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>> "$LOG") || {
    log "ds_failed"
    exit 0
}

CONTENT=$(echo "$RESP" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d['choices'][0]['message']['content'])
except: pass
" 2>> "$LOG")

if [ -z "$CONTENT" ]; then
    log "ds_empty"
    exit 0
fi

{
    echo "# 内容草稿 — $TODAY"
    echo ""
    echo "_来源 patterns:_"
    while IFS= read -r fp; do
        [ -z "$fp" ] && continue
        echo "- \`$(basename "$fp")\`"
    done <<< "$PICKED"
    echo ""
    echo "---"
    echo ""
    echo "$CONTENT"
    echo ""
    echo "---"
    echo ""
    echo "_Nova 审核后再发。发布平台：小红书 / X。_"
} > "$OUT"

log "content_synth_done out=$OUT"
