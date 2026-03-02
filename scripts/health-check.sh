#!/bin/bash
# System Health Check Script
# 运行方式: ./scripts/health-check.sh

set -e

echo "🔍 系统健康检查报告"
echo "=================="
echo "检查时间: $(date)"
echo ""

# 1. OpenClaw Gateway状态
echo "📡 OpenClaw Gateway 状态"
echo "------------------------"
if pgrep -f "openclaw.*gateway" > /dev/null; then
    echo "✅ Gateway 运行中"
else
    echo "❌ Gateway 未运行"
fi
echo ""

# 2. 磁盘空间
echo "💾 磁盘使用情况"
echo "---------------"
df -h /
echo ""

# 3. 内存使用
echo "🧠 内存使用情况"
echo "---------------"
free -h
echo ""

# 4. Cron任务状态
echo "⏰ Cron 任务列表"
echo "----------------"
openclaw cron list 2>/dev/null | head -20 || echo "无法获取cron列表"
echo ""

# 5. Git状态
echo "📁 Workspace Git状态"
echo "--------------------"
cd /root/.openclaw/workspace
git status --short || echo "干净"
echo ""

# 6. 会话文件大小
echo "📂 会话文件大小"
echo "--------------"
du -sh /root/.openclaw/agents/main/sessions/ 2>/dev/null || echo "目录不存在"
echo ""

echo "=================="
echo "检查完成"
