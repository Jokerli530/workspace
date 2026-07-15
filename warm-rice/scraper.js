/**
 * scraper.js v2 — 美团外卖商家版 (waimaie.meituan.com) 数据抓取
 * 
 * 登录后跳转到商家后台主页，从主页/数据中心提取数据
 */

const path = require('path');
const fs = require('fs');

const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'config.json'), 'utf-8'));

const BASE_URL = 'https://waimaie.meituan.com';

/**
 * 经营概览抓取 — 从当前页面提取核心指标
 * 不导航到其他页面，直接从dashboard提取
 */
async function scrapeOverview(page) {
  console.log('📊 正在抓取经营概览...');
  const date = new Date().toISOString().slice(0, 10);

  const result = {
    date,
    timestamp: Date.now(),
    platform: 'meituan',
    shop: config.shop.name,
    metrics: {},
    raw: {},
  };

  try {
    // 确保在商家后台首页
    const currentUrl = page.url();
    if (!currentUrl.includes('waimaie.meituan.com')) {
      console.log(`  🔄 导航到主页: ${BASE_URL}`);
      await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
    }
    
    await page.waitForTimeout(3000);

    // 截屏 — 保存当前dashboard画面
    const screenshotPath = path.join(__dirname, config.paths.screenshotsDir, `overview-${date}.png`);
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.log(`  📸 截图已保存: ${screenshotPath}`);

    // 获取页面所有可见文本用于分析
    const bodyText = await page.evaluate(() => document.body?.innerText || '');
    result.raw.pageText = bodyText.substring(0, 10000);
    
    // 尝试从页面文本中解析数字指标
    result.metrics = extractMetrics(bodyText);

    // 保存页面HTML结构（前10000字符用于调试）
    const html = await page.content();
    result.raw.htmlSample = html.substring(0, 5000);

    // 尝试通过前端状态数据提取（SPA通常有内部状态）
    const stateData = await page.evaluate(() => {
      try {
        // 尝试常见的React/Vue状态挂载点
        const appState = document.getElementById('__NEXT_DATA__')?.textContent 
          || document.getElementById('__NUXT__')?.textContent
          || document.querySelector('#app')?.__vue_app__?.config?.globalProperties?.$store?.state
          || window.__STATE__ 
          || window.__INITIAL_STATE__;
        return appState ? JSON.stringify(appState).substring(0, 5000) : null;
      } catch(e) {
        return null;
      }
    });
    if (stateData) {
      result.raw.stateData = stateData;
    }

    console.log(`  ✅ 提取到 ${Object.keys(result.metrics).length} 个指标`);

  } catch (err) {
    console.error('  ❌ 经营概览抓取失败:', err.message);
    result.error = err.message;
  }

  return result;
}

/**
 * 从页面文本中提取关键业务指标
 */
function extractMetrics(text) {
  const metrics = {};
  if (!text) return metrics;

  // 常见的指标关键词（中文数字组合）
  const patterns = [
    // 营业额/交易额
    { keys: ['营业额', '交易额', '实收金额', '营收'], name: '营业额', unit: '元' },
    // 订单量
    { keys: ['订单数', '订单量', '总订单', '已完成订单'], name: '订单量', unit: '单' },
    // 曝光
    { keys: ['曝光人数', '曝光量', '曝光', '展现量'], name: '曝光量', unit: '人' },
    // 进店
    { keys: ['进店人数', '进店率', '进店转化', '入店'], name: '进店', unit: '' },
    // 下单
    { keys: ['下单人数', '下单率', '下单转化', '成交率'], name: '下单', unit: '' },
    // 客单价
    { keys: ['客单价', '人均价', '平均客单价'], name: '客单价', unit: '元' },
    // 评分
    { keys: ['评分', '店铺评分', '综合评分'], name: '评分', unit: '分' },
    // 好评
    { keys: ['好评数', '好评'], name: '好评数', unit: '个' },
    // 排名
    { keys: ['商圈排名', '排名'], name: '排名', unit: '名' },
  ];

  for (const pattern of patterns) {
    for (const key of pattern.keys) {
      // 尝试匹配 "关键词 数字" 或 "关键词:数字" 或 "关键词：数字"
      const regex = new RegExp(`${key}[：:]?\\s*([\\d.,]+)`, 'i');
      const match = text.match(regex);
      if (match) {
        const value = parseFloat(match[1].replace(/,/g, ''));
        if (!isNaN(value)) {
          metrics[pattern.name] = value;
          console.log(`  📈 ${pattern.name}: ${value}${pattern.unit}`);
          break;
        }
      }
    }
  }

  return metrics;
}

/**
 * 抓取评价数据
 */
