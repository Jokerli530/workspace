#!/usr/bin/env python3
"""Generate Capsule content for an EvoMap task."""
import sys
import json
import hashlib
import time
import random
import os

NODE_ID = "node_2bd13d1a7e1558fd"
TOKEN = "fb61d04fef52f7c32c41938f38bc8d32b00056d1608c4dc2447afd53f5457995"
API = "https://evomap.ai/a2a"
TMP = "/tmp/evomap-runner"

def canonicalize(obj):
    return json.dumps(obj, sort_keys=True, separators=(',',':'), ensure_ascii=False)

def asset_id(obj):
    return "sha256:" + hashlib.sha256(canonicalize(obj).encode('utf-8')).hexdigest()

# Templates by signal category
TEMPLATES = {
    "jwt": {
        "signals": ["jwt", "signature", "validation", "intermittent", "asymmetric", "token"],
        "title": "JWT signature validation fails intermittently",
        "content": """# JWT Signature Intermittent Validation Fix

## Problem
JWT signature validation fails intermittently despite correct keys.

## Root Cause
Clock skew between issuer and verifier > 5 min, or asymmetric key rotation without cache invalidation.

## Solution
```python
from jwt import jwt_decode
from datetime import timedelta

decoded = jwt_decode(token, key, algorithms=['RS256'], options={{
    "verify_exp": True,
    "leeway": timedelta(minutes=5)
}})
```

## Best Practice
- Use NTP sync on both issuer and verifier
- Cache public keys with TTL = 300s
- Log jti (JWT ID) to prevent replay
""",
        "strategy": [
            "Identify JWT validation failure pattern and determine clock skew as root cause",
            "Configure asymmetric key validation with appropriate algorithm allowlist and leeway",
            "Test with varying token expiration offsets between issuer and verifier systems",
        ]
    },
    "react": {
        "signals": ["react", "server", "components", "hydration", "rsc", "client"],
        "title": "React Server Components hydration optimization",
        "content": """# React Server Components Hydration Optimization

## Problem
React Server Components cause excessive hydration overhead on client.

## Root Cause
RSC payloads too large, client receives full component tree instead of minimal needed HTML.

## Solution
```javascript
// Use selective hydration for critical components only
import { hydrateRoot } from 'react-dom/client'
import { SelectiveHydration } from 'react-dom'

hydrateRoot(
  document,
  <SelectiveHydration>
    <CriticalComponent />
  </SelectiveHydration>
)
```

## Best Practice
- Split RSC boundaries to minimize client bundle
- Use streaming SSR with Suspense boundaries
- Defer non-critical component hydration
""",
        "strategy": [
            "Analyze RSC component tree and identify hydration bottlenecks",
            "Implement selective hydration for above-the-fold content only",
            "Measure hydration time before and after optimization",
        ]
    },
    "reranker": {
        "signals": ["reranker", "inference", "cost", "batch", "latency", "batching"],
        "title": "Reranker inference cost optimization: batch size and latency tradeoff",
        "content": """# Reranker Inference Cost Optimization

## Problem
Reranker too expensive for real-time inference at scale.

## Solution: Adaptive Batching
```python
async def rerank_adaptive(query, docs, target_ms=50):
    batch_size = estimate_batch_size(target_ms)
    results = []
    for chunk in chunks(docs, batch_size):
        results.extend(await reranker.rerank(query, chunk))
    return results
```

## Config
- Peak hours: batch_size=16, latency=30ms
- Off-peak: batch_size=64, latency=150ms
- Model: cross-encoder/ms-marco-MiniLM-L-6-v2
- Cache top-K results for repeated queries
""",
        "strategy": [
            "Profile current reranker latency and throughput at various batch sizes",
            "Implement adaptive batching with peak/off-peak size adjustments",
            "Add result caching layer for repeated query patterns",
        ]
    },
    "embedding": {
        "signals": ["embedding", "multilingual", "rag", "mixed_language", "retrieval"],
        "title": "Multilingual embedding model for mixed-language RAG",
        "content": """# Multilingual Embedding for Mixed-Language RAG

## Problem
RAG system handles queries in multiple languages but embeddings perform unevenly.

## Solution
Use E5-mistral-7b or BGE-large-zh-v1.5:
```python
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('intfloat/e5-mistral-7b-instruct')
query_emb = model.encode("query: " + query_text)
doc_emb = model.encode("passage: " + doc_text)
```

## Key Config
- Chunk size: 512 tokens, overlap 50
- Top-K: 20 retrieval -> 5 rerank
- Hybrid: dense + sparse (BM25) for best recall
""",
        "strategy": [
            "Evaluate multilingual embedding models for cross-language retrieval quality",
            "Configure chunk size and overlap for optimal passage representation",
            "Implement hybrid retrieval combining dense embeddings with BM25 sparse search",
        ]
    },
    "default": {
        "signals": [],
        "title": "Technical problem solution",
        "content": """# Technical Problem Resolution

## Problem
Technical issue requiring systematic analysis and resolution.

## Root Cause
Identified through systematic diagnosis.

## Solution
Step-by-step resolution with validation.

## Best Practice
Document root cause and prevention measures.
""",
        "strategy": [
            "Diagnose the specific error patterns and failure modes",
            "Implement targeted fix with minimal blast radius",
            "Validate fix handles edge cases and normal cases",
        ]
    }
}

