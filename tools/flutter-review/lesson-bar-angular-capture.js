const { chromium } = require('playwright');
const out = process.argv[2];
(async () => {
  const b = await chromium.launch();
  const shots = async (vw, vh, suffix) => {
    const p = await b.newPage({ viewport: { width: vw, height: vh } });
    p.on('console', m => { if (m.type()==='error') console.log('ERR', m.text().slice(0,150)); });
    await p.goto('http://localhost:4300/');
    const exp = Date.now() + 1e10;
    await p.evaluate((exp) => {
      localStorage.setItem('tajweed_lesson_01-tajweed-fundamentals_intro-tajweed_intro-lesson-1',
        JSON.stringify({progress: 42, timestamp: Date.now(), expiresAt: exp, isCompleted:false, isLocked:false, version:'1.0.0', syncStatus:'pending', lastUpdated: Date.now()}));
    }, exp);
    await p.goto('http://localhost:4300/courses/01-tajweed-fundamentals/units/intro-tajweed/lessons/intro-lesson-1');
    await p.waitForTimeout(3500);
    await p.screenshot({ path: `${out}/video-closed${suffix}.png` });
    await p.click('.control-button');
    await p.waitForTimeout(800);
    await p.screenshot({ path: `${out}/video-menu${suffix}.png` });
    await p.goto('http://localhost:4300/courses/01-tajweed-fundamentals/units/pronunciation-practice/lessons/pronunciation-lesson-1');
    await p.waitForTimeout(3500);
    await p.screenshot({ path: `${out}/practice${suffix}.png` });
    await p.close();
  };
  await shots(1844, 853, '');
  await shots(915, 412, '-phone');
  await b.close();
})();
