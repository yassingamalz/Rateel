"""Screen 11 proposal sheet: reference annotated (code / reused asset / new ChatGPT asset / token
conflict), the Angular original, and the assets that are reused as they are.
Usage: python3 tools/flutter-review/leaderboard-proposal-sheet.py <reference.webp> <angular.png> <out.jpg>"""
import sys
from PIL import Image, ImageDraw, ImageFont

ref = Image.open(sys.argv[1]).convert('RGB')
ang = Image.open(sys.argv[2]).convert('RGB')
F = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
f_num, f_txt, f_h = ImageFont.truetype(F, 26), ImageFont.truetype(F, 24), ImageFont.truetype(F, 34)

KIND = {'code': (64, 220, 120), 'reuse': (80, 160, 255), 'new': (255, 150, 40), 'conf': (255, 70, 90)}
# (number, kind, box at 1844x853, legend)
ITEMS = [
    (1, 'new', (530, 22, 1135, 142), 'Nastro verde/oro (A1 ChatGPT); titolo scritto in codice'),
    (2, 'new', (0, 0, 560, 150), 'Motivo a reticolo oro sfumato (A2: ChatGPT o vettoriale mio)'),
    (3, 'conf', (36, 155, 1540, 280), 'Pannello: bordo oro ~4px+alone vs token 1.2px (K1)'),
    (4, 'code', (48, 280, 1527, 422), 'Righe vetro: avatar, nome, lezioni, punti, premi'),
    (5, 'reuse', (1405, 298, 1485, 400), 'Medaglie 1-2-3 = asset Angular'),
    (6, 'reuse', (1275, 298, 1375, 400), 'Avatar = asset Angular (cerchio oro in codice)'),
    (7, 'new', (150, 320, 222, 382), 'Pile di monete oro/argento/bronzo (A3)'),
    (8, 'new', (1218, 360, 1252, 395), 'Icona libro oro (A4)'),
    (9, 'reuse', (272, 328, 322, 376), 'Stella = glyphs/star.svg'),
    (10, 'conf', (1550, 162, 1630, 376), 'Linguetta oro sfumata vs oro piatto (K3)'),
    (11, 'code', (1550, 376, 1630, 800), 'Linguette verticali: Tutti / Amici / Regione'),
    (12, 'conf', (36, 654, 1540, 800), 'Barra utente: verde chiaro + oro (K2)'),
    (13, 'code', (95, 685, 180, 770), 'Freccia in cerchio vetro (token, disegno in codice)'),
    (14, 'conf', (1412, 684, 1500, 770), 'Disco rango 15 oro (K6)'),
    (15, 'reuse', (1665, 0, 1844, 853), 'Navigazione laterale approvata (04)'),
]

def annotate(img):
    im = img.copy()
    d = ImageDraw.Draw(im)
    for n, k, b, _ in ITEMS:
        c = KIND[k]
        d.rectangle(b, outline=c, width=4)
        x, y = b[0] + 4, b[1] + 4
        d.ellipse((x, y, x + 36, y + 36), fill=c)
        d.text((x + 18, y + 18), str(n), font=f_num, fill=(0, 0, 0), anchor='mm')
    return im

W = 1844
legend_h = 34 * ((len(ITEMS) + 1) // 2) + 90
ang_s = ang.resize((W // 2 - 20, int(ang.size[1] * (W // 2 - 20) / ang.size[0])))
assets = [Image.open(p).convert('RGBA') for p in sys.argv[4:]] if len(sys.argv) > 4 else []
H = 60 + 853 + legend_h + 60 + ang_s.size[1] + 40
sheet = Image.new('RGB', (W, H), (24, 24, 24))
d = ImageDraw.Draw(sheet)
d.text((20, 14), 'Schermata 11 classifica: riferimento ChatGPT annotato', font=f_h, fill=(255, 255, 255))
sheet.paste(annotate(ref), (0, 60))
y = 60 + 853 + 20
for i, (n, k, _, t) in enumerate(ITEMS):
    x = 20 + (i % 2) * (W // 2)
    yy = y + (i // 2) * 34
    d.ellipse((x, yy, x + 28, yy + 28), fill=KIND[k])
    d.text((x + 14, yy + 14), str(n), font=ImageFont.truetype(F, 18), fill=(0, 0, 0), anchor='mm')
    d.text((x + 40, yy + 2), t, font=f_txt, fill=(235, 235, 235))
y += 34 * ((len(ITEMS) + 1) // 2) + 10
x = 20
for k, lab in (('code', 'codice'), ('reuse', 'asset riusato'), ('new', 'asset nuovo (ChatGPT)'), ('conf', 'conflitto con token: decidi tu')):
    d.rectangle((x, y, x + 28, y + 28), fill=KIND[k]); d.text((x + 38, y), lab, font=f_txt, fill=(255, 255, 255)); x += 420
y += 70
d.text((20, y - 8), 'Originale Angular (comportamento: filtri, barra utente fissa, scorri alla tua posizione)', font=f_txt, fill=(255, 255, 255))
sheet.paste(ang_s, (20, y + 30))
sheet = sheet.crop((0, 0, W, y + 30 + ang_s.size[1] + 20))
sheet.save(sys.argv[3], quality=88)
