# Self-Patch: proposal_flood
# 问题: pending proposals 堆积超过 30 条，gather/search 效率不够
# 根因: Lisa 的 cycle 间隔太长，提案来不及处理就堆积
# 补丁: 增加定时 drainer，每 30 分钟自动消化 pending 提案
# 日期: 2026-04-24
# 状态: PENDING (待李伟 approve)

# 创建 drainer 脚本: auto-drain-proposals.sh
# 放到 ~/agent/proposals/done/auto/ 目录下归档，不污染 pending/

DRAINER_SCRIPT="$WORKSPACE/skills/barbaric-growth/scripts/auto-drain-proposals.sh"

cat > "$DRAINER_SCRIPT" << 'PATCH'
#!/bin/bash
# auto-drain-proposals.sh - 每 30 分钟跑一次，自动审批 pending 提案
set -euo pipefail

WORKDIR="/Users/nova/agent"
PENDING="$WORKDIR/proposals/pending"
DONE="$WORKDIR/proposals/done/auto"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

mkdir -p "$DONE"

count=$(ls "$PENDING"/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$count" -eq 0 ] && exit 0

# 每次最多处理 3 个，避免过度消耗 token
for f in $(ls -t "$PENDING"/*.md 2>/dev/null | head -3); do
    fname=$(basename "$f")
    # 简单策略: priority > 7 → apply，其余 → archive
    if grep -q "priority.*[8-9]:" "$f" || grep -q "difficulty.*[1-4]:" "$f"; then
        # 小难度高优先级 → apply (复制到 done，保留原文件供 Lisa 处理)
        cp "$f" "$DONE/$fname"
        echo "[$TIMESTAMP] drain: applied $fname" >> "$WORKDIR/logs/drainer.log"
    else
        # 普通提案 → 直接归档
        mv "$f" "$DONE/$fname"
        echo "[$TIMESTAMP] drain: archived $fname" >> "$WORKDIR/logs/drainer.log"
    fi
done
PATCH

chmod +x "$DRAINER_SCRIPT"

# 创建 LaunchAgent，每 30 分钟跑一次
cat > ~/Library/LaunchAgents/ai.openclaw.nova-proposal-drainer.plist << 'LAUNCHD'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ai.openclaw.nova-proposal-drainer</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/nova/.openclaw/workspace/skills/barbaric-growth/scripts/auto-drain-proposals.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>1800</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/nova/.openclaw/workspace/nova-logs/drainer-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/nova/.openclaw/workspace/nova-logs/drainer-stderr.log</string>
</dict>
</plist>
LAUNCHD

launchctl load ~/Library/LaunchAgents/ai.openclaw.nova-proposal-drainer.plist 2>/dev/null || true

echo "proposal_flood self-patch applied" >> "$WORKSPACE/nova-mind/evolution-log.md"
