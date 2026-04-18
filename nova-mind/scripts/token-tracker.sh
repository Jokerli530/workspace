#!/bin/bash
# Nova Token Economy Tracker v1.0
# 追踪每次任务的 token 消耗和经济指标

TRACKER_DIR="$HOME/.openclaw/workspace/nova-mind/logs"
TOKEN_LOG="$TRACKER_DIR/token-log.md"
METRICS_LOG="$TRACKER_DIR/metrics.json"

mkdir -p "$TRACKER_DIR"

# 当前时间窗口计算（MiniMax 5小时窗口）
get_window() {
    HOUR=$(date +%H)
    if [ "$HOUR" -ge 0 ] && [ "$HOUR" -lt 5 ]; then
        echo "00:00-05:00"
    elif [ "$HOUR" -ge 5 ] && [ "$HOUR" -lt 10 ]; then
        echo "05:00-10:00"
    elif [ "$HOUR" -ge 10 ] && [ "$HOUR" -lt 15 ]; then
        echo "10:00-15:00"
    elif [ "$HOUR" -ge 15 ] && [ "$HOUR" -lt 20 ]; then
        echo "15:00-20:00"
    else
        echo "20:00-00:00"
    fi
}

# 记录任务
log_task() {
    TASK_NAME="$1"
    EST_TOKENS="$2"
    NOTES="$3"
    WINDOW=$(get_window)
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
    
    cat >> "$TOKEN_LOG" << LOGEOF
| $TIMESTAMP | $WINDOW | $TASK_NAME | ~$EST_TOKENS | $NOTES |
LOGEOF
    echo "✅ Logged: $TASK_NAME (~${EST_TOKENS} tokens, $WINDOW window)"
}

# 统计当前窗口
report_window() {
    WINDOW=$(get_window)
    TODAY=$(date "+%Y-%m-%d")
    
    echo "=== Token Economy Report ==="
    echo "Window: $WINDOW"
    echo "Date: $TODAY"
    echo ""
    
    if [ -f "$TOKEN_LOG" ]; then
        echo "Recent entries:"
        grep "$TODAY" "$TOKEN_LOG" | tail -10
    fi
}

case "$1" in
    log)
        log_task "$2" "$3" "$4"
        ;;
    report)
        report_window
        ;;
    *)
        echo "Usage: token-tracker.sh {log|report}"
        echo "  log <task_name> <est_tokens> <notes>"
        echo "  report"
        ;;
esac
