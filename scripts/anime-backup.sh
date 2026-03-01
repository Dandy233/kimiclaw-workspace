#!/bin/bash
# ============================================
# 动漫收藏数据备份与恢复脚本
# 90s-anime-collection-backup.sh
# ============================================

# 配置
BACKUP_DIR="$HOME/.anime-collection/backups"
MARKDOWN_FILE="${1:-90s-anime-collection-checklist.md}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/anime_backup_$DATE.json"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 显示帮助
show_help() {
    echo -e "${BLUE}动漫收藏数据备份工具${NC}"
    echo ""
    echo "用法: $0 [命令] [文件]"
    echo ""
    echo "命令:"
    echo "  backup    备份当前标记数据 (默认)"
    echo "  export    导出为JSON格式"
    echo "  stats     显示观看统计"
    echo "  list      列出所有备份"
    echo "  restore   恢复指定备份"
    echo "  clean     清理旧备份"
    echo "  help      显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 backup                    # 备份当前数据"
    echo "  $0 export my-checklist.md    # 导出指定文件"
    echo "  $0 stats                     # 显示统计信息"
    echo "  $0 restore 20260301_120000   # 恢复指定备份"
}

# 解析Markdown中的标记数据
parse_markdown() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}错误: 文件不存在 $file${NC}"
        exit 1
    fi
    
    # 提取已观看的作品
    local watched=$(grep -E '^\| \[x\]' "$file" | wc -l)
    local total=$(grep -E '^\| \[[ x]\]' "$file" | wc -l)
    
    # 按分类统计
    local japanese=$(grep -A 100 '## 一、日本动画篇' "$file" | grep -E '^\| \[x\]' | wc -l)
    local chinese=$(grep -A 100 '## 二、国产动画篇' "$file" | grep -E '^\| \[x\]' | wc -l)
    local western=$(grep -A 100 '## 三、欧美动画篇' "$file" | grep -E '^\| \[x\]' | wc -l)
    
    # 生成JSON
    cat << EOF
{
  "backup_date": "$(date -Iseconds)",
  "source_file": "$file",
  "statistics": {
    "total_watched": $watched,
    "total_anime": $total,
    "completion_rate": $(echo "scale=2; $watched * 100 / $total" | bc 2>/dev/null || echo "0"),
    "by_region": {
      "japanese": $japanese,
      "chinese": $chinese,
      "western": $western
    }
  },
  "watched_list": [
$(grep -E '^\| \[x\]' "$file" | sed 's/| \[x\] | /** /; s/ |.*$//' | sed 's/^/    "/; s/$/",/' | sed '$ s/,$//')
  ],
  "backup_version": "1.0"
}
EOF
}

# 备份功能
backup_data() {
    echo -e "${BLUE}📦 正在备份动漫收藏数据...${NC}"
    
    local json_data=$(parse_markdown "$MARKDOWN_FILE")
    echo "$json_data" > "$BACKUP_FILE"
    
    # 同时备份原始Markdown
    cp "$MARKDOWN_FILE" "$BACKUP_DIR/anime_backup_$DATE.md"
    
    echo -e "${GREEN}✅ 备份完成!${NC}"
    echo -e "  JSON: ${YELLOW}$BACKUP_FILE${NC}"
    echo -e "  MD:   ${YELLOW}$BACKUP_DIR/anime_backup_$DATE.md${NC}"
    
    # 显示统计
    local watched=$(echo "$json_data" | grep -o '"total_watched": [0-9]*' | grep -o '[0-9]*')
    local total=$(echo "$json_data" | grep -o '"total_anime": [0-9]*' | grep -o '[0-9]*')
    echo ""
    echo -e "${BLUE}📊 当前进度: $watched / $total 部${NC}"
}

# 导出为JSON
export_json() {
    local output="${2:-anime_collection_export_$(date +%Y%m%d).json}"
    echo -e "${BLUE}📤 正在导出为JSON...${NC}"
    parse_markdown "$MARKDOWN_FILE" > "$output"
    echo -e "${GREEN}✅ 导出完成: $output${NC}"
}

