#!/bin/bash
# Shared helpers for the macOS scripts (sourced by the other .sh files).

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$DIR/break_reminder.py"
LABEL="com.breakreminder.agent"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/BreakReminder.log"
STATE_DIR="$HOME/Library/Application Support/BreakReminder"
DOMAIN="gui/$(id -u)"

# Find a Python 3 whose Tk is 8.6 or newer. Apple's own /usr/bin/python3 ships an old, buggy Tk,
# so the python.org installer (or `brew install python-tk`) is preferred.
find_python() {
  local p
  for p in /Library/Frameworks/Python.framework/Versions/Current/bin/python3 \
           /opt/homebrew/bin/python3 /usr/local/bin/python3 \
           "$(command -v python3 2>/dev/null)" /usr/bin/python3; do
    [ -n "$p" ] && [ -x "$p" ] || continue
    if "$p" -c 'import sys, tkinter; sys.exit(0 if tkinter.TkVersion >= 8.6 else 1)' >/dev/null 2>&1; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

need_python() {
  PY="$(find_python)" || {
    cat >&2 <<'MSG'
Could not find Python 3 with Tk 8.6.
Install Python from https://www.python.org/downloads/macos/ (it includes Tk), then run this again.
(With Homebrew: brew install python-tk)

没有找到带 Tk 8.6 的 Python 3。请先从 https://www.python.org/downloads/macos/ 安装 Python，再重新运行。
MSG
    exit 1
  }
}
