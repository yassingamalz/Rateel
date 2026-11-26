// Screen 22 demo (node tools/flutter-review/listening-demo.js <outdir> [W] [H] [rule|quiz]), web build on :8765, phone shape.
// Listening lesson (course 1, unit 1, mock lesson 0): the verse plays by itself (the recited word lights up, the
// waveform fills), Q1 right → word replays → next → Q2 wrong (shake, red, right one green) → next → Q3 pause/replay,
// right → Q4 → Q5 → «إنهاء» (end). Audio events are logged (`?logAudio=1`) to <outdir>/audio-events.json with their
// time from the start of the recording; tools/flutter-review/listening-demo-audio.py puts the sound back.
const fs = require('fs');
const { chromium } = require('playwright');
(async () => {
  const d = process.argv[2];
  const W = +(process.argv[3] || 915), H = +(process.argv[4] || 412), u = H / 100;
  const mode = process.argv[5] || 'quiz'; // 'rule': the rule lesson (lesson 0), 'quiz': the quiz (lesson 1)
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
  const play = () => tap(W / 2 - 73.2 * u, 68.55 * u); // variant B: left of the waveform
  if (mode === 'rule') {
    // Each ayah plays by itself (ghunna letters green, every word lit in turn) → «التالي» → … → 3 «find» questions
    // (tap the word, then its letter; the second one with a wrong letter).
    await p.goto('http://localhost:8765/?lessons=1,1&openLesson=0&logAudio=1' + (process.env.EXTRA || ''), { waitUntil: 'networkidle' });
    await w(13500);
    // SHORT=1: only the first three ayat (a quick look at the word light).
    if (process.env.SHORT) { for (const ms of [5800, 5800]) { await confirm(); await w(ms); } await c.close(); await b.close(); require('fs').writeFileSync(d + '/audio-events.json', JSON.stringify(events)); return; }
    for (const ms of [5800, 5800, 10300, 11300, 9300, 9800]) { await confirm(); await w(ms); }
    await confirm(); await w(9500);
    // «Find» questions: tap the word in the verse (x from the centre, in u), confirm, then its letter, confirm.
    const word = (dx) => tap(W / 2 + dx * u, 48.15 * u);
    const letter = (k) => tap(W - u * (72.6 + k * 13.7 + 5.75), 89.6 * u);
    for (const [dx, k] of [[-10.8, 2], [33.9, 0], [35.9, 1]]) {
      await word(dx); await w(900); await confirm(); await w(2400);
      await letter(k); await w(900); await confirm(); await w(4500); await confirm(); await w(8500);
    }
  } else {
    await p.goto('http://localhost:8765/?lessons=1,1&openLesson=1&logAudio=1', { waitUntil: 'networkidle' });
    await w(10500);
    await pill(1); await w(700); await pill(0); await w(900); await confirm(); await w(4500); await confirm(); await w(7500);
    await pill(2); await w(900); await confirm(); await w(4500); await confirm(); await w(3500);
    await play(); await w(1500); await play(); await w(8000);
    await pill(1); await w(900); await confirm(); await w(4000); await confirm(); await w(8500);
    await pill(1); await w(900); await confirm(); await w(4000); await confirm(); await w(8500);
    await pill(2); await w(900); await confirm(); await w(4500); await confirm(); await w(4000);
  }
  await c.close();
  await b.close();
  fs.writeFileSync(d + '/audio-events.json', JSON.stringify(events));
})();
