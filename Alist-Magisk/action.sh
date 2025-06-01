#!/system/bin/sh
# action.sh for AList Magisk Module

MODDIR=${0%/*}
ALIST_BINARY="/system/bin/alist"
DATA_DIR="$MODDIR/data"
PASSWORD_FILE="$MODDIR/密码.txt"

check_alist_status() {
  if pgrep -f "$ALIST_BINARY server --data $DATA_DIR" >/dev/null; then
    echo "AList 服务正在运行"
    return 0
  else
    echo "AList 服务未运行"
    return 1
  fi
}

start_alist() {
  if check_alist_status; then
    echo "AList 服务已在运行，无需启动"
  else
    $ALIST_BINARY server --data "$DATA_DIR" &
    sleep 1
    if check_alist_status; then
      echo "AList 服务启动成功"
    else
      echo "AList 服务启动失败"
      exit 1
    fi
  fi
}

stop_alist() {
  if check_alist_status; then
    pkill -f "$ALIST_BINARY server --data $DATA_DIR"
    sleep 1
    if check_alist_status; then
      echo "AList 服务停止失败"
      exit 1
    else
      echo "AList 服务已停止"
    fi
  else
    echo "AList 服务未运行，无需停止"
  fi
}

reset_password() {
  echo "正在重置 AList 管理员密码..."
  OUTPUT=$($ALIST_BINARY admin random --data "$DATA_DIR" 2>&1)
  USERNAME=$(echo "$OUTPUT" | grep -E 'username' | awk '{print $NF}' | head -n 1)
  PASSWORD=$(echo "$OUTPUT" | grep -E 'password' | awk '{print $NF}' | head -n 1)
  if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    echo "账号: $USERNAME" > "$PASSWORD_FILE"
    echo "密码: $PASSWORD" >> "$PASSWORD_FILE"
    chmod 644 "$PASSWORD_FILE"
    echo "新密码已保存到 $PASSWORD_FILE"
    echo "账号: $USERNAME"
    echo "密码: $PASSWORD"
  else
    echo "密码重置失败"
    exit 1
  fi
}

case "$1" in
  start)
    start_alist
    ;;
  stop)
    stop_alist
    ;;
  reset)
    reset_password
    ;;
  status)
    check_alist_status
    ;;
  *)
    check_alist_status
    echo "用法: $0 {start|stop|reset|status}"
    echo "  start  - 启动 AList 服务"
    echo "  stop   - 停止 AList 服务"
    echo "  reset  - 重置 AList 管理员密码"
    echo "  status - 检查 AList 服务状态"
    exit 0
    ;;
esac
