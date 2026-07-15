# 🏪 温暖十里 · 外卖运营自动化系统 v5

## 原理

不再用 Playwright 控制浏览器（美团会检测到自动化特征）。

改为**连接你手动打开的 Chrome** — 美团只看到普通用户在用，不会踢你。

## 三步走

### ⚡ 第一步：启动 Chrome（只需一次）

```bash
cd ~/.openclaw/workspace/warm-rice
npm run chrome
```

会显示启动命令，复制到终端执行即可。

### ⚡ 第二步：登录美团（只需一次）

```bash
npm run connect
```

等你在 Chrome 里登录完成后，脚本自动抓数据、出报告。

### ⚡ 第三步：每天自动抓取

Chrome 保持打开（最小化到 Dock 即可），每天 22:00 自动运行。

## 文件说明

```
warm-rice/
├── main.js          主程序（CDP连接模式）
├── scraper.js       数据抓取
├── analyzer.js      分析+报告
├── config.json      配置
├── data/
│   ├── daily/       每日原始数据
│   ├── reports/     每日分析报告
│   └── screenshots/ 页面截图
└── package.json     
```
