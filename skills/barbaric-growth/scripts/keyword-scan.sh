#!/bin/bash
# keyword-scan.sh v1.0 — barbaric-growth v1.5 P2
# 关键词定向搜索：补全 trending 漏掉的"够新但 stars 未到阈值"的项目
# 每轮 cycle 随机抽 2 个关键词跑搜索，门槛降到 stars:>200 + pushed:>30d

set -uo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
TRACKED="$WORKSPACE/barbaric-tracked.json"
KEYWORDS_FILE="$WORKSPACE/skills/barbaric-growth/config/keywords.txt"
LOG="/tmp/barbaric-growth.log"
PROXY="-x http://127.0.0.1:7897"
SECRETS="$HOME/.openclaw/secrets"

[ -f "$KEYWORDS_FILE" ] || { echo "no keywords file, skip" >&2; exit 0; }
[ -f "$TRACKED" ] || { echo "no tracked.json, skip" >&2; exit 0; }

# Load GitHub PAT if present
GH_AUTH=()
if [ -f "$SECRETS/github.env" ]; then
    # shellcheck disable=SC1091
    . "$SECRETS/github.env"
    [ -n "${GITHUB_TOKEN:-}" ] && GH_AUTH=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"; }

# Pick 2 random keywords
KEYWORDS=$(grep -v '^#' "$KEYWORDS_FILE" | grep -v '^$' | awk 'NF' | sort -R | head -2)
[ -z "$KEYWORDS" ] && exit 0

# Date cutoff: 30 days ago
CUTOFF=$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d "30 days ago" +%Y-%m-%d)

FOUND_COUNT=0
ADDED_COUNT=0

while IFS= read -r KEYWORD; do
    [ -z "$KEYWORD" ] && continue
    log "keyword_scan keyword=$KEYWORD"

    URL="https://api.github.com/search/repositories?q=${KEYWORD}+stars:>200+pushed:>${CUTOFF}&sort=stars&order=desc&per_page=5"
    if [ ${#GH_AUTH[@]} -gt 0 ]; then
        RAW=$(curl -s --max-time 20 $PROXY -H "Accept: application/vnd.github.v3+json" "${GH_AUTH[@]}" "$URL" 2>> "$LOG")
    else
        RAW=$(curl -s --max-time 20 $PROXY -H "Accept: application/vnd.github.v3+json" "$URL" 2>> "$LOG")
    fi
    [ -z "$RAW" ] && continue

    HITS=$(echo "$RAW" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for r in d.get('items', [])[:5]:
        print(f\"{r['full_name']}|{r['stargazers_count']}|{r.get('language','')}|{(r.get('description') or '')[:80]}\")
except Exception: pass
" 2>/dev/null)

    while IFS='|' read -r NAME STARS LANG DESC; do
        [ -z "$NAME" ] && continue
        FOUND_COUNT=$((FOUND_COUNT + 1))

        # Skip if already tracked
        KNOWN=$(python3 -c "
import json
with open('$TRACKED') as f:
    d = json.load(f)
print('yes' if any(r.get('name') == '$NAME' for r in d.get('tracked', [])) else 'no')
" 2>/dev/null)

        if [ "$KNOWN" = "no" ]; then
            python3 -c "
import json
with open('$TRACKED') as f:
    d = json.load(f)
d['tracked'].append({
    'name': '$NAME',
    'stars': $STARS,
    'language': '$LANG',
    'description': '''$DESC'''.strip(),
    'discovered': '$(date +%Y-%m-%d)',
    'discovered_via': 'keyword:$KEYWORD',
})
d.setdefault('pending_research', []).append('$NAME')
with open('$TRACKED', 'w') as f:
    json.dump(d, f, indent=2)
" 2>/dev/null
            log "keyword_hit_new keyword=$KEYWORD repo=$NAME stars=$STARS"
            ADDED_COUNT=$((ADDED_COUNT + 1))
        fi
    done <<< "$HITS"
done <<< "$KEYWORDS"

log "keyword_scan_done checked=$FOUND_COUNT added=$ADDED_COUNT keywords=$(echo "$KEYWORDS" | tr '\n' ',' | sed 's/,$//')"
echo "[$(date '+%H:%M:%S')] keyword-scan: $FOUND_COUNT hits / $ADDED_COUNT new"
