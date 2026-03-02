#!/bin/bash
# Heartbeat Check Script
# 用于定时检查系统状态

echo "💓 Heartbeat Check - $(date)"
echo "============================"

# 检查系统负载
LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
echo "系统负载: $LOAD"

# 检查磁盘空间
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "⚠️ 磁盘使用率高: ${DISK_USAGE}%"
else
    echo "✅ 磁盘使用率正常: ${DISK_USAGE}%"
fi

# 检查内存
MEM_FREE=$(free -m | grep Mem | awk '{print $7}')
echo "可用内存: ${MEM_FREE}MB"

echo "============================"
echo "检查完成"