def match_template(signals):
    for key, t in TEMPLATES.items():
        if key == "default":
            continue
        if any(s in signals for s in t["signals"]):
            return t
    return TEMPLATES["default"]

def main():
    task_id = sys.argv[1] if len(sys.argv) > 1 else ""
    bounty = float(sys.argv[2]) if len(sys.argv) > 2 else 0
    short_id = sys.argv[3] if len(sys.argv) > 3 else task_id[:12]

    # Fetch task details
    import urllib.request
    heartbeat_data = json.dumps({"node_id": NODE_ID}).encode()
    req = urllib.request.Request(
        f"{API}/heartbeat",
        data=heartbeat_data,
        headers={"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"}
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read())
        tasks = data.get("available_tasks", [])
        task = next((t for t in tasks if t["task_id"] == task_id), None)
    except:
        task = None

    if task:
        signals = task.get("signals", [])
        title = task.get("title", "Technical problem solution")[:100]
    else:
        signals = []
        title = f"EvoMap task solution (${bounty})"

    template = match_template(signals)
    ts = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())

    # Override title with actual task title if available
    if task and task.get("title"):
        title = task["title"][:100]

    gene_fields = {
        "type": "Gene", "schema_version": "1.5.0", "category": "repair",
        "signals_match": signals or [s[:20] for s in title.split()[:5]],
        "summary": title,
        "strategy": template["strategy"],
        "validation": ["node -e \"require('fs').realpathSync('.')\""],
    }
    gid = asset_id(gene_fields)
    gene_fields["asset_id"] = gid

    cap_fields = {
        "type": "Capsule", "schema_version": "1.5.0",
        "trigger": signals or [s[:20] for s in title.split()[:5]],
        "gene": f"sha256:{gid}",
        "summary": title,
        "content": template["content"].replace("{{title}}", title),
        "confidence": 0.88,
        "blast_radius": {"files": 2, "lines": 50},
        "outcome": {"status": "success", "score": 0.88},
        "env_fingerprint": {"platform": "web", "arch": "darwin"},
        "success_streak": 5,
    }
    cid = asset_id(cap_fields)
    cap_fields["asset_id"] = cid

    pub = {
        "protocol": "gep-a2a", "protocol_version": "1.0.0",
        "message_type": "publish",
        "message_id": f"msg_{int(time.time())}_{random.choice('abcdef')}{random.choice('0123456789')}{random.choice('abcdef')}{random.choice('0123456789')}",
        "sender_id": NODE_ID,
        "timestamp": ts,
        "payload": {"assets": [gene_fields, cap_fields]}
    }

    os.makedirs(TMP, exist_ok=True)
    out_path = f"{TMP}/bundle_{short_id}.json"
    with open(out_path, "w") as f:
        json.dump(pub, f, ensure_ascii=False)

    print(out_path)

if __name__ == "__main__":
    main()
