// Screen 22 captures: node tools/flutter-review/listening-capture.js <outdir> [tag] [phone|ref|all] [states]; web build on :8765.
// Listening lesson (course 1, unit 1 «noon-mushaddad-theory», mock lesson 0) opened directly, states through the review aids.
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2], tag = process.argv[3] || 'v1', mode = process.argv[4] || 'all';
  const all = {
    ref: 'listenAt=0.415&listenPick=0', idle: 'listenAt=0.001', ok: 'listenState=ok', ko: 'listenState=ko&listenPick=1',
    q4: 'listenQ=3&listenAt=0.3', last: 'listenQ=4&listenState=ok', light: 'listenAt=0.4&listenPick=0&readTheme=light',
    'ko-light': 'listenState=ko&listenPick=1&readTheme=light', text110: 'listenQ=1&listenAt=0.5&listenPick=1&textScale=1.1',
  };
  const pick = process.argv[5] ? process.argv[5].split(',') : Object.keys(all);
  const sizes = mode === 'phone' ? [[915, 412, 2.625, '-phone']] : mode === 'ref' ? [[1844, 853, 1, '']] : [[1844, 853, 1, ''], [915, 412, 2.625, '-phone']];
  const b = await chromium.launch();
  for (const [W, H, dpr, suf] of sizes) for (const name of pick) {
    const p = await b.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: dpr });
    await p.goto(`http://localhost:8765/?lessons=1,1&openLesson=0&${all[name]}`, { waitUntil: 'networkidle' });
    await p.waitForTimeout(5000);
    await p.screenshot({ path: `${d}/capture-${tag}-${name}${suf}.png` });
    await p.close();
  }
  await b.close();
})();
