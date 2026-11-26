from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def _font(size):
    for name in ("DejaVuSansMono.ttf", "Menlo.ttc", "Consolas.ttf", "cour.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def ascii_frames_to_gif(frames, path, fps=30, font_size=14,
                        fg=(235, 235, 235), bg=(12, 12, 12), loop=0):
    font = _font(font_size)
    rows0 = frames[0].split("\n")
    rows, cols = len(rows0), max(len(r) for r in rows0)

    probe = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    cw = max(1, round(probe.textlength("M", font=font)))
    ch = round(font_size * 1.2)
    size = (cols * cw, rows * ch)

    images = []
    for f in frames:
        img = Image.new("RGB", size, bg)
        d = ImageDraw.Draw(img)
        for i, line in enumerate(f.split("\n")):
            d.text((0, i * ch), line, font=font, fill=fg)
        images.append(img)

    Path(path).parent.mkdir(parents=True, exist_ok=True)
    images[0].save(path, save_all=True, append_images=images[1:],
                   duration=int(1000 / fps), loop=loop, optimize=True)
    return path
