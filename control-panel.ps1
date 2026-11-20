<#
  Break Reminder – Control Panel / 控制面板 / Panel de control
  Double-click "Break Reminder (Windows).bat" to open this window. No commands to type.
  双击 "Break Reminder (Windows).bat" 打开本窗口，不用输入任何命令。
  Haz doble clic en "Break Reminder (Windows).bat". No hay que escribir comandos.
#>
param(
    [string]$SelfTest = '',      # test only: draw the window to this .png and exit
    [string]$ForceLang = ''      # test only: show the window in this language without saving anything
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public static class BrDpi2 { [DllImport("user32.dll")] public static extern bool SetProcessDPIAware(); }'
[void][BrDpi2]::SetProcessDPIAware()
[System.Windows.Forms.Application]::EnableVisualStyles()

$Root = $PSScriptRoot
$TaskName = 'BreakReminder'
$SettingsFile = Join-Path $env:LOCALAPPDATA 'BreakReminder\settings.json'

# screen scaling (125 %, 150 %...): every size below is written for 100 % and multiplied by $Sc
$Sc = [System.Drawing.Graphics]::FromHwnd([IntPtr]::Zero).DpiX / 96.0
function S([double]$n) { return [int][math]::Round($n * $Sc) }
function F([double]$pt, [bool]$bold = $false) {
    $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    return (New-Object System.Drawing.Font('Microsoft YaHei UI', [float]($pt * 96 / 72 * $Sc), $style, [System.Drawing.GraphicsUnit]::Pixel))
}
function Set-B($ctrl, $x, $y, $w, $h) { $ctrl.SetBounds((S $x), (S $y), (S $w), (S $h)) }

function Get-SavedLanguage {
    try {
        if (Test-Path $SettingsFile) {
            $s = Get-Content $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($s.language -in @('zh', 'en', 'es')) { return [string]$s.language }
        }
    } catch { }
    return ''
}
function Save-Language([string]$l) {
    try {
        New-Item -ItemType Directory -Force (Split-Path $SettingsFile) | Out-Null
        (@{ language = $l } | ConvertTo-Json) | Set-Content -Path $SettingsFile -Encoding UTF8
    } catch { }
}

$Tx = @{
    zh = @{
        title = '休息提醒'; sub = '一个温柔的全屏休息闹钟'; lang = '语言'
        st_none = '还没有安装'; st_run = '正在运行'; st_pause = '已暂停（下次登录会自动恢复）'; st_off = '已暂停（点"恢复"才会再启动）'
        work = '每工作多少分钟提醒'; brk = '每次休息多少分钟'
        start = '开始提醒'; apply = '应用设置'; try_ = '立刻试一下'; pause = '暂停'; alsooff = '同时不要开机自启'
        resume = '恢复'; uninstall = '卸载'
        confirm = '要从这台电脑上卸载休息提醒吗？（卸载后可以直接删除这个文件夹）'
        m_start = '已开始！第一次休息会在 {0} 分钟后出现。'; m_pause = '已暂停。'; m_resume = '已恢复运行。'; m_gone = '已卸载，现在可以直接删除这个文件夹。'
        m_err = '出了点问题：'
    }
    en = @{
        title = 'Break Reminder'; sub = 'A gentle full-screen break clock'; lang = 'Language'
        st_none = 'Not installed yet'; st_run = 'Running'; st_pause = 'Paused (back at next login)'; st_off = 'Paused (press Resume to restart)'
        work = 'Work minutes between breaks'; brk = 'Break length (minutes)'
        start = 'Start the reminder'; apply = 'Apply settings'; try_ = 'Try it now'; pause = 'Pause'; alsooff = "Also don't start at login"
        resume = 'Resume'; uninstall = 'Uninstall'
        confirm = 'Remove the reminder from this computer? (You can delete the folder afterwards.)'
        m_start = 'Started! The first break appears in {0} minutes.'; m_pause = 'Paused.'; m_resume = 'Running again.'; m_gone = 'Uninstalled. You can now delete this folder.'
        m_err = 'Something went wrong: '
    }
    es = @{
        title = 'Break Reminder'; sub = 'Un reloj de descanso amable'; lang = 'Idioma'
        st_none = 'Todavía no instalado'; st_run = 'Funcionando'; st_pause = 'En pausa (vuelve al iniciar sesión)'; st_off = 'En pausa (pulsa Reanudar)'
        work = 'Minutos de trabajo entre descansos'; brk = 'Duración del descanso (min)'
        start = 'Iniciar el recordatorio'; apply = 'Aplicar ajustes'; try_ = 'Probar ahora'; pause = 'Pausar'; alsooff = 'Tampoco al iniciar sesión'
        resume = 'Reanudar'; uninstall = 'Desinstalar'
        confirm = '¿Quitar el recordatorio de este ordenador? (Después puedes borrar la carpeta.)'
        m_start = '¡Listo! El primer descanso aparece en {0} minutos.'; m_pause = 'En pausa.'; m_resume = 'Funcionando otra vez.'; m_gone = 'Desinstalado. Ya puedes borrar esta carpeta.'
        m_err = 'Algo salió mal: '
    }
}

$script:L = Get-SavedLanguage
if (-not $script:L) {
    $ui = (Get-UICulture).TwoLetterISOLanguageName
    $script:L = if ($ui -in @('zh', 'es')) { $ui } else { 'en' }
}
if ($ForceLang -in @('zh', 'en', 'es')) { $script:L = $ForceLang }

function C([int]$r, [int]$g, [int]$b) { [System.Drawing.Color]::FromArgb($r, $g, $b) }
$teal = C 96 186 176; $tealD = C 52 140 132; $cocoa = C 84 66 60; $white = C 255 255 255

$form = New-Object System.Windows.Forms.Form
$form.AutoScaleMode = 'None'
$form.Text = 'Break Reminder'
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.ClientSize = New-Object System.Drawing.Size((S 460), (S 580))
$form.BackColor = C 255 249 238
$form.Font = F 10

function New-Label($x, $y, $w, $h, $pt, $bold, $color) {
    $l = New-Object System.Windows.Forms.Label
    Set-B $l $x $y $w $h
    $l.Font = F $pt $bold
    $l.ForeColor = $color
    $l.BackColor = [System.Drawing.Color]::Transparent
    $form.Controls.Add($l)
    return $l
}
function New-Btn($x, $y, $w, $h, [bool]$primary) {
    $b = New-Object System.Windows.Forms.Button
    Set-B $b $x $y $w $h
    $b.FlatStyle = 'Flat'
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    $b.Font = F 10.5 $true
    if ($primary) {
        $b.BackColor = $teal; $b.ForeColor = $white; $b.FlatAppearance.BorderSize = 0
    } else {
        $b.BackColor = $white; $b.ForeColor = $tealD; $b.FlatAppearance.BorderColor = C 150 208 200; $b.FlatAppearance.BorderSize = 1
    }
    $form.Controls.Add($b)
    return $b
}

$lblTitle = New-Label 24 14 412 46 22 $true $cocoa
$lblSub = New-Label 26 64 412 26 10 $false (C 120 140 133)
$lblLang = New-Label 26 106 92 28 10 $false (C 150 125 105)
$btnZh = New-Btn 120 100 96 36 $false; $btnZh.Text = '中文'
$btnEn = New-Btn 222 100 96 36 $false; $btnEn.Text = 'English'
$btnEs = New-Btn 324 100 96 36 $false; $btnEs.Text = 'Español'

$status = New-Object System.Windows.Forms.Label
Set-B $status 24 154 412 48
$status.Font = F 11 $true
$status.TextAlign = 'MiddleCenter'
$form.Controls.Add($status)

$lblWork = New-Label 26 228 290 28 10 $false $cocoa
$numWork = New-Object System.Windows.Forms.NumericUpDown
Set-B $numWork 336 224 92 32; $numWork.Font = F 11; $numWork.Minimum = 5; $numWork.Maximum = 240; $numWork.Value = 30
$form.Controls.Add($numWork)
$lblBrk = New-Label 26 272 290 28 10 $false $cocoa
$numBrk = New-Object System.Windows.Forms.NumericUpDown
Set-B $numBrk 336 268 92 32; $numBrk.Font = F 11; $numBrk.Minimum = 1; $numBrk.Maximum = 60; $numBrk.Value = 5
$form.Controls.Add($numBrk)

$btnStart = New-Btn 24 324 412 54 $true
$btnTry = New-Btn 24 392 200 44 $false
$btnPause = New-Btn 236 392 200 44 $false
$chkOff = New-Object System.Windows.Forms.CheckBox
Set-B $chkOff 238 440 200 28; $chkOff.Font = F 9.5; $chkOff.ForeColor = C 120 105 95
$form.Controls.Add($chkOff)
$btnResume = New-Btn 24 476 200 44 $false
$btnGone = New-Btn 236 476 200 44 $false

$msg = New-Label 24 528 412 44 9.5 $false $tealD
$msg.TextAlign = 'MiddleCenter'

function Get-State {
    $t = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if (-not $t) { return 'none' }
    if ($t.State -eq 'Disabled') { return 'off' }
    if ($t.State -eq 'Running') { return 'run' }
    return 'pause'
}

function Set-Style($btn, [bool]$on, $fore) {
    $btn.Enabled = $on
    $btn.Cursor = if ($on) { [System.Windows.Forms.Cursors]::Hand } else { [System.Windows.Forms.Cursors]::Default }
    if ($on) { $btn.BackColor = $white; $btn.ForeColor = $fore } else { $btn.BackColor = C 240 236 228; $btn.ForeColor = C 175 168 158 }
}

function Update-Panel {
    $T = $Tx[$script:L]
    $st = Get-State
    switch ($st) {
        'none'  { $status.Text = '○  ' + $T.st_none;    $status.BackColor = C 240 233 222; $status.ForeColor = C 140 120 100 }
        'run'   { $status.Text = '●  ' + $T.st_run;     $status.BackColor = C 214 240 233; $status.ForeColor = $tealD }
        'pause' { $status.Text = '❚❚  ' + $T.st_pause; $status.BackColor = C 255 236 200; $status.ForeColor = C 150 100 40 }
        'off'   { $status.Text = '❚❚  ' + $T.st_off;   $status.BackColor = C 255 236 200; $status.ForeColor = C 150 100 40 }
    }
    $btnStart.Text = if ($st -eq 'none') { $T.start } else { $T.apply }
    Set-Style $btnTry $true $tealD
    Set-Style $btnPause ($st -eq 'run') $tealD
    Set-Style $btnResume (($st -eq 'pause') -or ($st -eq 'off')) $tealD
    Set-Style $btnGone ($st -ne 'none') (C 170 90 80)
    foreach ($pair in @(@($btnZh, 'zh'), @($btnEn, 'en'), @($btnEs, 'es'))) {
        if ($pair[1] -eq $script:L) { $pair[0].BackColor = C 205 235 228; $pair[0].ForeColor = $tealD } else { $pair[0].BackColor = $white; $pair[0].ForeColor = C 150 130 115 }
    }
}

function Set-PanelText {
    $T = $Tx[$script:L]
    $form.Text = $T.title
    $lblTitle.Text = $T.title; $lblSub.Text = $T.sub; $lblLang.Text = $T.lang
    $lblWork.Text = $T.work; $lblBrk.Text = $T.brk
    $btnTry.Text = $T.try_; $btnPause.Text = $T.pause; $chkOff.Text = $T.alsooff
    $btnResume.Text = $T.resume; $btnGone.Text = $T.uninstall
    Update-Panel
}

function Invoke-Script([string]$name, [string[]]$extra = @()) {
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $Root $name)) + $extra
    $out = & powershell @a 2>&1 | Out-String
    return @{ Ok = ($LASTEXITCODE -eq 0); Out = $out.Trim() }
}

