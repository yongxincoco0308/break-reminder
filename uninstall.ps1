# 卸载 / Uninstall / Desinstalar: stop the reminder and remove its auto-start entry.
Stop-ScheduledTask -TaskName 'BreakReminder' -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName 'BreakReminder' -Confirm:$false -ErrorAction SilentlyContinue
# 同时清掉本地保存的“播放到第几条名言”记录 / also remove the saved quote position
Remove-Item -Recurse -Force (Join-Path $env:LOCALAPPDATA 'BreakReminder') -ErrorAction SilentlyContinue
Write-Host 'Uninstalled. You can now delete this folder. / 已卸载，现在可以直接删除本文件夹。'
