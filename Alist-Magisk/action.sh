#!/system/bin/sh
# action.sh for AList Magisk Module

MODDIR=${0%/*}
ALIST_BINARY="/system/bin/alist"
DATA_DIR="$MODDIR/data"
MODULE_PROP="$MODDIR/module.prop"
SERVICE_SH="$MODDIR/service.sh"
REPO_URL="https://github.com/Alien-Et/Alist-Magisk"
LOG_FILE="$MODDIR/action.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_alist_status() {
    if pgrep -f alist >/dev/null; then
        return 0
    else
        return 1
    fi
}

update_module_prop_stopped() {
    sed -i "s|^description=.*|description=【已停止】请点击\"操作\"启动程序。项目地址：${REPO_URL}|" "$MODULE_PROP"
    log "Updated module.prop to stopped state"
}

log "Starting action.sh"
if check_alist_status; then
    pkill -f alist
    sleep 1
    if check_alist_status; then
        log "Failed to stop AList service"
        echo "无法停止 AList 服务"
        exit 1
    else
        log "AList service stopped"
        echo "AList 服务已停止"
        update_module_prop_stopped
    fi
else
    if [ -f "$SERVICE_SH" ]; then
        sh "$SERVICE_SH"
        sleep 1
        if check_alist_status; then
            log "AList service started successfully"
            echo "AList 服务启动成功"
        else
            log "Failed to start AList service"
            echo "无法启动 AList 服务"
            exit 1
        fi
    else
        log "Error: service.sh not found"
        echo "错误：service.sh 不存在"
        exit 1
    fi
fi
