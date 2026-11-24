const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();
for (const k of ['A','B','C']) for (const m of ['0','1']) {
const p=await b.newPage({viewport:{width:915,height:412},deviceScaleFactor:2});
await p.goto(`file://${process.cwd()}/mock-size-${k}.html?opt=F&menu=${m}&step=3&total=8`);await p.waitForTimeout(400);
await p.screenshot({path:`msize/${k}${m}.png`});await p.close();}
await b.close()})();
