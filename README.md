# Break Reminder ⏰

**A gentle full-screen alarm clock that makes you take a break.** Windows and Mac · Free & open source · English / 中文 / Español

**一个温柔的全屏休息闹钟，提醒你好好休息。** 支持 Windows 和 Mac · 免费开源 · 英文 / 中文 / 西班牙语

**Un reloj despertador amable, a pantalla completa, que te recuerda descansar.** Windows y Mac · Gratis y de código abierto

👇 Click your language below. 点下面的语言展开。 Haz clic en tu idioma.

<details open>
<summary><b>English</b></summary>

<br>

![Break Reminder preview](preview-en.png)

Every 30 minutes it covers your screen with a 5-minute countdown, a short health tip, and an encouraging quote.
You can switch the language at any time with one click.

## Why I made this

I spend a lot of hours at my computer, and when I'm busy I just don't stop.

After a while my body starts complaining: my shoulders ache, my eyes get dry and sore, and my hand gets that mouse-hand strain. Overall I just feel worn down.

What I noticed is that after a stretch of working indoors, stepping outside for some fresh air and a bit of stretching recharges me way more than pushing through. It helps me keep going for the long haul instead of burning out.

The problem is, I always forget. A tiny notification in the corner of the screen? I swipe it away without even looking. So I built something that takes over the whole screen when it's time, makes me actually stop, and says something kind while it does.

I use it every day now, and I'm sharing it in case it helps you too.

## Why taking breaks is good for you

A five-minute pause every half hour is a small habit with real benefits:

- **Your eyes.** Eye-care professionals (for example the American Optometric Association) recommend the "20-20-20 rule": every 20 minutes, look at something about 6 metres (20 feet) away for 20 seconds. Staring at a screen makes us blink less and strains our eyes.
- **Your blood flow and body.** Health organisations such as the WHO advise limiting long, unbroken periods of sitting. Standing up and walking around gets your circulation going and relaxes your neck, shoulders and back.
- **Your mind.** Short breaks help you stay focused and creative, and ease stress. Take a few deep breaths, drink some water, look out of the window.

*This is general wellness information, not medical advice.*

## Free download

It is **100% free** and open source (MIT license). No account, no ads, no tracking.

1. On this page, click the green **Code** button, then **Download ZIP**.
2. Right-click the downloaded ZIP and choose **Extract All** (on a Mac, just double-click it).

## Get started on Windows

You don't need to type any commands, and nothing else needs to be installed.

1. Open the extracted folder and **double-click `Break Reminder (Windows).bat`**.
   - Windows may show a blue "Windows protected your PC" window, or ask "Do you want to run this file?". Click **More info → Run anyway** (or **Run**). This appears for any file from the internet that isn't digitally signed. The scripts are plain text, so you can open and read them first.
2. A small window opens. Click **Start the reminder**. That's it.

It now runs quietly in the background and **starts by itself every time you log in to Windows**. The first break appears after 30 minutes. Want to see it right away? Click **Try it now**.

## Get started on Mac (beta)

1. **Install Python once** (free): download the macOS installer from https://www.python.org/downloads/macos/, open it and click through. It includes what this app needs.
2. Open the extracted folder and **double-click `Break Reminder (Mac).command`**. The first time, macOS may say it can't be opened because it is from an unidentified developer. Then **right-click the file → Open → Open**.
3. A menu appears. Choose **Start / apply settings** and answer the two questions.

This version is a **beta**: the look and the logic were tested, but the start-at-login part has not yet been tested on a real Mac, so please open an issue if something doesn't work. A small Python icon may show in the Dock while it runs, and the full-screen page covers your main display only.

## Change the language

You don't have to decide when you install. On the break screen, click **中文 · English · Español** in the **top-right corner**. The page switches instantly, and your choice is remembered for next time. On Windows you can also pick the language in the control panel. By default it follows your computer's language.

## Pause, resume, delete

Open the same file again (`Break Reminder (Windows).bat` or `Break Reminder (Mac).command`):

| I want to… | On Windows (control panel) | On Mac (menu) |
|---|---|---|
| **Pause for now** (comes back at your next login) | **Pause** | **Pause** |
| **Pause until I say so** | tick *Also don't start at login*, then **Pause** | **Pause until I resume** |
| **Resume** | **Resume** | **Resume** |
| **Check that it's running** | the status bar at the top | **Is it running?** |
| **Delete completely** | **Uninstall**, then delete the folder | **Uninstall**, then delete the folder |

