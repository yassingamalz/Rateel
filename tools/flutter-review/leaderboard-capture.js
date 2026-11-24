// Screen 11 captures: node tools/flutter-review/leaderboard-capture.js <outdir> [tag]; web build on :8765.
// States: start, after tapping the pinned bar (scrolled to the user), friends tab, region tab.
// Desktop 1844x853 and phone 915x412 (dpr 2.625).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1';const b=await chromium.launch();
for (const [W,H,dpr,suf] of [[1844,853,1,''],[915,412,2.625,'-phone']]) {
 const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
 const u=H/100;
 await p.goto('http://localhost:8765/?section=3',{waitUntil:'networkidle'});await p.waitForTimeout(4000);
 await p.screenshot({path:`${d}/capture-${tag}-start${suf}.png`});
 const content=W-18.5*u, panelRight=content-15*u;
 await p.mouse.click((4.4*u+panelRight)/2, H-6.6*u-8.25*u);await p.waitForTimeout(2200);
 await p.screenshot({path:`${d}/capture-${tag}-me${suf}.png`});
 const tabX=content-8.8*u, tabTop=19.3*u, tabH=(H-6.4*u-tabTop)/3;
 for (const [i,n] of [[1,'friends'],[2,'region']]) {
  await p.mouse.click(tabX, tabTop+tabH*(i+0.5));await p.waitForTimeout(1500);
  await p.screenshot({path:`${d}/capture-${tag}-${n}${suf}.png`});
 }
 await p.close();}
await b.close()})();
