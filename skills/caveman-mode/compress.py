#!/usr/bin/env python3
"""Caveman compressor — strips filler, keeps substance. ~65% tokens saved."""

import re
import sys

FILLER = {
    "sure", "certainly", "of course", "happy to", "glad to",
    "i'd be happy", "i'm happy", "no problem", "you're welcome",
    "just", "really", "basically", "actually", "simply", "literally",
    "very", "quite", "rather", "somewhat", "a bit", "a little",
    "the issue is", "the problem is", "what happens is",
    "as i mentioned", "as i said", "as we discussed",
    "it is worth noting", "it is important to",
    "in order to", "in order for",
    "first of all", "to begin with",
    "i'm not sure", "i'm not certain", "it seems like",
}

def compress(text: str, level: str = "full") -> str:
    # Protect code blocks
    code_blocks = []
    def save_block(m):
        code_blocks.append(m.group(0))
        idx = len(code_blocks) - 1
        return f"__CB{idx}__"
    text = re.sub(r'```[\s\S]*?```', save_block, text)
    text = re.sub(r'(?<!`)`(?!`)([^`]+)`(?!`)', save_block, text)  # single ticks only
    
    # Lowercase and remove filler phrases
    t = text.lower()
    for phrase in sorted(FILLER, key=len, reverse=True):
        t = re.sub(r'\b' + re.escape(phrase) + r'\b', '', t, flags=re.IGNORECASE)
    
    if level in ("full", "ultra"):
        for art in [" a ", " an ", " the "]:
            t = t.replace(art, " ")
        for pron in [" i ", " you ", " your ", " we're ", " they're "]:
            t = t.replace(pron, " ")
    
    if level == "ultra":
        abbrevs = {
            "authentication": "auth", "authorization": "auth",
            "configuration": "conf", "application": "app",
            "database": "DB", "function": "fn", "variable": "var",
            "object": "obj", "implementation": "impl",
            "reference": "ref", "parameter": "param",
        }
        for word, abbr in abbrevs.items():
            t = re.sub(r'\b' + word + r'\b', abbr, t)
        t = re.sub(r'(\w+)\s+(?:causes?|leads? to|results? in|means?)\s+(\w+)', r'\1 -> \2', t)
    
    # Clean up artifacts: leading/bad punctuation
    t = re.sub(r'\s+', ' ', t).strip()
    t = re.sub(r"^[\s,!?'-]+", "", t)  # strip leading junk
    t = re.sub(r"[\s,!?'-]+$", "", t)  # strip trailing junk
    
    # Restore code blocks
    for i, block in enumerate(code_blocks):
        t = t.replace(f"__CB{i}__", block)
    
    return t

if __name__ == "__main__":
    level = sys.argv[1] if len(sys.argv) > 1 else "full"
    print(compress(sys.stdin.read(), level))