To skip a single break, click **Skip this break** on the break screen (or press **Esc**). **Remind me in 5 min** postpones it by five minutes.

Always click **Uninstall** *before* deleting the folder. Otherwise the start-at-login entry stays behind.

## Settings

In the Windows control panel (or the Mac menu) you can change how many minutes you work between breaks (default 30) and how long each break lasts (default 5), then click **Apply settings**.

<details>
<summary>For advanced users: command line</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -WorkMinutes 45 -BreakMinutes 10 -SnoozeMinutes 5
```

On Mac: `bash macos/install.sh --work 45 --break 10 --snooze 5`.
Extra options: `-Language en|zh|es` sets the starting language; `-SecondLanguage` also shows each quote in a second language. Pause / resume / uninstall scripts: `pause.ps1`, `resume.ps1`, `uninstall.ps1` (Windows) and `pause.sh`, `resume.sh`, `uninstall.sh`, `status.sh` (Mac).

</details>

## The quotes

There are 50 quotes, and each one is shown with its source (author and work):

- 20 from Chinese classics and poetry (Laozi, Confucius, Tao Yuanming, Li Bai and more)
- 14 from Western writers (Seneca, Marcus Aurelius, Mandela, Rilke, Winnie-the-Pooh and more)
- 14 from Spanish-language writers (Machado, Cervantes, Martí, Neruda and more)
- 2 short messages from a fortune cookie

Every quote is available in Chinese, English and Spanish. They rotate every 40 seconds and carry on where they left off after a restart. Edit `quotes.json` to add your own.

The wording and sources of the Western quotes were checked against Wikiquote. For the Chinese and Spanish-language quotes I checked as many sources as I could, but not every one, and the translations between languages are my own and meant as a friendly guide. Please open an issue if you spot a mistake.

## Privacy

It works fully offline. It collects nothing and sends nothing. The only things it saves are two tiny files (the number of the last quote shown, and your chosen language) in `%LOCALAPPDATA%\BreakReminder` on Windows, or `~/Library/Application Support/BreakReminder` on Mac. **Uninstall** removes them.

</details>

<details>
<summary><b>简体中文</b></summary>

<br>

![休息提醒预览](preview-zh.png)

每工作 30 分钟，它会盖满整个屏幕，给你一个 5 分钟的倒计时、一条健康小提示和一句鼓励的名言。随时点一下就能切换语言。

## 我为什么做这个

我每天对着电脑的时间特别长，一忙起来就停不下来。

时间一久，身体就开始抗议了：肩膀酸得不行，眼睛又干又痛，手也容易得鼠标手，整个人的状态都不太好。

后来我发现，在室内闷头干一阵之后，哪怕只是走到室外呼吸点新鲜空气、做做伸展，人恢复得特别快，像是把电量充回来了一样。这样工作反而能撑得更久，不用硬扛。

可我自己老是忘。屏幕角落那种小通知，我看都不看就划走了。所以我做了这个：到点就铺满整个屏幕，让我真的停下来，再配上一句暖心的话。

现在我自己天天在用。做出来了，也想分享给你，希望也能帮到你。

## 休息为什么对你好

每半小时停下来 5 分钟，是个小习惯，却有实实在在的好处：

- **对眼睛好。** 眼科专业人士（例如美国验光协会）推荐"20-20-20 法则"：每 20 分钟，看一眼大约 6 米（20 英尺）外的东西，持续 20 秒。盯着屏幕时我们眨眼变少，眼睛容易疲劳。
- **对血液循环和身体好。** 世界卫生组织等机构建议减少长时间不间断的久坐。站起来走一走，能促进血液循环，也能放松颈椎、肩膀和腰背。
- **对大脑好。** 短暂的休息能让你更专注、更有灵感，也能缓解压力。深呼吸几次、喝点水、看看窗外吧。

*以上是一般性的健康常识，不构成医疗建议。*

## 免费下载

它**完全免费**，使用 MIT 许可证开源。不用注册账号，没有广告，也不收集任何数据。

1. 在本页面点击绿色的 **Code** 按钮，再点 **Download ZIP**。
2. 在下载好的压缩包上右键，选择 **全部解压缩**（Mac 上直接双击即可）。

## 在 Windows 上开始用

不用输入任何命令，也不用再安装别的东西。

1. 打开解压出来的文件夹，**双击 `Break Reminder (Windows).bat`**。
   - Windows 可能会弹出蓝色的"Windows 已保护你的电脑"窗口，或者问你"是否要运行此文件"。点 **更多信息 → 仍要运行**（或者 **运行**）。任何从网上下载、没有数字签名的文件都会这样提示。这些脚本都是纯文本，你可以先打开看看。
2. 会打开一个小窗口。点 **开始提醒**，就好了。

它会在后台安静运行，而且**每次登录 Windows 都会自动启动**。第一次休息会在 30 分钟后出现。想马上看看效果？点 **立刻试一下**。

## 在 Mac 上开始用（测试版）

1. **先安装一次 Python**（免费）：到 https://www.python.org/downloads/macos/ 下载 macOS 安装包，打开后一路点下一步。它自带这个程序需要的东西。
2. 打开解压出来的文件夹，**双击 `Break Reminder (Mac).command`**。第一次 macOS 可能会说"无法打开，因为来自身份不明的开发者"，这时**右键点这个文件 → 打开 → 打开**。
3. 会弹出一个菜单。选 **开始 / 应用设置**，回答两个问题就行。

这个版本是**测试版**：画面和程序逻辑都测试过，但"登录时自动启动"这一部分还没有在真正的 Mac 上测试过，如果有问题，欢迎提 issue。运行时 Dock 里可能会出现一个小小的 Python 图标，全屏页面只会盖住主显示器。

## 切换语言

安装时不用先决定语言。在休息页面的**右上角**点 **中文 · English · Español**，整页立刻换成对应的语言，下次会记住你的选择。Windows 上也可以在控制面板里选语言。默认跟随你电脑的语言。

## 暂停、恢复、删除

再次打开同一个文件（`Break Reminder (Windows).bat` 或 `Break Reminder (Mac).command`）：

| 我想要…… | Windows（控制面板） | Mac（菜单） |
|---|---|---|
| **先暂停一下**（下次登录会自动恢复） | **暂停** | **暂停** |
| **一直暂停，直到我说恢复** | 勾选 *同时不要开机自启*，再点 **暂停** | **一直暂停** |
| **恢复** | **恢复** | **恢复** |
| **确认它在运行** | 窗口最上面的状态栏 | **它在运行吗？** |
| **彻底删除** | 点 **卸载**，然后删除文件夹 | 选 **卸载**，然后删除文件夹 |

只想跳过某一次休息：在休息页面点 **跳过本次休息**（或按 **Esc**）。点 **稍后 5 分钟再提醒**，可以延后五分钟。

删除时记得**先点"卸载"，再删文件夹**，否则开机自启的记录会留在电脑里。

## 设置

在 Windows 控制面板（或 Mac 菜单）里，可以改两次休息之间工作多少分钟（默认 30）、每次休息多少分钟（默认 5），再点 **应用设置**。

<details>
<summary>进阶：命令行用法</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -WorkMinutes 45 -BreakMinutes 10 -SnoozeMinutes 5
```

