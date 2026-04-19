#!/bin/bash
# sync-state.sh - 同步 barbar-tracked.json 和 patterns/ 之间的状态
# 确保 capsule_id 和 research_status 保持一致

WORKSPACE="/Users/nova/.openclaw/workspace"
TRACKED="$WORKSPACE/barbaric-tracked.json"
PATTERNS="$WORKSPACE/patterns"

echo "🔄 同步 barbar-tracked.json 和 patterns/ ..."

# For each tracked repo, check pattern file for capsule_id
python3 << 'PYEOF'
import json
import os

TRACKED = "/Users/nova/.openclaw/workspace/barbaric-tracked.json"
PATTERNS = "/Users/nova/.openclaw/workspace/patterns"

with open(TRACKED) as f:
    d = json.load(f)

changed = False
for repo in d.get("tracked", []):
    name = repo.get("name", "")
    pattern_file = os.path.join(PATTERNS, name.replace("/", "_") + ".md")
    
    capsule_id = None
    if os.path.exists(pattern_file):
        with open(pattern_file) as f:
            for line in f:
                if line.startswith("capsule_id:"):
                    cid = line.split(":", 1)[1].strip()
                    if cid and cid != "待发布":
                        capsule_id = cid
                        break
    
    old_status = repo.get("research_status", "unknown")
    old_capsule = repo.get("capsule_id")
    
    if capsule_id:
        repo["capsule_id"] = capsule_id
        if repo.get("research_status") != "capsule_published":
            repo["research_status"] = "capsule_published"
            repo["updated"] = "2026-04-19"
    elif os.path.exists(pattern_file):
        if repo.get("research_status") != "pattern_done":
            repo["research_status"] = "pattern_done"
            repo["updated"] = "2026-04-19"
        if "capsule_id" not in repo or repo["capsule_id"] is None:
            repo["capsule_id"] = None
    
    if old_capsule != repo.get("capsule_id") or old_status != repo.get("research_status"):
        changed = True
        print(f"  📝 {name}: {old_status} → {repo.get('research_status')}")

with open(TRACKED, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)

if changed:
    print("✅ barbar-tracked.json 已更新")
else:
    print("ℹ️  没有变化，已经是最新状态")

# Summary
print("\n📊 当前状态:")
for repo in d.get("tracked", []):
    name = repo.get("name", "")
    status = repo.get("research_status", "?")
    capsule = repo.get("capsule_id", "none")
    capsule_short = capsule[:20] + "..." if capsule and len(capsule) > 20 else capsule
    print(f"  {'✅' if status == 'capsule_published' else '⏳'} {name}: {status} | {capsule_short}")
PYEOF
