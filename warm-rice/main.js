#!/usr/bin/env node

/**
 * main.js v5 — CDP 连接模式
 * 
 * 不再由 Playwright 启动浏览器，
 * 而是连接到用户自己打开的 Chrome（无自动化标记）
 * 
 * 用法:
 *   npm run chrome     # 第一步：打开 Chrome（带远程调试端口）
 *   npm run connect    # 第二步：登录美团后，连接抓取数据
 *   npm run auto       # 第三步：Chrome 保持打开，每天自动抓取
 *   npm run report     # 仅生成报告
 */

const path = require('path');
const fs = require('fs');
const { chromium } = require('playwright');

const scraper = require('./scraper');
const analyzer = require('./analyzer');
const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'config.json'), 'utf-8'));
const MEITUAN_URL = 'https://waimaie.meituan.com';

async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--chrome') || args.includes('chrome')) {
    return showChromeLaunchInstructions();
  }

  if (args.includes('--connect') || args.includes('connect')) {
    return connectToChrome();
  }

  if (args.includes('--help')) {
    console.log(`
🏪 温暖十里 外卖运营自动化 v5

用法（三步走）:

  第一步（只需一次）:
    npm run chrome
    → 会告诉你如何启动 Chrome

  第二步（登录美团，只需一次）:
    npm run connect
    → 等你在 Chrome 里登录完成后，抓取数据

  第三步（每天自动）:
    npm run auto
    → Chrome 保持打开，每晚自动抓取

注意: Chrome 要保持打开状态（最小化即可）`);
    return;
  }

  if (args.includes('--report')) {
    return generateReportOnly();
  }

  if (args.includes('--auto') || args.includes('auto')) {
    return autoMode();
  }

  // 默认显示帮助
  console.log('🏪 温暖十里 外卖运营自动化系统');
  console.log('用法: npm run <chrome|connect|auto|report|help>');
}

/**
 * 显示如何启动 Chrome
 */
function showChromeLaunchInstructions() {
  console.log('');
  console.log('  ╔══════════════════════════════════════╗');
  console.log('  ║  🏪 准备 Chrome 远程调试模式         ║');
  console.log('  ╚══════════════════════════════════════╝');
  console.log('');
  console.log('📌 请按以下步骤操作：');
  console.log('');
  console.log('  第一步：关闭所有 Chrome 窗口');
  console.log('');
  console.log('  第二步：在终端执行：');
  console.log('');
  console.log('    /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome \\');
  console.log('      --remote-debugging-port=9222 \\');
  console.log('      --user-data-dir=/tmp/chrome-warm-rice');
  console.log('');
  console.log('  第三步：Chrome 会打开，请手动访问：');
  console.log(`    ${MEITUAN_URL}`);
  console.log('    输入温暖十里的账号密码 + 短信验证码 登录');
  console.log('');
  console.log('  第四步：登录成功后，新开一个终端窗口，运行：');
  console.log('');
  console.log('    cd ~/.openclaw/workspace/warm-rice');
  console.log('    npm run connect');
  console.log('');
  console.log('⚠️  重要：启动 Chrome 的那个终端窗口不要关！');
  console.log('    Chrome 要保持打开（可以最小化到 Dock）');
  console.log('    之后每晚自动抓取时，Chrome 会自己工作');
}

/**
 * 连接到已打开的 Chrome 实例
 */
/**
 * 自动模式：尝试连接已打开的 Chrome，没有的话就自己启动
 */
async function autoMode() {
  console.log('🤖 自动模式...');
  
  // 先尝试连接已有的 Chrome
  const connected = await tryConnect(true);
  if (connected) return;
  
  // 连接失败，启动 Chrome
  console.log('🔄 Chrome 未运行，正在启动...');
  const launched = await launchChromeWithCDP();
  if (!launched) {
    console.log('❌ 无法启动 Chrome，请手动运行 npm run chrome 查看启动方法');
    return;
  }
  
  // 等 Chrome 启动完成
  console.log('⏳ 等待 Chrome 启动...');
  await new Promise(r => setTimeout(r, 5000));
  
  await tryConnect(true);
}

/**
 * 启动 Chrome 并开启 CDP 端口
 */
