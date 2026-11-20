# 休息提醒闹钟 ⏰

[English](README.md) · **简体中文** · [Español](README.es.md)

一个温柔的全屏闹钟，提醒你好好休息。每工作 30 分钟，它会盖满整个屏幕，给你一个 5 分钟的倒计时、
一条健康小提示和一句鼓励的名言。免费、开源，仅支持 Windows，一条命令就能装好。

![休息提醒预览](preview-zh.png)

## 我为什么做这个

我每天对着电脑的时间特别长，一忙起来就停不下来。

时间一久，身体就开始抗议了：肩膀酸得不行，眼睛又干又痛，手也容易得鼠标手。整个人的状态都不太好。

后来我发现一件事：在室内闷头干一阵之后，哪怕只是走出去透口气、伸展一下身体，人恢复得特别快，就像把电量充回来了一样。这样工作反而能撑得更久，不用硬扛。

可我自己老是忘。屏幕角落那种小通知，我看都不看就划走了。所以我做了这个：到点就铺满整个屏幕，让我真的停下来，再配上一句暖心的话。

现在我自己天天在用。做出来了，也想分享给你，希望也能帮到你。

## 休息为什么对你好

每半小时停下来 5 分钟，是个小习惯，却有实实在在的好处：

- **对眼睛好。** 眼科专业人士（例如美国验光协会）推荐"20-20-20 法则"：每 20 分钟，看一眼大约 6 米（20 英尺）外的东西，
  持续 20 秒。盯着屏幕时我们眨眼变少，眼睛容易疲劳。
- **对血液循环和身体好。** 世界卫生组织等机构建议减少长时间不间断的久坐。站起来走一走，
  能促进血液循环，也能放松颈椎、肩膀和腰背。
- **对大脑好。** 短暂的休息能让你更专注、更有灵感，也能缓解压力。深呼吸几次、喝点水、看看窗外吧。

*以上是一般性的健康常识，不构成医疗建议。*

## 免费下载

它**完全免费**，使用 MIT 许可证开源。不用注册账号，没有广告，也不收集任何数据。

1. 在本页面点击绿色的 **Code** 按钮，再点 **Download ZIP**。
2. 在下载好的压缩包上右键，选择 **全部解压缩**。

（如果你会用 git：`git clone https://github.com/yongxincoco0308/break-reminder.git`）

## 怎么启动

需要 Windows 10 或 11，不用再安装别的东西。

1. 在文件资源管理器里打开解压出来的文件夹。
2. 点一下文件夹顶部的地址栏，输入 `powershell`，按 **回车**。会弹出一个蓝色窗口。
3. 把下面任意一行复制进去，按 **回车**。选一种语言：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Language zh
```

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Language en
```

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Language es
```

这样就好了。提醒会在后台安静运行，而且**每次登录 Windows 都会自动启动**。第一次休息会在 30 分钟后出现。

想马上看看效果？运行下面这条（只弹一次休息页面，然后退出）：

```powershell
powershell -ExecutionPolicy Bypass -File .\break-reminder.ps1 -TestNow -Language zh
```

如果不指定语言，它会跟随你的 Windows 显示语言（中文、西班牙语，其他一律英文）。

## 怎么暂停

照上面的第 1、2 步，在文件夹里重新打开 PowerShell，然后：

| 我想要…… | 运行这条 |
|---|---|
| **先暂停一下**（下次登录会自动恢复） | `powershell -ExecutionPolicy Bypass -File .\pause.ps1` |
| **一直暂停，直到我说恢复**（也不再自动启动） | `powershell -ExecutionPolicy Bypass -File .\pause.ps1 -Disable` |
| **恢复** | `powershell -ExecutionPolicy Bypass -File .\resume.ps1` |

只想跳过某一次休息：在休息页面按 **Esc**，或点 **跳过本次休息**。
点 **稍后 5 分钟再提醒**，可以延后五分钟。

## 怎么彻底删除

1. 在文件夹里打开 PowerShell，运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

2. 删除这个文件夹。电脑上不会留下别的东西。

*更喜欢点鼠标？* 在开始菜单里打开 **任务计划程序**，在"任务计划程序库"里找到 **BreakReminder**，
右键选择 **结束**、**禁用** 或 **删除**。

## 设置

在安装命令后面加参数就行。比如，工作 45 分钟、休息 10 分钟、使用西班牙语：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Language es -WorkMinutes 45 -BreakMinutes 10
```

| 参数 | 含义 | 默认值 |
|---|---|---|
| `-Language` | `zh`（中文）、`en`（英文）或 `es`（西班牙语） | 你的 Windows 语言 |
| `-SecondLanguage` | 名言再显示第二种语言（比如 `en`） | 无 |
| `-WorkMinutes` | 两次休息之间的工作分钟数 | 30 |
| `-BreakMinutes` | 休息多少分钟 | 5 |
| `-SnoozeMinutes` | 点"稍后再提醒"延后多少分钟 | 5 |

重新运行 `install.ps1` 会直接替换之前的设置。

## 关于名言

内置 50 条思想家、作家和诗人的名言（老子、孔子、塞涅卡、马可·奥勒留、曼德拉、海伦·凯勒、里尔克、小熊维尼等），
有中文、英文、西班牙语三个版本。每 40 秒换一条，重启后接着上次的位置往下播。想加自己的？编辑 `quotes.json` 即可。

西方名言的英文原文对照 Wikiquote 核对过。不同语言之间的翻译是我自己翻译的，仅供参考，如发现错误，欢迎提 issue。

## 隐私

它完全离线运行，不收集也不上传任何东西。它只会在 `%LOCALAPPDATA%\BreakReminder` 里保存一个很小的文件，
记录上一条播放到第几条名言（运行 `uninstall.ps1` 时会一并清除）。

## 许可证

代码使用 [MIT](LICENSE) 许可证。名言的版权归原作者所有。