Mac 上：`bash macos/install.sh --work 45 --break 10 --snooze 5`。
其他参数：`-Language en|zh|es` 设置初始语言；`-SecondLanguage` 让每句名言再显示第二种语言。暂停、恢复、卸载的脚本：`pause.ps1`、`resume.ps1`、`uninstall.ps1`（Windows），`pause.sh`、`resume.sh`、`uninstall.sh`、`status.sh`（Mac）。

</details>

## 关于名言

内置 50 条名言，每一条都标明了出处（作者和作品）：

- 20 条来自中国古籍和诗词（老子、孔子、陶渊明、李白等）
- 14 条来自西方作家（塞涅卡、马可·奥勒留、曼德拉、里尔克、小熊维尼等）
- 14 条来自西班牙语作家（马查多、塞万提斯、马蒂、聂鲁达等）
- 2 条来自幸运饼干的小话

每一条都有中文、英文、西班牙语三个版本。每 40 秒换一条，重启后接着上次的位置往下播。想加自己的？编辑 `quotes.json` 即可。

西方名言的原文和出处都对照 Wikiquote 核对过。中国古籍和西班牙语作家的出处，我尽量核对了，但不是每一条都核对过。不同语言之间的翻译是我自己翻译的，仅供参考。如发现错误，欢迎提 issue。

