## LaunchAgent 后台监控 Pattern

**触发条件**: 需要持续监控某个事件（API状态、外部任务），但不想依赖 OpenClaw cron

**核心思路**:
```
LaunchAgent (launchctl) → 独立进程持续运行 → 写 alert 文件
    ↓
HEARTBEAT.md 定期检查 alert 文件 → 发现后通知
```

**标准流程**:
1. 写监控脚本 `~/.openclaw/[monitor-name]/[monitor-name].sh`
2. 创建 plist: `~/Library/LaunchAgents/ai.openclaw.[monitor-name].plist`
3. `launchctl load` 加载
4. 验证：`launchctl list | grep [monitor-name]`
5. alert 写入 `~/.openclaw/[monitor-name]/ALERT.txt`

**已知坑点**:
- MacOS SIP 可能阻止某些路径
- 代理在 exec 里不自动继承 → 脚本里要显式加 `-x http://127.0.0.1:7897`
- 日志只在发现问题才写，正常运行是沉默的

**模板**: `skills/barbaric-growth/scripts/evomap-monitor.sh`
