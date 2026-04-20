#!/bin/bash
# Nova 主动汇报心跳 - 每20分钟触发一次
# 不再静默，汇报当前状态+下一步打算

SCRIPT_DIR="$HOME/.openclaw/workspace/skills/nova-orbit/scripts"
WORKSPACE="$HOME/.openclaw/workspace"
STATE_FILE="$WORKSPACE/heartbeat-state.json"

# 读取心跳状态
if [ -f "$STATE_FILE" ]; then
    LAST_RUN=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d.get('lastChecks',{}).get('statusReport', 'never'))" 2>/dev/null || echo "never")
else
    LAST_RUN="never"
fi

# 构建汇报内容
REPORT="🧊 Nova 主动汇报

📍 当前状态："
# 读取队列状态
if [ -f "$WORKSPACE/tasks/QUEUE.md" ]; then
    PAUSED=$(grep -c "PAUSED" "$WORKSPACE/tasks/QUEUE.md" 2>/dev/null || echo "0")
    READY=$(grep -c "\- \[ \]" "$WORKSPACE/tasks/QUEUE.md" 2>/dev/null || echo "0")
    INPROG=$(grep -c "\- \[x\]" "$WORKSPACE/tasks/QUEUE.md" 2>/dev/null || echo "0")
    REPORT="$REPORT 队列$([ "$PAUSED" -gt "0" ] && echo "PAUSED" || echo "活跃"), $READY 项就绪, $INPROG 项进行中"
fi

# 读取今日工作记录
if [ -f "$WORKSPACE/memory/2026-04-20.md" ]; then
    LAST_LOG=$(tail -20 "$WORKSPACE/memory/2026-04-20.md" 2>/dev/null | grep -E "^## |^### " | tail -5 | head -3)
    REPORT="$REPORT

📋 今日进展：
$LAST_LOG"
fi

# 下一步打算
REPORT="$REPORT

🔮 下一步打算："

NEXT_ITEMS=""
if [ -d "$WORKSPACE/nova-mind/deep-dives" ]; then
    UNDONE=$(ls "$WORKSPACE/nova-mind/deep-dives/"*.md 2>/dev/null | wc -l | tr -d ' ')
    [ "$UNDONE" -gt "0" ] && NEXT_ITEMS="$NEXT_ITEMS · 深挖分析（$UNDONE 个项目待完成）"
fi

if ls ~/gbrain/bin/gbrain 2>/dev/null > /dev/null; then
    NEXT_ITEMS="$NEXT_ITEMS · GBrain 初始化（等 API key）"
fi

if [ -f "$WORKSPACE/memory/waimai-operations-research.md" ]; then
    NEXT_ITEMS="$NEXT_ITEMS · 外卖运营研究（账号回来后对接）"
fi

NEXT_ITEMS="$NEXT_ITEMS · 继续 GitHub 调研 · MEMORY.md 自进化"

REPORT="$REPORT
$NEXT_ITEMS

⏰ $(date '+%H:%M:%S')"

# 发送消息到飞书
openclaw message send --channel feishu --target "user:ou_8b42447ee49c0f3a8c4c6df96e7ec4ae" --message "$REPORT" 2>/dev/null

# 更新状态
python3 -c "
import json
from time import time
d = json.load(open('$STATE_FILE')) if __import__('os').path.exists('$STATE_FILE') else {'lastChecks':{}}
d['lastChecks']['statusReport'] = time()
with open('$STATE_FILE', 'w') as f:
    json.dump(d, f, indent=2)
" 2>/dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Nova 主动汇报心跳已发送"
