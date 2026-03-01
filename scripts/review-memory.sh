#!/bin/bash
# Weekly Memory Review Script
# 运行方式: ./scripts/review-memory.sh 或添加到crontab
# 建议: 每周日 22:00 运行

set -e

WORKSPACE="/root/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
ARCHIVE_DIR="$WORKSPACE/archive"
REPORT_FILE="$MEMORY_DIR/weekly-review-$(date +%Y-W%W).md"

echo "🧠 开始每周记忆回顾..."
echo "报告将保存至: $REPORT_FILE"

# 创建报告头
cat > "$REPORT_FILE" << EOF
# 每周记忆回顾报告

**生成时间**: $(date '+%Y-%m-%d %H:%M %Z')  
**回顾周期**: $(date -d '7 days ago' '+%Y-%m-%d') 至 $(date '+%Y-%m-%d')

## 📊 本周概览

### 每日日志统计
EOF

# 统计本周日志文件
WEEK_START=$(date -d '7 days ago' '+%Y-%m-%d')
LOG_COUNT=0
for i in {0..6}; do
    DATE=$(date -d "$WEEK_START + $i days" '+%Y-%m-%d')
    LOG_FILE="$MEMORY_DIR/$DATE.md"
    if [ -f "$LOG_FILE" ]; then
        LINES=$(wc -l < "$LOG_FILE")
        echo "- **$DATE**: $LINES 行" >> "$REPORT_FILE"
        ((LOG_COUNT++))
    fi
done

echo "" >> "$REPORT_FILE"
echo "**本周日志文件数**: $LOG_COUNT/7" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 提取重要事件
echo "## 🔍 重要事件提炼" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for i in {0..6}; do
    DATE=$(date -d "$WEEK_START + $i days" '+%Y-%m-%d')
    LOG_FILE="$MEMORY_DIR/$DATE.md"
    if [ -f "$LOG_FILE" ]; then
        # 提取标题和关键内容
        echo "### $DATE" >> "$REPORT_FILE"
        grep -E "^(#{2,3}|\*\*重要|\*\*事件|\- \[x\]|\- \[ \])" "$LOG_FILE" 2>/dev/null | head -20 >> "$REPORT_FILE" || echo "- 无结构化记录" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
done

# 系统状态检查
echo "## ⚙️ 系统状态" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 磁盘使用" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
df -h / >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Git状态
echo "### Git提交统计" >> "$REPORT_FILE"
cd "$WORKSPACE"
COMMIT_COUNT=$(git log --oneline --since="7 days ago" | wc -l)
echo "**本周提交数**: $COMMIT_COUNT" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**最近提交**:" >> "$REPORT_FILE"
git log --oneline -5 --since="7 days ago" >> "$REPORT_FILE" 2>/dev/null || echo "- 无新提交" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 待办事项汇总
echo "## ✅ 待办事项汇总" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 来自本周日志" >> "$REPORT_FILE"
grep -h "^- \[ \]" "$MEMORY_DIR"/2026-*.md 2>/dev/null | sort -u | head -10 >> "$REPORT_FILE" || echo "- 无待办事项" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# MEMORY.md 更新建议
echo "## 📝 MEMORY.md 更新建议" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "检查以下信息是否需要更新到 MEMORY.md:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- [ ] 新的用户偏好或习惯" >> "$REPORT_FILE"
echo "- [ ] 重要的系统配置变更" >> "$REPORT_FILE"
echo "- [ ] 新安装的软件/技能" >> "$REPORT_FILE"
echo "- [ ] 定期任务的执行情况" >> "$REPORT_FILE"
echo "- [ ] 已完成的待办事项归档" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 归档建议
echo "## 📦 归档建议" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
OLD_LOGS=$(find "$MEMORY_DIR" -name "*.md" -type f -mtime +30 | wc -l)
if [ "$OLD_LOGS" -gt 0 ]; then
    echo "⚠️ 发现 $OLD_LOGS 个超过30天的日志文件，建议归档到 $ARCHIVE_DIR/" >> "$REPORT_FILE"
else
    echo "✅ 暂无需要归档的旧日志文件" >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

echo "---" >> "$REPORT_FILE"
echo "*报告生成完成*" >> "$REPORT_FILE"

echo "✅ 每周回顾报告已生成: $REPORT_FILE"
echo ""
echo "💡 建议操作:"
echo "1. 查看报告内容: cat $REPORT_FILE"
echo "2. 根据建议更新 MEMORY.md"
echo "3. 处理或归档旧日志文件"
