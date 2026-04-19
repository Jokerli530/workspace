#!/bin/bash
# barbaric-growth Runner v1.3 - Nova's autonomous research engine
# Searches GitHub → discovers new repos → updates known repos → publishes EvoMap Capsules

set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
STATE="$WORKSPACE/heartbeat-state.json"
LOG="/tmp/barbaric-growth.log"
BRV_STATE="$WORKSPACE/byterover-state.json"
TRACKED="$WORKSPACE/barbaric-tracked.json"
PROXY="-x http://127.0.0.1:7897"
CYCLE_SCRIPT_DIR="$(dirname "$0")"

# Check token guard
bash "$WORKSPACE/skills/barbaric-growth/scripts/token-guard.sh" check 2>/dev/null || {
    echo "[$(date '+%H:%M:%S')] token_guard_blocked" >> "$LOG"
    exit 0
}

log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

init_tracked() {
    [ -f "$TRACKED" ] && return
    echo '{"tracked":[],"pending_research":[]}' > "$TRACKED"
}

log "barbaric_growth_start"
init_tracked

# 1. GitHub Trending - find interesting repos (AI/agent related)
log "phase=github action=search"
SEARCH_QUERIES=(
    "stars:>50000+language:rust+pushed:>2026-01-01"
    "stars:>50000+language:typescript+AI+agent+pushed:>2026-01-01"
    "stars:>30000+openclaw+OR+claude-code+OR+agent-harness+pushed:>2026-01-01"
)

TRENDING=""
for query in "${SEARCH_QUERIES[@]}"; do
    RAW=$(curl -s $PROXY \
        "https://api.github.com/search/repositories?q=${query}&sort=stars&per_page=3" \
        -H "Accept: application/vnd.github.v3+json" 2>> "$LOG")
    ITEMS=$(echo "$RAW" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    for r in d.get('items',[])[:3]:
        print(f\"{r['full_name']}|{r['stargazers_count']}|{r.get('language','')}|{r.get('description','')[:60]}\")
except: pass
" 2>> "$LOG")
    TRENDING="$TRENDING"$'\n'"$ITEMS"
done

# Deduplicate and filter
NEW_REPOS=$(echo "$TRENDING" | grep -v "^$" | sort -u -t'|' -k1,1 | head -5)

# Track newly discovered repos
echo "$NEW_REPOS" | while IFS='|' read -r NAME STARS LANG DESC; do
    [ -z "$NAME" ] && continue
    
    # Check if already tracked
    KNOWN=$(python3 -c "
import json
with open('$TRACKED') as f:
    d = json.load(f)
names = [r['name'] for r in d.get('tracked',[])]
print('yes' if '$NAME' in names else 'no')
" 2>/dev/null)
    
    if [ "$KNOWN" = "no" ]; then
        log "NEW_REPO_DISCOVERED: $NAME ($STARS stars, $LANG)"
        
        # Add to tracked
        python3 -c "
import json
with open('$TRACKED') as f:
    d = json.load(f)
d['tracked'].append({
    'name': '$NAME',
    'stars': $STARS,
    'language': '$LANG',
    'description': '''$DESC'''.strip(),
    'discovered': '$(date +%Y-%m-%d)'
})
d['pending_research'].append('$NAME')
with open('$TRACKED', 'w') as f:
    json.dump(d, f)
" 2>/dev/null
        
        # If high-value repo (>=50k stars), queue for capsule
        if [ "$STARS" -ge 50000 ] 2>/dev/null; then
            log "HIGH_VALUE_REPO_QUEUED: $NAME ($STARS stars) - needs EvoMap Capsule"
        fi
    fi
done

# 2. Pending research check - high priority repos to deep dive
PENDING=$(python3 -c "
import json
with open('$TRACKED') as f:
    d = json.load(f)
pending = d.get('pending_research', [])
print('\n'.join(pending[:3]))
" 2>/dev/null)

if [ -n "$PENDING" ]; then
    for repo in $PENDING; do
        log "RESEARCH_PENDING: $repo"
    done
fi

# 3. ByteRover curation (if tokens available)
BRV_TOKENS=$(python3 -c "
import json
try:
    with open('$BRV_STATE') as f:
        s = json.load(f)
    print(s.get('daily_remaining', 50))
except: print(50)
" 2>/dev/null)

if [ "$BRV_TOKENS" -gt 5 ] && [ -n "$NEW_REPOS" ]; then
    BRV_CONTENT="Auto-research by Nova barbaric-growth runner on $(date '+%Y-%m-%d'):\n\n$NEW_REPOS"
    echo "$BRV_CONTENT" | brv curate --detach 2>/dev/null && {
        log "byterover_captured"
        python3 -c "
import json
with open('$BRV_STATE') as f:
    s = json.load(f)
s['daily_remaining'] = max(0, s.get('daily_remaining', 50) - 1)
with open('$BRV_STATE', 'w') as f:
    json.dump(s, f)
" 2>/dev/null
    } || log "byterover_skipped"
else
    [ "$BRV_TOKENS" -le 5 ] && log "byterover_exhausted"
fi

# 4. Star Office update
log "phase=staroffice action=update"
curl -s -X POST "http://127.0.0.1:19000/api/status" \
    -H "Content-Type: application/json" \
    -d '{"status":"researching","detail":"barbaric-growth v1.3 running"}' 2>/dev/null || true

# 5. Update heartbeat state
python3 -c "
import json, time
try:
    with open('$STATE') as f:
        s = json.load(f)
    s.setdefault('lastChecks', {})['barbaric'] = time.time()
    with open('$STATE', 'w') as f:
        json.dump(s, f)
except: pass
" 2>/dev/null

log "barbaric_growth_complete"
