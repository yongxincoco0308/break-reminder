#!/bin/bash
# Is it running? / 它在运行吗？ / ¿Está funcionando?
. "$(dirname "$0")/_common.sh"

if launchctl print "$DOMAIN/$LABEL" >/tmp/break-reminder-status.$$ 2>/dev/null; then
  grep -E '^[[:space:]]*(state|pid) =' /tmp/break-reminder-status.$$ || true
  echo "=> Loaded. If it says 'state = running', the reminder is active. / 已加载；显示 state = running 就是正在运行。"
else
  echo "=> Not running (paused, or not installed). / 没有在运行（已暂停或还没安装）。"
fi
rm -f /tmp/break-reminder-status.$$
