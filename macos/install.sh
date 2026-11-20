#!/bin/bash
# Install / 安装 / Instalar
# Starts the reminder now and at every login.
#   bash install.sh                                  # language = your Mac's language
#   bash install.sh --language en                    # en | zh | es
#   bash install.sh --language es --work 45 --break 10
#   bash install.sh --language zh --second-language en
set -e
. "$(dirname "$0")/_common.sh"
need_python

xml() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
  echo '<plist version="1.0"><dict>'
  echo "<key>Label</key><string>$LABEL</string>"
  echo '<key>ProgramArguments</key><array>'
  echo "<string>$(xml "$PY")</string>"
  echo "<string>$(xml "$SCRIPT")</string>"
  for a in "$@"; do echo "<string>$(xml "$a")</string>"; done
  echo '</array>'
  echo '<key>RunAtLoad</key><true/>'
  echo '<key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>'
  echo "<key>StandardOutPath</key><string>$(xml "$LOG")</string>"
  echo "<key>StandardErrorPath</key><string>$(xml "$LOG")</string>"
  echo '<key>ProcessType</key><string>Interactive</string>'
  echo '</dict></plist>'
} > "$PLIST"

launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl enable "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl bootstrap "$DOMAIN" "$PLIST"

echo "Installed and started. The first break appears in 30 minutes (change with --work)."
echo "已安装并启动，第一次休息在 30 分钟后。"
echo "Python used: $PY"
