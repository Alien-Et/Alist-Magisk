#!/system/bin/sh
ui_print "正在安装 AList Magisk 模块..."
ARCH=$(getprop ro.product.cpu.abi)
ui_print "检测到架构: $ARCH"

if echo "$ARCH" | grep -q "arm64"; then
  ui_print "安装 64 位 AList 二进制..."
  mv $MODPATH/system/bin/alist-arm64 $MODPATH/system/bin/alist
  rm $MODPATH/system/bin/alist-arm
else
  ui_print "安装 32 位 AList 二进制..."
  mv $MODPATH/system/bin/alist-arm $MODPATH/system/bin/alist
  rm $MODPATH/system/bin/alist-arm64
fi

chmod 755 $MODPATH/system/bin/alist
ui_print "AList 已安装到 /system/bin/alist"

DATA_DIR="$MODPATH/data"
PASSWORD_FILE="$MODPATH/密码.txt"
if [ ! -d "$DATA_DIR" ] || [ -z "$(ls -A $DATA_DIR)" ]; then
  mkdir -p "$DATA_DIR"
  OUTPUT=$(/system/bin/sh -c "cd $MODPATH/system/bin && ./alist admin random --data $DATA_DIR 2>&1")
  USERNAME=$(echo "$OUTPUT" | grep -E 'username' | awk '{print $NF}' | head -n 1)
  PASSWORD=$(echo "$OUTPUT" | grep -E 'password' | awk '{print $NF}' | head -n 1)
  if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    ui_print "账号: $USERNAME"
    ui_print "密码: $PASSWORD"
    echo "账号: $USERNAME" > "$PASSWORD_FILE"
    echo "密码: $PASSWORD" >> "$PASSWORD_FILE"
    chmod 644 "$PASSWORD_FILE"
    ui_print "密码已保存到 $PASSWORD_FILE"
  else
    ui_print "警告: 无法生成或捕获账号和密码"
  fi
else
  ui_print "检测到已有 data 目录，跳过密码设置"
fi
