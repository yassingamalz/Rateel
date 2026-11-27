// Screen 27 captures: node tools/flutter-review/badges-capture.js <outdir> [tag] [query]; web build on :8765.
// States: start (M05 selected), tile 2 selected, earned filter, locked filter, celebration frames (?earn=5).
// Desktop 1844x853 and phone 915x412 (dpr 2.625).
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1',q=process.argv[4]||'';const b=await chromium.launch();
for (const [W,H,dpr,suf] of [[1844,853,1,''],[915,412,2.625,'-phone']]) {
 const p=await b.newPage({viewport:{width:W,height:H},deviceScaleFactor:dpr});
 const u=H/100, content=W-18.5*u;
 await p.goto(`http://localhost:8765/?section=4${q}`,{waitUntil:'networkidle'});await p.waitForTimeout(4500);
 await p.screenshot({path:`${d}/capture-${tag}-start${suf}.png`});
 // tile of column 1 row 0 (second from the right)
 const panelL=(4.2+57.6+3.4)*u, panelR=content-3.6*u, gridPad=3.8*u, gap=3.6*u, tw=(panelR-panelL-2*gridPad-3*gap)/4;
 const tx=panelR-gridPad-1.5*tw-gap, ty=23.4*u+12.3*u+12*u;
 await p.mouse.click(tx,ty);await p.waitForTimeout(1500);
 await p.screenshot({path:`${d}/capture-${tag}-tile2${suf}.png`});
 const tabsRight=panelR-4.9*u, tabY=23.4*u+2.3*u+3*u;
 await p.mouse.click(tabsRight-(20.2+2.6+23.1/2)*u,tabY);await p.waitForTimeout(1500);
 await p.screenshot({path:`${d}/capture-${tag}-earned${suf}.png`});
 await p.mouse.click(tabsRight-(20.2+2.6+23.1+2.6+25.1/2)*u,tabY);await p.waitForTimeout(1500);
 await p.screenshot({path:`${d}/capture-${tag}-locked${suf}.png`});
 await p.close();}
await b.close()})();
