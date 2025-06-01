#!/system/bin/sh
DATA_DIR="$MODPATH/data"
ALIST_BINARY="/system/bin/alist"
$ALIST_BINARY server --data "$DATA_DIR" &
