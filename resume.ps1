# 恢复 / Resume / Reanudar: start the reminder again (and re-enable auto-start if it was turned off).
Enable-ScheduledTask -TaskName 'BreakReminder' | Out-Null
Start-ScheduledTask -TaskName 'BreakReminder'
Write-Host 'Reminder is running again. / 休息提醒已恢复运行。'
