#!/bin/bash
# llm-extract.sh v1.0 - 从 GitHub repo 真实内容提炼 pattern（v1.3 P1）
# 用 DeepSeek 对 README 做结构化分析，产出 "## 深度分析" 段
#
# Usage: llm-extract.sh <repo> <stars> <lang> <desc> <pattern_file>
# Exit: 0=success (appended), 1=failure (caller should fallback to static template)

set -uo pipefail

REPO="${1:-}"
STARS="${2:-0}"
LANG="${3:-Unknown}"
DESC="${4:-}"
PATTERN_FILE="${5:-}"

[ -z "$REPO" ] || [ -z "$PATTERN_FILE" ] && { echo "usage: llm-extract.sh <repo> <stars> <lang> <desc> <pattern_file>" >&2; exit 1; }

WORKSPACE="/Users/nova/.openclaw/workspace"
PATTERNS="$WORKSPACE/patterns"
SECRETS="$HOME/.openclaw/secrets"
PROXY="-x http://127.0.0.1:7897"

# Load DeepSeek creds (required)
if [ ! -f "$SECRETS/deepseek.env" ]; then
    echo "no deepseek.env, skip LLM" >&2
    exit 1
fi
# shellcheck disable=SC1091
. "$SECRETS/deepseek.env"
: "${DEEPSEEK_API_KEY:?missing}"
: "${DEEPSEEK_BASE_URL:=https://api.deepseek.com}"

# Load GitHub PAT if present (optional, raises rate limit)
GH_AUTH=()
if [ -f "$SECRETS/github.env" ]; then
    # shellcheck disable=SC1091
    . "$SECRETS/github.env"
    [ -n "${GITHUB_TOKEN:-}" ] && GH_AUTH=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

