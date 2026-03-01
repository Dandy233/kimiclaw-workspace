#!/bin/bash
# ============================================
# 动漫收藏分享卡片生成工具
# anime-share.sh
# ============================================

MARKDOWN_FILE="${1:-90s-anime-collection-checklist.md}"
OUTPUT_DIR="./shares"
DATE=$(date +%Y%m%d)

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

mkdir -p "$OUTPUT_DIR"

# 获取统计信息
get_stats() {
    TOTAL=$(grep -E '^\| \[[ x]\]' "$MARKDOWN_FILE" | wc -l)
    WATCHED=$(grep -E '^\| \[x\]' "$MARKDOWN_FILE" | wc -l)
    PERCENTAGE=$((WATCHED * 100 / TOTAL))
    JP=$(grep -A 100 '## 一、日本动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    CN=$(grep -A 100 '## 二、国产动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    EN=$(grep -A 100 '## 三、欧美动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
}

# 获取等级称号
get_level() {
    if [[ $WATCHED -ge 150 ]]; then
        LEVEL="🏆 神级大佬"
        LEVEL_DESC="动画之神"
    elif [[ $WATCHED -ge 100 ]]; then
        LEVEL="⭐ 动画达人"
        LEVEL_DESC="资深动画迷"
    elif [[ $WATCHED -ge 50 ]]; then
        LEVEL="🎬 资深观众"
        LEVEL_DESC="阅片无数"
    elif [[ $WATCHED -ge 20 ]]; then
        LEVEL="📺 合格90后"
        LEVEL_DESC="童年完整"
    else
        LEVEL="🌱 动画萌新"
        LEVEL_DESC="正在探索"
    fi
}

# 生成文字分享卡片
gen_card_text() {
    get_stats
    get_level
    
    local output="$OUTPUT_DIR/share_card_$DATE.txt"
    
    cat > "$output" << EOF
╔══════════════════════════════════════╗
║                                      ║
║     🎌 90后经典动漫收藏挑战 🎌       ║
║                                      ║
╠══════════════════════════════════════╣
║                                      ║
║   📊 我的战绩                        ║
║                                      ║
║   已观看: ${WATCHED} / ${TOTAL} 部                 ║
║   完成度: ${PERCENTAGE}%                        ║
║   等级: ${LEVEL}           ║
║                                      ║
╠══════════════════════════════════════╣
║                                      ║
║   🌍 观看分布                        ║
║                                      ║
║   🇯🇵 日本动画: ${JP} 部                      ║
║   🇨🇳 国产动画: ${CN} 部                       ║
║   🇺🇸 欧美动画: ${EN} 部                       ║
║                                      ║
╠══════════════════════════════════════╣
║                                      ║
║   "我们的童年，是被神作喂大的"       ║
║                                      ║
║   #90后动漫 #童年回忆 #二次元        ║
║                                      ║
╚══════════════════════════════════════╝

生成时间: $(date '+%Y-%m-%d %H:%M')
EOF

    echo -e "${GREEN}✅ 文字卡片已生成: $output${NC}"
    echo ""
    cat "$output"
}

# 生成个性化推荐列表
gen_recommendations() {
    get_stats
    
    local output="$OUTPUT_DIR/recommendations_$DATE.md"
    
    # 根据观看数量生成不同推荐
    cat > "$output" << EOF
# 🎯 个性化推荐清单

基于您已观看 ${WATCHED} 部动画的记录，为您推荐以下作品：

EOF

    if [[ $WATCHED -lt 20 ]]; then
        cat >> "$output" << 'EOF'
## 🌟 入门必看 (经典中的经典)

如果你是动画萌新，这几部是必看的入门神作：

### 日本动画
- [ ] **千与千寻** - 宫崎骏巅峰之作，奥斯卡最佳动画
- [ ] **灌篮高手** - 热血运动番的巅峰
- [ ] **名侦探柯南** - 推理入门必看
- [ ] **海贼王** - 少年漫的集大成者

### 国产动画
- [ ] **大闹天宫** - 中国动画巅峰
- [ ] **哪吒传奇** - 90后共同回忆
- [ ] **西游记(动画版)** - 经典永不褪色

### 欧美动画
- [ ] **狮子王** - 迪士尼巅峰之作
- [ ] **玩具总动员** - 皮克斯开山之作

EOF
    elif [[ $WATCHED -lt 50 ]]; then
        cat >> "$output" << 'EOF'
## 🌟 进阶推荐 (深度佳作)

您已有一定观影量，推荐一些更有深度的作品：

### 深度剧情
- [ ] **新世纪福音战士(EVA)** - 心理学与哲学的完美结合
- [ ] **钢之炼金术师FA** - 剧情完美的神作
- [ ] **命运石之门** - 时间旅行的巅峰

### 治愈系
- [ ] **夏目友人帐** - 温暖治愈的妖怪故事
- [ ] **虫师** - 意境深远的艺术之作
- [ ] **蜂蜜与四叶草** - 青春群像的经典

### 国产精品
- [ ] **天书奇谭** - 上美厂经典
- [ ] **围棋少年** - 国风动画佳作
EOF
    else
        cat >> "$output" << 'EOF'
## 🌟 大师级推荐 (冷门神作)

您已是资深观众，推荐一些冷门但高质量的作品：

### 冷门神作
- [ ] **银河英雄传说** - 太空版三国演义
- [ ] **怪物(Monster)** - 悬疑心理剧的巅峰
- [ ] **永生之酒** - 叙事结构的杰作

### 实验性作品
- [ ] **怪化猫** - 浮世绘画风的独特体验
- [ ] **猫汤** - 超现实主义的黑暗童话
- [ ] **灰羽联盟** - 意境深远的心理剧

### 补全系列
如果您喜欢某部作品，可以补完系列：
- **宫崎骏全系列** - 未看完的吉卜力作品
- **皮克斯短片集** - 皮克斯的短篇动画
- **上海美影厂合集** - 完整的国产经典
EOF
    fi

    # 添加统计
    cat >> "$output" << EOF

---

## 📊 您的观看统计

- **总进度**: ${WATCHED} / ${TOTAL} 部 (${PERCENTAGE}%)
- **等级**: ${LEVEL}

---

*生成时间: $(date '+%Y年%m月%d日')*
EOF

    echo -e "${GREEN}✅ 推荐清单已生成: $output${NC}"
}

# 生成"求推荐"模板
gen_ask_template() {
    get_stats
    get_level
    
    local output="$OUTPUT_DIR/ask_recommendation_$DATE.md"
    
    cat > "$output" << EOF
# 🙋 求推荐动画！

大家好，我正在补完90后经典动漫，求推荐！

## 📊 我的情况

**已观看**: ${WATCHED} / ${TOTAL} 部 (${PERCENTAGE}%)  
**当前等级**: ${LEVEL}  
**风格偏好**: [请填写，如：热血/治愈/悬疑/搞笑]

## ✅ 已看过 (列举几部最喜欢的)

1. [填写作品1]
2. [填写作品2]
3. [填写作品3]

## ❌ 不太喜欢的类型

- [填写不感兴趣的题材]

## 🎯 求推荐

还缺这些类型的佳作：

- [ ] 热血战斗番
- [ ] 恋爱校园番
- [ ] 科幻机战番
- [ ] 治愈日常番
- [ ] 悬疑推理番
- [ ] 其他：[请注明]

## 💬 备注

[填写其他要求，如：
- 不要太长的(集数<50)
- 要已完结的
- 画风不要太老
- ...]

---

*使用 90后经典动漫收藏清单 生成*
EOF

    echo -e "${GREEN}✅ 求推荐模板已生成: $output${NC}"
    echo -e "${BLUE}💡 使用提示: 复制内容到社交媒体或论坛发布${NC}"
}

# 生成社交媒体分享文本
gen_social_text() {
    get_stats
    get_level
    
    echo ""
    echo -e "${PURPLE}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}🎌 90后经典动漫收藏挑战 🎌${NC}"
    echo ""
    echo -e "📊 ${YELLOW}我的战绩:${NC}"
    echo "   已观看: $WATCHED / $TOTAL 部"
    echo "   完成度: $PERCENTAGE%"
    echo ""
    echo -e "🏆 ${GREEN}等级: $LEVEL${NC}"
    echo ""
    echo "🌍 观看分布:"
    echo "   🇯🇵 日本: ${JP}部  🇨🇳 国产: ${CN}部  🇺🇸 欧美: ${EN}部"
    echo ""
    echo "\"我们的童年，是被神作喂大的。\""
    echo ""
    echo "#90后动漫 #童年回忆 #二次元"
    echo ""
    echo -e "${PURPLE}════════════════════════════════════════${NC}"
    echo ""
}

# 生成Markdown分享卡片
gen_card_markdown() {
    get_stats
    get_level
    
    local output="$OUTPUT_DIR/share_card_$DATE.md"
    
    cat > "$output" << EOF
# 🎌 我的90后动漫收藏战绩

> 📅 生成于 $(date '+%Y年%m月%d日')

---

## 📊 观看统计

| 项目 | 数据 |
|------|------|
| **已观看** | ${WATCHED} / ${TOTAL} 部 |
| **完成度** | ${PERCENTAGE}% |
| **当前等级** | ${LEVEL} |

### 🌍 地区分布

| 地区 | 已看数量 |
|------|----------|
| 🇯🇵 日本动画 | ${JP} 部 |
| 🇨🇳 国产动画 | ${CN} 部 |
| 🇺🇸 欧美动画 | ${EN} 部 |

---

## 📈 进度可视化

\`\`\`
$(python3 <></p>>$PERCENTAGE/10}; i++)); do echo -n "█"; done
$(for i in $(seq 1 $((10-PERCENTAGE/10))); do echo -n "░"; done)
\`\`\`

**${PERCENTAGE}%** 已完成

---

## 🏆 成就徽章

EOF

    # 根据观看数量添加徽章
    if [[ $WATCHED -ge 10 ]]; then
        echo "- ✅ **初出茅庐** - 观看10部以上" >> "$output"
    fi
    if [[ $WATCHED -ge 50 ]]; then
        echo "- ✅ **资深观众** - 观看50部以上" >> "$output"
    fi
    if [[ $WATCHED -ge 100 ]]; then
        echo "- ✅ **动画达人** - 观看100部以上" >> "$output"
    fi
    if [[ $PERCENTAGE -ge 50 ]]; then
        echo "- ✅ **过半达成** - 完成度超过50%" >> "$output"
    fi
    if [[ $JP -ge 50 ]]; then
        echo "- ✅ **日漫专家** - 日本动画50部以上" >> "$output"
    fi
    if [[ $CN -ge 20 ]]; then
        echo "- ✅ **国产情怀** - 国产动画20部以上" >> "$output"
    fi

    cat >> "$output" << EOF

---

*"愿你走出半生，归来仍是少年。"*

#90后动漫 #童年回忆 #二次元 #动画收藏
EOF

    echo -e "${GREEN}✅ Markdown分享卡片已生成: $output${NC}"
}

# 显示帮助
show_help() {
    echo -e "${BLUE}动漫收藏分享工具${NC}"
    echo ""
    echo "用法: $0 [命令] [文件]"
    echo ""
    echo "命令:"
    echo "  card      生成文字分享卡片 (默认)"
    echo "  social    生成社交媒体分享文本"
    echo "  rec       生成个性化推荐清单"
    echo "  ask       生成\"求推荐\"模板"
    echo "  md        生成Markdown分享卡片"
    echo "  all       生成所有分享内容"
    echo "  help      显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 card                          # 生成分享卡片"
    echo "  $0 rec my-checklist.md           # 基于指定文件生成推荐"
}

# 主程序
case "${1:-card}" in
    card|text)
        gen_card_text
        ;;
    social|weibo|twitter)
        gen_social_text
        ;;
    rec|recommend)
        gen_recommendations
        ;;
    ask|template)
        gen_ask_template
        ;;
    md|markdown)
        gen_card_markdown
        ;;
    all)
        gen_card_text
        gen_social_text
        gen_recommendations
        gen_ask_template
        gen_card_markdown
        echo ""
        echo -e "${GREEN}✅ 所有分享内容已生成到 $OUTPUT_DIR/${NC}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        show_help
        exit 1
        ;;
esac