## 隐私

它完全离线运行，不收集也不上传任何东西。它只会保存两个很小的文件（上一次播放到第几条名言、你选的语言），Windows 上在 `%LOCALAPPDATA%\BreakReminder`，Mac 上在 `~/Library/Application Support/BreakReminder`。点 **卸载** 时会一并清除。

</details>

<details>
<summary><b>Español</b></summary>

<br>

![Vista previa de Break Reminder](preview-es.png)

Cada 30 minutos cubre tu pantalla con una cuenta atrás de 5 minutos, un consejo de salud y una cita que te anima. Puedes cambiar de idioma en cualquier momento con un clic.

## Por qué lo hice

Paso muchas horas frente al ordenador y, cuando estoy en plena faena, no paro.

Con el tiempo el cuerpo se queja: se me cargan los hombros, los ojos se me resecan y me duelen, y la mano se resiente por el ratón. En general, termino con el cuerpo molido.

Me he dado cuenta de que, después de un rato trabajando en interior, salir a respirar aire fresco y estirarme un poco me recarga las pilas mucho más que seguir a base de aguantar. Así puedo mantener el ritmo mucho más tiempo sin quemarme.

El problema es que siempre se me olvida. Una notificación diminuta en la esquina de la pantalla la descarto sin ni mirarla. Así que hice algo que, cuando toca, ocupa toda la pantalla, me obliga a parar de verdad y me dice algo bonito.

Ahora lo uso todos los días y lo comparto por si a ti también te sirve.

## Por qué descansar te hace bien

Una pausa de cinco minutos cada media hora es un hábito pequeño con beneficios reales:

- **Tus ojos.** Los profesionales del cuidado visual (por ejemplo, la Asociación Optométrica Americana) recomiendan la «regla 20-20-20»: cada 20 minutos, mira algo a unos 6 metros (20 pies) durante 20 segundos. Frente a la pantalla parpadeamos menos y los ojos se cansan.
- **Tu circulación y tu cuerpo.** Organismos de salud como la OMS aconsejan limitar los periodos largos sin interrupción sentado. Levantarte y caminar activa la circulación de la sangre y relaja el cuello, los hombros y la espalda.
- **Tu mente.** Las pausas cortas te ayudan a mantener la concentración y la creatividad, y alivian el estrés. Respira hondo unas veces, bebe agua, mira por la ventana.

*Esta es información general de bienestar, no un consejo médico.*

## Descarga gratuita

Es **100 % gratis** y de código abierto (licencia MIT). Sin cuenta, sin anuncios, sin rastreo.

1. En esta página, haz clic en el botón verde **Code** y luego en **Download ZIP**.
2. Haz clic derecho en el ZIP descargado y elige **Extraer todo** (en Mac, basta con hacer doble clic).

## Empezar en Windows

No hay que escribir ningún comando y no hace falta instalar nada más.

1. Abre la carpeta extraída y **haz doble clic en `Break Reminder (Windows).bat`**.
   - Windows puede mostrar una ventana azul «Windows protegió su PC» o preguntar «¿Quieres ejecutar este archivo?». Pulsa **Más información → Ejecutar de todas formas** (o **Ejecutar**). Aparece con cualquier archivo de internet que no esté firmado digitalmente. Los scripts son texto plano, así que puedes abrirlos y leerlos antes.
2. Se abre una ventana pequeña. Pulsa **Iniciar el recordatorio**. Ya está.

Ahora funciona en segundo plano y **se inicia solo cada vez que inicias sesión en Windows**. El primer descanso aparece a los 30 minutos. ¿Quieres verlo ya? Pulsa **Probar ahora**.

## Empezar en Mac (beta)

1. **Instala Python una sola vez** (gratis): descarga el instalador para macOS de https://www.python.org/downloads/macos/, ábrelo y ve pulsando siguiente. Incluye lo que necesita esta aplicación.
2. Abre la carpeta extraída y **haz doble clic en `Break Reminder (Mac).command`**. La primera vez, macOS puede decir que no se puede abrir porque es de un desarrollador no identificado. Entonces **clic derecho en el archivo → Abrir → Abrir**.
3. Aparece un menú. Elige **Iniciar / aplicar ajustes** y responde a las dos preguntas.

