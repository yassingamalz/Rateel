const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();
const L=[['F','0','',2,16,1844,853,'F-2'],['F','0','',9,16,1844,853,'F-9'],['F','0','',16,16,1844,853,'F-16'],
['F','1','',2,16,1844,853,'F-menu-strong'],['F','1','light',2,16,1844,853,'F-menu-light'],
['F','0','',2,16,915,412,'F-2-phone'],['F','1','light',2,16,915,412,'F-menu-light-phone'],['I','0','',0,0,1844,853,'icons']];
for (const [o,m,v,st,tot,W,H,n] of L){const p=await b.newPage({viewport:{width:W,height:H}});
await p.goto(`file://${process.cwd()}/mock-v3.html?opt=${o}&menu=${m}&veil=${v}&step=${st}&total=${tot}`);await p.waitForTimeout(400);
await p.screenshot({path:`mock3/${n}.png`});await p.close();}
await b.close()})();
