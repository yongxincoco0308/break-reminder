<#
  Break Reminder  (中文 / English / Español)
  每工作 N 分钟，全屏弹出一个可爱的闹钟倒计时页面，附带健康小提示和名人名言。
  Every N minutes a cute full-screen alarm clock counts down a break, with a health tip and a quote.
  Cada N minutos aparece un reloj despertador a pantalla completa con una cuenta atrás, un consejo y una cita.

  参数 / Parameters / Parámetros:
    -Language zh|en|es        语言 / language / idioma（默认按系统语言 / default: system language）
    -SecondLanguage zh|en|es  名言下面再显示第二种语言 / show the quote in a 2nd language too
    -WorkMinutes 30  -BreakMinutes 5  -SnoozeMinutes 5
  名言在同目录的 quotes.json / Quotes live in quotes.json next to this script.
#>
param(
    [double]$WorkMinutes = 30,
    [double]$BreakMinutes = 5,
    [double]$SnoozeMinutes = 5,
    [string]$Language = '',
    [string]$SecondLanguage = '',
    [string]$PreviewPath = '',
    [int]$PreviewIndex = 0,
    [switch]$PreviewFinished,
    [switch]$TestNow
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# 高分屏下保持清晰 / keep text sharp on HiDPI screens
Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public static class BrDpi { [DllImport("user32.dll")] public static extern bool SetProcessDPIAware(); }'
[void][BrDpi]::SetProcessDPIAware()
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---- 界面文字 / UI text / Textos ----
$Strings = @{
    zh = @{
        top = '辛苦啦，已经连续工作 {0:0} 分钟'
        title = '休息 {0:0} 分钟吧！'
        skip = '跳过本次休息'
        snooze = '稍后 {0:0} 分钟再提醒'
        hint = '按 Esc 或点按钮可随时关闭'
        doneTitle = '休息好啦，继续加油吧'
        doneSub = '你已经做得很棒了'
        doneTop = '下一次提醒在 {0:0} 分钟后'
        doneBtn = '开始下一个计时'
        doneClock = '完成'
        by = '—— '
        tips = @(
            '休息一下对眼睛好：看看远处，让它们放松放松。',
            '站起来动一动，血液循环更顺畅，腿脚也会感谢你。',
            '放松颈椎、肩膀和腰背，久坐的僵硬会慢慢散开。',
            '让大脑歇一歇，回来之后会更专注、更有灵感。',
            '深呼吸几次，新鲜空气能让你更平静、更清醒。',
            '喝点水吧，身体补足水分，状态会更好。',
            '适时休息能缓解压力，让精力一整天都更稳定。'
        )
    }
    en = @{
        top = "Nice work! You've been working for {0:0} minutes"
        title = 'Time for a {0:0}-minute break!'
        skip = 'Skip this break'
        snooze = 'Remind me in {0:0} min'
        hint = 'Press Esc or click a button to close anytime'
        doneTitle = "Break's over. You've got this!"
        doneSub = "You're doing great"
        doneTop = 'Next reminder in {0:0} minutes'
        doneBtn = 'Start next timer'
        doneClock = 'Done'
        by = '— '
        tips = @(
            'A short break is good for your eyes: look into the distance and let them relax.',
            'Standing up gets your blood flowing again, and your legs will thank you.',
            'Loosen up your neck, shoulders and back. Sitting stiffness fades fast.',
            'Rest your mind now, and you will come back more focused and creative.',
            'Take a few deep breaths. Fresh air helps you feel calm and clear.',
            'Drink some water. Your body works better when it is well hydrated.',
            'Regular breaks ease stress and keep your energy steady all day.'
        )
    }
    es = @{
        top = 'Buen trabajo, llevas {0:0} minutos trabajando'
        title = '¡Hora de un descanso de {0:0} minutos!'
        skip = 'Saltar este descanso'
        snooze = 'Recuérdamelo en {0:0} min'
        hint = 'Pulsa Esc o un botón para cerrar cuando quieras'
        doneTitle = '¡Descanso terminado, tú puedes!'
        doneSub = 'Lo estás haciendo genial'
        doneTop = 'Próximo aviso en {0:0} minutos'
        doneBtn = 'Empezar el siguiente ciclo'
        doneClock = 'Listo'
        by = '— '
        tips = @(
            'Un descanso corto es bueno para tus ojos: mira a lo lejos y deja que se relajen.',
            'Ponerte de pie reactiva la circulación de la sangre, y tus piernas te lo agradecerán.',
            'Afloja el cuello, los hombros y la espalda. La rigidez de estar sentado se va rápido.',
            'Descansa la mente ahora y volverás con más concentración y creatividad.',
            'Respira hondo unas cuantas veces. El aire fresco te ayuda a sentirte tranquilo y despejado.',
            'Bebe un poco de agua. Tu cuerpo funciona mejor bien hidratado.',
            'Las pausas regulares alivian el estrés y mantienen tu energía estable todo el día.'
        )
    }
}

# 语言：参数 > 系统语言 > 英文
$Lang = $Language.ToLower()
if ($Lang -notin @('zh', 'en', 'es')) {
    $ui = (Get-UICulture).TwoLetterISOLanguageName
    $Lang = if ($ui -in @('zh', 'es')) { $ui } else { 'en' }
}
$SecondLang = $SecondLanguage.ToLower()
if ($SecondLang -notin @('zh', 'en', 'es') -or $SecondLang -eq $Lang) { $SecondLang = '' }
$Txt = $Strings[$Lang]

# ---- 名言 / Quotes ----
$QuotesFile = Join-Path $PSScriptRoot 'quotes.json'
$Quotes = @()
try { $Quotes = @(Get-Content -LiteralPath $QuotesFile -Raw -Encoding UTF8 | ConvertFrom-Json | ForEach-Object { $_ }) } catch { }
if ($Quotes.Count -eq 0) {
    $Quotes = @([pscustomobject]@{ zh = '休息一下，再出发。'; en = 'Rest a little, then go on.'; es = 'Descansa un poco y sigue.'; zh_by = '小提醒'; en_by = 'Break Reminder'; es_by = 'Break Reminder' })
}
$StateDir = Join-Path $env:LOCALAPPDATA 'BreakReminder'

function Get-QText($q, $lang) {
    $v = $q.$lang
    if (-not $v) { $v = $q.en }
    if (-not $v) { $v = $q.zh }
    return [string]$v
}
function Get-QBy($q, $lang) {
    $v = $q."$($lang)_by"
    if (-not $v) { $v = $q.en_by }
    if (-not $v) { $v = $q.zh_by }
    return [string]$v
}

# 轮流取下一条（序号记在本地，重启后接着往下播）/ rotate through quotes, remembering the position
function Step-Quote {
    if ($PreviewPath) { return $Quotes[$PreviewIndex % $Quotes.Count] }
    $f = Join-Path $StateDir 'index.txt'
    $i = 0
    try { if (Test-Path $f) { $i = [int](Get-Content $f -Raw) } } catch { }
    $q = $Quotes[$i % $Quotes.Count]
    try {
        New-Item -ItemType Directory -Force $StateDir | Out-Null
        Set-Content -Path $f -Value (($i + 1) % $Quotes.Count)
    } catch { }
    return $q
}

# ---- 绘图小工具 ----
$script:tmp = New-Object System.Collections.ArrayList
function Col([int]$a, [int]$r, [int]$g, [int]$b) { [System.Drawing.Color]::FromArgb($a, $r, $g, $b) }
function Br($c) { $b = New-Object System.Drawing.SolidBrush($c); [void]$script:tmp.Add($b); return $b }
function Pn($c, [float]$w) { $p = New-Object System.Drawing.Pen($c, $w); $p.StartCap = 'Round'; $p.EndCap = 'Round'; [void]$script:tmp.Add($p); return $p }
function Free-Tmp { foreach ($o in $script:tmp) { $o.Dispose() }; $script:tmp.Clear() }

function New-RoundPath {
    param([float]$X, [float]$Y, [float]$W, [float]$H, [float]$R)
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $R * 2
    $p.AddArc($X, $Y, $d, $d, 180, 90)
    $p.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
    $p.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
    $p.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

function Get-StarPoints([float]$cx, [float]$cy, [float]$ro, [float]$ri, [int]$n) {
    $pts = New-Object 'System.Collections.Generic.List[System.Drawing.PointF]'
    for ($i = 0; $i -lt (2 * $n); $i++) {
        $rad = if ($i % 2 -eq 0) { $ro } else { $ri }
        $ang = (-90 + $i * 180 / $n) * [math]::PI / 180
        $pts.Add((New-Object System.Drawing.PointF([float]($cx + $rad * [math]::Cos($ang)), [float]($cy + $rad * [math]::Sin($ang)))))
    }
    return , $pts.ToArray()
}

function Get-HeartPoints([float]$cx, [float]$cy, [float]$s) {
    $pts = New-Object 'System.Collections.Generic.List[System.Drawing.PointF]'
    for ($i = 0; $i -lt 60; $i++) {
        $t = 2 * [math]::PI * $i / 60
        $hx = 16 * [math]::Pow([math]::Sin($t), 3)
        $hy = 13 * [math]::Cos($t) - 5 * [math]::Cos(2 * $t) - 2 * [math]::Cos(3 * $t) - [math]::Cos(4 * $t)
        $pts.Add((New-Object System.Drawing.PointF([float]($cx + $hx * $s), [float]($cy - $hy * $s))))
    }
    return , $pts.ToArray()
}

function Draw-Cloud($g, [float]$x, [float]$y, [float]$s) {
    $b = New-Object System.Drawing.SolidBrush((Col 235 255 255 255))
    $g.FillEllipse($b, [float]($x - 1.6 * $s), [float]($y - 0.5 * $s), [float](3.2 * $s), [float](1.0 * $s))
    $g.FillEllipse($b, [float]($x - 1.1 * $s), [float]($y - 1.1 * $s), [float](1.5 * $s), [float](1.5 * $s))
    $g.FillEllipse($b, [float]($x - 0.35 * $s), [float]($y - 1.6 * $s), [float](1.9 * $s), [float](1.9 * $s))
    $g.FillEllipse($b, [float]($x + 0.55 * $s), [float]($y - 1.0 * $s), [float](1.3 * $s), [float](1.3 * $s))
    $b.Dispose()
}

function New-Background {
    param([int]$W, [int]$H)
    $bmp = New-Object System.Drawing.Bitmap($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
    $lg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, (Col 255 255 249 236), (Col 255 224 240 235), [float]80)
    $g.FillRectangle($lg, $rect); $lg.Dispose()

    # 闹钟后面的柔光
    $cx = $W / 2; $cy = $H * 0.42; $gr = $H * 0.42
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse([float]($cx - $gr), [float]($cy - $gr), [float](2 * $gr), [float](2 * $gr))
    $pg = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
    $pg.CenterColor = Col 190 255 255 255
    $pg.SurroundColors = @((Col 0 255 255 255))
    $g.FillPath($pg, $path); $pg.Dispose(); $path.Dispose()

    # 波点
    $dot = New-Object System.Drawing.SolidBrush((Col 70 255 255 255))
    $step = $H * 0.085; $dr = $H * 0.0075; $row = 0
    for ($y = $step / 2; $y -lt $H; $y += $step) {
        $off = if ($row % 2 -eq 0) { 0 } else { $step / 2 }
        for ($x = $off; $x -lt $W; $x += $step) { $g.FillEllipse($dot, [float]($x - $dr), [float]($y - $dr), [float](2 * $dr), [float](2 * $dr)) }
        $row++
    }
    $dot.Dispose()

    # 云朵
    Draw-Cloud $g ($W * 0.09) ($H * 0.97) ($H * 0.075)
    Draw-Cloud $g ($W * 0.93) ($H * 0.95) ($H * 0.085)
    Draw-Cloud $g ($W * 0.90) ($H * 0.13) ($H * 0.05)
    Draw-Cloud $g ($W * 0.10) ($H * 0.11) ($H * 0.045)

    # 星星
    $stars = @(
        @(0.07, 0.24, 0.032, 255, 224, 130), @(0.93, 0.22, 0.030, 255, 224, 130), @(0.15, 0.62, 0.026, 255, 224, 130),
        @(0.86, 0.60, 0.028, 255, 224, 130), @(0.22, 0.07, 0.022, 255, 224, 130), @(0.79, 0.06, 0.024, 255, 224, 130),
        @(0.05, 0.47, 0.020, 255, 224, 130), @(0.96, 0.44, 0.020, 255, 224, 130)
    )
    foreach ($st in $stars) {
        $b = New-Object System.Drawing.SolidBrush((Col 235 $st[3] $st[4] $st[5]))
        $g.FillPolygon($b, (Get-StarPoints ($W * $st[0]) ($H * $st[1]) ($H * $st[2]) ($H * $st[2] * 0.48) 5)); $b.Dispose()
    }
    # 爱心
    $hearts = @(
        @(0.12, 0.37, 255, 190, 140), @(0.89, 0.35, 150, 208, 200), @(0.19, 0.76, 200, 190, 240),
        @(0.81, 0.78, 255, 190, 140), @(0.26, 0.30, 215, 190, 245), @(0.75, 0.29, 150, 208, 200)
    )
    foreach ($ht in $hearts) {
        $b = New-Object System.Drawing.SolidBrush((Col 225 $ht[2] $ht[3] $ht[4]))
        $g.FillPolygon($b, (Get-HeartPoints ($W * $ht[0]) ($H * $ht[1]) ($H * 0.0014))); $b.Dispose()
    }
    # 闪光
    $sparks = @(@(0.20, 0.46), @(0.80, 0.42), @(0.09, 0.13), @(0.91, 0.84), @(0.06, 0.70), @(0.95, 0.66), @(0.30, 0.90), @(0.70, 0.92))
    foreach ($sp in $sparks) {
        $b = New-Object System.Drawing.SolidBrush((Col 230 190 230 215))
        $g.FillPolygon($b, (Get-StarPoints ($W * $sp[0]) ($H * $sp[1]) ($H * 0.018) ($H * 0.005) 4)); $b.Dispose()
    }
    $g.Dispose()
    return $bmp
}

# ---- 可爱闹钟 / the cute alarm clock ----
function Draw-Clock {
    param($g, [float]$cx, [float]$cy, [float]$R, [double]$frac, [string]$text, [bool]$done, [double]$wig, $font)
    $cocoa = Col 255 84 66 60
    $body = Col 255 96 186 176
    $bodyD = Col 255 62 148 142
    $butter = Col 255 255 214 118
    $butterD = Col 255 240 170 70

    # 影子
    $g.FillEllipse((Br (Col 38 60 90 85)), [float]($cx - 0.95 * $R), [float]($cy + 1.20 * $R), [float](1.9 * $R), [float](0.24 * $R))
    # 小脚
    $lp = Pn $bodyD ($R * 0.17)
    $g.DrawLine($lp, [float]($cx - 0.60 * $R), [float]($cy + 0.80 * $R), [float]($cx - 0.84 * $R), [float]($cy + 1.14 * $R))
    $g.DrawLine($lp, [float]($cx + 0.60 * $R), [float]($cy + 0.80 * $R), [float]($cx + 0.84 * $R), [float]($cy + 1.14 * $R))
    # 铃铛 + 叮铃线
    foreach ($sign in @(-1, 1)) {
        $ad = $sign * (42 + $wig)
        $ar = $ad * [math]::PI / 180
        $bx = $cx + 1.02 * $R * [math]::Sin($ar)
        $by = $cy - 1.02 * $R * [math]::Cos($ar)
        $brr = 0.36 * $R
        $head = $ad - 90
        $ringPen = Pn (Col 255 130 205 195) ($R * 0.045)
        $g.DrawArc($ringPen, [float]($bx - 1.35 * $brr), [float]($by - 1.35 * $brr), [float](2.7 * $brr), [float](2.7 * $brr), [float]($head - 32), [float]64)
        $g.DrawArc($ringPen, [float]($bx - 1.70 * $brr), [float]($by - 1.70 * $brr), [float](3.4 * $brr), [float](3.4 * $brr), [float]($head - 24), [float]48)
        $g.FillEllipse((Br $butter), [float]($bx - $brr), [float]($by - $brr), [float](2 * $brr), [float](2 * $brr))
        $g.DrawEllipse((Pn $butterD ($R * 0.04)), [float]($bx - $brr), [float]($by - $brr), [float](2 * $brr), [float](2 * $brr))
        $g.FillEllipse((Br (Col 200 255 255 255)), [float]($bx - 0.45 * $brr), [float]($by - 0.55 * $brr), [float](0.5 * $brr), [float](0.35 * $brr))
    }
    # 锤子
    $g.DrawLine((Pn $bodyD ($R * 0.07)), [float]$cx, [float]($cy - 1.0 * $R), [float]$cx, [float]($cy - 1.24 * $R))
    $g.FillEllipse((Br $bodyD), [float]($cx - 0.10 * $R), [float]($cy - 1.34 * $R), [float](0.20 * $R), [float](0.20 * $R))
    # 钟身 + 表盘
    $g.FillEllipse((Br $body), [float]($cx - $R), [float]($cy - $R), [float](2 * $R), [float](2 * $R))
    $fr = 0.84 * $R
    $g.FillEllipse((Br (Col 255 255 253 250)), [float]($cx - $fr), [float]($cy - $fr), [float](2 * $fr), [float](2 * $fr))
    # 剩余时间（粉色扇形）
    $sr = 0.80 * $R
    if ($frac -gt 0.002) {
        $sb = Br (Col 255 196 234 226)
        if ($frac -ge 0.999) { $g.FillEllipse($sb, [float]($cx - $sr), [float]($cy - $sr), [float](2 * $sr), [float](2 * $sr)) }
        else { $g.FillPie($sb, [float]($cx - $sr), [float]($cy - $sr), [float](2 * $sr), [float](2 * $sr), [float]-90, [float](360 * $frac)) }
    }
    # 刻度小圆点
    for ($i = 0; $i -lt 12; $i++) {
        $ta = ($i * 30 - 90) * [math]::PI / 180
        $tr = if ($i % 3 -eq 0) { 0.040 * $R } else { 0.024 * $R }
        $tx = $cx + 0.72 * $R * [math]::Cos($ta); $ty = $cy + 0.72 * $R * [math]::Sin($ta)
        $g.FillEllipse((Br (Col 230 96 186 176)), [float]($tx - $tr), [float]($ty - $tr), [float](2 * $tr), [float](2 * $tr))
    }
    # 脸：眼睛、腮红、嘴巴
    foreach ($sign in @(-1, 1)) {
        $ex = $cx + $sign * 0.25 * $R; $ey = $cy - 0.38 * $R
        if ($done) {
            $g.DrawArc((Pn $cocoa ($R * 0.045)), [float]($ex - 0.075 * $R), [float]($ey - 0.05 * $R), [float](0.15 * $R), [float](0.12 * $R), [float]200, [float]140)
        } else {
            $g.FillEllipse((Br $cocoa), [float]($ex - 0.06 * $R), [float]($ey - 0.06 * $R), [float](0.12 * $R), [float](0.12 * $R))
            $g.FillEllipse((Br (Col 255 255 255 255)), [float]($ex - 0.025 * $R), [float]($ey - 0.04 * $R), [float](0.04 * $R), [float](0.04 * $R))
        }
        $g.FillEllipse((Br (Col 150 255 190 150)), [float]($cx + $sign * 0.47 * $R - 0.10 * $R), [float]($cy - 0.28 * $R), [float](0.20 * $R), [float](0.11 * $R))
    }
    $g.DrawArc((Pn $cocoa ($R * 0.04)), [float]($cx - 0.09 * $R), [float]($cy - 0.40 * $R), [float](0.18 * $R), [float](0.14 * $R), [float]20, [float]140)
    # 倒计时数字
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
    $g.DrawString($text, $font, (Br $cocoa), (New-Object System.Drawing.RectangleF([float]($cx - 0.8 * $R), [float]($cy + 0.04 * $R), [float](1.6 * $R), [float](0.55 * $R))), $sf)
    $sf.Dispose()
}

function Set-Buttons {
    $W = $script:W; $H = $script:H
    $bh = [float]($H * 0.070)
    if ($script:finished) {
        $bw = [float]($H * 0.34); $y = [float]($H * 0.865)
        $script:btns = @(
            @{ Rect = (New-Object System.Drawing.RectangleF((($W - $bw) / 2), $y, $bw, $bh)); Text = $Txt.doneBtn; Action = 'done'; Style = 'primary' }
        )
    } else {
        # 引导用户选“稍后提醒”：它是醒目的主按钮；“跳过本次休息”只是下面一行不起眼的小字
        $bw = [float]($H * 0.44); $y = [float]($H * 0.843)
        $lw = [float]($H * 0.30); $lh = [float]($H * 0.040)
        $script:btns = @(
            @{ Rect = (New-Object System.Drawing.RectangleF((($W - $bw) / 2), $y, $bw, $bh)); Text = ($Txt.snooze -f $SnoozeMinutes); Action = 'snooze'; Style = 'primary' },
            @{ Rect = (New-Object System.Drawing.RectangleF((($W - $lw) / 2), ($H * 0.919), $lw, $lh)); Text = $Txt.skip; Action = 'done'; Style = 'link' }
        )
    }
}

function Show-Break {
    param([double]$Minutes)

    $script:result = 'done'
    $script:finished = $false
    $script:frac = 1.0
    $script:wig = 0.0
    $script:total = [TimeSpan]::FromMinutes($Minutes)
    $script:end = (Get-Date).Add($script:total)
    if ($PreviewPath) { $script:end = (Get-Date).AddSeconds(222) }   # 预览图显示 03:42
    if ($PreviewFinished) { $script:end = (Get-Date).AddSeconds(-1) }
    $script:hover = -1
    $script:q = Step-Quote
    $script:tipIdx = if ($PreviewPath) { 0 } else { Get-Random -Maximum $Txt.tips.Count }
    $script:tip = $Txt.tips[$script:tipIdx]
    $script:msgAlpha = if ($PreviewPath) { 255 } else { 0 }
    $script:lastMsg = Get-Date
    $script:shownAt = Get-Date
    $script:title = ($Txt.title -f $BreakMinutes)
    $script:topText = ($Txt.top -f $WorkMinutes)
    $script:centerText = ''

    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $script:W = $bounds.Width
    $script:H = $bounds.Height
    $H = $script:H
    $script:bg = New-Background $script:W $script:H
    Set-Buttons

    $fn = 'Microsoft YaHei UI'
    $px = [System.Drawing.GraphicsUnit]::Pixel
    $bold = [System.Drawing.FontStyle]::Bold
    $reg = [System.Drawing.FontStyle]::Regular
    $script:clockR = [float]($H * 0.14)
    $mainFont = if ($Lang -eq 'zh') { New-Object System.Drawing.Font($fn, [float]($H * 0.033), $bold, $px) }
                else { New-Object System.Drawing.Font('Georgia', [float]($H * 0.030), $bold, $px) }
    $script:fonts = @{
        Top   = New-Object System.Drawing.Font($fn, [float]($H * 0.021), $reg, $px)
        Title = New-Object System.Drawing.Font($fn, [float]($H * 0.052), $bold, $px)
        Sub   = New-Object System.Drawing.Font($fn, [float]($H * 0.022), $reg, $px)
        Count = New-Object System.Drawing.Font($fn, [float]($script:clockR * 0.40), $bold, $px)
        QMain = $mainFont
        QSec  = New-Object System.Drawing.Font('Georgia', [float]($H * 0.022), [System.Drawing.FontStyle]::Italic, $px)
        QBy   = New-Object System.Drawing.Font($fn, [float]($H * 0.017), $reg, $px)
        BtnMain = New-Object System.Drawing.Font($fn, [float]($H * 0.028), $bold, $px)
        Link  = New-Object System.Drawing.Font($fn, [float]($H * 0.018), $reg, $px)
        Hint  = New-Object System.Drawing.Font($fn, [float]($H * 0.017), $reg, $px)
    }
    $script:sf = New-Object System.Drawing.StringFormat
    $script:sf.Alignment = 'Center'; $script:sf.LineAlignment = 'Center'
    $script:sfTop = New-Object System.Drawing.StringFormat
    $script:sfTop.Alignment = 'Center'; $script:sfTop.LineAlignment = 'Near'

    $form = New-Object System.Windows.Forms.Form
    $script:form = $form
    $form.FormBorderStyle = 'None'
    $form.StartPosition = 'Manual'
    $form.Bounds = $bounds
    $form.TopMost = $true
    $form.ShowInTaskbar = $false
    $form.KeyPreview = $true
    $form.BackColor = Col 255 240 246 238
    $form.GetType().GetProperty('DoubleBuffered', [Reflection.BindingFlags]'Instance,NonPublic').SetValue($form, $true, $null)

    # 其他显示器铺一层同色背景 / cover other monitors too
    $script:backdrops = @()
    if (-not $PreviewPath) {
        foreach ($scr in [System.Windows.Forms.Screen]::AllScreens) {
            if ($scr.Primary) { continue }
            $bf = New-Object System.Windows.Forms.Form
            $bf.FormBorderStyle = 'None'; $bf.StartPosition = 'Manual'
            $bf.Bounds = $scr.Bounds; $bf.TopMost = $true; $bf.ShowInTaskbar = $false
            $bf.BackColor = Col 255 236 244 238
            $bf.Show()
            $script:backdrops += $bf
        }
    }

    $form.Add_Paint({
        param($sender, $e)
        $g = $e.Graphics
        $g.SmoothingMode = 'AntiAlias'
        $g.TextRenderingHint = 'AntiAliasGridFit'
        $g.DrawImage($script:bg, 0, 0)
        $W = $script:W; $H = $script:H; $cx = $W / 2
        $sf = $script:sf; $f = $script:fonts
        $cocoa = Col 255 84 66 60
        $a = [int]$script:msgAlpha

        # 上方：已工作多久、标题、休息的好处
        $g.DrawString($script:topText, $f.Top, (Br (Col 255 150 125 105)), (New-Object System.Drawing.RectangleF(0, ($H * 0.035), $W, ($H * 0.05))), $sf)
        $g.DrawString($script:title, $f.Title, (Br $cocoa), (New-Object System.Drawing.RectangleF(0, ($H * 0.072), $W, ($H * 0.10))), $sf)
        $g.DrawString($script:tip, $f.Sub, (Br (Col $a 100 140 133)), (New-Object System.Drawing.RectangleF(($W * 0.1), ($H * 0.162), ($W * 0.8), ($H * 0.04))), $sf)

        # 闹钟
        Draw-Clock $g $cx ($H * 0.42) $script:clockR $script:frac $script:centerText $script:finished $script:wig $f.Count

        # 下方：名言（所选语言；可选再加第二种语言）+ 出处
        $qw = [int]($W * 0.60); $x0 = ($W - $qw) / 2; $y = $H * 0.635
        $mainText = Get-QText $script:q $Lang
        $mh = $g.MeasureString($mainText, $f.QMain, $qw, $script:sfTop).Height
        $g.DrawString($mainText, $f.QMain, (Br (Col $a 84 66 60)), (New-Object System.Drawing.RectangleF($x0, $y, $qw, $mh)), $script:sfTop)
        $y += $mh + $H * 0.006
        if ($SecondLang) {
            $secText = Get-QText $script:q $SecondLang
            $sh = $g.MeasureString($secText, $f.QSec, $qw, $script:sfTop).Height
            $g.DrawString($secText, $f.QSec, (Br (Col $a 125 112 100)), (New-Object System.Drawing.RectangleF($x0, $y, $qw, $sh)), $script:sfTop)
            $y += $sh + $H * 0.010
        } else {
            $y += $H * 0.008
        }
        $byText = $Txt.by + (Get-QBy $script:q $Lang)
        $g.DrawString($byText, $f.QBy, (Br (Col $a 70 160 152)), (New-Object System.Drawing.RectangleF($x0, $y, $qw, ($H * 0.04))), $script:sfTop)

        # 按钮
        for ($i = 0; $i -lt $script:btns.Count; $i++) {
            $bt = $script:btns[$i]; $rc = $bt.Rect
            $hov = ($i -eq $script:hover)
            if ($bt.Style -eq 'link') {
                # 弱化：只有一行小字，颜色很淡，鼠标移上去才稍微变深
                $lc = if ($hov) { Col 255 110 95 85 } else { Col 150 150 130 115 }
                $g.DrawString($bt.Text, $f.Link, (Br $lc), $rc, $sf)
                continue
            }
            # 强化：主按钮带一圈柔和的光晕，更大、更亮
            $halo = New-RoundPath ($rc.X - 7) ($rc.Y - 7) ($rc.Width + 14) ($rc.Height + 14) (($rc.Height + 14) / 2)
            $g.FillPath((Br (Col 55 96 186 176)), $halo)
            $halo.Dispose()
            $bp = New-RoundPath $rc.X $rc.Y $rc.Width $rc.Height ($rc.Height / 2)
            $fc = if ($hov) { Col 255 122 202 192 } else { Col 255 96 186 176 }
            $g.FillPath((Br $fc), $bp)
            $bp.Dispose()
            $g.DrawString($bt.Text, $f.BtnMain, (Br (Col 255 255 255 255)), $rc, $sf)
        }

        $g.DrawString($Txt.hint, $f.Hint, (Br (Col 150 140 125 110)), (New-Object System.Drawing.RectangleF(0, ($H * 0.962), $W, ($H * 0.035))), $sf)
        Free-Tmp
    })

    $form.Add_MouseMove({
        param($sender, $e)
        $idx = -1
        for ($i = 0; $i -lt $script:btns.Count; $i++) {
            if ($script:btns[$i].Rect.Contains([float]$e.X, [float]$e.Y)) { $idx = $i }
        }
        if ($idx -ne $script:hover) {
            $script:hover = $idx
            $script:form.Cursor = if ($idx -ge 0) { [System.Windows.Forms.Cursors]::Hand } else { [System.Windows.Forms.Cursors]::Default }
            $script:form.Invalidate((New-Object System.Drawing.Rectangle(0, [int]($script:H * 0.84), $script:W, [int]($script:H * 0.12))))
        }
    })

    $form.Add_MouseClick({
        param($sender, $e)
        if (((Get-Date) - $script:shownAt).TotalSeconds -lt 1.5) { return }   # 刚弹出时防误触 / ignore accidental input right after popup
        if ($script:hover -ge 0) {
            $script:result = $script:btns[$script:hover].Action
            $script:form.Close()
        }
    })

    $form.Add_KeyDown({
        param($sender, $e)
        if (((Get-Date) - $script:shownAt).TotalSeconds -lt 1.5) { return }
        if ($e.KeyCode -eq 'Escape') { $script:result = 'done'; $script:form.Close() }
    })

    $timer = New-Object System.Windows.Forms.Timer
    $script:timer = $timer
    $timer.Interval = 200
    $timer.Add_Tick({
        $left = $script:end - (Get-Date)
        if ($left.TotalSeconds -le 0) {
            if (-not $script:finished) {
                $script:finished = $true
                $script:frac = 1.0
                $script:wig = 0.0
                $script:centerText = $Txt.doneClock
                $script:title = $Txt.doneTitle
                $script:tip = $Txt.doneSub
                $script:topText = ($Txt.doneTop -f $WorkMinutes)
                $script:hover = -1
                Set-Buttons
                if (-not $PreviewPath) { [System.Media.SystemSounds]::Asterisk.Play() }
                $script:form.Invalidate()
            }
        } else {
            $script:frac = [math]::Min(1.0, $left.TotalSeconds / $script:total.TotalSeconds)
            $script:centerText = '{0:00}:{1:00}' -f [int][math]::Floor($left.TotalMinutes), $left.Seconds
            # 铃铛每 5 秒晃一下
            if (-not $PreviewPath -and ((Get-Date).Second % 5) -eq 0) { $script:wig = [math]::Sin((Get-Date).Millisecond / 1000.0 * 6 * [math]::PI) * 7 } else { $script:wig = 0.0 }
            # 每 40 秒换下一条名言和健康小提示 / next quote and tip every 40 s
            if (-not $PreviewPath -and ((Get-Date) - $script:lastMsg).TotalSeconds -ge 40) {
                $script:q = Step-Quote
                $script:tipIdx = ($script:tipIdx + 1) % $Txt.tips.Count
                $script:tip = $Txt.tips[$script:tipIdx]
                $script:msgAlpha = 0
                $script:lastMsg = Get-Date
            }
        }
        if ($script:msgAlpha -lt 255) { $script:msgAlpha = [math]::Min(255, $script:msgAlpha + 17) }
        $script:form.Invalidate((New-Object System.Drawing.Rectangle([int]($script:W * 0.05), [int]($script:H * 0.15), [int]($script:W * 0.90), [int]($script:H * 0.64))))
    })

    $form.Add_Shown({
        $script:form.Activate()
        $script:shownAt = Get-Date
        if (-not $PreviewPath) { [System.Media.SystemSounds]::Asterisk.Play() }
        $script:timer.Start()
        if ($PreviewPath) {
            $script:cap = New-Object System.Windows.Forms.Timer
            $script:cap.Interval = 1200
            $script:cap.Add_Tick({
                $script:cap.Stop()
                $W = $script:W; $H = $script:H
                $raw = New-Object System.Drawing.Bitmap($W, $H)
                $script:form.DrawToBitmap($raw, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
                $pw = 1920; $ph = [int]($H * $pw / $W)
                $out = New-Object System.Drawing.Bitmap($pw, $ph)
                $g = [System.Drawing.Graphics]::FromImage($out)
                $g.InterpolationMode = 'HighQualityBicubic'
                $g.DrawImage($raw, 0, 0, $pw, $ph)
                $g.Dispose()
                $out.Save($PreviewPath, [System.Drawing.Imaging.ImageFormat]::Png)
                $script:form.Close()
            })
            $script:cap.Start()
        }
    })

    try {
        [void]$form.ShowDialog()
    } finally {
        $timer.Stop(); $timer.Dispose()
        foreach ($bf in $script:backdrops) { $bf.Close(); $bf.Dispose() }
        $form.Dispose()
        $script:bg.Dispose()
    }
    return $script:result
}

# 仅生成预览图，不影响正在运行的提醒 / preview only; does not touch a running reminder
if ($PreviewPath) {
    [void](Show-Break -Minutes $BreakMinutes)
    exit
}

# 立刻试一次（弹一次休息页面就退出）/ show one break right now, then exit
if ($TestNow) {
    [void](Show-Break -Minutes $BreakMinutes)
    exit
}

# 只允许运行一个实例 / single instance only
$created = $false
$mutex = New-Object System.Threading.Mutex($true, 'Local\BreakReminder', [ref]$created)
if (-not $created) { exit }

$wait = $WorkMinutes
while ($true) {
    $until = (Get-Date).AddMinutes($wait)
    while ((Get-Date) -lt $until) { Start-Sleep -Seconds 2 }
    $r = Show-Break -Minutes $BreakMinutes
    if ($r -eq 'snooze') { $wait = $SnoozeMinutes } else { $wait = $WorkMinutes }
}
