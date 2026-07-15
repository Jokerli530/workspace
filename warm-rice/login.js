/**
 * login.js — 美团/饿了么商家后台登录管理
 * 
 * 核心机制：
 * 1. 使用持久化浏览器 context（userDataDir）保存登录状态
 * 2. 第一次运行：启动有头浏览器，等待用户手动登录
 * 3. 之后运行：自动复用已保存的登录态
 */

const path = require('path');
const fs = require('fs');
const { chromium } = require('playwright');

const CONFIG_PATH = path.join(__dirname, 'config.json');
const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf-8'));

const USER_DATA_DIR = path.join(__dirname, 'data', 'browser-profile');
const SCREENSHOT_DIR = path.join(__dirname, config.paths.screenshotsDir);

/**
 * 确保登录态有效
 * 如果有保存的登录态，直接复用
 * 如果没有，启动有头浏览器让用户手动登录
 * 
 * @param {boolean} forceRelogin - 是否强制重新登录
 * @returns {Promise<object>} { browser, context, page }
 */
async function ensureLogin(forceRelogin = false) {
  // 确保目录存在
  fs.mkdirSync(USER_DATA_DIR, { recursive: true });
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });

  const context = await chromium.launchPersistentContext(USER_DATA_DIR, {
    headless: false,       // 有头模式，用户能看到浏览器
    channel: 'chromium',
    args: [
      '--disable-blink-features=AutomationControlled',
      '--no-sandbox',
      '--disable-web-security',
    ],
    viewport: { width: 1366, height: 900 },
    locale: 'zh-CN',
    timezoneId: 'Asia/Shanghai',
  });

  const page = await context.newPage();
  
  if (forceRelogin) {
    // 清除cookies强制重新登录
    await context.clearCookies();
  }

  // 导航到美团商家版
  console.log('🌐 正在打开美团商家中心...');
  await page.goto(config.platforms.meituan.loginUrl, { waitUntil: 'networkidle', timeout: 60000 });
  await page.waitForTimeout(2000);

  // 检查是否已登录（通过判断URL或页面元素）
  const currentUrl = page.url();
  const isLoggedIn = !currentUrl.includes('login') && !currentUrl.includes('passport');

  if (isLoggedIn) {
    console.log('✅ 已检测到登录态，直接使用');
    return { browser: context, context, page, isNewLogin: false };
  }

  console.log('🔑 需要登录 — 请在打开的浏览器中手动输入账号和验证码');
  console.log('📌 提示：登录完成后不要关浏览器，回到终端按 Enter 继续...');
  
  // 截屏保存当前登录页
  await page.screenshot({ path: path.join(SCREENSHOT_DIR, 'login-page.png') });

  return { browser: context, context, page, isNewLogin: true };
}

/**
 * 等待用户完成手动登录
 * 轮询检查页面URL是否已离开登录页
 */
async function waitForManualLogin(page, timeoutMinutes = 5) {
  const startTime = Date.now();
  const maxWait = timeoutMinutes * 60 * 1000;

  while (Date.now() - startTime < maxWait) {
    const currentUrl = page.url();
    // 如果URL不再包含login/passport，说明登录成功
    if (!currentUrl.includes('login') && !currentUrl.includes('passport') && !currentUrl.includes('auth')) {
      console.log(`✅ 登录成功！当前URL: ${currentUrl}`);
      await page.waitForTimeout(2000);
      return true;
    }
    await page.waitForTimeout(2000);
  }
  
  console.log('⏰ 等待登录超时');
  return false;
}

/**
 * 获取已登录的页面实例
 * 日常调用：尝试复用context，失败则提示重新登录
 */
async function getSession() {
  // 检查是否有已保存的浏览器profile
  const profileExists = fs.existsSync(path.join(USER_DATA_DIR, 'Default'));

  if (profileExists) {
    console.log('📂 发现已保存的登录profile，尝试复用...');
    try {
      const ctx = await chromium.launchPersistentContext(USER_DATA_DIR, {
        headless: true,   // 日常运行用无头模式
        args: ['--no-sandbox'],
        viewport: { width: 1366, height: 900 },
        locale: 'zh-CN',
        timezoneId: 'Asia/Shanghai',
      });
      const page = await ctx.newPage();
      await page.goto(config.platforms.meituan.homeUrl, { waitUntil: 'networkidle', timeout: 30000 });
      
      // 检查是否真的登录了
      const url = page.url();
      if (!url.includes('login') && !url.includes('passport')) {
        console.log('✅ 登录态有效');
        return { context: ctx, page, ok: true };
      }
      
      console.log('⚠️ 登录态已过期，需要重新登录');
      await ctx.close();
    } catch (err) {
      console.log('⚠️ context加载失败:', err.message);
    }
  }

  // 需要交互式登录
  const session = await ensureLogin(false);
  console.log('⏳ 请在浏览器中完成登录，然后按 Enter 继续...');
  
  // 这里需要返回并等待外部调用 waitForManualLogin
  return { 
    ...session, 
    ok: false,
    needsManualLogin: true 
  };
}

module.exports = {
  ensureLogin,
  waitForManualLogin,
  getSession,
  config,
  CONFIG_PATH,
};
