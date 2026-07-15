/**
 * analyzer.js — 外卖数据分析与报告生成
 * 
 * 从抓取的数据中提取关键指标，生成日报/周报
 * 以及运营建议
 */

const path = require('path');
const fs = require('fs');
const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'config.json'), 'utf-8'));

/**
 * 生成日报
 */
function generateDailyReport(rawData) {
  const date = new Date().toISOString().slice(0, 10);
  const metrics = rawData.overview?.metrics || {};

  // 尝试解析关键指标
  const report = {
    date,
    shop: config.shop.name,
    platform: '美团',
    metrics: parseMetrics(metrics, rawData),
    reviews: extractReviewInsights(rawData.reviews),
    suggestions: [],
    score: calculateHealthScore(metrics),
  };

  // 生成诊断建议
  report.suggestions = generateSuggestions(report.metrics, report.reviews);

  return report;
}

/**
 * 尝试从抓取数据中解析标准指标
 */
function parseMetrics(metrics, rawData) {
  const result = {
    曝光量: null,
    进店率: null,
    下单率: null,
    营业额: null,
    订单量: null,
    客单价: null,
    好评数: null,
    差评数: null,
  };

  // 尝试从 key-value 匹配
  const keyMap = {
    '曝光': '曝光量',
    '曝光人数': '曝光量',
    '展现': '曝光量',
    '进店': '进店率',
    '进店转化': '进店率',
    '入店': '进店率',
    '下单': '下单率',
    '下单转化': '下单率',
    '成交': '下单率',
    '营业额': '营业额',
    '交易额': '营业额',
    '实收': '营业额',
    '订单': '订单量',
    '订单数': '订单量',
    '单量': '订单量',
    '客单': '客单价',
    '人均': '客单价',
    '好评': '好评数',
    '差评': '差评数',
    '评分': '评分',
  };

  for (const [key, value] of Object.entries(metrics)) {
    for (const [keyword, standardKey] of Object.entries(keyMap)) {
      if (key.includes(keyword)) {
        const numValue = parseFloat(value.replace(/[^0-9.]/g, ''));
        if (!isNaN(numValue)) {
          result[standardKey] = numValue;
        }
        break;
      }
    }
  }

  return result;
}

/**
 * 提取评价洞察
 */
function extractReviewInsights(reviewsData) {
  if (!reviewsData || !reviewsData.reviews) return { count: 0, recentComments: [] };

  return {
    count: reviewsData.reviews.length,
    summary: reviewsData.summary || {},
    recentComments: reviewsData.reviews.slice(0, 10),
  };
}

/**
 * 计算健康分 (0-100)
 */
function calculateHealthScore(metrics) {
  let score = 70; // 基础分
  
  // 根据数据调整（占位逻辑，后续根据实际数据优化）
  // 这里需要在有真实数据后调整权重
  
  return Math.min(100, Math.max(0, score));
}

/**
 * 根据数据生成运营建议
 */
function generateSuggestions(metrics, reviews) {
  const suggestions = [];
  const m = metrics;

  if (m.曝光量 === null && m.订单量 === null) {
    suggestions.push('📊 首次数据采集完成，连续采集3天后可给出精准分析');
    return suggestions;
  }

  if (m.曝光量 !== null && m.曝光量 < 500) {
    suggestions.push('🔺 曝光量偏低，建议增加点金推广投入，优化门店头图/标题');
  }

  if (m.进店率 !== null && m.进店率 < 0.08) {
    suggestions.push('🔺 进店率偏低（<8%），建议优化门店头图、评分展示、配送费设置');
  }

  if (m.下单率 !== null && m.下单率 < 0.25) {
    suggestions.push('🔺 下单率偏低（<25%），建议优化菜单结构、活动力度、起送价');
  }

  if (m.客单价 !== null && m.客单价 < 18) {
    suggestions.push('🔺 客单价偏低，建议设置凑单提醒、增加小食/饮品搭配');
  }

  if (reviews && reviews.recentComments) {
    const negativeComments = reviews.recentComments.filter(c => 
      c.includes('差') || c.includes('慢') || c.includes('少') || c.includes('淡') || c.includes('贵')
    );
    if (negativeComments.length > 0) {
      suggestions.push(`⚠️ 最近有${negativeComments.length}条负面评价，建议主动回复并针对性改进`);
    }
  }

  // 如果有历史数据，可以对比趋势
  return suggestions;
}

/**
 * 保存日报到文件
 */
function saveReport(report) {
  const date = report.date;
  const filePath = path.join(__dirname, config.paths.reportsDir, `日报-${date}.md`);
  
  const content = generateReportMarkdown(report);
  fs.writeFileSync(filePath, content, 'utf-8');
  
  console.log(`📝 日报已生成: ${filePath}`);
  return filePath;
}

/**
 * 生成Markdown格式的日报
 */
function generateReportMarkdown(report) {
  const m = report.metrics;
  const date = report.date;

  let md = `# 📊 温暖十里（恒昌一期店）外卖日报\n\n`;
  md += `**日期**: ${date}\n`;
  md += `**平台**: ${report.platform}\n\n`;

  md += `---\n\n`;

  md += `## 📈 核心指标\n\n`;
  md += `| 指标 | 数值 |\n`;
  md += `|------|------|\n`;
  md += `| 曝光量 | ${m.曝光量 ?? '—'} |\n`;
  md += `| 进店率 | ${m.进店率 ? (m.进店率 * 100).toFixed(1) + '%' : '—'} |\n`;
  md += `| 下单率 | ${m.下单率 ? (m.下单率 * 100).toFixed(1) + '%' : '—'} |\n`;
  md += `| 订单量 | ${m.订单量 ?? '—'} |\n`;
  md += `| 营业额 | ${m.营业额 ? '¥' + m.营业额 : '—'} |\n`;
  md += `| 客单价 | ${m.客单价 ? '¥' + m.客单价 : '—'} |\n`;
  md += `| 健康分 | ${report.score}/100 |\n\n`;

  md += `---\n\n`;

  if (report.reviews && report.reviews.recentComments.length > 0) {
    md += `## ⭐ 最新评价\n\n`;
    report.reviews.recentComments.forEach((c, i) => {
      md += `${i + 1}. ${c.substring(0, 200)}\n\n`;
    });
  }

  md += `## 💡 运营建议\n\n`;
  if (report.suggestions.length === 0) {
    md += `数据不足，暂无可信建议。连续采集3天后开始输出分析。\n`;
  } else {
    report.suggestions.forEach(s => {
      md += `- ${s}\n`;
    });
  }

  md += `\n---\n\n`;
  md += `*🤖 由 Nova 自动生成 · ${new Date().toLocaleString('zh-CN')}*\n`;

  return md;
}

module.exports = {
  generateDailyReport,
  saveReport,
  generateReportMarkdown,
};
