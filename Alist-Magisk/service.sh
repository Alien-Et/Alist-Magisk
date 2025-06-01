#!/system/bin/sh
# service.sh for AList Magisk Module

MODDIR=${0%/*}
DATA_DIR="$MODDIR/data"
ALIST_BINARY="/system/bin/alist"
MODULE_PROP="$MODDIR/module.prop"
PASSWORD_FILE="$MODDIR/随机密码.txt"
REPO_URL="https://github.com/Alien-Et/Alist-Magisk"

get_lan_ip() {
  LAN_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
  [ -z "$LAN_IP" ] && LAN_IP=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
  [ -z "$LAN_IP" ] && LAN_IP="192.168.x.x"
  echo "$LAN_IP"
}

generate_random_password() {
  OUTPUT=$($ALIST_BINARY admin random --data "$DATA_DIR" 2>&1 | \
           grep -E "username|password" | \
           awk '/username/ {print "账号：" $NF} /password/ {print "密码：" $NF}')
  if [ -n "$OUTPUT" ]; then
    echo "$OUTPUT" > "$PASSWORD_FILE"
    chmod 644 "$PASSWORD_FILE"
    echo "密码已保存到 $PASSWORD_FILE"
    echo "$OUTPUT"
  else
    echo "警告: 无法生成或捕获账号和密码"
    return 1
  fi
}

update_module_prop_running() {
  LAN_IP=$(get_lan_ip)
  if [ -f "$PASSWORD_FILE" ]; then
    USERNAME=$(grep "账号：" "$PASSWORD_FILE" | awk '{print $2}')
    PASSWORD=$(grep "密码：" "$PASSWORD_FILE" | awk '{print $2}')
    if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
      sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL} | 初始账号：${USERNAME} | 初始密码：${PASSWORD}（仅未手动修改时有效）|" "$MODULE_PROP"
    else
      sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL}|" "$MODULE_PROP"
    fi
  else
    sed -i "s|^description=.*|description=【运行中】局域网地址：http://${LAN_IP}:5244 项目地址：${REPO_URL}|" "$MODULE_PROP"
  fi
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

mkdir -p "$DATA_DIR"

$ALIST_BINARY server --data "$DATA_DIR" &
sleep 1
if pgrep -f alist >/dev/null; then
  echo "AList 服务启动成功"
  if [ ! -f "$PASSWORD_FILE" ]; then
    generate_random_password || echo "密码生成失败，继续运行"
  else
    echo "检测到 $PASSWORD_FILE，跳过密码生成"
  fi
  update_module_prop_running
else
  echo "无法启动 AList 服务"
  exit 1
fi
