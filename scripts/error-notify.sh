#!/bin/bash
# error-notify.sh - 全局错误捕获和通知脚本

# 飞书用户ID
FEISHU_USER="ou_f6f7fe688f92292263380d223f1ea860"

# 获取当前时间和主机名
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)

# 发送飞书通知的函数
send_feishu_notify() {
    local title="$1"
    local content="$2"
    local level="$3"  # info, warning, error
    
    # 使用 openclaw 的 message 工具发送通知
    # 注意：这个脚本需要在 openclaw 环境中运行
    openclaw message send \
        --channel feishu \
        --target "$FEISHU_USER" \
        --content "[$level] $title

$content

时间: $TIMESTAMP
主机: $HOSTNAME" 2>/dev/null || echo "Failed to send notification"
}

# 主函数
main() {
    local command="$1"
    shift
    
    echo "[$TIMESTAMP] Starting: $command"
    echo "[$TIMESTAMP] Args: $@"
    
    # 执行命令，捕获输出和错误
    local output
    local exit_code
    
    if output=$("$command" "$@" 2>&1); then
        exit_code=0
        echo "[$TIMESTAMP] Success"
        echo "$output"
    else
        exit_code=$?
        echo "[$TIMESTAMP] Failed with exit code: $exit_code"
        echo "$output"
        
        # 判断错误类型
        local error_type="error"
        local title="任务执行失败"
        
        if echo "$output" | grep -qi "429\|rate limit\|too many requests"; then
            error_type="warning"
            title="API 限流 (429)"
        elif echo "$output" | grep -qi "timeout"; then
            title="执行超时"
        elif echo "$output" | grep -qi "permission\|unauthorized"; then
            title="权限错误"
        fi
        
        # 发送通知
        send_feishu_notify "$title" "命令: $command $@
错误码: $exit_code
输出:
$output" "$error_type"
    fi
    
    return $exit_code
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <command> [args...]"
        exit 1
    fi
    main "$@"
fi
