#!/bin/bash
# nova-growth reflect.sh - 扫 patterns/ 找跨项目规律，写到 nova-mind/reflections/
set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
PATTERNS_DIR="$WORKSPACE/patterns"
REFLECT_DIR="$WORKSPACE/nova-mind/reflections"
LOG="/tmp/nova-reflect.log"
LOCK="$WORKSPACE/nova-reflect.lock"
DS_SECRET="$HOME/.openclaw/secrets/deepseek.env"
TODAY=$(date +%Y-%m-%d)
OUT="$REFLECT_DIR/$TODAY.md"

mkdir -p "$REFLECT_DIR"

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"; }

# Lock
if [ -f "$LOCK" ]; then
    PID=$(cat "$LOCK" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        log "already_running pid=$PID"
        exit 0
    fi
    rm -f "$LOCK"
fi
echo $$ > "$LOCK"
trap "rm -f $LOCK" EXIT

log "reflect_start"

# Load DeepSeek key
if [ ! -f "$DS_SECRET" ]; then
    log "deepseek_missing fallback=static"
    DS_KEY=""
else
    # shellcheck disable=SC1090
    . "$DS_SECRET"
    DS_KEY="${DEEPSEEK_API_KEY:-}"
fi

# Collect pattern files (skip templates)
if [ ! -d "$PATTERNS_DIR" ]; then
    log "no_patterns_dir"
    exit 0
fi

PATTERN_FILES=$(ls "$PATTERNS_DIR"/*.md 2>/dev/null | grep -v -i template | head -20)

if [ -z "$PATTERN_FILES" ]; then
    log "no_patterns"
    exit 0
fi

# Build material: for each pattern, extract repo name + core positioning + unique mechanism
MATERIAL=$(PATTERNS_DIR="$PATTERNS_DIR" python3 << 'PYEOF'
import os, re, glob
patterns_dir = os.environ.get('PATTERNS_DIR', '/Users/nova/.openclaw/workspace/patterns')
entries = []
for fp in sorted(glob.glob(f"{patterns_dir}/*.md")):
    name = os.path.basename(fp).replace('.md','')
    if 'template' in name.lower():
        continue
    with open(fp) as f:
        txt = f.read()
    # get repo name from first heading
    m = re.search(r'^#\s+(.+)$', txt, re.M)
    title = m.group(1).strip() if m else name
    # get 核心定位 block
    positioning = ''
    m = re.search(r'核心定位[^\n]*\n+([\s\S]*?)(?=\n##|\n\*\*|\Z)', txt)
    if m:
        positioning = m.group(1).strip()[:400]
    # get 独特机制 block
    mechanism = ''
    m = re.search(r'独特机制[^\n]*\n+([\s\S]*?)(?=\n##|\n\*\*|\Z)', txt)
    if m:
        mechanism = m.group(1).strip()[:400]
    if positioning or mechanism:
        entries.append(f"### {title}\n定位: {positioning}\n机制: {mechanism}")

print("\n\n".join(entries[:15]))
PYEOF
) || MATERIAL=""

if [ -z "$MATERIAL" ]; then
    log "no_material"
    exit 0
fi

MATERIAL_LEN=${#MATERIAL}
log "material_collected len=$MATERIAL_LEN"

# Write header + raw material (always, even if LLM fails)
{
    echo "# Nova 反思日记 — $TODAY"
    echo ""
    echo "_自动扫描 \`barbaric-growth/patterns/\` 产出跨项目规律。_"
    echo ""
    echo "## 原始素材（已研究项目的定位 + 机制）"
    echo ""
    echo "$MATERIAL"
    echo ""
} > "$OUT"

# Call DeepSeek for synthesis
if [ -z "$DS_KEY" ]; then
    log "no_ds_key skip_llm"
    exit 0
fi

PROMPT=$(cat << EOF
你是 Nova 的反思助手。下面是我（Nova）近期通过 barbaric-growth 研究过的开源项目摘要。

请从跨项目视角找出 3-5 个「规律」或「反复出现的模式」——比如：
- 多个项目都在解决同一类问题吗？
- 有没有技术栈上的趋势（比如大家都用 MCP / 都选 Rust）？
- 有没有哪个机制在不同项目里以不同形式出现？
- 对 Nova/Lisa 项目的启示是什么？

输出格式（不要 JSON，直接 Markdown）：

## 规律 1: <一句话标题>
<2-3 句分析，引用具体项目名>
**对我的启示**: <一句话，具体可执行>

## 规律 2: ...

最后来一段「## 本周要尝试的一件事」，从上述规律里挑最值得 Nova 动手的一条，写成明天可以开始做的小动作。

---
素材：
$MATERIAL
EOF
)

PAYLOAD=$(python3 -c "
import json, sys
p = sys.stdin.read()
print(json.dumps({
    'model': 'deepseek-chat',
    'messages': [{'role':'user','content': p}],
    'temperature': 0.4,
    'max_tokens': 1200
}))
" <<< "$PROMPT")

log "ds_call_start"
RESP=$(curl -s --max-time 60 \
    -x "http://127.0.0.1:7897" \
    "https://api.deepseek.com/chat/completions" \
    -H "Authorization: Bearer $DS_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>> "$LOG") || {
    log "ds_call_failed"
    exit 0
}

CONTENT=$(echo "$RESP" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d['choices'][0]['message']['content'])
except Exception as e:
    print('', file=sys.stderr)
    sys.exit(1)
" 2>> "$LOG") || {
    log "ds_parse_failed"
    exit 0
}

if [ -z "$CONTENT" ]; then
    log "ds_empty"
    exit 0
fi

{
    echo ""
    echo "---"
    echo ""
    echo "## LLM 综合反思"
    echo ""
    echo "$CONTENT"
} >> "$OUT"

log "reflect_done out=$OUT"
