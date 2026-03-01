#!/bin/bash
# ============================================
# 动漫收藏数据导出工具
# anime-export.sh
# ============================================

# 配置
MARKDOWN_FILE="${1:-90s-anime-collection-checklist.md}"
OUTPUT_DIR="./exports"
DATE=$(date +%Y%m%d)

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

mkdir -p "$OUTPUT_DIR"

show_help() {
    echo -e "${BLUE}动漫收藏数据导出工具${NC}"
    echo ""
    echo "用法: $0 [格式] [输入文件]"
    echo ""
    echo "导出格式:"
    echo "  csv       导出为CSV表格（适合Excel分析）"
    echo "  json      导出为JSON（适合开发者）"
    echo "  html      导出为HTML网页（适合浏览器查看）"
    echo "  txt       导出为纯文本列表"
    echo "  markdown  导出纯净版Markdown"
    echo "  notion    导出为Notion导入格式"
    echo ""
    echo "示例:"
    echo "  $0 csv                          # 导出为CSV"
    echo "  $0 html my-checklist.md         # 导出指定文件为HTML"
}

# 导出为CSV
export_csv() {
    local output="$OUTPUT_DIR/anime_collection_$DATE.csv"
    
    echo -e "${BLUE}📊 正在导出为CSV格式...${NC}"
    
    # CSV 表头
    echo "看过,作品名称,年份,地区,类型,简介,经典度" > "$output"
    
    # 解析日本动画
    awk '/## 一、日本动画篇/{flag=1; next} /## 二、/{flag=0} flag && /^\| \[[ x]\]/' "$MARKDOWN_FILE" | \
    while IFS='|' read -r check name year desc rating; do
        local watched=$(echo "$check" | grep -q 'x' && echo "是" || echo "否")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs)
        echo "\"$watched\",\"$name_clean\",\"$year_clean\",\"日本\",\"\",\"\",\"$rating_clean\"" >> "$output"
    done
    
    # 解析国产动画
    awk '/## 二、国产动画篇/{flag=1; next} /## 三、/{flag=0} flag && /^\| \[[ x]\]/' "$MARKDOWN_FILE" | \
    while IFS='|' read -r check name year desc rating; do
        local watched=$(echo "$check" | grep -q 'x' && echo "是" || echo "否")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs)
        echo "\"$watched\",\"$name_clean\",\"$year_clean\",\"国产\",\"\",\"\",\"$rating_clean\"" >> "$output"
    done
    
    # 解析欧美动画
    awk '/## 三、欧美动画篇/{flag=1; next} /^---/{flag=0} flag && /^\| \[[ x]\]/' "$MARKDOWN_FILE" | \
    while IFS='|' read -r check name year desc rating; do
        local watched=$(echo "$check" | grep -q 'x' && echo "是" || echo "否")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs)
        echo "\"$watched\",\"$name_clean\",\"$year_clean\",\"欧美\",\"\",\"\",\"$rating_clean\"" >> "$output"
    done
    
    echo -e "${GREEN}✅ CSV导出完成: $output${NC}"
}

