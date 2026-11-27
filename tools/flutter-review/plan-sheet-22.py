"""Visual plan sheet of screen 22: reference with numbered elements + lesson-production video frames."""
import sys
from PIL import Image, ImageDraw, ImageFont
ref, frames_dir, out = sys.argv[1], sys.argv[2], sys.argv[3]
F = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
def font(s): return ImageFont.truetype(F, s)
R = Image.open(ref).convert('RGB')            # 1844x853
d = ImageDraw.Draw(R)
marks = [  # (n, x, y) on the reference
    (1, 1750, 165), (2, 220, 135), (3, 922, 30), (4, 920, 195), (5, 1710, 350), (6, 250, 245),
    (7, 925, 335), (8, 640, 500), (9, 1010, 625), (10, 1550, 715), (11, 1110, 690), (12, 190, 690)]
for n, x, y in marks:
    d.ellipse((x-24, y-24, x+24, y+24), fill=(220, 40, 60), outline='white', width=3)
    t = str(n); w = d.textlength(t, font=font(28))
    d.text((x-w/2, y-17), t, fill='white', font=font(28))
W = 1844
sheet = Image.new('RGB', (W, 853 + 70 + 2 * 470 + 140), (16, 22, 20))
s = ImageDraw.Draw(sheet)
s.text((20, 18), 'Screen 22 - reference (numbered elements)', fill='white', font=font(32))
sheet.paste(R, (0, 70))
y0 = 853 + 70
s.text((20, y0 + 16), 'Examples from the lesson-production video (rateel-lezione1-v2.mp4)', fill='white', font=font(32))
caps = [('g96.jpg', 'A  t=1:36  each word lights gold while recited'), ('g162.jpg', 'B  t=2:42  verse card, reciter, surah, "listen" pill'),
        ('g54.jpg', 'C  t=0:54  wrong answer = red row with X'), ('g174.jpg', 'D  t=2:54  two-answer question row')]
for i, (f, c) in enumerate(caps):
    im = Image.open(f'{frames_dir}/{f}').convert('RGB').resize((900, 415))
    x = 22 + (i % 2) * 922; y = y0 + 70 + (i // 2) * 470
    sheet.paste(im, (x, y)); s.text((x, y + 420), c, fill=(240, 220, 150), font=font(26))
sheet.save(out, quality=88)
