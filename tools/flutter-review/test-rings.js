const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch();
  for (const [n, light] of [[2,0],[5,0],[6,0],[7,0],[9,0],[10,0],[5,1],[7,1],[10,1]]) {
    const p = await b.newPage({ viewport: { width: 915, height: 412 }, deviceScaleFactor: 2 });
    await p.goto(`http://localhost:8765/?lessons=0,4&openLesson=0&testState=results&testRight=${n}${light ? '&readTheme=light' : ''}`, { waitUntil: 'networkidle' });
    await p.waitForTimeout(4000);
    await p.screenshot({ path: `/tmp/claude-0/ring-${n}-${light}.png`, clip: { x: 640, y: 150, width: 260, height: 120 } });
    await p.close();
  }
  await b.close();
})();
