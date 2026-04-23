#!/bin/bash
# nova-growth patrol.sh - 健康巡检 Lisa + 核心组件
set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
LOG="/tmp/nova-patrol.log"
LOCK="$WORKSPACE/nova-patrol.lock"
ALERT_FILE="$HOME/.openclaw/evomap-monitor/ALERT.txt"
AGENT_DIR="/Users/nova/agent"
NOW=$(date '+%Y-%m-%d %H:%M:%S')
TS=$(date +%s)

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"; }
alert() {
    mkdir -p "$(dirname "$ALERT_FILE")"
    echo "[$NOW] nova-patrol: $1" >> "$ALERT_FILE"
    log "ALERT: $1"
}

# Lock
if [ -f "$LOCK" ]; then
    PID=$(cat "$LOCK" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        exit 0
    fi
    rm -f "$LOCK"
fi
echo $$ > "$LOCK"
trap "rm -f $LOCK" EXIT

log "patrol_start"

ISSUES=0

# Capture launchctl list once — piping to `grep -q` with pipefail on gives
# false negatives because grep closes the pipe and launchctl gets SIGPIPE.
LC_LIST=$(launchctl list 2>/dev/null || true)

# 1. Lisa LaunchAgent alive?
if echo "$LC_LIST" | grep -q "com.nova.agent"; then
    STATUS=$(echo "$LC_LIST" | grep "com.nova.agent" | awk '{print $1,$2}')
    log "lisa_agent ok status=$STATUS"
    # Column 2 = last exit code. Non-zero (except "-") means crashed
    EXIT_CODE=$(echo "$STATUS" | awk '{print $2}')
    if [ "$EXIT_CODE" != "0" ] && [ "$EXIT_CODE" != "-" ]; then
        alert "Lisa LaunchAgent 上次退出码=$EXIT_CODE（非零）"
        ISSUES=$((ISSUES+1))
    fi
else
    alert "Lisa LaunchAgent com.nova.agent 不在 launchctl list 里"
    ISSUES=$((ISSUES+1))
fi

# 2. state.db freshness - agent 活着会刷这个文件
if [ -f "$AGENT_DIR/state.db" ]; then
    MTIME=$(stat -f %m "$AGENT_DIR/state.db")
    AGE=$((TS - MTIME))
    AGE_MIN=$((AGE / 60))
    log "state_db age_min=$AGE_MIN"
    # Lisa 至少每小时会写点东西 —— 超过 3h 没动静就报
    if [ "$AGE" -gt 10800 ]; then
        alert "state.db 已 ${AGE_MIN} 分钟未更新 — Lisa 可能卡住"
        ISSUES=$((ISSUES+1))
    fi
else
    alert "Lisa state.db 文件不存在: $AGENT_DIR/state.db"
    ISSUES=$((ISSUES+1))
fi

# 3. 今日日志是否有 ERROR/CRITICAL（只看最近 100 行，过滤常见误报）
TODAY_LOG="$AGENT_DIR/logs/$(date +%Y-%m-%d).log"
if [ -f "$TODAY_LOG" ]; then
    ERR_COUNT=$(tail -200 "$TODAY_LOG" 2>/dev/null | grep -c -E "(ERROR|CRITICAL|Traceback)" || true)
    log "today_log errors=$ERR_COUNT"
    if [ "$ERR_COUNT" -gt 5 ]; then
        alert "Lisa 今日日志末 200 行含 ${ERR_COUNT} 个 ERROR/Traceback"
        ISSUES=$((ISSUES+1))
    fi
fi

# 4. barbaric-growth LaunchAgents 健康
for AGENT in ai.openclaw.barbaric-growth ai.openclaw.barbaric-growth-discover; do
    if ! echo "$LC_LIST" | grep -q "$AGENT"; then
        alert "LaunchAgent $AGENT 不在 launchctl list 里"
        ISSUES=$((ISSUES+1))
    fi
done

# 5. 磁盘占用告警 (根分区 > 90%)
DISK_USE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
log "disk_use ${DISK_USE}%"
if [ "${DISK_USE:-0}" -gt 90 ] 2>/dev/null; then
    alert "根分区磁盘使用率 ${DISK_USE}%"
    ISSUES=$((ISSUES+1))
fi

# 6. pending proposals 太多（超过 10 条说明 Nova 没在审批）
PROPOSAL_DIR="$AGENT_DIR/proposals/pending"
if [ -d "$PROPOSAL_DIR" ]; then
    PENDING_COUNT=$(ls "$PROPOSAL_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
    log "proposals_pending=$PENDING_COUNT"
    if [ "$PENDING_COUNT" -gt 10 ]; then
        alert "Lisa 待审批提案堆了 ${PENDING_COUNT} 条 — Nova 请review"
        ISSUES=$((ISSUES+1))
    fi
fi

log "patrol_done issues=$ISSUES"

# 轮转日志，避免无限膨胀
if [ -f "$LOG" ]; then
    LOG_SIZE=$(stat -f %z "$LOG" 2>/dev/null || echo 0)
    if [ "$LOG_SIZE" -gt 524288 ]; then  # 500KB
        tail -500 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
    fi
fi