function Show-Result($res, [string]$okText) {
    $T = $Tx[$script:L]
    if ($res.Ok) { $msg.ForeColor = $tealD; $msg.Text = $okText }
    else { $msg.ForeColor = C 170 90 80; $msg.Text = $T.m_err + $res.Out }
    Update-Panel
}

foreach ($b in @($btnZh, $btnEn, $btnEs)) {
    $b.Add_Click({
        param($sender, $e)
        $script:L = @{ '中文' = 'zh'; 'English' = 'en'; 'Español' = 'es' }[$sender.Text]
        Save-Language $script:L      # the reminder itself uses this language from the next break on
        $msg.Text = ''
        Set-PanelText
    })
}

$btnStart.Add_Click({
    $T = $Tx[$script:L]
    $wv = [int]$numWork.Value; $bv = [int]$numBrk.Value
    $res = Invoke-Script 'install.ps1' @('-WorkMinutes', "$wv", '-BreakMinutes', "$bv")
    Show-Result $res ($T.m_start -f $wv)
})
$btnTry.Add_Click({
    $bv = [int]$numBrk.Value; $wv = [int]$numWork.Value
    Start-Process powershell -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', (Join-Path $Root 'break-reminder.ps1'), '-TestNow', '-WorkMinutes', "$wv", '-BreakMinutes', "$bv"
})
$btnPause.Add_Click({
    $T = $Tx[$script:L]
    $extra = if ($chkOff.Checked) { @('-Disable') } else { @() }
    Show-Result (Invoke-Script 'pause.ps1' $extra) $T.m_pause
})
$btnResume.Add_Click({
    $T = $Tx[$script:L]
    Show-Result (Invoke-Script 'resume.ps1') $T.m_resume
})
$btnGone.Add_Click({
    $T = $Tx[$script:L]
    $ans = [System.Windows.Forms.MessageBox]::Show($T.confirm, $T.title, 'YesNo', 'Question')
    if ($ans -eq 'Yes') { Show-Result (Invoke-Script 'uninstall.ps1') $T.m_gone }
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 2500
$timer.Add_Tick({ Update-Panel })

Set-PanelText
$form.Add_Shown({
    $form.Activate()
    $timer.Start()
    if ($SelfTest) {
        $cap = New-Object System.Windows.Forms.Timer
        $cap.Interval = 900
        $cap.Add_Tick({
            param($sender, $e)
            $sender.Stop()
            $bmp = New-Object System.Drawing.Bitmap($form.Width, $form.Height)
            $form.DrawToBitmap($bmp, (New-Object System.Drawing.Rectangle(0, 0, $form.Width, $form.Height)))
            $bmp.Save($SelfTest, [System.Drawing.Imaging.ImageFormat]::Png)
            $form.Close()
        })
        $cap.Start()
    }
})
[void]$form.ShowDialog()
$timer.Stop()