# 导出为HTML
export_html() {
    local output="$OUTPUT_DIR/anime_collection_$DATE.html"
    
    echo -e "${BLUE}🌐 正在导出为HTML格式...${NC}"
    
    cat << 'EOF' > "$output"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>90后经典动漫收藏 - 我的观看记录</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #ff6b6b 0%, #feca57 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }
        .header p {
            font-size: 1.2em;
            opacity: 0.95;
        }
        .stats-bar {
            display: flex;
            justify-content: space-around;
            padding: 30px;
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
        }
        .stat-item {
            text-align: center;
        }
        .stat-value {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #6c757d;
            margin-top: 5px;
        }
        .content {
            padding: 40px;
        }
        .section {
            margin-bottom: 40px;
        }
        .section-title {
            font-size: 1.5em;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .anime-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 15px;
        }
        .anime-card {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 15px;
            border-left: 4px solid #dee2e6;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .anime-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        .anime-card.watched {
            border-left-color: #28a745;
            background: linear-gradient(135deg, #d4edda 0%, #f8f9fa 100%);
        }
        .anime-name {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        .anime-meta {
            font-size: 0.9em;
            color: #6c757d;
        }
        .watched-badge {
            display: inline-block;
            background: #28a745;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.75em;
            margin-left: 8px;
        }
        .rating {
            color: #ffc107;
            letter-spacing: 2px;
        }
        .progress-container {
            padding: 30px 40px;
            background: #fff;
        }
        .progress-bar {
            height: 30px;
            background: #e9ecef;
            border-radius: 15px;
            overflow: hidden;
            position: relative;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px;
            transition: width 1s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #6c757d;
            font-size: 0.9em;
            border-top: 1px solid #e9ecef;
        }
        @media print {
            body { background: white; }
            .container { box-shadow: none; }
            .anime-card { break-inside: avoid; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎌 90后经典动漫收藏 🎌</h1>
            <p>我的童年回忆与观看记录</p>
        </div>
EOF

    # 统计
    local total=$(grep -E '^\| \[[ x]\]' "$MARKDOWN_FILE" | wc -l)
    local watched=$(grep -E '^\| \[x\]' "$MARKDOWN_FILE" | wc -l)
    local percentage=$((watched * 100 / total))
    local jp=$(grep -A 100 '## 一、日本动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    local cn=$(grep -A 100 '## 二、国产动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    local en=$(grep -A 100 '## 三、欧美动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    
    cat << EOF >> "$output"
        <div class="stats-bar">
            <div class="stat-item">
                <div class="stat-value">$watched</div>
                <div class="stat-label">已观看</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">$total</div>
                <div class="stat-label">总数</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${percentage}%</div>
                <div class="stat-label">完成度</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">🇯🇵</div>
                <div class="stat-label">$jp 部</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">🇨🇳</div>
                <div class="stat-label">$cn 部</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">🇺🇸</div>
                <div class="stat-label">$en 部</div>
            </div>
        </div>
        
        <div class="progress-container">
            <div class="progress-bar">
                <div class="progress-fill" style="width: ${percentage}%">${percentage}%</div>
            </div>
        </div>
        
        <div class="content">
EOF

    # 日本动画
    echo '            <div class="section">' >> "$output"
    echo '                <div class="section-title">🇯🇵 日本动画</div>' >> "$output"
    echo '                <div class="anime-grid">' >> "$output"
    
    grep -A 100 '## 一、日本动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[[ x]\]' | while IFS='|' read -r check name year desc rating; do
        local is_watched=$(echo "$check" | grep -q 'x' && echo "watched" || echo "")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs | sed 's/⭐/★/g')
        local badge=$(echo "$check" | grep -q 'x' && echo '<span class="watched-badge">✓ 已看</span>' || echo '')
        
        echo "                    <div class=\"anime-card $is_watched\">" >> "$output"
        echo "                        <div class=\"anime-name\">$name_clean $badge</div>" >> "$output"
        echo "                        <div class=\"anime-meta\">$year_clean | <span class=\"rating\">$rating_clean</span></div>" >> "$output"
        echo "                    </div>" >> "$output"
    done
    
    echo '                </div>' >> "$output"
    echo '            </div>' >> "$output"
    
    # 国产动画
    echo '            <div class="section">' >> "$output"
    echo '                <div class="section-title">🇨🇳 国产动画</div>' >> "$output"
    echo '                <div class="anime-grid">' >> "$output"
    
    grep -A 100 '## 二、国产动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[[ x]\]' | while IFS='|' read -r check name year desc rating; do
        local is_watched=$(echo "$check" | grep -q 'x' && echo "watched" || echo "")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs | sed 's/⭐/★/g')
        local badge=$(echo "$check" | grep -q 'x' && echo '<span class="watched-badge">✓ 已看</span>' || echo '')
        
        echo "                    <div class=\"anime-card $is_watched\">" >> "$output"
        echo "                        <div class=\"anime-name\">$name_clean $badge</div>" >> "$output"
        echo "                        <div class=\"anime-meta\">$year_clean | <span class=\"rating\">$rating_clean</span></div>" >> "$output"
        echo "                    </div>" >> "$output"
    done
    
    echo '                </div>' >> "$output"
    echo '            </div>' >> "$output"
    
    # 欧美动画
    echo '            <div class="section">' >> "$output"
    echo '                <div class="section-title">🇺🇸 欧美动画</div>' >> "$output"
    echo '                <div class="anime-grid">' >> "$output"
    
    grep -A 100 '## 三、欧美动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[[ x]\]' | while IFS='|' read -r check name year desc rating; do
        local is_watched=$(echo "$check" | grep -q 'x' && echo "watched" || echo "")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs | sed 's/⭐/★/g')
        local badge=$(echo "$check" | grep -q 'x' && echo '<span class="watched-badge">✓ 已看</span>' || echo '')
        
        echo "                    <div class=\"anime-card $is_watched\">" >> "$output"
        echo "                        <div class=\"anime-name\">$name_clean $badge</div>" >> "$output"
        echo "                        <div class=\"anime-meta\">$year_clean | <span class=\"rating\">$rating_clean</span></div>" >> "$output"
        echo "                    </div>" >> "$output"
    done
    
    echo '                </div>' >> "$output"
    echo '            </div>' >> "$output"
    
    # Footer
    cat << EOF >> "$output"
        </div>
        
        <div class="footer">
            <p>生成时间: $(date '+%Y年%m月%d日') | 90后经典动漫收藏</p>
            <p>"愿你走出半生，归来仍是少年。"</p>
        </div>
    </div>
</body>
</html>
EOF

    echo -e "${GREEN}✅ HTML导出完成: $output${NC}"
    echo -e "${BLUE}💡 提示: 用浏览器打开即可查看，按 Ctrl+P 可打印为PDF${NC}"
}

# 导出为Notion格式
export_notion() {
    local output="$OUTPUT_DIR/anime_collection_notion_$DATE.md"
    
    echo -e "${BLUE}📝 正在导出为Notion格式...${NC}"
    
    cat << EOF > "$output"
# 90后经典动漫收藏 - Notion导入版

> 💡 **导入说明**: 复制以下内容到Notion页面即可
> 格式已优化为Notion数据库兼容格式

EOF

    # 创建数据库表格
    echo "| 状态 | 作品名称 | 年份 | 地区 | 评分 | 备注 |" >> "$output"
    echo "|------|----------|------|------|------|------|" >> "$output"
    
    # 日本动画
    grep -A 100 '## 一、日本动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[[ x]\]' | while IFS='|' read -r check name year desc rating; do
        local status=$(echo "$check" | grep -q 'x' && echo "✅ 已看" || echo "⬜ 未看")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs)
        echo "| $status | $name_clean | $year_clean | 日本 | $rating_clean | |" >> "$output"
    done
    
    # 国产动画
    grep -A 100 '## 二、国产动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[[ x]\]' | while IFS='|' read -r check name year desc rating; do
        local status=$(echo "$check" | grep -q 'x' && echo "✅ 已看" || echo "⬜ 未看")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs)
        echo "| $status | $name_clean | $year_clean | 国产 | $rating_clean | |" >> "$output"
    done
    
    # 欧美动画
    grep -A 100 '## 三、欧美动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[[ x]\]' | while IFS='|' read -r check name year desc rating; do
        local status=$(echo "$check" | grep -q 'x' && echo "✅ 已看" || echo "⬜ 未看")
        local name_clean=$(echo "$name" | sed 's/\[\[.*\]\]//g' | sed 's/\*\*//g' | xargs)
        local year_clean=$(echo "$year" | xargs)
        local rating_clean=$(echo "$rating" | tr -d '|' | xargs)
        echo "| $status | $name_clean | $year_clean | 欧美 | $rating_clean | |" >> "$output"
    done
    
    echo "" >> "$output"
    echo "---" >> "$output"
    echo "" >> "$output"
    echo "## 📊 统计数据" >> "$output"
    echo "" >> "$output"
    
    local watched=$(grep -E '^\| \[x\]' "$MARKDOWN_FILE" | wc -l)
    local total=$(grep -E '^\| \[[ x]\]' "$MARKDOWN_FILE" | wc -l)
    echo "- **已观看**: $watched 部" >> "$output"
    echo "- **总计**: $total 部" >> "$output"
    echo "- **完成度**: $((watched * 100 / total))%" >> "$output"
    
    echo -e "${GREEN}✅ Notion格式导出完成: $output${NC}"
    echo -e "${BLUE}💡 提示: 复制表格内容到Notion，可自动转换为数据库${NC}"
}

