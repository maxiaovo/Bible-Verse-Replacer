#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

import qrcode
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Assets" / "Poster" / "BibleVerseReplacer-Poster-v0.1.0.png"
QR_OUT = ROOT / "Assets" / "Poster" / "BibleVerseReplacer-Release-QR.png"
RELEASE_URL = "https://github.com/maxiaovo/Bible-Verse-Replacer/releases/tag/v0.1.0"

W, H = 1080, 1600

BG = (7, 10, 18)
INK = (238, 244, 248)
MUTED = (147, 157, 172)
CYAN = (50, 222, 210)
MAGENTA = (245, 70, 150)
GOLD = (255, 191, 74)
CARD = (14, 19, 31)
CARD_2 = (20, 27, 42)
LINE = (58, 69, 90)
GREEN = (48, 210, 136)
BLUE = (83, 130, 255)


def font(size: int, weight: str = "regular") -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/Library/Fonts/Arial Unicode.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size=size, index=0)
            except OSError:
                continue
    return ImageFont.load_default()


F_TITLE = font(92)
F_NAME = font(38)
F_SUB = font(32)
F_BODY = font(28)
F_SMALL = font(22)
F_TINY = font(18)
F_MONO = font(30)


def rounded_rectangle(draw: ImageDraw.ImageDraw, xy, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, fnt, max_width: int) -> list[str]:
    lines: list[str] = []
    current = ""
    for char in text:
        trial = current + char
        if draw.textlength(trial, font=fnt) <= max_width or not current:
            current = trial
        else:
            lines.append(current)
            current = char
    if current:
        lines.append(current)
    return lines


def draw_text_block(draw: ImageDraw.ImageDraw, text: str, xy, fnt, fill, max_width: int, line_gap: int = 10) -> int:
    x, y = xy
    for line in wrap_text(draw, text, fnt, max_width):
        draw.text((x, y), line, font=fnt, fill=fill)
        y += fnt.size + line_gap
    return y


def make_qr() -> Image.Image:
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_Q,
        box_size=14,
        border=4,
    )
    qr.add_data(RELEASE_URL)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white").convert("RGB")
    QR_OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(QR_OUT)
    return img


def draw_badge(draw: ImageDraw.ImageDraw, text: str, x: int, y: int, fill, text_fill=(255, 255, 255)) -> int:
    pad_x, pad_y = 18, 9
    tw = int(draw.textlength(text, font=F_SMALL))
    h = F_SMALL.size + pad_y * 2
    rounded_rectangle(draw, (x, y, x + tw + pad_x * 2, y + h), 10, fill)
    draw.text((x + pad_x, y + pad_y - 1), text, font=F_SMALL, fill=text_fill)
    return x + tw + pad_x * 2 + 12


def draw_scanline_grid(draw: ImageDraw.ImageDraw) -> None:
    for y in range(72, H, 44):
        draw.line((0, y, W, y), fill=(12, 18, 30), width=1)
    for x in range(42, W, 54):
        draw.line((x, 0, x, H), fill=(11, 16, 27), width=1)
    for i in range(-260, W, 92):
        draw.line((i, 0, i + 420, 420), fill=(15, 25, 42), width=3)


