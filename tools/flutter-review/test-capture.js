// Screen 10 captures: node tools/flutter-review/test-capture.js <outdir> [tag] [phone|ref|all] [states]; web build on :8765.
// Test lesson (course 0, unit 4 «assessment-fundamentals», lesson 0) opened directly, states through the review aids.
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2], tag = process.argv[3] || 'v1', mode = process.argv[4] || 'all';
  const all = {
    q: 'testQ=4', sel: 'testQ=3&testPick=1', ok: 'testQ=4&testState=ok', ko: 'testQ=4&testState=ko&testPick=1',
    light: 'testQ=4&readTheme=light', 'sel-light': 'testQ=3&testPick=1&readTheme=light', 'ko-light': 'testQ=4&testState=ko&testPick=1&readTheme=light',
    results: 'testState=results', fail: 'testState=fail', details: 'testState=details',
    tf: 'testQ=7', 'results-light': 'testState=results&readTheme=light', streak: 'testQ=4&testState=streak', partial: 'testQ=3&testState=partial', 'fail-light': 'testState=fail&readTheme=light', 'q-light': 'testQ=4&readTheme=light', text: 'testQ=5&testState=ko', multi: 'testQ=2', first: '',
  };
  const pick = process.argv[5] ? process.argv[5].split(',') : Object.keys(all);
  const sizes = mode === 'phone' ? [[915, 412, 2.625, '-phone']] : mode === 'ref' ? [[1842, 854, 1, '']] : [[1842, 854, 1, ''], [915, 412, 2.625, '-phone']];
  const b = await chromium.launch();
  for (const [W, H, dpr, suf] of sizes) for (const name of pick) {
    const p = await b.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: dpr });
    await p.goto(`http://localhost:8765/?lessons=0,4&openLesson=0&${all[name]}`, { waitUntil: 'networkidle' });
    await p.waitForTimeout(4500);
    await p.screenshot({ path: `${d}/capture-${tag}-${name}${suf}.png` });
    await p.close();
  }
  await b.close();
})();
