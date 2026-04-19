#!/bin/bash
# barbaric-growth Runner - Nova's autonomous research engine
# Searches GitHub → ByteRover knowledge → EvoMap Capsule → Star Office

set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
STATE="$WORKSPACE/heartbeat-state.json"
LOG="/tmp/barbaric-growth.log"
BRV_STATE="$WORKSPACE/byterover-state.json"
PROXY="-x http://127.0.0.1:7897"

# Check token guard first
bash "$WORKSPACE/skills/barbaric-growth/scripts/token-guard.sh" check 2>/dev/null || {
    echo "[$(date '+%H:%M:%S')] token_guard_blocked" >> "$LOG"
    exit 0
}

log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

log "barbaric_growth_start"

# 1. GitHub Trending - find interesting repos
log "phase=github action=search"
TRENDING=$(curl -s $PROXY \
    "https://api.github.com/search/repositories?q=stars:>100+created:>2025-01-01&sort=stars&per_page=5" \
    -H "Accept: application/vnd.github.v3+json" 2>> "$LOG" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    for r in d.get('items',[])[:5]:
        print(f\"{r['full_name']}|{r['stargazers_count']}|{r['description'] or ''[:80]}\")
except: print('github_err')
" 2>> "$LOG")

if [ -z "$TRENDING" ] || echo "$TRENDING" | grep -q "github_err"; then
    log "github_failed"
else
    echo "$TRENDING" | while IFS='|' read -r NAME STARS DESC; do
        [ -z "$NAME" ] && continue
        log "found_repo: $NAME ($STARS stars)"
    done
fi

# 2. ByteRover - curate interesting findings
BRV_TOKENS=$(python3 -c "
import json
try:
    with open('$BRV_STATE') as f:
        s = json.load(f)
    print(s.get('daily_remaining', 50))
except: print(50)
" 2>/dev/null)

if [ "$BRV_TOKENS" -gt 5 ]; then
    log "phase=byterover action=curate tokens=$BRV_TOKENS"
    # Use ByteRover to store a research note
    echo "# GitHub Research $(date '+%Y-%m-%d')

## Trending Repos
$TRENDING

## Notes
Auto-researched by Nova barbaric-growth runner." > /tmp/brv_input.md
    
    # Try brv curate
    brv curate --file /tmp/brv_input.md 2>/dev/null && {
        log "byterover_captured"
        python3 -c "
import json
try:
    with open('$BRV_STATE') as f:
        s = json.load(f)
    s['daily_remaining'] = max(0, s.get('daily_remaining', 50) - 1)
    with open('$BRV_STATE', 'w') as f:
        json.dump(s, f)
except: pass
"
    } || log "byterover_skipped"
else
    log "byterover_exhausted"
fi

# 3. Star Office - update status
log "phase=staroffice action=update"
STAR_PORT=19000
curl -s -X POST "http://127.0.0.1:$STAR_PORT/api/status" \
    -H "Content-Type: application/json" \
    -d '{"status":"researching","detail":"barbaric-growth running"}' 2>/dev/null || true

# 4. Check if there's a pending research task in QUEUE
RESEARCH_TASK=$(grep -A3 "GitHub调研" "$WORKSPACE/tasks/QUEUE.md" 2>/dev/null | grep "\- \[ \]" | head -1)
if [ -n "$RESEARCH_TASK" ]; then
    log "queue_task_found"
    # Mark it in progress in QUEUE.md (just log, actual research needs Nova)
fi

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
