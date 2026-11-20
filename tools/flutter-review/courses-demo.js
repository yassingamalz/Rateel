// Screen 03 demo video (real time): entry, locked tap, drag through the path, back, play, menu.
// Usage: node courses-demo.js <outdir>  -> <outdir>/vid/*.webm
const {chromium}=require('playwright');(async()=>{const d=process.argv[2];const b=await chromium.launch();
const W=1280,H=592,u=H/100;
const c=await b.newContext({viewport:{width:W,height:H},recordVideo:{dir:d+'/vid',size:{width:W,height:H}}});const p=await c.newPage();
await p.goto('http://localhost:8765/',{waitUntil:'commit'});await p.waitForTimeout(5000);
const drag=async(x0,dx,steps=24)=>{await p.mouse.move(x0,H*0.64);await p.mouse.down();
 for(let i=1;i<=steps;i++){await p.mouse.move(x0+dx*i/steps,H*0.64);await p.waitForTimeout(16)}await p.mouse.up()};
await p.mouse.click(W*0.33,H*0.6);await p.waitForTimeout(2600);           // locked card: shake + toast
await drag(300,500);await p.waitForTimeout(1200);                         // next card
await drag(300,500);await p.waitForTimeout(1200);
await drag(800,-500);await p.waitForTimeout(1200);                        // back
await drag(800,-500);await p.waitForTimeout(1500);                        // to the first
await p.mouse.click(W-(158/1844*W)-W*0.32,H*0.795);await p.waitForTimeout(2400); // play
await p.mouse.click(W-9.2*u,6.4*u);await p.waitForTimeout(1500);          // menu open
await p.mouse.click(200,300);await p.waitForTimeout(1500);                // close
await c.close();await b.close()})();
