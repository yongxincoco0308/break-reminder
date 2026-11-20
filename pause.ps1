<#
  暂停 / Pause / Pausar
    .\pause.ps1            立即停止提醒，下次登录 Windows 时会自动恢复。
                           Stops the reminder now; it comes back at your next Windows login.
    .\pause.ps1 -Disable   停止，并且开机也不再自动启动，直到运行 .\resume.ps1。
                           Stops it AND turns off auto-start until you run .\resume.ps1.
#>
param([switch]$Disable)

Stop-ScheduledTask -TaskName 'BreakReminder' -ErrorAction SilentlyContinue
if ($Disable) {
    Disable-ScheduledTask -TaskName 'BreakReminder' | Out-Null
    Write-Host 'Paused, and auto-start is off. Run .\resume.ps1 to turn it back on. / 已暂停，且不再自动启动。运行 .\resume.ps1 可恢复。'
} else {
    Write-Host 'Paused until your next login. Run .\resume.ps1 to restart now. / 已暂停，下次登录会自动恢复。运行 .\resume.ps1 可立刻恢复。'
}
