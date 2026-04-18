## Token Guard Pattern（断路器）

**触发条件**: 大量消耗 Token 的自动化任务，需要防超额

**规则**:
- 窗口 1500 次，>80% 警告，>95% 停止
- 周上限 15000 次
- 状态文件: `~/.openclaw/token-state.json`

**核心逻辑**:
```bash
~/.openclaw/workspace/skills/barbaric-growth/scripts/token-guard.sh check  # 执行前检查
~/.openclaw/workspace/skills/barbaric-growth/scripts/token-guard.sh increment N  # 执行后报告
```

**已知坑点**:
- 测试必须用临时文件，不能污染真实状态
- 脚本里的数学运算在 macOS date 特殊时要小心
- 窗口刷新时间要确认（GMT+8 5小时窗口）

**模板**: `skills/barbaric-growth/scripts/token-guard.sh`
