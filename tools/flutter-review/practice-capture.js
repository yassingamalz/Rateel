// Screen 31 captures: node tools/flutter-review/practice-capture.js <outdir> [tag] [extra-query]; web build on :8765.
// 31-A (rail item «التدريب») and 31-B (reminder over the listening quiz of 22), dark and light,
// reference size 1844x853 and phone 915x412 (dpr 2.625). Data as the reference: today Tuesday,
// Sat–Mon done and the Friday before (streak 4). The saved profile is set so the onboarding (30) is skipped.
const {chromium}=require('playwright');(async()=>{const d=process.argv[2],tag=process.argv[3]||'v1',extra=process.argv[4]||'';
const b=await chromium.launch();
const base='today=2026-11-24&practiceDays=1,2,3,4';
const states={a:`section=2&${base}`,b:`lessons=1,1&lessonDone=2&openLesson=1&remind=1&today=2026-11-24&practiceDays=2,3`};
for (const [st,q] of Object.entries(states))
for (const theme of ['dark','light'])
for (const [W,H,dpr,suf] of [[1844,853,1,''],[915,412,2.625,'-phone']]) {
 const ctx=await b.newContext({viewport:{width:W,height:H},deviceScaleFactor:dpr});
 await ctx.addInitScript(()=>{localStorage.setItem('flutter.profile.v1',JSON.stringify(JSON.stringify({onboarded:true,name:'أحمد',avatar:6,level:0,goal:10})));});
 const p=await ctx.newPage();
 await p.goto(`http://localhost:8765/?${q}${theme==='light'?'&theme=light':''}${extra}`,{waitUntil:'networkidle'});
 await p.waitForTimeout(st==='b'?9000:7000);
 await p.screenshot({path:`${d}/capture-${tag}-${st}-${theme}${suf}.png`});
 await ctx.close();}
await b.close()})();