async function scrapeReviews(page) {
  console.log('⭐ 正在抓取评价数据...');
  const date = new Date().toISOString().slice(0, 10);

  const result = {
    date,
    reviews: [],
    summary: {},
  };

  try {
    // 尝试导航到评价管理页（美团外卖商家版常见路径）
    const urls = [
      `${BASE_URL}/review`,
      `${BASE_URL}/comment`,
      `${BASE_URL}/evaluate`,
      `${BASE_URL}/evaluation`,
    ];

    let loaded = false;
    for (const url of urls) {
      try {
        await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 10000 });
        await page.waitForTimeout(2000);
        const currentUrl = page.url();
        // 如果没有被重定向到登录页，说明有效
        if (!currentUrl.includes('login') && !currentUrl.includes('sso')) {
          loaded = true;
          console.log(`  ✅ 评价页面: ${currentUrl}`);
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!loaded) {
      console.log('  ⚠️ 未找到评价管理页，停留在当前页面提取');
    }

    // 截屏
    await page.screenshot({ 
      path: path.join(__dirname, config.paths.screenshotsDir, `reviews-${date}.png`),
      fullPage: true 
    });

    // 提取评论文本
    const bodyText = await page.evaluate(() => document.body?.innerText || '');
    const reviewLines = bodyText.split('\n').filter(l => 
      l.includes('好评') || l.includes('中评') || l.includes('差评') ||
      l.includes('味道') || l.includes('配送') || l.includes('服务') ||
      l.includes('好吃') || l.includes('一般') || l.includes('慢') ||
      l.includes('赞') || l.includes('不错') || l.includes('差')
    );
    
    result.reviews = reviewLines.slice(0, 20).map(l => l.trim()).filter(l => l.length > 5);

    // 尝试提取评分
    const scoreMatch = bodyText.match(/(?:综合)?评分[：:]?\s*([\d.]+)/);
    if (scoreMatch) {
      result.summary.score = scoreMatch[1];
    }

  } catch (err) {
    console.error('  ❌ 评价抓取失败:', err.message);
    result.error = err.message;
  }

  return result;
}

/**
 * 抓取营销活动数据
 */
async function scrapeMarketing(page) {
  console.log('🎯 正在抓取营销活动数据...');
  const date = new Date().toISOString().slice(0, 10);

  const result = {
    date,
    activities: [],
    activePromotions: [],
  };

  try {
    // 导航回到首页（活动信息通常在首页dashboard）
    await page.goto(BASE_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.waitForTimeout(2000);

    const bodyText = await page.evaluate(() => document.body?.innerText || '');
    
    // 寻找活动/促销关键词
    const activityLines = bodyText.split('\n').filter(l =>
      l.includes('活动') || l.includes('满减') || l.includes('折扣') ||
      l.includes('优惠') || l.includes('推广') || l.includes('促销') ||
      l.includes('红包') || l.includes('减') || l.includes('券')
    );
    
    result.activities = activityLines.slice(0, 15).map(l => l.trim()).filter(l => l.length > 3);

    // 截屏
    await page.screenshot({ 
      path: path.join(__dirname, config.paths.screenshotsDir, `marketing-${date}.png`),
      fullPage: true 
    });

  } catch (err) {
    console.error('  ❌ 营销数据抓取失败:', err.message);
    result.error = err.message;
  }

  return result;
}

/**
 * 保存每日数据
 */
function saveDailyData(data) {
  const date = new Date().toISOString().slice(0, 10);
  const filePath = path.join(__dirname, config.paths.dailyDir, `${date}.json`);
  
  let existing = {};
  if (fs.existsSync(filePath)) {
    existing = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  }
  
  const merged = { ...existing, ...data };
  fs.writeFileSync(filePath, JSON.stringify(merged, null, 2), 'utf-8');
  console.log(`  💾 数据已保存: ${filePath}`);
  return filePath;
}

/**
 * 全量抓取
 */
async function scrapeAll(page) {
  console.log('');
  console.log('='.repeat(50));
  console.log(`🕐 开始全量抓取: ${new Date().toLocaleString('zh-CN')}`);
  console.log('='.repeat(50));
  console.log('');

  const overview = await scrapeOverview(page);
  const reviews = await scrapeReviews(page);
  const marketing = await scrapeMarketing(page);

  const fullData = { overview, reviews, marketing, scrapedAt: Date.now() };
  saveDailyData(fullData);

  console.log('');
  console.log('='.repeat(50));
  console.log('✅ 全量抓取完成');
  console.log('='.repeat(50));

  return fullData;
}

module.exports = {
  scrapeOverview,
  scrapeReviews,
  scrapeMarketing,
  scrapeAll,
  saveDailyData,
  extractMetrics,
};
