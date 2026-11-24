import importlib.util,sys
spec=importlib.util.spec_from_file_location('s','sheet.py')
src=open('sheet.py').read().split("a='ang/'")[0]; exec(src)
m='mock/'
z=lambda n:fit(m+n+'.png',crop=(0,0,460,110))
sheet([[(z('F-2'),'Capsula piena, zoom ×2: passo 2/16'),(z('F-9'),'Passo 9/16: il numero diventa scuro sopra l’oro')],
       [(z('F-16'),'Passo 16/16: capsula tutta oro'),(fit(m+'F-2.png'),'Lezione a schermo intero, barra laterale nascosta')],
       [(fit(m+'F-menu-strong.png'),'Domanda 5, velo FORTE (Angular): 45% + sfocatura, contenuto 98%'),(fit(m+'F-menu-light.png'),'Domanda 5, velo LEGGERO: 12% nero, niente sfocatura')],
       [(fit(m+'F-2-phone.png'),'Telefono 915×412'),(fit(m+'F-menu-light-phone.png'),'Telefono, menu aperto (velo leggero)')],
       [(fit(m+'icons.png',crop=(380,200,1464,620)),'Domanda 6, icone mie: pausa, play, ricomincia, indietro'),(fit(m+'F-menu-strong.png',crop=(1384,0,1844,110)),'Le stesse icone nei pulsanti, zoom ×2')]],
      'proposal-v2.jpg')
