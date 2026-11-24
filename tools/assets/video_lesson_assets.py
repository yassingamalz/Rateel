"""Screen 07 assets from the owner (docs/design-assets/video-lesson/, on magenta) → app_flutter/assets/ui/video/.
Full un-mix against the magenta key everywhere (no silver here): alpha = 1 − (B − 0.85·G)/255, colour un-blended.
Keeps the arch's semi-transparent dark fill and the corners' fade and dark offset line.
Usage: python3 -I tools/assets/video_lesson_assets.py <repo-root>"""
import sys
import numpy as np
from PIL import Image

root = sys.argv[1]
src = root + '/docs/design-assets/video-lesson/'
out = root + '/app_flutter/assets/ui/video/'
K = np.array([255, 0, 255], np.float32)


def key(name, target, longest, trim=True):
    rgb = np.asarray(Image.open(src + name).convert('RGB'), np.float32)
    g, b = rgb[..., 1], rgb[..., 2]
    alpha = np.clip(1 - (b - 0.85 * g) / 255.0, 0, 1)
    alpha = np.where(alpha < 0.07, 0, alpha)
    a = alpha[..., None]
    col = np.clip(np.where(a > 0.995, rgb, (rgb - (1 - a) * K) / np.maximum(a, 1e-3)), 0, 255)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    if trim:
        im = im.crop(im.getchannel('A').point(lambda v: 255 if v > 60 else 0).getbbox())
    im.thumbnail((longest, longest), Image.LANCZOS)
    im.save(out + target, quality=92)
    print(target, im.size)


key('01b-video-unavailable-icon-v2.png', 'unavailable_icon.webp', 512)  # v2 (owner): closer to the reference; 01 kept as a spare
key('02-gold-ogee-arch.png', 'arch_frame.webp', 2048, trim=False)  # untrimmed: fitted on the reference as 2048x683
def corner(name, target, size):
    # ChatGPT faded the lattice by blending gold towards pink, not linearly towards the key: un-mixing leaves pink.
    # Gold alpha from the green channel (magenta has none), colour = the line's own gold; dark carved offset line from
    # the darkness of red/blue (below the key).
    rgb = np.asarray(Image.open(src + name).convert('RGB'), np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    a_gold = np.clip(g / 190.0, 0, 1)
    gc = np.where(a_gold > 0.995, g, 190.0)
    gold = np.dstack([np.clip(gc * 1.18, 0, 255), gc, gc * 0.32])
    a_dark = np.clip((235 - np.maximum(r, b)) / 200.0, 0, 1) * (g < 60)
    dark = np.zeros_like(rgb) + np.array([6, 18, 10], np.float32)
    use_gold = (a_gold >= a_dark)[..., None]
    col = np.where(use_gold, gold, dark)
    alpha = np.where(use_gold[..., 0], a_gold, a_dark)
    alpha = np.where(alpha < 0.07, 0, alpha)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA')
    im = im.resize((size, size), Image.LANCZOS)
    im.save(out + target, quality=92)
    print(target, im.size)


corner('03-lattice-bottom-left.png', 'corner_bottom_left.webp', 800)
corner('04-lattice-bottom-right.png', 'corner_bottom_right.webp', 800)


def band(name, target, x0, x1, height):
    # Seamless strip cut between two crossings of the middle row (4 periods of 332 px), alpha and colour as the corners.
    rgb = np.asarray(Image.open(src + name).convert('RGB'), np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    a_gold = np.clip(g / 190.0, 0, 1)
    gc = np.where(a_gold > 0.995, g, 190.0)
    gold = np.dstack([np.clip(gc * 1.18, 0, 255), gc, gc * 0.32])
    a_dark = np.clip((235 - np.maximum(r, b)) / 200.0, 0, 1) * (g < 60)
    use_gold = (a_gold >= a_dark)[..., None]
    col = np.where(use_gold, gold, np.zeros_like(rgb) + np.array([6, 18, 10], np.float32))
    alpha = np.where(use_gold[..., 0], a_gold, a_dark)
    alpha = np.where(alpha < 0.07, 0, alpha)
    im = Image.fromarray(np.dstack([col, alpha * 255]).astype(np.uint8), 'RGBA').crop((x0, 0, x1, rgb.shape[0]))
    bb = im.getchannel('A').point(lambda v: 255 if v > 60 else 0).getbbox()
    im = im.crop((0, bb[1], im.width, bb[3]))
    im = im.resize((round(im.width * height / im.height), height), Image.LANCZOS)
    im.save(out + target, quality=92)
    a = np.asarray(im, np.float32)[..., 3]
    print(target, im.size, 'seam diff', float(np.abs(a[:, 0] - a[:, -1]).mean()))


band('06-lattice-bottom-band.png', 'bottom_band.webp', 255, 1584, 256)
