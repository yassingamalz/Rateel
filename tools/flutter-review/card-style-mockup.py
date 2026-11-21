import sys
A, OUT = sys.argv[1], sys.argv[2]
u = 10  # 1u = 10 px in the mockup (card 62u x 50u)
cards = [
  dict(n=1, title='أساسيات التجويد', desc='المبادئ الأساسية للتجويد وقواعد التلاوة الصحيحة للمبتدئين', active=True),
  dict(n=2, title='النون والميم المشددتان', desc='دراسة متعمقة لأحكام النون والميم المشددتين في التلاوة القرآنية', active=False),
  dict(n=3, title='مخارج الحروف', desc='دورة متخصصة في مخارج الحروف العربية وصفاتها', active=False),
]
# Variants: emblem box (left, top, size) and the gold arc path (in card px)
variants = {
 'V1 · arco-alone': dict(
   box=(12, 14, 215), arc='M 270 -10 C 285 140, 215 270, -10 300',
   note='Icona grande in alto a sinistra; l\'arco gira attorno al lato destro dell\'icona come un alone e scende verso l\'angolo in basso a sinistra.'),
 'V2 · arco-cornice': dict(
   box=(12, 14, 215), arc='M 280 -10 A 290 290 0 0 1 -10 280',
   note='L\'arco è un quarto di cerchio concentrico all\'icona: la incornicia come una nicchia (mihrab).'),
 'V3 · arco-dietro': dict(
   box=(12, 14, 215), arc='M 400 -10 C 250 60, 110 180, -10 400',
   note='L\'arco attraversa la carta passando DIETRO l\'icona (l\'icona lo copre al centro), più dinamico.'),
}
font = f"{A}/fonts/ReadexPro.ttf"
def card(c, v):
    x, y, s = v['box']
    W, H = 62*u, 50*u
    rim = '#C69F3D' if c['active'] else '#27654F'
    rim2 = '#D3A436' if c['active'] else '#2F6954'
    pill = '''<div class="pill"><span>مستوى مبتدئ</span><b>★</b></div>''' if c['active'] else '<div class="lock">🔒</div>'
    play = '''<div class="play">▶</div><div class="bar"></div><div class="pct">0%</div>''' if c['active'] else ''
    lines = 2 if c['active'] else 3
    return f'''
<div class="card" style="width:{W}px;height:{H}px;border-color:{rim};box-shadow:inset 0 0 0 2px {rim2}, 0 6px 22px #0008">
  <div class="pattern"></div>
  <svg class="arc" viewBox="0 0 {W} {H}" width="{W}" height="{H}">
    <defs><linearGradient id="g{c['n']}" x1="1" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#E1AC36" stop-opacity="0"/><stop offset=".3" stop-color="#F0C04A"/>
      <stop offset=".75" stop-color="#E1AC36" stop-opacity=".8"/><stop offset="1" stop-color="#E1AC36" stop-opacity="0"/></linearGradient>
      <filter id="b{c['n']}"><feGaussianBlur stdDeviation="4"/></filter></defs>
    <path d="{v['arc']}" stroke="url(#g{c['n']})" stroke-width="6" fill="none" filter="url(#b{c['n']})" opacity=".7"/>
    <path d="{v['arc']}" stroke="url(#g{c['n']})" stroke-width="2.2" fill="none"/>
  </svg>
  <img class="emb" src="file://{A}/ui/course_art/emblem/course_{c['n']:02d}.webp" style="left:{x}px;top:{y}px;width:{s}px;height:{s}px">
  {pill}
  <div class="txt" style="top:{10.5*u}px">
    <div class="t">{c['title']}</div>
    <img class="div" src="file://{A}/ui/decor/title_divider.svg">
    <div class="d" style="-webkit-line-clamp:{lines}">{c['desc']}</div>
  </div>
  {play}
</div>'''
css = f'''
@font-face{{font-family:R;src:url(file://{font})}}
body{{margin:0;background:#00271D;font-family:R;color:#FAF1D8;padding:20px}}
h2{{font-size:26px;color:#F2B623;margin:28px 0 6px;direction:ltr}} p{{direction:ltr;color:#cfd0ba;margin:0 0 12px;font-size:18px}}
.row{{display:flex;gap:40px;direction:rtl}}
.card{{position:relative;border:3px solid;border-radius:47px;overflow:hidden;flex:none;
 background:linear-gradient(#033428,#012F25 50%,#023126 72%,#053F30)}}
.pattern{{position:absolute;left:0;right:0;bottom:-30px;height:130px;opacity:.5;
 background:url(file://{A}/ui/decor/card_pattern.svg) center/100% 100%;filter:brightness(.6) sepia(1) hue-rotate(90deg)}}
.arc{{position:absolute;left:0;top:0}}
.emb{{position:absolute;object-fit:contain;filter:drop-shadow(0 6px 14px #0007)}}
.txt{{position:absolute;right:35px;width:340px;text-align:right;direction:rtl}}
.t{{font-size:40px;font-weight:560;line-height:1.2;text-shadow:0 3px 6px #0008;height:106px;display:flex;align-items:flex-end;justify-content:flex-end}}
.div{{display:block;width:220px;height:22px;margin:8px 55px 8px auto}}
.d{{font-size:30px;line-height:44px;color:#F4EAD0;display:-webkit-box;-webkit-box-orient:vertical;overflow:hidden;font-weight:340}}
.pill{{position:absolute;right:35px;top:36px;border:2px solid #F2B623;border-radius:30px;padding:6px 18px;color:#F2B623;font-size:30px;background:#062D20;display:flex;gap:12px;direction:rtl}}
.pill b{{color:#F2B623}}
.lock{{position:absolute;right:42px;top:36px;width:72px;height:72px;border-radius:50%;background:#01261E;border:2px solid #1A533F;display:grid;place-items:center;font-size:30px}}
.play{{position:absolute;left:62px;top:358px;width:76px;height:76px;border-radius:50%;background:#43552A;border:3px solid #FFDA6B;color:#F2B623;display:grid;place-items:center;font-size:30px}}
.bar{{position:absolute;left:187px;top:390px;width:300px;height:14px;border-radius:7px;background:#265343}}
.pct{{position:absolute;right:40px;top:380px;font-size:27px;direction:ltr}}
'''
html = f'<html><head><meta charset="utf-8"><style>{css}</style></head><body>'
for name, v in variants.items():
    html += f'<h2>{name}</h2><p>{v["note"]}</p><div class="row">' + ''.join(card(c, v) for c in cards) + '</div>'
open(OUT, 'w').write(html + '</body></html>')
