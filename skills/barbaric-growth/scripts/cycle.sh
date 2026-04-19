#!/bin/bash
# barbaric-growth Runner v1.3 - Nova's autonomous research engine
# Searches GitHub → discovers new repos → updates known repos → publishes EvoMap Capsules

set -euo pipefail

WORKSPACE=

# Prevent concurrent runs
LOCK="$WORKSPACE/barbaric-growth-run.lock"
if [ -f "$LOCK" ]; then
    LOCK_PID=$(cat "$LOCK" 2>/dev/null)
    if [ -n "$LOCK_PID" ] && kill -0 "$LOCK_PID" 2>/dev/null; then
        echo "barbaric-growth already running (PID $LOCK_PID), exiting"
        exit 0
    fi
    rm -f "$LOCK"
fi
echo $$ > "$LOCK"
trap "rm -f $LOCK" EXIT
"/Users/nova/.openclaw/workspace"
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
# Single combined query - reduces from 3 API calls to 1
RAW=$(curl -s $PROXY \
    "https://api.github.com/search/repositories?q=stars:>50000+language:rust+OR+language:typescript+pushed:>2026-01-01&sort=stars&per_page=10" \
    -H "Accept: application/vnd.github.v3+json" 2>> "$LOG")
TRENDING=$(echo "$RAW" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    seen=set()
    count=0
    for r in d.get('items',[]):
        name=r['full_name']
        if name not in seen and count < 5:
            seen.add(name)
            print(f\"{name}|{r['stargazers_count']}|{r.get('language','')}|{r.get('description','')[:60]}\")
            count+=1
except: pass
" 2>> "$LOG")

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

# Self-evolution: extract patterns from newly researched repos
bash "$WORKSPACE/skills/barbaric-growth/scripts/self-evo.sh" 2>/dev/null

# Sync barbar-tracked.json with pattern files
bash "$WORKSPACE/skills/barbaric-growth/scripts/sync-state.sh" 2>/dev/null

log "barbaric_growth_complete"

# GitHub API cache - 减少重复请求
GITHUB_CACHE="$WORKSPACE/.github-cache.json"
CACHE_TTL=600  # 10分钟内不重复请求

github_cached() {
    local query="$1"
    local now=$(date +%s)
    
    if [ -f "$GITHUB_CACHE" ]; then
        local cached=$(python3 -c "
import json, time
try:
    with open('$GITHUB_CACHE') as f:
        d = json.load(f)
    if '$query' in d:
        entry = d['$query']
        if $now - entry.get('ts', 0) < $CACHE_TTL:
            print(entry.get('data', ''))
        else:
            print('EXPIRED')
    else:
        print('MISS')
except: print('ERR')
" 2>/dev/null)
        echo "$cached"
    else
        echo "MISS"
    fi
}

github_save_cache() {
    local query="$1"
    local data="$2"
    local now=$(date +%s)
    
    python3 << PYEOF 2>/dev/null
import json, time, os
cache_file = '$GITHUB_CACHE'
d = {}
if os.path.exists(cache_file):
    try:
        with open(cache_file) as f:
            d = json.load(f)
    except: d = {}
d['$query'] = {'ts': $now, 'data': '$data'}
with open(cache_file, 'w') as f:
    json.dump(d, f)
PYEOF
}
