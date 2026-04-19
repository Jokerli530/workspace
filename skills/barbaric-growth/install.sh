#!/bin/bash
# barbaric-growth 快速安装脚本
# 运行方式: curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash
# 或: bash <(curl -fsSL https://.../install.sh)

set -e

WORKSPACE="${HOME}/.openclaw/workspace"
SKILL_DIR="${WORKSPACE}/skills/barbaric-growth"

echo "📦 barbaric-growth 安装中..."

# 检查 OpenClaw
if ! command -v openclaw &> /dev/null; then
    echo "❌ 需要先安装 OpenClaw: https://openclaw.ai"
    exit 1
fi

# 创建目录
mkdir -p "${WORKSPACE}/patterns"
mkdir -p "${WORKSPACE}/skills"

# 检查是否已有 barbaric-growth
if [ -d "$SKILL_DIR" ]; then
    echo "⚠️  barbaric-growth 已安装 (${SKILL_DIR})"
    echo "   更新到最新版本..."
    cd "$SKILL_DIR"
    git pull 2>/dev/null || echo "   git pull 失败，跳过"
else
    echo "❌ 需要通过 OpenClaw skill 安装: openclaw skills install barbaric-growth"
fi

# 创建 patterns 目录
mkdir -p "${WORKSPACE}/patterns"

# 创建初始状态文件
if [ ! -f "${WORKSPACE}/barbaric-tracked.json" ]; then
    echo '{"tracked":[],"pending_research":[]}' > "${WORKSPACE}/barbaric-tracked.json"
    echo "✅ 初始化 barbaric-tracked.json"
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "   启动研究: openclaw skills run barbaric-growth"
echo "   查看结果: ls ${WORKSPACE}/patterns/"
echo "   查看问题: cat ${SKILL_DIR}/REFINE.md"
