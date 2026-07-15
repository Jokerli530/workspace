#!/bin/bash
# 温暖十里 自动运行脚本
cd "$(dirname "$0")"
/opt/homebrew/bin/node main.js --auto 2>&1 >> "data/logs/$(date +%Y-%m-%d).log"
