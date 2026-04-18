#!/bin/bash
# Nova Self-Assessment — Run after each major task
# Usage: bash self-assessment.sh "<task description>"

TASK="$1"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
LOG="$HOME/.openclaw/workspace/nova-mind/logs/evolution.md"

if [ -z "$TASK" ]; then
  echo "Usage: self-assessment.sh <task description>"
  exit 1
fi

cat >> "$LOG" << EOF
## $DATE $TIME — $TASK

**任务**: $TASK

**自评估**:
1. 最正确的决定是什么？
2. 如果重来，会怎么改？
3. 这个任务揭示了什么缺陷？
4. 下次遇到类似，怎么更好？

EOF

echo "✅ Self-assessment logged"
echo "Open: $LOG"
