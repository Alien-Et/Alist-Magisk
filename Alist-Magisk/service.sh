#!/system/bin/sh
# service.sh for AList Magisk Module

DATA_DIR="$MODPATH/data"
ALIST_BINARY="/system/bin/alist"

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
