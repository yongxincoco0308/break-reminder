<#
  安装 / Install / Instalar
  登录 Windows 时自动在后台运行休息提醒，并立即启动。
  Runs the reminder in the background at every Windows login, and starts it now.

  用法 / Usage (open PowerShell in this folder):
    .\install.ps1                          # 默认语言=系统语言 / default language = system language
    .\install.ps1 -Language en             # English   (zh = 中文, es = Español)
    .\install.ps1 -Language es -WorkMinutes 45 -BreakMinutes 10
    .\install.ps1 -Language zh -SecondLanguage en     # 中文 + 英文双语名言
#>
param(
    [double]$WorkMinutes = 30,
    [double]$BreakMinutes = 5,
    [double]$SnoozeMinutes = 5,
    [string]$Language = '',
    [string]$SecondLanguage = ''
)

$script = Join-Path $PSScriptRoot 'break-reminder.ps1'
if (-not (Test-Path $script)) { throw "Cannot find $script" }

$taskArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`" -WorkMinutes $WorkMinutes -BreakMinutes $BreakMinutes -SnoozeMinutes $SnoozeMinutes"
if ($Language) { $taskArgs += " -Language $Language" }
if ($SecondLanguage) { $taskArgs += " -SecondLanguage $SecondLanguage" }

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $taskArgs
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew

Stop-ScheduledTask -TaskName 'BreakReminder' -ErrorAction SilentlyContinue
Register-ScheduledTask -TaskName 'BreakReminder' -Action $action -Trigger $trigger -Settings $settings `
    -Description 'Break Reminder' -Force | Out-Null
Start-ScheduledTask -TaskName 'BreakReminder'
Write-Host "Installed and started: a $BreakMinutes-minute break every $WorkMinutes minutes. / 已安装并启动：每工作 $WorkMinutes 分钟休息 $BreakMinutes 分钟。"