def draw_chip(draw: ImageDraw.ImageDraw, text: str, x: int, y: int, color) -> None:
    rounded_rectangle(draw, (x, y, x + 286, y + 84), 16, CARD_2, (58, 69, 90), 1)
    draw.rectangle((x, y, x + 7, y + 84), fill=color)
    draw.text((x + 24, y + 25), text, font=F_SMALL, fill=INK)


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    qr_img = make_qr()

    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    draw_scanline_grid(draw)
    draw.rectangle((0, 0, W, 18), fill=CYAN)
    draw.rectangle((0, 18, W, 28), fill=MAGENTA)
    draw.rectangle((72, 76, 1008, 80), fill=(36, 49, 70))

    # Header.
    draw.text((76, 104), "正文替换器", font=F_TITLE, fill=INK)
    draw.text((80, 104), "正文替换器", font=F_TITLE, fill=(255, 255, 255))
    draw.text((80, 212), "TEXT SUMMONER / v0.1.0", font=F_NAME, fill=CYAN)
    draw_text_block(draw, "选中坐标，按键召唤正文。复制粘贴退散。", (80, 274), F_SUB, INK, 900, 10)
    draw.text((82, 336), "macOS + Windows · 离线 · 常驻后台 · 低调启动", font=F_SMALL, fill=MUTED)

    # Example card.
    card_x, card_y, card_w, card_h = 72, 414, 936, 322
    rounded_rectangle(draw, (card_x, card_y, card_x + card_w, card_y + card_h), 22, CARD, (71, 86, 115), 2)
    draw.rectangle((card_x, card_y, card_x + card_w, card_y + 62), fill=(18, 25, 41))
    draw.ellipse((card_x + 28, card_y + 21, card_x + 42, card_y + 35), fill=MAGENTA)
    draw.ellipse((card_x + 52, card_y + 21, card_x + 66, card_y + 35), fill=GOLD)
    draw.ellipse((card_x + 76, card_y + 21, card_x + 90, card_y + 35), fill=GREEN)
    draw.text((card_x + 116, card_y + 17), "HOTKEY SEQUENCE", font=F_SMALL, fill=MUTED)

    draw.text((card_x + 40, card_y + 92), "> INPUT", font=F_SMALL, fill=CYAN)
    draw.text((card_x + 40, card_y + 135), "创 1:1", font=F_MONO, fill=INK)
    draw.text((card_x + 40, card_y + 196), "> OUTPUT", font=F_SMALL, fill=MAGENTA)
    output = "创世记 1:1 起初，神创造天地。"
    draw_text_block(draw, output, (card_x + 40, card_y + 238), F_BODY, INK, card_w - 80, 8)

    # Feature badges and bullets.
    y = 786
    x = 72
    x = draw_badge(draw, "macOS 13+", x, y, (18, 118, 110))
    x = draw_badge(draw, "Windows 7 SP1+", x, y, (46, 76, 154))
    x = draw_badge(draw, "快捷键可改", x, y, (118, 64, 142))
    draw_badge(draw, "不联网", x, y, (30, 125, 80))

    draw_chip(draw, "中英书卷名", 72, 874, CYAN)
    draw_chip(draw, "全角半角通吃", 397, 874, MAGENTA)
    draw_chip(draw, "输出格式可选", 722, 874, GOLD)
    draw_chip(draw, "后台潜行", 72, 982, GREEN)
    draw_chip(draw, "一键替换", 397, 982, BLUE)
    draw_chip(draw, "离线正文库", 722, 982, (147, 96, 255))

    rounded_rectangle(draw, (72, 1114, 1008, 1182), 14, (18, 25, 41), (58, 69, 90), 1)
    draw.text((104, 1134), "提示：微信里发它，就说是“正文工具”。别解释，解释就输了。", font=F_SMALL, fill=(211, 218, 230))

    # QR panel.
    panel_x, panel_y, panel_w, panel_h = 72, 1230, 936, 268
    rounded_rectangle(draw, (panel_x, panel_y, panel_x + panel_w, panel_y + panel_h), 22, (235, 241, 242), None)
    draw.rectangle((panel_x, panel_y, panel_x + 16, panel_y + panel_h), fill=MAGENTA)

    qr_size = 210
    qr = qr_img.resize((qr_size, qr_size), Image.Resampling.NEAREST)
    qr_bg_x, qr_bg_y = panel_x + panel_w - qr_size - 42, panel_y + 29
    rounded_rectangle(draw, (qr_bg_x - 12, qr_bg_y - 12, qr_bg_x + qr_size + 12, qr_bg_y + qr_size + 12), 18, (255, 255, 255), (28, 36, 48), 2)
    img.paste(qr, (qr_bg_x, qr_bg_y))

    draw.text((panel_x + 48, panel_y + 42), "扫码解锁", font=F_NAME, fill=(17, 24, 37))
    draw.text((panel_x + 50, panel_y + 104), "v0.1.0 · 双系统 · 绿色下载", font=F_BODY, fill=(47, 58, 74))
    draw_text_block(draw, RELEASE_URL, (panel_x + 50, panel_y + 164), F_TINY, (75, 84, 97), 548, 7)

    img.save(OUT, quality=96)
    print(OUT)
    print(QR_OUT)


if __name__ == "__main__":
    main()
