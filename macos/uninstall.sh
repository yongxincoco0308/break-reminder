#!/bin/bash
# Uninstall / 卸载 / Desinstalar: stop the reminder and remove everything it created.
. "$(dirname "$0")/_common.sh"

launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl enable "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
rm -f "$PLIST" "$LOG"
rm -rf "$STATE_DIR"
echo "Uninstalled. You can now delete this folder. / 已卸载，现在可以直接删除本文件夹。"