# 导出为纯文本列表
export_txt() {
    local output="$OUTPUT_DIR/anime_collection_$DATE.txt"
    
    echo -e "${BLUE}📝 正在导出为纯文本...${NC}"
    
    cat << EOF > "$output"
=====================================
   90后经典动漫收藏 - 观看清单
=====================================

EOF

    echo "【已观看作品】" >> "$output"
    echo "" >> "$output"
    grep -E '^\| \[x\]' "$MARKDOWN_FILE" | sed 's/| \[x\] | /✓ /; s/ |.*$//' >> "$output"
    
    echo "" >> "$output"
    echo "【待观看作品】" >> "$output"
    echo "" >> "$output"
    grep -E '^\| \[ \]' "$MARKDOWN_FILE" | sed 's/| \[ \] | /○ /; s/ |.*$//' >> "$output"
    
    echo "" >> "$output"
    echo "=====================================" >> "$output"
    local watched=$(grep -E '^\| \[x\]' "$MARKDOWN_FILE" | wc -l)
    local total=$(grep -E '^\| \[[ x]\]' "$MARKDOWN_FILE" | wc -l)
    echo "总计: $watched / $total 部 ($(echo "scale=1; $watched * 100 / $total" | bc)%)" >> "$output"
    echo "导出时间: $(date '+%Y-%m-%d %H:%M')" >> "$output"
    echo "=====================================" >> "$output"
    
    echo -e "${GREEN}✅ 文本导出完成: $output${NC}"
}

# 主程序
case "${1:-help}" in
    csv)
        export_csv
        ;;
    html)
        export_html
        ;;
    notion)
        export_notion
        ;;
    txt|text)
        export_txt
        ;;
    json)
        echo -e "${BLUE}📦 使用 anime-backup.sh export 导出JSON${NC}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${YELLOW}未知格式: $1${NC}"
        show_help
        exit 1
        ;;
esac
