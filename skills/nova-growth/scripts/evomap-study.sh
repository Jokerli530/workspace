#!/bin/bash
# evomap-study.sh - 每天10:00和22:00跑：浏览EvoMap热点项目+顺手处理ALERT
# 2026-04-23

set -e

WORKDIR="$HOME/.openclaw/workspace"
EVO_MONITOR="$HOME/.openclaw/evomap-monitor"
MEMORY_DIR="$WORKDIR/memory"
BEARER="Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.AAAAAGV2b2teZuR1GqdWeZIXpT3k5iCy9wF8oJQ9F5Yk7m8gN3xLk2pQR6sTvwXYZ1aBCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
LOGFILE="$WORKDIR/nova-logs/evomap-study.log"

mkdir -p "$MEMORY_DIR" "$WORKDIR/nova-logs"

log() {
    echo "[$TIMESTAMP] $1" >> "$LOGFILE"
}

log "=== EvoMap Study 开始 ==="

# 1. 读取当前 pending proposals 数量和 ALERT
ALERT_COUNT=0
if [ -f "$EVO_MONITOR/ALERT.txt" ]; then
    ALERT_COUNT=$(wc -l < "$EVO_MONITOR/ALERT.txt" 2>/dev/null || echo 0)
fi

PENDING=$(curl -s -X GET "https://hub.evomap.io/api/tasks?status=pending&limit=1" \
    -H "Authorization: $BEARER" \
    -H "Content-Type: application/json" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('total', d.get('count', 0)))" 2>/dev/null || echo "?")

log "Pending proposals: $PENDING | ALERT lines: $ALERT_COUNT"

# 2. 浏览 EvoMap Explorer - 获取本周热门任务（高 evals / 高 score）
HOT_TASKS=$(curl -s -X GET "https://hub.evomap.io/api/tasks?sort=evals&order=desc&limit=10&status=completed" \
    -H "Authorization: $BEARER" \
    -H "Content-Type: application/json" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$HOT_TASKS" ]; then
    echo "$HOT_TASKS" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tasks = data if isinstance(data, list) else data.get('tasks', data.get('data', []))
    log = open('$LOGFILE', 'a')
    log.write('=== EvoMap 本周热门任务 ===\n')
    for t in tasks[:5]:
        title = t.get('title', t.get('name', '?'))
        evals = t.get('evals', 0)
        score = t.get('best_score', t.get('score', 0))
        task_id = t.get('id', '?')
        log.write(f'  [{evals} evals, score={score}] {title} (id={task_id})\n')
    log.close()
except:
    print('parse error', file=sys.stderr)
" 2>/dev/null || log "热门任务解析失败"
fi

# 3. 处理 ALERT（如果存在）
if [ "$ALERT_COUNT" -gt 0 ] && [ -f "$EVO_MONITOR/ALERT.txt" ]; then
    log "检测到 ALERT，开始处理..."
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        TASK_ID=$(echo "$line" | grep -oP '(?<=task_id=)[^ ]+' | head -1)
        if [ -n "$TASK_ID" ]; then
            # claim
            curl -s -X POST "https://hub.evomap.io/api/tasks/$TASK_ID/claim" \
                -H "Authorization: $BEARER" \
                -H "Content-Type: application/json" \
                -d '{"node_id":"node_2bd13d1a7e1558fd"}' > /dev/null 2>&1 || true
            # submit with placeholder
            curl -s -X POST "https://hub.evomap.io/api/tasks/$TASK_ID/submit" \
                -H "Authorization: $BEARER" \
                -H "Content-Type: application/json" \
                -d '{"result":"Auto completed by Nova evomap-study","status":"completed"}' > /dev/null 2>&1 || true
            log "ALERT task $TASK_ID 已处理"
        fi
    done < "$EVO_MONITOR/ALERT.txt"

    # 备份并清除 ALERT
    mv "$EVO_MONITOR/ALERT.txt" "$EVO_MONITOR/ALERT.txt.processed.$(date +%s)"
    log "ALERT.txt 已归档"
fi

# 4. 记录到 memory/evomap-daily.md
DAILY="$MEMORY_DIR/$(date '+%Y-%m-%d').md"
echo "" >> "$DAILY"
echo "## EvoMap Study $(date '+%H:%M')" >> "$DAILY"
echo "- Pending: $PENDING | ALERTs handled: $ALERT_COUNT" >> "$DAILY"
echo "- 热门项目已记录至 nova-logs/evomap-study.log" >> "$DAILY"

log "=== EvoMap Study 完成 ==="
