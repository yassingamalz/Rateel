from PIL import Image, ImageDraw, ImageFont
F=ImageFont.truetype('ReadexPro.ttf',26)
W=900
def fit(p,w=W,crop=None):
    im=Image.open(p).convert('RGB')
    if crop: im=im.crop(crop)
    return im.resize((w,int(im.height*w/im.width)),Image.LANCZOS)
def sheet(rows,out):
    gap=20;lab=44
    H=sum(max(i.height for i,_ in r)+lab+gap for r in rows)+gap
    S=Image.new('RGB',(2*W+3*gap,H),'#101814');d=ImageDraw.Draw(S);y=gap
    for r in rows:
        x=gap
        for im,t in r:
            d.text((x,y),t,font=F,fill='#F4EAD0');S.paste(im,(x,y+lab));x+=W+gap
        y+=max(i.height for i,_ in r)+lab+gap
    S.save(out,quality=88)
a='ang/';m='mock/'
sheet([[(fit(a+'video-closed.png'),'Angular, lezione video: barra 42/100 in alto a sinistra, pausa a destra'),(fit(a+'video-menu.png'),'Angular, menu aperto: play oro pulsante + rigioca e indietro; sfondo velato')],
       [(fit(a+'practice-dark.png'),'Angular, lezione pratica: due barre (0/100 e la linea sottile)'),(fit(a+'video-closed.png',crop=(0,0,460,110)),'Angular, zoom ×2: la barra 200×24 px si perde sul video')]],
      'angular-original.jpg')
sheet([[(fit(m+'A0.png'),'Proposta A: capsula di vetro + barra oro, pulsante vetro (token 06)'),(fit(m+'A1.png'),'Proposta A, menu aperto: play oro, «ricomincia» e «indietro»')],
       [(fit(m+'B0.png'),'Proposta B: barra sottile a tutta larghezza + contatore'),(fit(m+'B1.png'),'Proposta B, menu aperto')],
       [(fit(m+'A0.png',crop=(0,0,460,110)),'Proposta A, zoom ×2 (stessa scala dello zoom Angular)'),(fit(m+'A1.png',crop=(1384,0,1844,110)),'Proposta A, zoom ×2 dei pulsanti a menu aperto')],
       [(fit(m+'A0-phone.png'),'Proposta A, telefono 915×412'),(fit(m+'A1-phone.png'),'Proposta A, telefono, menu aperto')]],
      'proposal-v1.jpg')
