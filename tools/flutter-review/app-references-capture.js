// App screenshots used as ChatGPT style references (docs/flutter/app-references/).
// node tools/flutter-review/app-references-capture.js <outdir> [names]; web build of master on :8765.
// 1844x853, dark, deviceScaleFactor 1 (the size of the references). Save as webp with cwebp/PIL afterwards.
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2];
  const all = {
    'app-03-courses': '',
    'app-05-units': 'units=0',
    'app-06-lessons': 'lessons=0,1',
    'app-08-reading-dark': 'lessons=0,1&openLesson=0',
    'app-08-reading-rules': 'lessons=0,1&openLesson=0&rules=1',
    'app-10-test-question': 'lessons=0,4&openLesson=0&testQ=3&testPick=1',
    'app-10-test-results': 'lessons=0,4&openLesson=0&testState=results',
    'app-11-leaderboard': 'section=3',
    'app-12-daily-challenges': 'challenges=1&chalDone=3&streak=4',
    'app-14-coming-soon': 'section=1',
    'app-22-listening-rule': 'lessons=1,1&openLesson=0&listenAt=0.6',
    'app-22-listening-question': 'lessons=1,1&openLesson=1&listenState=ok',
    'app-23-settings': 'section=6',
    'app-08-reading-light': 'lessons=0,1&openLesson=0&readTheme=light',
    'app-10-test-results-light': 'lessons=0,4&openLesson=0&testState=results&readTheme=light',
  };
  const pick = process.argv[3] ? process.argv[3].split(',') : Object.keys(all);
  const b = await chromium.launch();
  for (const name of pick) {
    const p = await b.newPage({ viewport: { width: 1844, height: 853 }, deviceScaleFactor: 1 });
    await p.goto(`http://localhost:8765/?${all[name]}`, { waitUntil: 'networkidle' });
    await p.waitForTimeout(6000);
    await p.screenshot({ path: `${d}/${name}.png` });
    await p.close();
  }
  await b.close();
})();