# 显示统计
show_stats() {
    echo -e "${BLUE}📊 动漫收藏统计${NC}"
    echo "========================"
    
    local json_data=$(parse_markdown "$MARKDOWN_FILE")
    
    local watched=$(grep -E '^\| \[x\]' "$MARKDOWN_FILE" | wc -l)
    local total=$(grep -E '^\| \[[ x]\]' "$MARKDOWN_FILE" | wc -l)
    local percentage=$((watched * 100 / total))
    
    echo ""
    echo -e "总进度: ${GREEN}$watched${NC} / ${BLUE}$total${NC} 部 (${YELLOW}$percentage%${NC})"
    echo ""
    
    # 进度条
    local filled=$((percentage / 2))
    local empty=$((50 - filled))
    printf "[${GREEN}"
    printf '%0.s█' $(seq 1 $filled)
    printf "${NC}"
    printf '%0.s░' $(seq 1 $empty)
    printf "] %d%%\n" $percentage
    echo ""
    
    # 按地区统计
    local jp=$(grep -A 100 '## 一、日本动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    local cn=$(grep -A 100 '## 二、国产动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    local en=$(grep -A 100 '## 三、欧美动画篇' "$MARKDOWN_FILE" | grep -E '^\| \[x\]' | wc -l)
    
    echo -e "按地区统计:"
    echo -e "  🇯🇵 日本动画: ${GREEN}$jp${NC} 部"
    echo -e "  🇨🇳 国产动画: ${GREEN}$cn${NC} 部"
    echo -e "  🇺🇸 欧美动画: ${GREEN}$en${NC} 部"
    echo ""
    
    # 等级评定
    echo -e "${BLUE}🏆 观看等级:${NC}"
    if [[ $watched -ge 150 ]]; then
        echo -e "  ${YELLOW}⭐⭐⭐⭐⭐ 神级大佬${NC}"
    elif [[ $watched -ge 100 ]]; then
        echo -e "  ${YELLOW}⭐⭐⭐⭐ 动画达人${NC}"
    elif [[ $watched -ge 50 ]]; then
        echo -e "  ${YELLOW}⭐⭐⭐ 资深观众${NC}"
    elif [[ $watched -ge 20 ]]; then
        echo -e "  ${YELLOW}⭐⭐ 合格90后${NC}"
    else
        echo -e "  ${YELLOW}⭐ 动画萌新${NC}"
    fi
}

# 列出备份
list_backups() {
    echo -e "${BLUE}📁 备份列表:${NC}"
    echo "========================"
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}暂无备份文件${NC}"
        return
    fi
    
    ls -lt "$BACKUP_DIR"/*.json 2>/dev/null | while read line; do
        local file=$(echo "$line" | awk '{print $NF}')
        local date=$(echo "$line" | awk '{print $6, $7, $8}')
        local size=$(echo "$line" | awk '{print $5}')
        local name=$(basename "$file")
        echo -e "${GREEN}$name${NC} (${size}b) - $date"
    done
}

# 恢复备份
restore_backup() {
    local backup_name="$1"
    
    if [[ -z "$backup_name" ]]; then
        echo -e "${RED}错误: 请指定备份文件名${NC}"
        list_backups
        exit 1
    fi
    
    local backup_file="$BACKUP_DIR/anime_backup_$backup_name.md"
    
    if [[ ! -f "$backup_file" ]]; then
        echo -e "${RED}错误: 备份文件不存在${NC}"
        list_backups
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️  即将恢复备份，当前数据将被覆盖!${NC}"
    read -p "确认恢复? (yes/no): " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        cp "$backup_file" "$MARKDOWN_FILE"
        echo -e "${GREEN}✅ 恢复完成!${NC}"
    else
        echo -e "${YELLOW}已取消恢复${NC}"
    fi
}

# 清理旧备份
clean_backups() {
    echo -e "${BLUE}🧹 清理旧备份...${NC}"
    
    # 保留最近10个备份
    local count=$(ls -1 "$BACKUP_DIR"/*.json 2>/dev/null | wc -l)
    
    if [[ $count -gt 10 ]]; then
        local to_delete=$((count - 10))
        echo "将删除 $to_delete 个旧备份文件"
        ls -1t "$BACKUP_DIR"/*.json 2>/dev/null | tail -n $to_delete | xargs rm -f
        echo -e "${GREEN}✅ 清理完成，保留最近10个备份${NC}"
    else
        echo -e "${YELLOW}备份数量 ($count) 未超过限制，无需清理${NC}"
    fi
}

# 主程序
case "${1:-backup}" in
    backup)
        backup_data
        ;;
    export)
        export_json "$@"
        ;;
    stats|stat)
        show_stats
        ;;
    list|ls)
        list_backups
        ;;
    restore)
        restore_backup "$2"
        ;;
    clean)
        clean_backups
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
