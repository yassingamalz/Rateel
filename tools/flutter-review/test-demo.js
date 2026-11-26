// Screen 10 demo (node tools/flutter-review/test-demo.js <outdir>), web build on :8765, phone size 915x412.
// Test lesson (course 0, unit 4, lesson 0) opened at question 8 (1–7 answered right): true/false right → next →
// question 9 wrong (shake, red, correct shown) → next → question 10 partly right → «إنهاء الاختبار» → results and
// end popup → tap closes it → moon (light) → answer details → close → «إنهاء الدرس» (back to screen 06).
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2];
  const b = await chromium.launch();
  const W = 915, H = 412, u = H / 100;
  const c = await b.newContext({ viewport: { width: W, height: H }, recordVideo: { dir: d + '/vid-10', size: { width: W, height: H } } });
  const p = await c.newPage();
  const w = (ms) => p.waitForTimeout(ms);
  const tap = (x, y) => p.mouse.click(x, y);
  await p.goto('http://localhost:8765/?lessons=0,4&openLesson=0&testQ=7', { waitUntil: 'networkidle' });
  await w(3000);
  const row = (k) => (49.5 + 4.75 + k * 12.4) * u;
  const confirm = () => tap(W / 2, 86.25 * u);
  const next = () => tap(34.8 * u, 83.7 * u);
  await tap(W / 2, row(0)); await w(900); await confirm(); await w(2600); await next(); await w(1400);
  await tap(W / 2, row(1)); await w(900); await confirm(); await w(2800); await next(); await w(1400);
  await tap(W / 2, row(0)); await w(500); await tap(W / 2, row(1)); await w(900); await confirm(); await w(2800);
  await next(); await w(4200);
  await tap(W / 2, 50 * u); await w(1500);
  await tap(11.5 * u, 22 * u); await w(1800);
  await tap(30 * u, 47.5 * u); await w(2600);
  await tap(W / 2, 79.7 * u); await w(1200);
  await tap(11.5 * u, 22 * u); await w(1500);
  await tap(W / 2 + 21.5 * u, 86.25 * u); await w(4500);
  await c.close();
  await b.close();
})();
