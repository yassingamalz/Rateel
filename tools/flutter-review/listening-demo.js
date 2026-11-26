// Screen 22 demo (node tools/flutter-review/listening-demo.js <outdir>), web build on :8765, phone size 915x412.
// Listening lesson (course 1, unit 1, mock lesson 0): the verse plays by itself (words light up, waveform fills),
// Q1 right → word replays → next → Q2 wrong (shake, red, right one green) → next → Q3 pause/replay, right → … → last → end.
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2];
  const b = await chromium.launch({ args: ['--autoplay-policy=no-user-gesture-required'] });
  const W = 915, H = 412, u = H / 100;
  const c = await b.newContext({ viewport: { width: W, height: H }, recordVideo: { dir: d + '/vid-22', size: { width: W, height: H } } });
  const p = await c.newPage();
  const w = (ms) => p.waitForTimeout(ms);
  const tap = (x, y) => p.mouse.click(x, y);
  const pill = (i) => tap(W - u * (72.6 + i * 31.1 + 13.6), 89.6 * u);
  const confirm = () => tap(u * 23, 89 * u);
  const play = () => tap(W / 2, 73.6 * u);
  await p.goto('http://localhost:8765/?lessons=1,1&openLesson=0', { waitUntil: 'networkidle' });
  await w(10500);
  await pill(1); await w(700); await pill(0); await w(900); await confirm(); await w(4500); await confirm(); await w(7500);
  await pill(2); await w(900); await confirm(); await w(4500); await confirm(); await w(3500);
  await play(); await w(1500); await play(); await w(8000);
  await pill(1); await w(900); await confirm(); await w(4000); await confirm(); await w(8500);
  await pill(1); await w(900); await confirm(); await w(4000); await confirm(); await w(8500);
  await pill(2); await w(900); await confirm(); await w(4500); await confirm(); await w(4000);
  await c.close();
  await b.close();
})();
