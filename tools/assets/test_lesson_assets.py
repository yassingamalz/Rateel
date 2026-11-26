"""Screen 10 icons from the owner (docs/design-assets/test-lesson/icons/, ChatGPT on magenta, prompts T4-T6)
→ app_flutter/assets/ui/test/. Un-mix against the magenta key on the outer edge only (the inside stays opaque), alpha < 7% cleared,
trimmed."""
import numpy as np
from PIL import Image, ImageFilter

src = 'docs/design-assets/test-lesson/icons/'
out = 'app_flutter/assets/ui/test/'


def unmix(name, dst, size):
    rgb = np.asarray(Image.open(src + name).convert('RGB'), np.float32)
    g, b = rgb[..., 1], rgb[..., 2]
    alpha = np.clip(1 - (b - 0.85 * g) / 255.0, 0, 1)
    alpha = np.where(alpha < 0.07, 0, alpha)
    # Un-mix only next to the magenta key (outside and in the holes, e.g. the trophy's handles), grown by 6 px;
    # elsewhere every pixel is opaque (the cream flame would otherwise turn half transparent).
    bg = (rgb[..., 0] > 190) & (rgb[..., 2] > 190) & (g < 110)
    edge = np.asarray(Image.fromarray((bg * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(13))) > 0
    alpha = np.where(bg, 0, np.where(edge, alpha, 1.0))
    a = alpha[..., None]
    k = np.array([255, 0, 255], np.float32)
    col = np.clip(np.where(a > 0.995, rgb, (rgb - (1 - a) * k) / np.maximum(a, 1e-3)), 0, 255)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    im = im.crop(im.getchannel('A').point(lambda v: 255 if v > 40 else 0).getbbox())
    im.thumbnail((size, size), Image.LANCZOS)
    im.save(out + dst, quality=92)
    print(dst, im.size)


unmix('01_trophy.png', 'trophy.webp', 384)
unmix('02_flame_medallion.png', 'flame_medallion.webp', 384)
unmix('03_flame_glyph.png', 'flame.webp', 192)
# Star coins (owner, 2026-11-26): gold used for the points; emerald and mint kept in the library.
unmix('04_star_coin_gold.png', 'star_coin_gold.webp', 256)
unmix('05_star_coin_emerald.png', 'star_coin_emerald.webp', 256)
unmix('06_star_coin_mint_glow.png', 'star_coin_mint.webp', 256)
