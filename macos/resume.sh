#!/bin/bash
# Resume / 恢复 / Reanudar
. "$(dirname "$0")/_common.sh"

if [ ! -f "$PLIST" ]; then
  echo "Not installed yet. Run: bash install.sh   / 还没有安装，请先运行 bash install.sh"
  exit 1
fi
launchctl enable "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl bootstrap "$DOMAIN" "$PLIST" >/dev/null 2>&1 || launchctl kickstart -k "$DOMAIN/$LABEL"
echo "Reminder is running again. / 休息提醒已恢复运行。"
