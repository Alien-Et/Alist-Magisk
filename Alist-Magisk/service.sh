#!/system/bin/sh
# service.sh for AList Magisk Module

MODDIR=${0%/*}
DATA_DIR="$MODDIR/data"
ALIST_BINARY="/system/bin/alist"
MODULE_PROP="$MODDIR/module.prop"
REPO_URL="https://github.com/Alien-Et/Alist-Magisk"

get_lan_ip() {
  LAN_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
  [ -z "$LAN_IP" ] && LAN_IP=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
  [ -z "$LAN_IP" ] && LAN_IP="192.168.x.x"
  echo "$LAN_IP"
}

update_module_prop_running() {
  LAN_IP=$(get_lan_ip)
  sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL}|" "$MODULE_PROP"
}

MAX_WAIT=60
WAIT_INTERVAL=2
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
  if [ "$(getprop sys.boot_completed)" = "1" ]; then
    echo "Android 系统启动完成，开始启动 AList 服务"
    break
  fi
  echo "等待 Android 系统启动... ($ELAPSED/$MAX_WAIT 秒)"
  sleep $WAIT_INTERVAL
  ELAPSED=$((ELAPSED + WAIT_INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
  echo "警告：系统启动超时，尝试启动 AList 服务"
fi

$ALIST_BINARY server --data "$DATA_DIR" &
sleep 1
if pgrep -f "$ALIST_BINARY server --data $DATA_DIR" >/dev/null; then
  echo "AList 服务启动成功"
  update_module_prop_running
else
  echo "无法启动 AList 服务"
  exit 1
fi
