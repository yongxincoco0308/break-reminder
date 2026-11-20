#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Break Reminder for macOS  (中文 / English / Español)
每工作 N 分钟，全屏弹出一个可爱的闹钟倒计时页面，附带健康小提示和名人名言。
Every N minutes a cute full-screen alarm clock counts down a break, with a health tip and a quote.
Cada N minutos aparece un reloj despertador a pantalla completa con una cuenta atrás, un consejo y una cita.

Only needs Python 3 with tkinter (Tk 8.6). No other packages.
Options:
  --language zh|en|es        default: your system language
  --second-language zh|en|es show the quote in a second language too
  --work 30 --break 5 --snooze 5     (minutes)
  --test-now                 show one break right now, then exit
"""
import argparse
import json
import locale
import math
import os
import random
import re
import socket
import subprocess
import sys
import time
import tkinter as tk
import tkinter.font as tkfont

HERE = os.path.dirname(os.path.abspath(__file__))
QUOTES_FILE = os.path.join(os.path.dirname(HERE), "quotes.json")   # shared with the Windows version
if sys.platform == "darwin":
    STATE_DIR = os.path.join(os.path.expanduser("~"), "Library", "Application Support", "BreakReminder")
else:
    STATE_DIR = os.path.join(os.path.expanduser("~"), ".break-reminder")
LANGS = ("zh", "en", "es")
SETTINGS_FILE = os.path.join(STATE_DIR, "settings.json")      # remembers the language the user clicked


def get_saved_language():
    try:
        with open(SETTINGS_FILE, "r", encoding="utf-8-sig") as f:
            lang = json.load(f).get("language", "")
        return lang if lang in LANGS else ""
    except Exception:
        return ""


def save_language(code):
    try:
        os.makedirs(STATE_DIR, exist_ok=True)
        with open(SETTINGS_FILE, "w", encoding="utf-8") as f:
            json.dump({"language": code}, f)
    except Exception:
        pass

STRINGS = {
    "zh": {
        "top": "辛苦啦，已经连续工作 {n} 分钟",
        "title": "休息 {n} 分钟吧！",
        "skip": "跳过本次休息",
        "snooze": "稍后 {n} 分钟再提醒",
        "hint": "按 Esc 或点按钮可随时关闭",
        "done_title": "休息好啦，继续加油吧",
        "done_sub": "你已经做得很棒了",
        "done_top": "下一次提醒在 {n} 分钟后",
        "done_btn": "开始下一个计时",
        "done_clock": "完成",
        "by": "—— ",
        "tips": [
            "休息一下对眼睛好：看看远处，让它们放松放松。",
            "站起来动一动，血液循环更顺畅，腿脚也会感谢你。",
            "放松颈椎、肩膀和腰背，久坐的僵硬会慢慢散开。",
            "让大脑歇一歇，回来之后会更专注、更有灵感。",
            "深呼吸几次，新鲜空气能让你更平静、更清醒。",
            "喝点水吧，身体补足水分，状态会更好。",
            "适时休息能缓解压力，让精力一整天都更稳定。",
        ],
    },
    "en": {
        "top": "Nice work! You've been working for {n} minutes",
        "title": "Time for a {n}-minute break!",
        "skip": "Skip this break",
        "snooze": "Remind me in {n} min",
        "hint": "Press Esc or click a button to close anytime",
        "done_title": "Break's over. You've got this!",
        "done_sub": "You're doing great",
        "done_top": "Next reminder in {n} minutes",
        "done_btn": "Start next timer",
        "done_clock": "Done",
        "by": "— ",
        "tips": [
            "A short break is good for your eyes: look into the distance and let them relax.",
            "Standing up gets your blood flowing again, and your legs will thank you.",
            "Loosen up your neck, shoulders and back. Sitting stiffness fades fast.",
            "Rest your mind now, and you will come back more focused and creative.",
            "Take a few deep breaths. Fresh air helps you feel calm and clear.",
            "Drink some water. Your body works better when it is well hydrated.",
            "Regular breaks ease stress and keep your energy steady all day.",
        ],
    },
    "es": {
        "top": "Buen trabajo, llevas {n} minutos trabajando",
        "title": "¡Hora de un descanso de {n} minutos!",
        "skip": "Saltar este descanso",
        "snooze": "Recuérdamelo en {n} min",
        "hint": "Pulsa Esc o un botón para cerrar cuando quieras",
        "done_title": "¡Descanso terminado! ¡Tú puedes!",
        "done_sub": "Lo estás haciendo genial",
        "done_top": "Próximo aviso en {n} minutos",
        "done_btn": "Empezar el siguiente ciclo",
        "done_clock": "Listo",
        "by": "— ",
        "tips": [
            "Un descanso corto es bueno para tus ojos: mira a lo lejos y deja que se relajen.",
            "Ponerte de pie reactiva la circulación de la sangre, y tus piernas te lo agradecerán.",
            "Afloja el cuello, los hombros y la espalda. La rigidez de estar sentado se va rápido.",
            "Descansa la mente ahora y volverás con más concentración y creatividad.",
            "Respira hondo unas cuantas veces. El aire fresco te ayuda a sentirte tranquilo y despejado.",
            "Bebe un poco de agua. Tu cuerpo funciona mejor bien hidratado.",
            "Las pausas regulares alivian el estrés y mantienen tu energía estable todo el día.",
        ],
    },
}

FALLBACK_QUOTE = {"zh": "休息一下，再出发。", "en": "Rest a little, then go on.", "es": "Descansa un poco y sigue.",
                  "zh_by": "小提醒", "en_by": "Break Reminder", "es_by": "Break Reminder"}

# ---- colours (same neutral palette as the Windows version) ----
BG_TOP, BG_BOTTOM = (255, 249, 236), (224, 240, 235)
WHITE = (255, 255, 255)
COCOA = (84, 66, 60)
BODY, BODY_D = (96, 186, 176), (62, 148, 142)
BUTTER, BUTTER_D = (255, 214, 118), (240, 170, 70)
FACE, SECTOR = (255, 253, 250), (196, 234, 226)
RING = (130, 205, 195)


def hexc(c):
    return "#%02x%02x%02x" % tuple(int(max(0, min(255, v))) for v in c)


def blend(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def fmt_n(text, n):
    n = int(n) if float(n) == int(n) else n
    return text.replace("{n}", str(n))


def system_language():
    try:
        if sys.platform == "darwin":
            out = subprocess.run(["defaults", "read", "-g", "AppleLanguages"], capture_output=True,
                                 text=True, timeout=5).stdout
            m = re.search(r'"?([A-Za-z]{2})[-_"]', out)
            if m:
                return m.group(1).lower()
        loc = locale.getdefaultlocale()[0] or ""
        return loc[:2].lower()
    except Exception:
        return "en"


def pick_font(root, candidates, fallback="TkDefaultFont"):
    have = set(tkfont.families(root))
    for f in candidates:
        if f in have:
            return f
    return fallback


def play_sound(root, name="Glass"):
    path = "/System/Library/Sounds/%s.aiff" % name
    try:
        if sys.platform == "darwin" and os.path.exists(path):
            subprocess.Popen(["afplay", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            root.bell()
    except Exception:
        pass


class BreakScreen:
    def __init__(self, app, minutes, on_close, preview_finished=False, preview=False):
        if not preview:        # the language may have been changed on the last break screen
            saved = get_saved_language()
            if saved and saved != app.lang:
                app.set_language(saved)
        self.app, self.S = app, app.S
        self.minutes = minutes
        self.on_close = on_close
        self.preview = preview
        self.result = "done"
        self.finished = False
        self.closed = False
        self.frac = 1.0
        self.wig = 0.0
        self.total = float(minutes) * 60.0
        self.end = time.time() + self.total
        if preview:
            self.end = time.time() + 222            # shows 03:42
        if preview_finished:
            self.end = time.time() - 1
        self.hover = -1
        self.quote = app.next_quote()
        tips = self.S["tips"]
        self.tip_idx = 0 if preview else random.randrange(len(tips))
        self.tip = tips[self.tip_idx]
        self.fade = 1.0 if preview else 0.0
        self.last_msg = time.time()
        self.shown_at = time.time()
        self.title = fmt_n(self.S["title"], minutes)
        self.top_text = fmt_n(self.S["top"], app.args.work)
        self.center_text = ""
        self.btns = []

        w = tk.Toplevel(app.root)
        self.win = w
        w.title("Break Reminder")
        w.configure(bg=hexc(BG_TOP))
        w.protocol("WM_DELETE_WINDOW", lambda: None)
        w.attributes("-topmost", True)
        try:
            w.attributes("-fullscreen", True)
        except tk.TclError:
            w.geometry("%dx%d+0+0" % (w.winfo_screenwidth(), w.winfo_screenheight()))
        self.canvas = tk.Canvas(w, highlightthickness=0, bd=0, bg=hexc(BG_TOP))
        self.canvas.pack(fill="both", expand=True)
        w.update()
        self.W = max(self.canvas.winfo_width(), 400)
        self.H = max(self.canvas.winfo_height(), 300)
        self.make_fonts()
        self.draw_static()
        self.set_buttons()
        w.bind("<Escape>", self.on_escape)
        self.canvas.bind("<Motion>", self.on_motion)
        self.canvas.bind("<Button-1>", self.on_click)
        w.lift()
        w.focus_force()
        if not preview:
            play_sound(app.root, "Glass")
        self.tick()

    # ---------- fonts ----------
    def make_fonts(self):
        H, root = self.H, self.app.root
        ui = pick_font(root, ["PingFang SC", "Hiragino Sans GB", "Microsoft YaHei UI", "Noto Sans CJK SC",
                              "Helvetica Neue", "Segoe UI", "Arial"])
        serif = pick_font(root, ["Georgia", "Times New Roman", "Times"])

        def f(family, frac, weight="normal", slant="roman", underline=0):
            return tkfont.Font(root=root, family=family, size=-max(8, int(H * frac)), weight=weight,
                               slant=slant, underline=underline)
        self.fonts = {
            "top": f(ui, 0.021), "title": f(ui, 0.052, "bold"), "sub": f(ui, 0.022),
            "count": f(ui, 0.14 * 0.40, "bold"),
            "qmain": None,
            "qsec": f(serif, 0.022, slant="italic"), "qby": f(ui, 0.017),
            "btn": f(ui, 0.028, "bold"), "link": f(ui, 0.018), "link_h": f(ui, 0.018, underline=1),
            "hint": f(ui, 0.017),
        }
        self.ui_family, self.serif_family = ui, serif
        self.fonts["qmain"] = self.make_qmain()

    def make_qmain(self):
        # main quote font: CJK sans for Chinese, serif for English / Spanish
        px = -max(8, int(self.H * (0.033 if self.app.lang == "zh" else 0.030)))
        family = self.ui_family if self.app.lang == "zh" else self.serif_family
        return tkfont.Font(root=self.app.root, family=family, size=px, weight="bold")

    # ---------- background ----------
    def bg_at(self, y):
        t = max(0.0, min(1.0, y / float(self.H)))
        return blend(BG_TOP, BG_BOTTOM, t)

    def draw_static(self):
        c, W, H = self.canvas, self.W, self.H
        c.delete("bg")
        steps = 160
        for i in range(steps):
            y0, y1 = int(H * i / steps), int(H * (i + 1) / steps) + 1
            c.create_rectangle(0, y0, W, y1, fill=hexc(self.bg_at((y0 + y1) / 2.0)), outline="", tags="bg")
        # soft glow behind the clock
        cx, cy = W / 2.0, H * 0.42
        # drawn as thin horizontal slices so the glow follows the gradient behind it (no visible rings)
        rings, band = 16, max(3, int(H / 300))
        for k in range(rings):
            r = H * 0.44 * (1 - k / float(rings))
            t = 0.02 + 0.40 * k / rings
            y = cy - r
            while y < cy + r:
                dy = (y + band / 2.0) - cy
                half = math.sqrt(max(0.0, r * r - dy * dy))
                c.create_rectangle(cx - half, y, cx + half, y + band + 1,
                                   fill=hexc(blend(self.bg_at(y), WHITE, t)), outline="", tags="bg")
                y += band
        # polka dots
        step, dr, row, y = H * 0.085, H * 0.0075, 0, H * 0.085 / 2
        while y < H:
            x = 0 if row % 2 == 0 else step / 2
            while x < W:
                c.create_oval(x - dr, y - dr, x + dr, y + dr, fill=hexc(blend(self.bg_at(y), WHITE, 0.30)),
                              outline="", tags="bg")
                x += step
            y += step
            row += 1
        for (fx, fy, s) in ((0.09, 0.97, 0.075), (0.93, 0.95, 0.085), (0.90, 0.13, 0.05), (0.10, 0.11, 0.045)):
            self.cloud(W * fx, H * fy, H * s)
        for (fx, fy, s) in ((0.07, 0.24, 0.032), (0.93, 0.22, 0.030), (0.15, 0.62, 0.026), (0.86, 0.60, 0.028),
                            (0.22, 0.07, 0.022), (0.79, 0.06, 0.024), (0.05, 0.47, 0.020), (0.96, 0.44, 0.020)):
            self.poly(self.star_pts(W * fx, H * fy, H * s, H * s * 0.48, 5), (255, 224, 130))
        for (fx, fy, col) in ((0.12, 0.37, (255, 190, 140)), (0.89, 0.35, (150, 208, 200)), (0.19, 0.76, (200, 190, 240)),
                              (0.81, 0.78, (255, 190, 140)), (0.26, 0.30, (215, 190, 245)), (0.75, 0.29, (150, 208, 200))):
            self.poly(self.heart_pts(W * fx, H * fy, H * 0.0014), col)
        for (fx, fy) in ((0.20, 0.46), (0.80, 0.42), (0.09, 0.13), (0.91, 0.84), (0.06, 0.70), (0.95, 0.66),
                         (0.30, 0.90), (0.70, 0.92)):
            self.poly(self.star_pts(W * fx, H * fy, H * 0.018, H * 0.005, 4), (190, 230, 215))
        c.tag_lower("bg")

    def poly(self, pts, col):
        self.canvas.create_polygon(pts, fill=hexc(col), outline="", tags="bg")

    @staticmethod
    def star_pts(cx, cy, ro, ri, n):
        pts = []
        for i in range(2 * n):
            rad = ro if i % 2 == 0 else ri
            ang = math.radians(-90 + i * 180.0 / n)
            pts += [cx + rad * math.cos(ang), cy + rad * math.sin(ang)]
        return pts

    @staticmethod
    def heart_pts(cx, cy, s):
        pts = []
        for i in range(60):
            t = 2 * math.pi * i / 60
            hx = 16 * math.sin(t) ** 3
            hy = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
            pts += [cx + hx * s, cy - hy * s]
        return pts

    def cloud(self, x, y, s):
        c = self.canvas
        col = hexc(blend(self.bg_at(y), WHITE, 0.92))
        for (ox, oy, w, h) in ((-1.6, -0.5, 3.2, 1.0), (-1.1, -1.1, 1.5, 1.5), (-0.35, -1.6, 1.9, 1.9), (0.55, -1.0, 1.3, 1.3)):
            c.create_oval(x + ox * s, y + oy * s, x + (ox + w) * s, y + (oy + h) * s, fill=col, outline="", tags="bg")

    # ---------- buttons ----------
    def set_buttons(self):
        self._main_buttons()
        # language switch in the top-right corner: 中文 · English · Español (click = switch now, and remember)
        W, H = self.W, self.H
        chip_h, gap = H * 0.040, H * 0.008
        items = (("zh", "中文", 0.072), ("en", "English", 0.095), ("es", "Español", 0.095))
        total = sum(H * wf + gap for _, _, wf in items)
        x = W - H * 0.025 - total + gap
        for code, label, wf in items:
            cw = H * wf
            self.btns.append(dict(rect=(x, H * 0.022, x + cw, H * 0.022 + chip_h), text=label,
                                  action="lang:" + code, style="lang"))
            x += cw + gap

    def _main_buttons(self):
        W, H, S = self.W, self.H, self.S
        bh = H * 0.070
        if self.finished:
            bw, y = H * 0.44, H * 0.843
            self.btns = [dict(rect=((W - bw) / 2, y, (W + bw) / 2, y + bh), text=S["done_btn"], action="done", style="primary")]
        else:
            # nudge people towards "remind me later": big primary button vs. a faint "skip" link
            bw, y = H * 0.44, H * 0.843
            lw, lh = H * 0.30, H * 0.040
            self.btns = [
                dict(rect=((W - bw) / 2, y, (W + bw) / 2, y + bh), text=fmt_n(S["snooze"], self.app.args.snooze),
                     action="snooze", style="primary"),
                dict(rect=((W - lw) / 2, H * 0.919, (W + lw) / 2, H * 0.919 + lh), text=S["skip"], action="done", style="link"),
            ]

    def pill(self, x0, y0, x1, y1, fill):
        c, r = self.canvas, (y1 - y0) / 2.0
        kw = dict(fill=hexc(fill), outline="", tags="dyn")
        c.create_oval(x0, y0, x0 + 2 * r, y1, **kw)
        c.create_oval(x1 - 2 * r, y0, x1, y1, **kw)
        c.create_rectangle(x0 + r, y0, x1 - r, y1, **kw)

    # ---------- drawing the changing parts ----------
    def text(self, x, y, s, font, color, anchor="center", width=None, fade=None, justify="center"):
        f = self.fade if fade is None else fade
        col = blend(self.bg_at(y), color, f) if f < 1.0 else color
        kw = dict(text=s, font=font, fill=hexc(col), anchor=anchor, justify=justify, tags="dyn")
        if width:
            kw["width"] = int(width)
        return self.canvas.create_text(x, y, **kw)

    def draw_dynamic(self):
        c, W, H, F = self.canvas, self.W, self.H, self.fonts
        c.delete("dyn")
        cx = W / 2.0
        self.text(cx, H * 0.060, self.top_text, F["top"], (150, 125, 105), fade=1.0)
        self.text(cx, H * 0.122, self.title, F["title"], COCOA, fade=1.0)
        self.text(cx, H * 0.182, self.tip, F["sub"], (100, 140, 133), width=W * 0.8)
        self.draw_clock(cx, H * 0.42, H * 0.14)

        # quote (chosen language, optional second language) + source
        qw, y = W * 0.60, H * 0.635
        q, lang = self.quote, self.app.lang
        t = self.text(cx, y, self.app.qtext(q, lang), F["qmain"], COCOA, anchor="n", width=qw)
        y = c.bbox(t)[3] + H * 0.006
        if self.app.second:
            t = self.text(cx, y, self.app.qtext(q, self.app.second), F["qsec"], (125, 112, 100), anchor="n", width=qw)
            y = c.bbox(t)[3] + H * 0.010
        else:
            y += H * 0.008
        self.text(cx, y, self.S["by"] + self.app.qby(q, lang), F["qby"], (70, 160, 152), anchor="n", width=qw)

        for i, b in enumerate(self.btns):
            x0, y0, x1, y1 = b["rect"]
            hov = (i == self.hover)
            if b["style"] == "lang":
                cur = (b["action"] == "lang:" + self.app.lang)
                if cur:
                    self.pill(x0, y0, x1, y1, (205, 235, 228))
                col = (52, 140, 132) if cur else ((84, 66, 60) if hov else blend(self.bg_at(y0), (150, 130, 115), 0.75))
                self.text((x0 + x1) / 2, (y0 + y1) / 2, b["text"], F["link"], col, fade=1.0)
                continue
            if b["style"] == "link":
                col = (110, 95, 85) if hov else (150, 130, 115)
                self.text((x0 + x1) / 2, (y0 + y1) / 2, b["text"], F["link_h"] if hov else F["link"],
                          blend(self.bg_at(y0), col, 1.0 if hov else 0.62), fade=1.0)
                continue
            halo = blend(self.bg_at((y0 + y1) / 2), BODY, 0.22)
            self.pill(x0 - 7, y0 - 7, x1 + 7, y1 + 7, halo)
            self.pill(x0, y0, x1, y1, (122, 202, 192) if hov else BODY)
            self.text((x0 + x1) / 2, (y0 + y1) / 2, b["text"], F["btn"], WHITE, fade=1.0)
        self.text(cx, H * 0.978, self.S["hint"], F["hint"], blend(self.bg_at(H * 0.978), (140, 125, 110), 0.62), fade=1.0)

    def draw_clock(self, cx, cy, R):
        c, T = self.canvas, "dyn"

        def oval(x0, y0, x1, y1, **kw):
            return c.create_oval(x0, y0, x1, y1, tags=T, **kw)
        oval(cx - 0.95 * R, cy + 1.20 * R, cx + 0.95 * R, cy + 1.44 * R,
             fill=hexc(blend(self.bg_at(cy + 1.3 * R), (60, 90, 85), 0.14)), outline="")
        for sx in (-1, 1):
            c.create_line(cx + sx * 0.60 * R, cy + 0.80 * R, cx + sx * 0.84 * R, cy + 1.14 * R, width=R * 0.17,
                          capstyle="round", fill=hexc(BODY_D), tags=T)
        for sign in (-1, 1):
            ad = sign * (42 + self.wig)
            ar = math.radians(ad)
            bx, by, br = cx + 1.02 * R * math.sin(ar), cy - 1.02 * R * math.cos(ar), 0.36 * R
            head = math.degrees(math.atan2(math.cos(ar), math.sin(ar)))
            for rad, span in ((1.35, 64), (1.70, 48)):
                rr = rad * br
                c.create_arc(bx - rr, by - rr, bx + rr, by + rr, start=head - span / 2.0, extent=span, style="arc",
                             outline=hexc(RING), width=R * 0.045, tags=T)
            oval(bx - br, by - br, bx + br, by + br, fill=hexc(BUTTER), outline=hexc(BUTTER_D), width=R * 0.04)
            oval(bx - 0.45 * br, by - 0.55 * br, bx + 0.05 * br, by - 0.20 * br, fill="#fff6e0", outline="")
        c.create_line(cx, cy - 1.0 * R, cx, cy - 1.24 * R, width=R * 0.07, capstyle="round", fill=hexc(BODY_D), tags=T)
        oval(cx - 0.10 * R, cy - 1.34 * R, cx + 0.10 * R, cy - 1.14 * R, fill=hexc(BODY_D), outline="")
        oval(cx - R, cy - R, cx + R, cy + R, fill=hexc(BODY), outline="")
        fr = 0.84 * R
        oval(cx - fr, cy - fr, cx + fr, cy + fr, fill=hexc(FACE), outline="")
        sr = 0.80 * R
        if self.frac > 0.002:
            if self.frac >= 0.999:
                oval(cx - sr, cy - sr, cx + sr, cy + sr, fill=hexc(SECTOR), outline="")
            else:
                c.create_arc(cx - sr, cy - sr, cx + sr, cy + sr, start=90, extent=-360 * self.frac, style="pieslice",
                             fill=hexc(SECTOR), outline="", tags=T)
        for i in range(12):
            ta = math.radians(i * 30 - 90)
            tr = 0.040 * R if i % 3 == 0 else 0.024 * R
            tx, ty = cx + 0.72 * R * math.cos(ta), cy + 0.72 * R * math.sin(ta)
            oval(tx - tr, ty - tr, tx + tr, ty + tr, fill=hexc(BODY), outline="")
        for sign in (-1, 1):
            ex, ey = cx + sign * 0.25 * R, cy - 0.38 * R
            if self.finished:
                c.create_arc(ex - 0.075 * R, ey - 0.06 * R, ex + 0.075 * R, ey + 0.06 * R, start=20, extent=140,
                             style="arc", outline=hexc(COCOA), width=R * 0.045, tags=T)
            else:
                oval(ex - 0.06 * R, ey - 0.06 * R, ex + 0.06 * R, ey + 0.06 * R, fill=hexc(COCOA), outline="")
                oval(ex - 0.025 * R, ey - 0.045 * R, ex + 0.015 * R, ey - 0.005 * R, fill="#ffffff", outline="")
            bxc = cx + sign * 0.47 * R
            oval(bxc - 0.10 * R, cy - 0.28 * R, bxc + 0.10 * R, cy - 0.17 * R,
                 fill=hexc(blend(FACE, (255, 190, 150), 0.55)), outline="")
        c.create_arc(cx - 0.09 * R, cy - 0.40 * R, cx + 0.09 * R, cy - 0.26 * R, start=200, extent=140, style="arc",
                     outline=hexc(COCOA), width=R * 0.04, tags=T)
        c.create_text(cx, cy + 0.32 * R, text=self.center_text, font=self.fonts["count"], fill=hexc(COCOA), tags=T)

    # ---------- behaviour ----------
    def tick(self):
        if self.closed:
            return
        S = self.S
        left = self.end - time.time()
        if left <= 0:
            if not self.finished:
                self.finished = True
                self.frac, self.wig = 1.0, 0.0
                self.center_text = S["done_clock"]
                self.title = S["done_title"]
                self.tip = S["done_sub"]
                self.top_text = fmt_n(S["done_top"], self.app.args.work)
                self.hover = -1
                self.set_buttons()
                if not self.preview:
                    play_sound(self.app.root, "Glass")
        else:
            self.frac = min(1.0, left / self.total)
            self.center_text = "%02d:%02d" % (int(left // 60), int(left % 60))
            now = time.time()
            ms = int((now - int(now)) * 1000)
            self.wig = math.sin(ms / 1000.0 * 6 * math.pi) * 7 if (not self.preview and int(now) % 5 == 0) else 0.0
            if not self.preview and now - self.last_msg >= 40:          # next quote + tip every 40 s
                self.quote = self.app.next_quote()
                self.tip_idx = (self.tip_idx + 1) % len(S["tips"])
                self.tip = S["tips"][self.tip_idx]
                self.fade, self.last_msg = 0.0, now
        if self.fade < 1.0:
            self.fade = min(1.0, self.fade + 0.07)
        self.draw_dynamic()
        self.win.after(200, self.tick)

    def on_motion(self, e):
        idx = -1
        for i, b in enumerate(self.btns):
            x0, y0, x1, y1 = b["rect"]
            if x0 <= e.x <= x1 and y0 <= e.y <= y1:
                idx = i
        if idx != self.hover:
            self.hover = idx
            self.canvas.config(cursor="hand2" if idx >= 0 else "")

    def update_texts(self):
        S = self.S
        if self.finished:
            self.center_text, self.title, self.tip = S["done_clock"], S["done_title"], S["done_sub"]
            self.top_text = fmt_n(S["done_top"], self.app.args.work)
        else:
            self.title = fmt_n(S["title"], self.minutes)
            self.top_text = fmt_n(S["top"], self.app.args.work)
            self.tip = S["tips"][self.tip_idx]
        self.set_buttons()

    def switch_language(self, code):
        if code == self.app.lang:
            return
        self.app.set_language(code)
        if not self.preview:
            save_language(code)
        self.S = self.app.S
        self.fonts["qmain"] = self.make_qmain()
        self.update_texts()

    def on_click(self, e):
        if time.time() - self.shown_at < 1.5 or self.hover < 0:     # ignore accidental input right after popup
            return
        action = self.btns[self.hover]["action"]
        if action.startswith("lang:"):
            self.switch_language(action[5:])                        # change language without closing the break
            return
        self.close(action)

    def on_escape(self, e=None):
        if time.time() - self.shown_at < 1.5:
            return
        self.close("done")

    def close(self, result):
        if self.closed:
            return
        self.closed = True
        self.result = result
        try:
            self.win.destroy()
        finally:
            self.on_close(result)


class App:
    def __init__(self, args):
        self.args = args
        # priority: what the user clicked in the app > --language > system language > English
        lang = "" if args.preview else get_saved_language()
        if not lang:
            lang = (args.language or "").lower()
        if lang not in LANGS:
            lang = system_language()
        self.lang = lang if lang in LANGS else "en"
        sec = (args.second_language or "").lower()
        self.second = sec if (sec in LANGS and sec != self.lang) else ""
        self.S = STRINGS[self.lang]
        self.root = tk.Tk()
        self.root.withdraw()
        self.quotes = self.load_quotes()
        self.due = 0.0

    def set_language(self, code):
        self.lang = code
        self.S = STRINGS[code]
        if self.second == code:
            self.second = ""

    def load_quotes(self):
        try:
            with open(QUOTES_FILE, "r", encoding="utf-8-sig") as f:
                data = json.load(f)
            if isinstance(data, list) and data:
                return data
        except Exception:
            pass
        return [FALLBACK_QUOTE]

    @staticmethod
    def qtext(q, lang):
        return q.get(lang) or q.get("en") or q.get("zh") or ""

    @staticmethod
    def qby(q, lang):
        return q.get(lang + "_by") or q.get("en_by") or q.get("zh_by") or ""

    def next_quote(self):
        if self.args.preview:
            return self.quotes[self.args.preview_index % len(self.quotes)]
        path = os.path.join(STATE_DIR, "index.txt")
        i = 0
        try:
            with open(path, "r") as f:
                i = int(f.read().strip())
        except Exception:
            pass
        q = self.quotes[i % len(self.quotes)]
        try:
            os.makedirs(STATE_DIR, exist_ok=True)
            with open(path, "w") as f:
                f.write(str((i + 1) % len(self.quotes)))
        except Exception:
            pass
        return q

    # scheduling: check the wall clock every 2 s, so it still works after the Mac sleeps
    def schedule(self, minutes):
        self.due = time.time() + minutes * 60.0
        self.root.after(2000, self.check)

    def check(self):
        if time.time() >= self.due:
            self.show_break()
        else:
            self.root.after(2000, self.check)

    def show_break(self):
        BreakScreen(self, self.args.break_minutes, self.on_break_closed)

    def on_break_closed(self, result):
        self.schedule(self.args.snooze if result == "snooze" else self.args.work)

    def run(self):
        a = self.args
        if a.preview:
            scr = BreakScreen(self, a.break_minutes, lambda r: self.root.quit(), preview_finished=a.preview_finished, preview=True)
            if a.preview_switch_to in LANGS:
                scr.switch_language(a.preview_switch_to)          # test only: pretend the user clicked a language
            self.root.after(1500, lambda: self.capture(scr))
            self.root.mainloop()
            return
        if a.test_now:
            BreakScreen(self, a.break_minutes, lambda r: self.root.quit())
            self.root.mainloop()
            return
        self.schedule(a.work)
        self.root.mainloop()

    def capture(self, scr):
        try:
            from PIL import ImageGrab          # only for making README screenshots; not needed normally
            img = ImageGrab.grab()
            w = 1920
            img = img.resize((w, int(img.height * w / img.width)))
            img.save(self.args.preview)
        finally:
            scr.close("done")


def single_instance():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.bind(("127.0.0.1", 47931))
        s.listen(1)
        return s
    except OSError:
        return None


def main():
    p = argparse.ArgumentParser(description="Break Reminder (macOS / tkinter)")
    p.add_argument("--language", default="")
    p.add_argument("--second-language", default="")
    p.add_argument("--work", type=float, default=30)
    p.add_argument("--break", dest="break_minutes", type=float, default=5)
    p.add_argument("--snooze", type=float, default=5)
    p.add_argument("--test-now", action="store_true")
    p.add_argument("--preview", default="", help=argparse.SUPPRESS)
    p.add_argument("--preview-index", type=int, default=0, help=argparse.SUPPRESS)
    p.add_argument("--preview-finished", action="store_true", help=argparse.SUPPRESS)
    p.add_argument("--preview-switch-to", default="", help=argparse.SUPPRESS)
    args = p.parse_args()
    if not (args.test_now or args.preview):
        lock = single_instance()           # keep a reference so the port stays bound
        if lock is None:
            return
    App(args).run()


if __name__ == "__main__":
    main()