# 1. Fetch README (6KB cap)
fetch_readme() {
    local url="https://api.github.com/repos/$REPO/readme"
    local raw
    if [ ${#GH_AUTH[@]} -gt 0 ]; then
        raw=$(curl -s --max-time 20 $PROXY -H "Accept: application/vnd.github.v3+json" "${GH_AUTH[@]}" "$url" 2>/dev/null)
    else
        raw=$(curl -s --max-time 20 $PROXY -H "Accept: application/vnd.github.v3+json" "$url" 2>/dev/null)
    fi
    [ -z "$raw" ] && return 1
    # decode base64 content; cap at 6000 chars
    echo "$raw" | python3 -c "
import sys, json, base64
try:
    d = json.load(sys.stdin)
    c = d.get('content', '')
    if not c: sys.exit(1)
    txt = base64.b64decode(c).decode('utf-8', errors='ignore')
    sys.stdout.write(txt[:6000])
except Exception: sys.exit(1)
" 2>/dev/null
}

# 2a. Find related patterns (same-language, top 3) as prior context
find_related_context() {
    local me="${PATTERN_FILE##*/}"
    local related=""
    local count=0
    for f in "$PATTERNS"/*.md; do
        [ -f "$f" ] || continue
        [ "${f##*/}" = "$me" ] && continue
        if grep -q "^- language: $LANG$" "$f" 2>/dev/null; then
            local summary
            summary=$(awk '/^## 核心定位/{flag=1; next} /^## /{flag=0} flag{print}' "$f" 2>/dev/null | head -2 | tr '\n' ' ')
            local other_repo
            other_repo=$(basename "$f" .md | sed 's/_/\//g')
            [ -n "$summary" ] && related="${related}- ${other_repo}: ${summary}\n"
            count=$((count + 1))
            [ "$count" -ge 3 ] && break
        fi
    done
    printf "%b" "$related"
}

# 2b. Fetch same-author sibling repos (top 5 by stars, cross-language) — P2
fetch_author_siblings() {
    local owner="${REPO%%/*}"
    local me_name="${REPO##*/}"
    local url="https://api.github.com/users/${owner}/repos?sort=updated&per_page=20"
    local raw
    if [ ${#GH_AUTH[@]} -gt 0 ]; then
        raw=$(curl -s --max-time 15 $PROXY -H "Accept: application/vnd.github.v3+json" "${GH_AUTH[@]}" "$url" 2>/dev/null)
    else
        raw=$(curl -s --max-time 15 $PROXY -H "Accept: application/vnd.github.v3+json" "$url" 2>/dev/null)
    fi
    [ -z "$raw" ] && return
    echo "$raw" | python3 -c "
import sys, json
try:
    arr = json.load(sys.stdin)
    if not isinstance(arr, list): sys.exit(0)
    me = '$me_name'
    others = [r for r in arr if r.get('name') != me and not r.get('fork')]
    others.sort(key=lambda r: r.get('stargazers_count', 0), reverse=True)
    for r in others[:5]:
        lang = r.get('language') or '—'
        stars = r.get('stargazers_count', 0)
        desc = (r.get('description') or '')[:80]
        print(f'- {r[\"full_name\"]} ({stars}★, {lang}): {desc}')
except Exception: sys.exit(0)
" 2>/dev/null
}

README=$(fetch_readme) || README=""
if [ -z "$README" ]; then
    echo "readme fetch failed for $REPO" >&2
    exit 1
fi

RELATED=$(find_related_context)
[ -z "$RELATED" ] && RELATED="（无同语言已研究项目）"

AUTHOR_SIBLINGS=$(fetch_author_siblings)
[ -z "$AUTHOR_SIBLINGS" ] && AUTHOR_SIBLINGS="（未发现作者其他项目）"

# 3. Build prompt + call DeepSeek (OpenAI-compatible)
SYSTEM='你是开源项目快速分析师，专为 Nova 的 agent 研究服务。从 README 提炼结构化要素，精准、避免废话。输出纯 Markdown，不加代码块围栏。'

USER_PROMPT=$(python3 -c "
import sys, json
repo = '''$REPO'''
stars = '''$STARS'''
lang = '''$LANG'''
desc = '''$DESC'''
related = '''$RELATED'''
author_siblings = '''$AUTHOR_SIBLINGS'''
readme = sys.stdin.read()
prompt = f'''分析以下 GitHub 项目，按下面 5 段输出 Markdown（标题固定为 ## 级）：

## 核心定位
一句话说清楚它到底是什么、解决什么问题。

## 技术栈
关键依赖、框架、运行时（列表）。

## 独特机制
这个项目和常见同类相比，独特在哪？（2-4 条具体机制，不要泛泛）。如果该作者还有其他相关项目，点出本项目在其作者生态里的定位。

## 与 OpenClaw 集成可能
如果要把它接进 OpenClaw 生态，最顺的切入点是什么？不可行就直说。

## 值得深入的点
对 Nova 的 agent 研究最有启发的 2-3 个技术细节。

---
Repo: {repo} ({stars} stars, {lang})
Description: {desc}

已研究的同语言相关项目（供对比参考）：
{related}

该作者的其他项目（跨语言也算，供定位参考）：
{author_siblings}

README（前 6KB）:
{readme}'''
print(prompt)
" <<< "$README")

PAYLOAD=$(jq -n \
    --arg sys "$SYSTEM" \
    --arg usr "$USER_PROMPT" \
    '{model:"deepseek-chat", messages:[{role:"system",content:$sys},{role:"user",content:$usr}], temperature:0.3, max_tokens:800}')

RESPONSE=$(curl -s --max-time 60 \
    "$DEEPSEEK_BASE_URL/chat/completions" \
    -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>/dev/null)

[ -z "$RESPONSE" ] && { echo "deepseek empty response for $REPO" >&2; exit 1; }

CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' 2>/dev/null)

if [ -z "$CONTENT" ] || [ "$CONTENT" = "null" ]; then
    echo "deepseek parse failed for $REPO: $(echo "$RESPONSE" | head -c 300)" >&2
    exit 1
fi

# 4. Append to pattern file
{
    echo ""
    echo "## 深度分析（LLM 提炼）"
    echo ""
    echo "$CONTENT"
    echo ""
    echo "_extracted_by: deepseek-chat · $(date +%Y-%m-%d' '%H:%M)_"
} >> "$PATTERN_FILE"

# Mark metadata for downstream reuse
if ! grep -q "^- content_source: llm$" "$PATTERN_FILE" 2>/dev/null; then
    # Insert under "## 元信息" block, before next ##
    python3 -c "
import re
p = '$PATTERN_FILE'
with open(p) as f: s = f.read()
s2 = re.sub(r'(## 元信息\n(?:- [^\n]*\n)+)', r'\1- content_source: llm\n', s, count=1)
with open(p, 'w') as f: f.write(s2)
"
fi

exit 0
