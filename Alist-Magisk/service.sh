#!/system/bin/sh
# service.sh for AList Magisk Module

MODDIR=${0%/*}
DATA_DIR="$MODDIR/data"
ALIST_BINARY="/system/bin/alist"
MODULE_PROP="$MODDIR/module.prop"
PASSWORD_FILE="$MODDIR/随机密码.txt"
LOG_FILE="$MODDIR/service.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_lan_ip() {
    LAN_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    [ -z "$LAN_IP" ] && LAN_IP=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
    [ -z "$LAN_IP" ] && LAN_IP="192.168.x.x"
    log "get_lan_ip: LAN_IP=$LAN_IP"
    echo "$LAN_IP"
}

generate_random_password() {
    log "Attempting to generate random password"
    OUTPUT=$($ALIST_BINARY admin random --data "$DATA_DIR" 2>&1 | \
             grep -E "username|password" | \
             awk '/username/ {print "账号：" $NF} /password/ {print "密码：" $NF}')
    if [ -n "$OUTPUT" ]; then
        echo "$OUTPUT" > "$PASSWORD_FILE"
        chmod 600 "$PASSWORD_FILE"
        log "Password file created at $PASSWORD_FILE with content: $OUTPUT"
        echo "$OUTPUT"
    else
        log "Error: Failed to generate or capture username and password"
        return 1
    fi
}

update_module_prop_running() {
    LAN_IP=$(get_lan_ip)
    
    log "Updating module.prop for running state, LAN_IP=$LAN_IP"
    # 确保 module.prop 存在且可写
    if [ ! -f "$MODULE_PROP" ]; then
        log "Error: $MODULE_PROP does not exist"
        return 1
    fi
    if [ ! -w "$MODULE_PROP" ]; then
        log "Error: $MODULE_PROP is not writable"
        chmod 644 "$MODULE_PROP" || log "Error: Failed to set permissions on $MODULE_PROP"
    fi
    # 记录更新前的 module.prop 内容
    log "module.prop content before update: $(cat "$MODULE_PROP")"
    # 添加分隔符和账密提示信息
    NEW_DESC="description=【运行中】局域网地址：http://${LAN_IP}:5244 | 初始账密请移步到\"/data/adb/modules/alist-magisk/随机密码.txt\"查看"
    # 使用临时文件更新 module.prop，避免生成备份文件
    echo "$(grep -v '^description=' "$MODULE_PROP")" > "${MODULE_PROP}.tmp"
    echo "$NEW_DESC" >> "${MODULE_PROP}.tmp"
    mv "${MODULE_PROP}.tmp" "$MODULE_PROP"
    if [ $? -eq 0 ]; then
        log "Updated module.prop successfully"
    else
        log "Error: Failed to update module.prop"
    fi
    # 清理任何可能的备份文件
    rm -f "${MODULE_PROP}.bak" "${MODULE_PROP}.tmp.*"
    # 检查 module.prop 是否包含非键值对行
    if grep -vE '^[a-zA-Z_]+=' "$MODULE_PROP" > /dev/null; then
        log "Warning: module.prop contains invalid lines, cleaning up"
        grep -E '^[a-zA-Z_]+=' "$MODULE_PROP" > "${MODULE_PROP}.clean"
        mv "${MODULE_PROP}.clean" "$MODULE_PROP"
        log "Cleaned module.prop content: $(cat "$MODULE_PROP")"
    fi
}

log "Starting service.sh at $(date '+%Y-%m-%d %H:%M:%S')"
# 检查 ip 命令是否存在
if ! command -v ip >/dev/null 2>&1; then
    log "Error: ip command not found"
    exit 1
fi
# 检查 alist 二进制文件
if [ ! -x "$ALIST_BINARY" ]; then
    log "Error: $ALIST_BINARY is not executable or does not exist"
    exit 1
fi

ELAPSED=0
MAX_WAIT=60
WAIT_INTERVAL=5
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if [ "$(getprop sys.boot_completed)" = "1" ]; then
        log "Android system boot completed"
        break
    fi
    log "Waiting for Android system boot... ($ELAPSED/$MAX_WAIT seconds)"
    sleep $WAIT_INTERVAL
    ELAPSED=$((ELAPSED + WAIT_INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    log "Warning: System boot timeout, attempting to start AList service"
fi

mkdir -p "$DATA_DIR"
log "Created data directory: $DATA_DIR"

$ALIST_BINARY server --data "$DATA_DIR" &
sleep 1
if pgrep -f alist >/dev/null; then
    log "AList service started successfully"
    if [ ! -f "$PASSWORD_FILE" ]; then
        generate_random_password || log "Password generation failed, continuing"
    else
        log "Detected $PASSWORD_FILE, skipping password generation"
    fi
    update_module_prop_running
else
    log "Failed to start AList service"
    exit 1
fi
