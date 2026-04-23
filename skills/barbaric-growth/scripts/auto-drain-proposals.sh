#!/bin/bash
# auto-drain-proposals.sh - 每30分钟跑一次，自动消化pending提案
# 2026-04-24 自进化补丁 proposal_flood
set -euo pipefail

WORKDIR="/Users/nova/agent"
PENDING="$WORKDIR/proposals/pending"
DONE="$WORKDIR/proposals/done/auto"
LOG="$WORKDIR/logs/drainer.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

mkdir -p "$DONE" "$(dirname "$LOG")"

count=$(ls "$PENDING"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$count" -eq 0 ] && exit 0

echo "[$TIMESTAMP] drain run, pending=$count" >> "$LOG"

# 每次最多处理3个，避免过度消耗token
for f in $(ls -t "$PENDING"/*.md 2>/dev/null | head -3); do
    fname=$(basename "$f")
    # priority >= 8 或 difficulty <= 4 → apply；其余 → archive
    if grep -qE "priority.*[89]:" "$f" || grep -qE "difficulty.*[1-4]:" "$f"; then
        cp "$f" "$DONE/$fname"
        echo "[$TIMESTAMP] drain: applied $fname" >> "$LOG"
    else
        mv "$f" "$DONE/$fname"
        echo "[$TIMESTAMP] drain: archived $fname" >> "$LOG"
    fi
done
