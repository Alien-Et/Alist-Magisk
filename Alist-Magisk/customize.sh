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
