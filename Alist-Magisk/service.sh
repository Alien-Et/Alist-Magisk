#!/system/bin/sh
# service.sh for AList Magisk Module

MODDIR=${0%/*}
DATA_DIR="$MODDIR/data"
ALIST_BINARY="/system/bin/alist"
MODULE_PROP="$MODDIR/module.prop"
PASSWORD_FILE="$MODDIR/随机密码.txt"
REPO_URL="https://github.com/Alien-Et/Alist-Magisk"
LOG_FILE="$MODDIR/service.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_lan_ip() {
  LAN_IP=$(ip addr show wlan0 2>/dev/null | grep -w 'inet' | awk '{print $2}' | cut -d'/' -f1)
  [ -z "$LAN_IP" ] && LAN_IP=$(ifconfig wlan0 2>/dev/null | grep -w 'inet' | awk '{print $2}' | cut -d':' -f2)
  [ -z "$LAN_IP" ] && LAN_IP="192.168.x.x"
  echo "$LAN_IP"
}

generate_random_password() {
  log "Attempting to generate random password"
  OUTPUT=$($ALIST_BINARY admin random --data "$DATA_DIR" 2>&1 | \
           grep -E "username|password" | \
           awk '/username/ {print "账号：" $NF} /password/ {print "密码：" $NF}' | tr -d '\r')
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
  if [ -f "$PASSWORD_FILE" ]; then
    log "Reading $PASSWORD_FILE"
    cat "$PASSWORD_FILE" >> "$LOG_FILE"
    USERNAME=$(grep -E "^账号：" "$PASSWORD_FILE" | sed -E 's/^账号：(.*)/\1/' | tr -d '\r')
    PASSWORD=$(grep -E "^密码：" "$PASSWORD_FILE" | sed -E 's/^密码：(.*)/\1/' | tr -d '\r')
    log "Raw grep output for username: $(grep -E "^账号：" "$PASSWORD_FILE")"
    log "Raw grep output for password: $(grep -E "^密码：" "$PASSWORD_FILE")"
    log "Parsed USERNAME=$USERNAME, PASSWORD=$PASSWORD"
    if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
      sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL} | 初始账号：${USERNAME} | 初始密码：${PASSWORD}（仅未手动修改时有效）|" "$MODULE_PROP"
      log "Updated module.prop with username and password"
    else
      sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL}|" "$MODULE_PROP"
      log "No valid username or password, updated module.prop without credentials"
    fi
  else
    sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL}|" "$MODULE_PROP"
    log "No password file found, updated module.prop without credentials"
  fi
}

MAX_WAIT=60
WAIT_INTERVAL=2
ELAPSED=0

log "Starting service.sh"
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
