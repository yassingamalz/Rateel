// Screen 22 demo (node tools/flutter-review/listening-demo.js <outdir> [W] [H]), web build on :8765, phone shape.
// Listening lesson (course 1, unit 1, mock lesson 0): the verse plays by itself (the recited word lights up, the
// waveform fills), Q1 right → word replays → next → Q2 wrong (shake, red, right one green) → next → Q3 pause/replay,
// right → Q4 → Q5 → «إنهاء» (end). Audio events are logged (`?logAudio=1`) to <outdir>/audio-events.json with their
// time from the start of the recording; tools/flutter-review/listening-demo-audio.py puts the sound back.
const fs = require('fs');
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2];
  const W = +(process.argv[3] || 915), H = +(process.argv[4] || 412), u = H / 100;
  const b = await chromium.launch({ args: ['--autoplay-policy=no-user-gesture-required'] });
  const c = await b.newContext({ viewport: { width: W, height: H }, recordVideo: { dir: d + '/vid-22', size: { width: W, height: H } } });
  const p = await c.newPage();
  const t0 = Date.now();
  const events = [];
  p.on('console', (m) => { const t = m.text(); if (t.startsWith('AUDIO ')) events.push([Date.now() - t0, t.slice(6)]); });
  const w = (ms) => p.waitForTimeout(ms);
  const tap = (x, y) => p.mouse.click(x, y);
  const pill = (i) => tap(W - u * (72.6 + i * 31.1 + 13.6), 89.6 * u);
  const confirm = () => tap(u * 23, 89 * u);
  const play = () => tap(W / 2, 73.6 * u);
  await p.goto('http://localhost:8765/?lessons=1,1&openLesson=0&logAudio=1', { waitUntil: 'networkidle' });
  await w(10500);
  await pill(1); await w(700); await pill(0); await w(900); await confirm(); await w(4500); await confirm(); await w(7500);
  await pill(2); await w(900); await confirm(); await w(4500); await confirm(); await w(3500);
  await play(); await w(1500); await play(); await w(8000);
  await pill(1); await w(900); await confirm(); await w(4000); await confirm(); await w(8500);
  await pill(1); await w(900); await confirm(); await w(4000); await confirm(); await w(8500);
  await pill(2); await w(900); await confirm(); await w(4500); await confirm(); await w(4000);
  await c.close();
  await b.close();
  fs.writeFileSync(d + '/audio-events.json', JSON.stringify(events));
})();
