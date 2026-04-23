#!/bin/bash
# nova-growth ledger-review.sh - 每周变现回顾
set -euo pipefail

WORKSPACE="/Users/nova/.openclaw/workspace"
LEDGER_DIR="/Users/nova/agent/ledger"
REVIEW_DIR="$WORKSPACE/nova-mind/ledger-reviews"
LOG="/tmp/nova-ledger.log"
LOCK="$WORKSPACE/nova-ledger.lock"
DS_SECRET="$HOME/.openclaw/secrets/deepseek.env"

YEAR=$(date +%Y)
WEEK=$(date +%V)
OUT="$REVIEW_DIR/${YEAR}-W${WEEK}.md"
TODAY=$(date '+%Y-%m-%d')

mkdir -p "$REVIEW_DIR"

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"; }

if [ -f "$LOCK" ]; then
    PID=$(cat "$LOCK" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        exit 0
    fi
    rm -f "$LOCK"
fi
echo $$ > "$LOCK"
trap "rm -f $LOCK" EXIT

log "ledger_review_start week=$YEAR-W$WEEK"

if [ ! -d "$LEDGER_DIR" ]; then
    log "ledger_dir_missing: $LEDGER_DIR"
    exit 0
fi

# Parse income.csv / expense.csv (assumed format: date,amount,category,note)
INCOME_CSV="$LEDGER_DIR/income.csv"
EXPENSE_CSV="$LEDGER_DIR/expense.csv"

STATS=$(python3 << PYEOF
import csv, os, datetime, sys
ledger = "$LEDGER_DIR"
week_start = datetime.date.today() - datetime.timedelta(days=6)

def parse(path):
    if not os.path.exists(path):
        return []
    rows = []
    with open(path) as f:
        try:
            reader = csv.reader(f)
            for row in reader:
                if not row or row[0].strip().startswith('#'): continue
                if row[0].strip().lower() in ('date','日期'): continue
                if len(row) < 2: continue
                try:
                    d = datetime.date.fromisoformat(row[0].strip())
                    amt = float(row[1].strip())
                    cat = row[2].strip() if len(row) > 2 else ''
                    note = row[3].strip() if len(row) > 3 else ''
                    rows.append({'date':d, 'amt':amt, 'cat':cat, 'note':note})
                except Exception:
                    continue
        except Exception as e:
            print(f"parse_err {path}: {e}", file=sys.stderr)
    return rows

income = parse("$INCOME_CSV")
expense = parse("$EXPENSE_CSV")

week_income = [r for r in income if r['date'] >= week_start]
week_expense = [r for r in expense if r['date'] >= week_start]

total_income_all = sum(r['amt'] for r in income)
total_expense_all = sum(r['amt'] for r in expense)
week_income_sum = sum(r['amt'] for r in week_income)
week_expense_sum = sum(r['amt'] for r in week_expense)

print(f"WEEK_INCOME={week_income_sum}")
print(f"WEEK_EXPENSE={week_expense_sum}")
print(f"WEEK_NET={week_income_sum - week_expense_sum}")
print(f"TOTAL_INCOME={total_income_all}")
print(f"TOTAL_EXPENSE={total_expense_all}")
print(f"INCOME_ENTRIES={len(week_income)}")
print(f"EXPENSE_ENTRIES={len(week_expense)}")
print("---ENTRIES---")
for r in week_income:
    print(f"IN|{r['date']}|{r['amt']}|{r['cat']}|{r['note']}")
for r in week_expense:
    print(f"OUT|{r['date']}|{r['amt']}|{r['cat']}|{r['note']}")
PYEOF
) || {
    log "stats_parse_failed"
    exit 0
}

log "stats_ok"

# Extract summary vars
WEEK_INCOME=$(echo "$STATS" | grep "^WEEK_INCOME=" | cut -d= -f2)
WEEK_EXPENSE=$(echo "$STATS" | grep "^WEEK_EXPENSE=" | cut -d= -f2)
WEEK_NET=$(echo "$STATS" | grep "^WEEK_NET=" | cut -d= -f2)
TOTAL_INCOME=$(echo "$STATS" | grep "^TOTAL_INCOME=" | cut -d= -f2)
TOTAL_EXPENSE=$(echo "$STATS" | grep "^TOTAL_EXPENSE=" | cut -d= -f2)
ENTRIES=$(echo "$STATS" | sed -n '/---ENTRIES---/,$p' | tail -n +2)

# 目标进度（200k / 8个月 → 25k/月 → 6250/周）
TARGET=200000
WEEK_TARGET=6250

# 写报告
{
    echo "# Ledger 周报 — ${YEAR}-W${WEEK}"
    echo ""
    echo "_生成于 ${TODAY}_"
    echo ""
    echo "## 本周"
    echo ""
    echo "| 项 | 金额 |"
    echo "|---|---|"
    echo "| 收入 | ¥${WEEK_INCOME} |"
    echo "| 支出 | ¥${WEEK_EXPENSE} |"
    echo "| 净值 | ¥${WEEK_NET} |"
    echo "| 周目标 | ¥${WEEK_TARGET} |"
    echo ""
    echo "## 累计"
    echo ""
    echo "| 项 | 金额 |"
    echo "|---|---|"
    echo "| 总收入 | ¥${TOTAL_INCOME} |"
    echo "| 总支出 | ¥${TOTAL_EXPENSE} |"
    echo "| 目标（M5 Studio） | ¥${TARGET} |"
    echo ""
    if [ -n "$ENTRIES" ]; then
        echo "## 本周明细"
        echo ""
        echo "\`\`\`"
        echo "$ENTRIES"
        echo "\`\`\`"
        echo ""
    fi
    echo "## balance.md 快照"
    echo ""
    if [ -f "$LEDGER_DIR/balance.md" ]; then
        head -40 "$LEDGER_DIR/balance.md" | sed 's/^/> /'
    fi
    echo ""
} > "$OUT"

# 没有收入就不调 LLM，避免浪费
if [ "${WEEK_INCOME%.*}" = "0" ] || [ -z "$WEEK_INCOME" ]; then
    {
        echo ""
        echo "## 诊断"
        echo ""
        echo "- 本周无收入入账"
        echo "- 启动金距离投入已 $(( ( $(date +%s) - $(date -j -f "%Y-%m-%d" 2026-04-21 +%s) ) / 86400 )) 天"
        echo "- **动作**: Nova 应该 review 待审批提案，让启动金实际流动起来"
    } >> "$OUT"
    log "no_income skip_llm"
    exit 0
fi

# LLM 给 ROI 评估
if [ ! -f "$DS_SECRET" ]; then
    log "no_ds_secret skip_llm"
    exit 0
fi
# shellcheck disable=SC1090
. "$DS_SECRET"
DS_KEY="${DEEPSEEK_API_KEY:-}"
if [ -z "$DS_KEY" ]; then
    log "ds_key_empty"
    exit 0
fi

PROMPT="下面是 Nova 的 Lisa 项目本周变现数据。目标是 8 个月内攒 ¥200,000 买 M5 Mac Studio（即 ~¥6,250/周）。

本周收入: ¥${WEEK_INCOME}
本周支出: ¥${WEEK_EXPENSE}
本周净值: ¥${WEEK_NET}
累计收入: ¥${TOTAL_INCOME}

本周明细:
${ENTRIES}

请输出（直接 Markdown）：
## ROI 评估
<一句话：这周节奏健康吗？距离周目标差多少？>

## 支出效率
<支出里哪笔最值 / 哪笔最虚？>

## 下周建议
<3 条具体动作，每条一行>"

PAYLOAD=$(python3 -c "
import json, sys
p = sys.stdin.read()
print(json.dumps({
    'model':'deepseek-chat',
    'messages':[{'role':'user','content':p}],
    'temperature':0.3,
    'max_tokens':600
}))
" <<< "$PROMPT")

RESP=$(curl -s --max-time 60 -x "http://127.0.0.1:7897" \
    "https://api.deepseek.com/chat/completions" \
    -H "Authorization: Bearer $DS_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>> "$LOG") || {
    log "ds_failed"
    exit 0
}

CONTENT=$(echo "$RESP" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d['choices'][0]['message']['content'])
except: pass
" 2>> "$LOG")

if [ -n "$CONTENT" ]; then
    {
        echo ""
        echo "---"
        echo ""
        echo "$CONTENT"
    } >> "$OUT"
    log "ledger_review_done out=$OUT"
else
    log "ds_empty"
fi
