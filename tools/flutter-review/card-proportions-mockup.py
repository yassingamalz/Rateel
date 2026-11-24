import sys
A, S, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
u = 853 / 100
cards = [
  dict(n=1, title='أساسيات التجويد', desc='المبادئ الأساسية للتجويد وقواعد التلاوة الصحيحة للمبتدئين', active=True),
  dict(n=2, title='النون والميم المشددتان', desc='دراسة متعمقة لأحكام النون والميم المشددتين في التلاوة القرآنية', active=False),
  dict(n=3, title='مخارج الحروف', desc='دورة متخصصة في مخارج الحروف العربية وصفاتها', active=False),
]
def page(name, W, H, gap, right, cy):
    Wp, Hp = W*u, H*u
    out = []
    for i, c in enumerate(cards):
        x = 1686 - right*u - (i+1)*Wp - i*gap*u
        y = cy*u - Hp/2
        rim = '#C69F3D' if c['active'] else '#27654F'
        rim2 = '#D3A436' if c['active'] else '#2F6954'
        s = 0.92*Hp  # emblem background box, as in the approved card
        top = '<div class="pill"><b>★</b><span>مستوى مبتدئ</span></div>' if c['active'] else f'<img class="lock" src="file://{A}/ui/glyphs/lock_badge.webp">'
        play = '<div class="play">▶</div><div class="bar"></div><div class="pct">0%</div>' if c['active'] else ''
        out.append(f'''
<div class="card" style="left:{x:.0f}px;top:{y:.0f}px;width:{Wp:.0f}px;height:{Hp:.0f}px;border-color:{rim};box-shadow:inset 0 0 0 {0.28*u:.1f}px {rim2},0 {0.6*u:.0f}px {2.2*u:.0f}px #0009">
  <div class="pattern"></div>
  <img class="bgart" src="file://{A}/ui/course_art/emblem/course_{c['n']:02d}.webp" style="left:{-0.12*Hp:.0f}px;top:{-0.04*Hp:.0f}px;width:{s:.0f}px;height:{s:.0f}px">
  {top}
  <div class="col">
    <div class="t">{c['title']}</div>
    <img class="div" src="file://{A}/ui/decor/title_divider.svg">
    <div class="d">{c['desc']}</div>
  </div>
  {play}
</div>''')
    css = f'''
@font-face{{font-family:R;src:url(file://{A}/fonts/ReadexPro.ttf)}}
body{{margin:0;width:1844px;height:853px;position:relative;overflow:hidden;font-family:R;color:#FAF1D8;
 background:linear-gradient(#022C21 0, #022C21 318px, #00271D 853px)}}
.hdr{{position:absolute;left:0;top:0}} .rail{{position:absolute;right:0;top:0;z-index:5}}
.tag{{position:absolute;left:20px;bottom:14px;color:#F2B623;font-size:22px;direction:ltr;z-index:6}}
.card{{position:absolute;border:{0.19*u:.1f}px solid;border-radius:{4.7*u:.0f}px;overflow:hidden;
 background:linear-gradient(#033428,#012F25 50%,#023126 72%,#053F30)}}
.pattern{{position:absolute;left:0;right:0;bottom:-{3*u:.0f}px;height:{13*u:.0f}px;opacity:.5;
 background:url(file://{A}/ui/decor/card_pattern.svg) center/100% 100%;filter:brightness(.6) sepia(1) hue-rotate(90deg)}}
.bgart{{position:absolute;object-fit:contain;opacity:.45;-webkit-mask-image:linear-gradient(90deg,#000 0%,#000 45%,transparent 92%)}}
.col{{position:absolute;right:{3.5*u:.0f}px;top:{9.6*u:.0f}px;width:{36*u:.0f}px;text-align:right;direction:rtl}}
.t{{font-size:{4.4*u:.0f}px;font-weight:560;line-height:1.15;text-shadow:0 {0.3*u:.0f}px {0.6*u:.0f}px #0008;
 display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}}
.div{{display:block;width:{22*u:.0f}px;height:{2.2*u:.0f}px;margin:{0.8*u:.0f}px {7*u:.0f}px {0.8*u:.0f}px auto}}
.d{{font-size:{3.0*u:.0f}px;line-height:{4.3*u:.0f}px;color:#F4EAD0;font-weight:340;
 display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}}
.pill{{position:absolute;right:{3.5*u:.0f}px;top:{3*u:.0f}px;height:{5.6*u:.0f}px;border:{0.23*u:.1f}px solid #F2B623;border-radius:{3*u:.0f}px;
 padding:0 {2*u:.0f}px;color:#F2B623;font-size:{3*u:.0f}px;background:#062D20;display:flex;align-items:center;gap:{1.2*u:.0f}px;direction:rtl}}
.pill span{{position:relative;top:-{0.5*u:.0f}px}}
.lock{{position:absolute;right:{4*u:.0f}px;top:{2.6*u:.0f}px;width:{7*u:.0f}px;height:{7*u:.0f}px}}
.play{{position:absolute;left:{5.5*u:.0f}px;bottom:{3*u:.0f}px;width:{7.4*u:.0f}px;height:{7.4*u:.0f}px;border-radius:50%;background:#43552A;
 border:{0.3*u:.1f}px solid #FFDA6B;color:#F2B623;display:grid;place-items:center;font-size:{3*u:.0f}px;box-sizing:border-box}}
.bar{{position:absolute;left:{16*u:.0f}px;right:{11*u:.0f}px;bottom:{6.0*u:.0f}px;height:{1.4*u:.0f}px;border-radius:{0.7*u:.0f}px;background:#265343}}
.pct{{position:absolute;right:{4*u:.0f}px;bottom:{5.1*u:.0f}px;font-size:{2.7*u:.0f}px;direction:ltr}}
.line{{position:absolute;height:{0.35*u:.1f}px;background:#265343}}
.node{{position:absolute;width:{2.6*u:.0f}px;height:{2.6*u:.0f}px;border-radius:50%;background:#265343}}
'''
    html = f'<html><head><meta charset="utf-8"><style>{css}</style></head><body>'
    html += f'<img class="hdr" src="file://{S}/header.png"><img class="rail" src="file://{S}/rail.png">'
    conn = []
    for i in range(len(cards)):
        right_card_left = 1686 - right*u - (i+1)*Wp - i*gap*u
        x1 = right_card_left; x0 = x1 - gap*u
        y = cy*u
        conn.append(f'<div class="line" style="left:{x0:.0f}px;top:{y - 0.17*u:.0f}px;width:{gap*u:.0f}px"></div>')
        conn.append(f'<div class="node" style="left:{(x0+x1)/2 - 1.3*u:.0f}px;top:{y - 1.3*u:.0f}px"></div>')
    html += ''.join(conn) + ''.join(out) + f'<div class="tag">{name}</div></body></html>'
    return html
for name, args in {'A2':(62, 42, 12, 2.5, 62)}.items():
    W,H,gap,right,cy = args
    open(f'{OUT}-{name}.html','w').write(page(f'{name} · {W}u × {H}u (rapporto {W/H:.2f}), oggi 62u × 50u (1.24)', *args))
