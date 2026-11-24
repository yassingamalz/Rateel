const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();
for (const [o,m,W,H,s] of [['A','0',1844,853,''],['A','1',1844,853,''],['B','0',1844,853,''],['B','1',1844,853,''],['A','0',915,412,'-phone'],['A','1',915,412,'-phone']]) {
const p=await b.newPage({viewport:{width:W,height:H}});
await p.goto(`file://${process.cwd()}/mock.html?opt=${o}&menu=${m}`);await p.waitForTimeout(500);
await p.screenshot({path:`mock/${o}${m}${s}.png`});await p.close();}
await b.close()})();
