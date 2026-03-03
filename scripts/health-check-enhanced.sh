#!/bin/bash
# health-check-enhanced.sh - 增强版健康检查脚本
# 用于检测系统状态并在异常时通知用户

FEISHU_USER="ou_f6f7fe688f92292263380d223f1ea860"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REPORT_FILE="/tmp/health-report-$(date +%Y%m%d-%H%M%S).txt"

# 报告收集
report=""
errors=()
warnings=()

add_to_report() {
    local status="$1"
    local message="$2"
    report+="[$status] $message\n"
    
    if [ "$status" == "ERROR" ]; then
        errors+=("$message")
    elif [ "$status" == "WARN" ]; then
        warnings+=("$message")
    fi
}

echo "=========================================="
echo "OpenClaw 健康检查报告 - $TIMESTAMP"
echo "=========================================="

# 1. 检查 Gateway 状态
echo ""
echo "[1/6] 检查 Gateway 状态..."
if openclaw gateway status > /dev/null 2>&1; then
    echo "[OK] Gateway 运行正常"
    add_to_report "OK" "Gateway 运行正常"
else
    echo "[ERROR] Gateway 异常"
    add_to_report "ERROR" "Gateway 未运行或无法访问"
fi

# 2. 检查磁盘空间
echo ""
echo "[2/6] 检查磁盘空间..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo "[OK] 磁盘使用率: ${DISK_USAGE}%"
    add_to_report "OK" "磁盘使用率: ${DISK_USAGE}%"
elif [ "$DISK_USAGE" -lt 90 ]; then
    echo "[WARN] 磁盘使用率: ${DISK_USAGE}% (建议清理)"
    add_to_report "WARN" "磁盘使用率较高: ${DISK_USAGE}%"
else
    echo "[ERROR] 磁盘使用率: ${DISK_USAGE}% (紧急)"
    add_to_report "ERROR" "磁盘空间不足: ${DISK_USAGE}%"
fi

# 3. 检查内存使用
echo ""
echo "[3/6] 检查内存使用..."
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
if [ "$MEMORY_USAGE" -lt 80 ]; then
    echo "[OK] 内存使用率: ${MEMORY_USAGE}%"
    add_to_report "OK" "内存使用率: ${MEMORY_USAGE}%"
else
    echo "[WARN] 内存使用率: ${MEMORY_USAGE}%"
    add_to_report "WARN" "内存使用率较高: ${MEMORY_USAGE}%"
fi

# 4. 检查 cron 任务状态
echo ""
echo "[4/6] 检查定时任务状态..."
# 使用更可靠的方式检查
FAILED_JOBS=$(openclaw cron list 2>/dev/null | grep -c "error" || echo "0")
if [ "$FAILED_JOBS" -eq 0 ]; then
    echo "[OK] 所有定时任务正常"
    add_to_report "OK" "所有定时任务运行正常"
else
    echo "[ERROR] $FAILED_JOBS 个定时任务最近失败"
    add_to_report "ERROR" "$FAILED_JOBS 个定时任务最近失败"
fi

# 5. 检查飞书连接
echo ""
echo "[5/6] 检查飞书连接..."
FEISHU_STATUS=$(openclaw status 2>/dev/null | grep -i feishu | head -1)
if echo "$FEISHU_STATUS" | grep -qi "ok\|ON"; then
    echo "[OK] 飞书连接正常"
    add_to_report "OK" "飞书连接正常"
else
    echo "[WARN] 飞书连接状态: ${FEISHU_STATUS:-unknown}"
    add_to_report "WARN" "飞书连接需要检查: ${FEISHU_STATUS:-unknown}"
fi

# 6. 检查日志错误
echo ""
echo "[6/6] 检查最近错误日志..."
TODAY=$(date +%Y-%m-%d)
LOG_FILE="/tmp/openclaw/openclaw-${TODAY}.log"
if [ -f "$LOG_FILE" ]; then
    ERROR_COUNT=$(grep -c '"logLevelId":5' "$LOG_FILE" 2>/dev/null || echo "0")
    if [ "$ERROR_COUNT" -lt 10 ]; then
        echo "[OK] 今日错误数: $ERROR_COUNT"
        add_to_report "OK" "今日错误数: $ERROR_COUNT"
    elif [ "$ERROR_COUNT" -lt 50 ]; then
        echo "[WARN] 今日错误数: $ERROR_COUNT"
        add_to_report "WARN" "今日错误数较多: $ERROR_COUNT"
    else
        echo "[ERROR] 今日错误数: $ERROR_COUNT"
        add_to_report "ERROR" "今日错误数过多: $ERROR_COUNT"
    fi
else
    echo "[OK] 今日暂无日志文件"
    add_to_report "OK" "今日暂无错误日志"
fi

# 生成报告摘要
echo ""
echo "=========================================="
echo "检查完成"
echo "=========================================="

echo ""
echo "摘要:"
echo "- 错误: ${#errors[@]}"
echo "- 警告: ${#warnings[@]}"

# 保存报告
printf "%b" "$report" > "$REPORT_FILE"
echo "详细报告: $REPORT_FILE"

# 显示发现的问题
if [ ${#errors[@]} -gt 0 ]; then
    echo ""
    echo "发现的问题:"
    for error in "${errors[@]}"; do
        echo "  [ERROR] $error"
    done
fi

if [ ${#warnings[@]} -gt 0 ]; then
    echo ""
    echo "警告:"
    for warning in "${warnings[@]}"; do
        echo "  [WARN] $warning"
    done
fi

# 返回状态码
if [ ${#errors[@]} -gt 0 ]; then
    exit 1
elif [ ${#warnings[@]} -gt 0 ]; then
    exit 2
else
    exit 0
fi
