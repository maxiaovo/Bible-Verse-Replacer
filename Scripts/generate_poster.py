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

BG = (248, 245, 236)
INK = (34, 38, 45)
MUTED = (94, 99, 107)
TEAL = (24, 112, 103)
GOLD = (209, 155, 56)
CARD = (255, 252, 244)
LINE = (225, 218, 202)
GREEN = (43, 135, 94)
BLUE = (50, 82, 150)


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


F_TITLE = font(82)
F_NAME = font(46)
F_SUB = font(34)
F_BODY = font(29)
F_SMALL = font(23)
F_TINY = font(19)
F_MONO = font(28)


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
    pad_x, pad_y = 18, 10
    tw = int(draw.textlength(text, font=F_SMALL))
    h = F_SMALL.size + pad_y * 2
    rounded_rectangle(draw, (x, y, x + tw + pad_x * 2, y + h), 18, fill)
    draw.text((x + pad_x, y + pad_y - 1), text, font=F_SMALL, fill=text_fill)
    return x + tw + pad_x * 2 + 12


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    qr_img = make_qr()

    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    # Soft geometric backdrop.
    draw.ellipse((-260, -180, 430, 450), fill=(231, 238, 225))
    draw.ellipse((720, -160, 1280, 410), fill=(237, 226, 199))
    draw.rectangle((0, 0, W, 18), fill=TEAL)
    draw.rectangle((0, 18, W, 26), fill=GOLD)

    # Header.
    draw.text((72, 92), "经文替换器", font=F_TITLE, fill=INK)
    draw.text((76, 198), "Bible Verse Replacer", font=F_NAME, fill=TEAL)
    draw_text_block(
        draw,
        "选中经文引用，按下快捷键，自动替换为完整经文。",
        (76, 280),
        F_SUB,
        INK,
        900,
        12,
    )

    # Example card.
    card_x, card_y, card_w, card_h = 76, 420, 928, 420
    rounded_rectangle(draw, (card_x, card_y, card_x + card_w, card_y + card_h), 28, CARD, LINE, 2)
    draw.text((card_x + 42, card_y + 38), "输入", font=F_SMALL, fill=MUTED)
    rounded_rectangle(draw, (card_x + 42, card_y + 80, card_x + card_w - 42, card_y + 150), 18, (244, 241, 232), None)
    draw.text((card_x + 70, card_y + 100), "创世记 1:1", font=F_MONO, fill=INK)

    draw.line((card_x + 42, card_y + 190, card_x + card_w - 42, card_y + 190), fill=LINE, width=2)
    draw.text((card_x + 42, card_y + 225), "替换后", font=F_SMALL, fill=MUTED)
    output = "创世记 1:1 起初，神创造天地。"
    draw_text_block(draw, output, (card_x + 42, card_y + 270), F_BODY, INK, card_w - 84, 12)

    # Feature badges and bullets.
    y = 900
    x = 76
    x = draw_badge(draw, "macOS 13+", x, y, TEAL)
    x = draw_badge(draw, "Windows 7 SP1+", x, y, BLUE)
    draw_badge(draw, "离线经文库", x, y, GREEN)

    bullets = [
        "支持中文 / 英文书卷名与常用缩写",
        "兼容全角、半角符号",
        "可自定义快捷键与输出格式",
        "内置新标点和合本简体 cmn-cu89s",
    ]
    y = 982
    for bullet in bullets:
        draw.ellipse((82, y + 9, 96, y + 23), fill=GOLD)
        draw.text((112, y), bullet, font=F_BODY, fill=INK)
        y += 54

    # QR panel.
    panel_x, panel_y, panel_w, panel_h = 76, 1230, 928, 270
    rounded_rectangle(draw, (panel_x, panel_y, panel_x + panel_w, panel_y + panel_h), 28, (31, 39, 47), None)

    qr_size = 210
    qr = qr_img.resize((qr_size, qr_size), Image.Resampling.NEAREST)
    qr_bg_x, qr_bg_y = panel_x + panel_w - qr_size - 44, panel_y + 30
    rounded_rectangle(draw, (qr_bg_x - 12, qr_bg_y - 12, qr_bg_x + qr_size + 12, qr_bg_y + qr_size + 12), 20, (255, 255, 255), None)
    img.paste(qr, (qr_bg_x, qr_bg_y))

    draw.text((panel_x + 44, panel_y + 46), "扫码下载 v0.1.0", font=F_NAME, fill=(255, 255, 255))
    draw.text((panel_x + 46, panel_y + 120), "常驻后台 · 一键替换 · 离线可用", font=F_BODY, fill=(226, 232, 230))
    draw_text_block(draw, RELEASE_URL, (panel_x + 46, panel_y + 174), F_TINY, (200, 207, 205), 560, 7)

    img.save(OUT, quality=96)
    print(OUT)
    print(QR_OUT)


if __name__ == "__main__":
    main()
