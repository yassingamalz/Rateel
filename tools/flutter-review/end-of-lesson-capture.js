// Screen 24 (end of lesson) captures: node tools/flutter-review/end-of-lesson-capture.js <outdir> [names]
// Web build on :8765. Desktop 1844x853 (dpr 1, reference size) and phone 915x412 (dpr 2.625).
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2];
  const base = 'lessons=1,1&openLesson=0&listenAt=0.6&streak=4';
  const all = {
    'end-dark': [base + '&end=3', 1844, 853, 1],
    'end-light': [base + '&end=3&readTheme=light', 1844, 853, 1],
    'end-dark-2stars': [base + '&end=2', 1844, 853, 1],
    'end-dark-1star': [base + '&end=1', 1844, 853, 1],
    'end-phone-dark': [base + '&end=3', 915, 412, 2.625],
    'end-phone-light': [base + '&end=3&readTheme=light', 915, 412, 2.625],
    'end-phone-text110': [base + '&end=3&textScale=1.1', 915, 412, 2.625],
    'end-reading': ['lessons=0,1&openLesson=0&end=3&streak=4', 1844, 853, 1],
  };
  const pick = process.argv[3] ? process.argv[3].split(',') : Object.keys(all);
  const b = await chromium.launch();
  for (const name of pick) {
    const [q, w, h, dpr] = all[name];
    const p = await b.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: dpr });
    await p.goto(`http://localhost:8765/?${q}`, { waitUntil: 'networkidle' });
    await p.waitForTimeout(8000);
    await p.screenshot({ path: `${d}/${name}.png` });
    await p.close();
  }
  await b.close();
})();