Esta versión es una **beta**: el aspecto y la lógica están probados, pero la parte de inicio automático todavía no se ha probado en un Mac real, así que abre un issue si algo no funciona. Mientras funciona puede aparecer un pequeño icono de Python en el Dock, y la pantalla completa solo cubre tu pantalla principal.

## Cambiar de idioma

No hace falta decidirlo al instalar. En la pantalla de descanso, haz clic en **中文 · English · Español** en la **esquina superior derecha**. La página cambia al instante y se recuerda tu elección. En Windows también puedes elegir el idioma en el panel de control. Por defecto usa el idioma de tu ordenador.

## Pausar, reanudar, eliminar

Abre otra vez el mismo archivo (`Break Reminder (Windows).bat` o `Break Reminder (Mac).command`):

| Quiero… | En Windows (panel de control) | En Mac (menú) |
|---|---|---|
| **Pausar por ahora** (vuelve en tu próximo inicio de sesión) | **Pausar** | **Pausar** |
| **Pausar hasta que yo diga** | marca *Tampoco al iniciar sesión* y pulsa **Pausar** | **Pausar hasta reanudar** |
| **Reanudar** | **Reanudar** | **Reanudar** |
| **Comprobar que funciona** | la barra de estado de arriba | **¿Funciona?** |
| **Eliminarlo por completo** | **Desinstalar** y luego borra la carpeta | **Desinstalar** y luego borra la carpeta |

Para saltarte un solo descanso, pulsa **Saltar este descanso** en la pantalla de descanso (o **Esc**). **Recuérdamelo en 5 min** lo aplaza cinco minutos.

Pulsa siempre **Desinstalar** *antes* de borrar la carpeta. Si no, la entrada de inicio automático se queda.

## Ajustes

En el panel de control de Windows (o en el menú de Mac) puedes cambiar los minutos de trabajo entre descansos (por defecto 30) y la duración de cada descanso (por defecto 5), y pulsar **Aplicar ajustes**.

<details>
<summary>Para usuarios avanzados: línea de comandos</summary>

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -WorkMinutes 45 -BreakMinutes 10 -SnoozeMinutes 5
```

En Mac: `bash macos/install.sh --work 45 --break 10 --snooze 5`.
Opciones extra: `-Language en|zh|es` fija el idioma inicial; `-SecondLanguage` muestra además cada cita en un segundo idioma. Scripts para pausar / reanudar / desinstalar: `pause.ps1`, `resume.ps1`, `uninstall.ps1` (Windows) y `pause.sh`, `resume.sh`, `uninstall.sh`, `status.sh` (Mac).

</details>

## Las citas

Incluye 50 citas, y cada una muestra su fuente (autor y obra):

- 20 de clásicos y poesía chinos (Laozi, Confucio, Tao Yuanming, Li Bai y más)
- 14 de escritores occidentales (Séneca, Marco Aurelio, Mandela, Rilke, Winnie the Pooh y más)
- 14 de escritores en español (Machado, Cervantes, Martí, Neruda y más)
- 2 mensajes cortos de una galleta de la fortuna

Todas están en chino, inglés y español. Cambian cada 40 segundos y, tras reiniciar, continúan donde se quedaron. Edita `quotes.json` para añadir las tuyas.

El texto y las fuentes de las citas occidentales se comprobaron con Wikiquote. En las citas chinas y de escritores en español comprobé las fuentes que pude, pero no todas, y las traducciones entre idiomas son mías y sirven de guía. Si ves algún error, abre un issue.

## Privacidad

Funciona sin conexión. No recopila ni envía nada. Solo guarda dos archivos diminutos (el número de la última cita mostrada y tu idioma elegido) en `%LOCALAPPDATA%\BreakReminder` en Windows, o en `~/Library/Application Support/BreakReminder` en Mac. **Desinstalar** los borra.

</details>

---

**License / 许可证 / Licencia:** code under [MIT](LICENSE). The quotes belong to their original authors. 名言版权归原作者所有。Las citas pertenecen a sus autores.
