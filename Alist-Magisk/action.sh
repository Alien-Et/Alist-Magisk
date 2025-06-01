#!/system/bin/sh
# action.sh for AList Magisk Module

MODDIR=${0%/*}
ALIST_BINARY="/system/bin/alist"
DATA_DIR="$MODDIR/data"
MODULE_PROP="$MODDIR/module.prop"
REPO_URL="https://github.com/Alien-Et/Alist-Magisk"

get_lan_ip() {
  LAN_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
  [ -z "$LAN_IP" ] && LAN_IP=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
  [ -z "$LAN_IP" ] && LAN_IP="192.168.x.x"
  echo "$LAN_IP"
}

check_alist_status() {
  if pgrep -f "$ALIST_BINARY server --data $DATA_DIR" >/dev/null; then
    return 0
  else
    return 1
  fi
}

update_module_prop() {
  local status="$1"
  if [ "$status" = "running" ]; then
    LAN_IP=$(get_lan_ip)
    sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL}|" "$MODULE_PROP"
  else
    sed -i "s|^description=.*|description=【已停止】请点击\"操作\"启动程序。项目地址：${REPO_URL}|" "$MODULE_PROP"
  fi
}

if check_alist_status; then
  pkill -f "$ALIST_BINARY server --data $DATA_DIR"
  sleep 1
  if check_alist_status; then
    echo "无法停止 AList 服务"
    exit 1
  else
    echo "AList 服务已停止"
    update_module_prop "stopped"
  fi
else
  $ALIST_BINARY server --data "$DATA_DIR" &
  sleep 1
  if check_alist_status; then
    echo "AList 服务启动成功"
    update_module_prop "running"
  else
    echo "无法启动 AList 服务"
    exit 1
  fi
fi
