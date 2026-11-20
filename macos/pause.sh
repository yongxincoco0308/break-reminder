#!/bin/bash
# Pause / 暂停 / Pausar
#   bash pause.sh             stop now; it comes back at your next login
#                             立刻停止，下次登录会自动恢复
#   bash pause.sh --disable   stop AND turn off auto-start until you run resume.sh
#                             停止，并且不再自动启动，直到运行 resume.sh
. "$(dirname "$0")/_common.sh"

launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
if [ "$1" = "--disable" ]; then
  launchctl disable "$DOMAIN/$LABEL"
  echo "Paused, and auto-start is off. Run: bash resume.sh   / 已暂停，且不再自动启动。运行 bash resume.sh 可恢复。"
else
  echo "Paused until your next login. Run: bash resume.sh to restart now.   / 已暂停，下次登录会自动恢复。"
fi