async function launchChromeWithCDP() {
  const chromePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  
  if (!fs.existsSync(chromePath)) {
    console.log('❌ 未找到系统 Chrome');
    return false;
  }
  
  const { spawn } = require('child_process');
  const userDataDir = path.join(__dirname, 'data', 'chrome-profile');
  fs.mkdirSync(userDataDir, { recursive: true });
  
  const proc = spawn(chromePath, [
    `--remote-debugging-port=9222`,
    `--user-data-dir=${userDataDir}`,
    '--no-first-run',
    '--no-default-browser-check',
  ], {
    stdio: 'ignore',
    detached: true,
  });
  
  proc.unref();
  
  // 保存 PID 以便将来关闭
  fs.writeFileSync(path.join(__dirname, 'data', 'chrome.pid'), String(proc.pid));
  
  console.log(`✅ Chrome 已启动 (PID: ${proc.pid})`);
  
  // 等待 CDP 端口就绪
  for (let i = 0; i < 30; i++) {
    try {
      const resp = await fetch('http://127.0.0.1:9222/json/version');
      if (resp.ok) {
        console.log('✅ CDP 端口已就绪');
        return true;
      }
    } catch (e) {}
    await new Promise(r => setTimeout(r, 1000));
  }
  
  console.log('⚠️ CDP 端口未能就绪');
  return false;
}

/**
 * 连接到已打开的 Chrome
 */
async function tryConnect(isAuto = false) {
  return connectToChrome(isAuto);
}

async function connectToChrome(isAuto = false) {
  console.log(isAuto ? '🤖 自动模式：正在连接 Chrome...' : '🔗 正在连接已打开的 Chrome...');
  
  let browser;
  try {
    // 通过 CDP 连接到本地 Chrome
    browser = await chromium.connectOverCDP('http://127.0.0.1:9222');
    console.log('✅ 已连接到 Chrome');
  } catch (err) {
    console.log('❌ 无法连接到 Chrome');
    console.log('   请确认 Chrome 已用远程调试模式启动：');
    console.log('   先运行 npm run chrome 查看启动方法');
    return;
  }

  // 查找已打开的 waimaie 页面
  const contexts = browser.contexts();
  let targetPage = null;

  for (const ctx of contexts) {
    const pages = ctx.pages();
    for (const page of pages) {
      const url = page.url();
      if (url.includes('waimaie.meituan.com')) {
        targetPage = page;
        console.log(`✅ 找到美团商家页面: ${url.slice(0, 60)}`);
        break;
      }
    }
    if (targetPage) break;
  }

  if (!targetPage) {
    // 没有美团页面，打开一个
    console.log('🌐 未找到美团页面，尝试打开...');
    const ctx = browser.contexts()[0] || await browser.newContext();
    targetPage = ctx.pages()[0] || await ctx.newPage();
    await targetPage.goto(MEITUAN_URL, { waitUntil: 'domcontentloaded' });
    console.log(`✅ 已打开 ${MEITUAN_URL}`);
    console.log('📌 请在 Chrome 中登录，然后重新运行: npm run connect');
    return;
  }

  // 检查是否已登录
  try {
    const text = await targetPage.evaluate(() => document.body?.innerText?.slice(0, 300) || '');
    const url = targetPage.url();

    if (url.includes('login') || url.includes('sso') || url.includes('auth') || text.includes('登录') && text.includes('密码')) {
      console.log('⚠️ 尚未登录，请在 Chrome 中完成登录后重新运行');
      return;
    }

    if (text.includes('退出') || text.includes('工作台') || text.includes('数据中心') || text.includes('经营概况')) {
      console.log('✅ 登录态有效！开始抓取数据...\n');
    } else {
      console.log('⚠️ 页面内容不明显，继续尝试抓取...');
    }

    // 抓取数据
    const data = await scraper.scrapeAll(targetPage);

    // 生成报告
    const report = analyzer.generateDailyReport(data);
    analyzer.saveReport(report);

    console.log(`\n✅ 完成！日报已保存: data/reports/日报-${report.date}.md`);

    if (report.suggestions.length > 0) {
      console.log('\n💡 运营建议:');
      report.suggestions.forEach(s => console.log(`  ${s}`));
    }

    if (!isAuto) {
      console.log('\n📌 Chrome 保留打开状态，之后每晚会自动抓取');
      console.log('   请保持 Chrome 在运行（最小化到 Dock 即可）');
    }

  } catch (err) {
    console.error('❌ 抓取出错:', err.message, '\n请确认已登录到美团商家页面');
  }
}

async function generateReportOnly() {
  const dailyDir = path.join(__dirname, config.paths.dailyDir);
  const files = fs.readdirSync(dailyDir).filter(f => f.endsWith('.json')).sort();
  if (files.length === 0) { console.log('❌ 没有历史数据'); return; }
  const latest = files[files.length - 1];
  const data = JSON.parse(fs.readFileSync(path.join(dailyDir, latest), 'utf-8'));
  const report = analyzer.generateDailyReport(data);
  analyzer.saveReport(report);
  console.log(`✅ 报告已生成，基于: ${latest}`);
  report.suggestions.forEach(s => console.log(`  ${s}`));
}

main().catch(err => console.error('💥 出错:', err.message));
