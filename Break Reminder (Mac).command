#!/bin/bash
# Break Reminder (Mac) - double-click me.   双击我就行。   Haz doble clic aquí.
# First time only: right-click this file, choose Open, then Open again.
# 第一次请右键点这个文件，选"打开"，再点"打开"。 / La primera vez: clic derecho, Abrir, y otra vez Abrir.
cd "$(dirname "$0")/macos" || exit 1

TITLE="Break Reminder"

say() {   # show a message box (works with plain text only)
  osascript -e "display dialog \"$1\" with title \"$TITLE\" buttons {\"OK\"} default button \"OK\"" >/dev/null 2>&1
}

ask_number() {   # $1 = question, $2 = default; prints the number (empty if the user pressed Cancel)
  osascript -e "text returned of (display dialog \"$1\" default answer \"$2\" with title \"$TITLE\" buttons {\"Cancel\", \"OK\"} default button \"OK\")" 2>/dev/null
}

menu() {
  osascript <<'EOF' 2>/dev/null
set choices to {"1.  Start / apply settings  ·  开始 / 应用设置  ·  Iniciar", "2.  Try it now  ·  立刻试一下  ·  Probar ahora", "3.  Pause  ·  暂停  ·  Pausar", "4.  Pause until I resume  ·  一直暂停  ·  Pausar hasta reanudar", "5.  Resume  ·  恢复  ·  Reanudar", "6.  Is it running?  ·  它在运行吗？  ·  ¿Funciona?", "7.  Uninstall  ·  卸载  ·  Desinstalar"}
set picked to choose from list choices with title "Break Reminder" with prompt "What do you want to do?   你想做什么？   ¿Qué quieres hacer?" OK button name "OK" cancel button name "Close"
if picked is false then return "0"
return text 1 of (item 1 of picked)
EOF
}

only_digits() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }

while true; do
  choice="$(menu)"
  case "$choice" in
    1)
      work="$(ask_number "Work minutes between breaks  ·  每工作多少分钟提醒  ·  Minutos de trabajo" 30)" || continue
      brk="$(ask_number "Break length in minutes  ·  每次休息多少分钟  ·  Minutos de descanso" 5)" || continue
      only_digits "$work" || work=30
      only_digits "$brk" || brk=5
      out="$(bash ./install.sh --work "$work" --break "$brk" 2>&1)"; code=$?
      if [ $code -ne 0 ]; then
        if echo "$out" | grep -q "Could not find Python"; then
          ans="$(osascript -e "button returned of (display dialog \"Please install Python first (one time, free).  请先安装 Python（只需一次，免费）。  Instala Python primero (una vez, gratis).\" with title \"$TITLE\" buttons {\"Close\", \"Open download page\"} default button \"Open download page\")" 2>/dev/null)"
          [ "$ans" = "Open download page" ] && open "https://www.python.org/downloads/macos/"
        else
          say "Something went wrong. 出了点问题。 Algo salió mal."
        fi
      else
        say "Started! 已开始！ ¡Listo!  First break in $work min / 第一次休息在 $work 分钟后 / primer descanso en $work min."
      fi
      ;;
    2) bash ./test-now.sh --break "${brk:-5}" >/dev/null 2>&1 & ;;
    3) bash ./pause.sh >/dev/null 2>&1;            say "Paused. 已暂停。 En pausa." ;;
    4) bash ./pause.sh --disable >/dev/null 2>&1;  say "Paused until you resume. 已暂停，直到你点恢复。 En pausa hasta que reanudes." ;;
    5) bash ./resume.sh >/dev/null 2>&1;           say "Running again. 已恢复。 Funcionando otra vez." ;;
    6)
      if bash ./status.sh 2>/dev/null | grep -q "state = running"; then
        say "Running. 正在运行。 Funcionando."
      else
        say "Not running (paused or not installed). 没有在运行（已暂停或还没安装）。 No está funcionando (en pausa o sin instalar)."
      fi
      ;;
    7)
      ans="$(osascript -e "button returned of (display dialog \"Uninstall the reminder?  要卸载休息提醒吗？  ¿Desinstalar el recordatorio?\" with title \"$TITLE\" buttons {\"No\", \"Yes\"} default button \"No\")" 2>/dev/null)"
      if [ "$ans" = "Yes" ]; then
        bash ./uninstall.sh >/dev/null 2>&1
        say "Uninstalled. You can delete this folder now. 已卸载，现在可以删除本文件夹。 Desinstalado. Ya puedes borrar la carpeta."
      fi
      ;;
    *) break ;;
  esac
done

# close this Terminal window when we are done
osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1 &
exit 0
