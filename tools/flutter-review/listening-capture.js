// Screen 22 captures: node tools/flutter-review/listening-capture.js <outdir> [tag] [phone|ref|all] [states]; web build on :8765.
// Listening lesson (course 1, unit 1 «noon-mushaddad-theory», mock lesson 0) opened directly, states through the review aids.
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2], tag = process.argv[3] || 'v1', mode = process.argv[4] || 'all';
  // Rule lesson (lesson 0): r1 = an-Nas 1 at 60% (the rule word lit), r6 = an-Nas 6, rq = its first question.
  const all = {
    r1: 'L0&listenAt=0.6', r4: 'L0&listenQ=3&listenAt=0.3', r6: 'L0&listenQ=5&listenAt=0.1', rq: 'L0&listenQ=7&listenAt=0.415&listenPick=0',
    'r1-light': 'L0&listenAt=0.6&readTheme=light',
    // Quiz (lesson 1, the first version of 22).
    ref: 'listenAt=0.415&listenPick=0', idle: 'listenAt=0.001', ok: 'listenState=ok', ko: 'listenState=ko&listenPick=1',
    q4: 'listenQ=3&listenAt=0.3', last: 'listenQ=4&listenState=ok', light: 'listenAt=0.4&listenPick=0&readTheme=light',
    'ko-light': 'listenState=ko&listenPick=1&readTheme=light', text110: 'listenQ=1&listenAt=0.5&listenPick=1&textScale=1.1',
  };
  const pick = process.argv[5] ? process.argv[5].split(',') : Object.keys(all);
  const sizes = mode === 'phone' ? [[915, 412, 2.625, '-phone']] : mode === 'ref' ? [[1844, 853, 1, '']] : [[1844, 853, 1, ''], [915, 412, 2.625, '-phone']];
  const b = await chromium.launch();
  for (const [W, H, dpr, suf] of sizes) for (const name of pick) {
    const p = await b.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: dpr });
    const q = all[name].startsWith('L0') ? 'openLesson=0' + all[name].slice(2) : 'openLesson=1&' + all[name];
    await p.goto(`http://localhost:8765/?lessons=1,1&${q}`, { waitUntil: 'networkidle' });
    await p.waitForTimeout(5000);
    await p.screenshot({ path: `${d}/capture-${tag}-${name}${suf}.png` });
    await p.close();
  }
  await b.close();
})();
