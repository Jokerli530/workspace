#!/bin/bash
# nova-growth self-review.sh - 每次 patrol 后轻量自检，写入 evolution-log
# 核心：找到具体失败点 → 判断是否需要改代码 → 立即落地

set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
PATROL_LOG="/tmp/nova-patrol.log"
EVOLUTION_LOG="$WORKSPACE/nova-mind/evolution-log.md"
WORKDIR="/Users/nova/agent"
AGENT_PY="$WORKDIR/agent.py"

mkdir -p "$(dirname "$EVOLUTION_LOG")"

log() { echo "[$(date '+%H:%M:%S') $1]" >> "$EVOLUTION_LOG"; }

# 读取最近一次 patrol 的 issue 列表
ISSUES=$(grep "ALERT:" "$PATROL_LOG" 2>/dev/null | tail -5 | sed 's/.*ALERT: //')

if [ -z "$ISSUES" ]; then
    log "self-review: no issues, skip"
    exit 0
fi

log "=== SELF-REVIEW $(date '+%Y-%m-%d %H:%M:%S') ==="
log "Issues: $ISSUES"

# ---- 通用错误模式检测 ----
# 使用临时文件存储建议，避免shell变量问题

check_and_log() {
    local pattern="$1"
    local suggestion="$2"
    local COUNT
    COUNT_INT=$(grep -c "$pattern" "$EVOLUTION_LOG" 2>/dev/null | tr -d '[:space:]' || echo "0")
    COUNT_INT=${COUNT_INT:-0}
    COUNT_INT=$((COUNT_INT + 0))
    if [ "$COUNT_INT" -ge 2 ]; then
        log "⚠️  PATTERN '$pattern' 出现第 $((COUNT_INT+1)) 次，触发 self-modification"
        log "   → 建议改进: $suggestion"
    else
        log "📝 PATTERN '$pattern' 首次出现（$COUNT_INT 次），记录观察"
    fi
}

while IFS= read -r line; do
    [ -z "$line" ] && continue

    # 1. state.db 未更新
    if echo "$line" | grep -q "state.db.*未更新\|state.db.*更新\|state.db.*stale"; then
        check_and_log "state_db_stale" "增加 state.db 强制刷新机制，每 30min 强制写一次"
    fi

    # 2. pending proposals 堆积
    if echo "$line" | grep -q "待审批提案.*堆了\|proposals.*pending"; then
        check_and_log "proposal_flood" "搜索无结果时立即 fallback，不等待超时"
    fi

    # 3. API 请求失败
    if echo "$line" | grep -q "API请求失败\|curl.*failed\|连接失败\|连接被拒绝"; then
        check_and_log "api_failure" "增加指数退避重试，timeout 15s->30s，proxy 自动切换"
    fi

    # 4. LaunchAgent 挂了
    if echo "$line" | grep -q "LaunchAgent.*不在\|LaunchAgent.*挂了\|不在 launchctl"; then
        check_and_log "launchagent_down" "自动 restart 对应的 LaunchAgent.plist"
    fi

    # 5. plan_cycle 空响应
    if echo "$line" | grep -q "plan_cycle.*空\|空响应.*崩溃\|plan.*crash"; then
        check_and_log "plan_cycle_empty" "plan_cycle 增加空响应检查，{} 返回时跳过不崩溃"
    fi

done <<< "$ISSUES"

log ""
