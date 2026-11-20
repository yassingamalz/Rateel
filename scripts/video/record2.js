// Records the guided lesson at real speed, full-frame and sharp (2x), by streaming
// CDP screencast frames into ffmpeg at a constant 30 fps. Media playback is logged
// so mix.py can rebuild the soundtrack in sync.
// usage: node record2.js <theme: ornate|glow|glassy|keep> <out-dir>
// env: LESSON_URL (app path of the lesson), STEPS (number of steps), MISTAKE (step index with one deliberate wrong answer),
//      CONTENT_FROM (content file to load instead, e.g. lesson-10-1-orus for a voice test)
const { chromium } = require('playwright');
const { spawn } = require('child_process');
const fs = require('fs');

const theme = process.argv[2] || 'ornate';
const out = process.argv[3] || 'rec-' + theme;
const W = 1688, H = 780, FPS = 30;
fs.mkdirSync(out, { recursive: true });

(async () => {
  const b = await chromium.launch({ args: ['--autoplay-policy=no-user-gesture-required', '--use-fake-device-for-media-stream', '--use-fake-ui-for-media-stream'] });
  const ctx = await b.newContext({ viewport: { width: 844, height: 390 }, deviceScaleFactor: 2, permissions: ['microphone'] });
  const p = await ctx.newPage();
  await p.route('**/content/guided/*.json', async (route) => {
    // CONTENT_FROM=<lessonId>: play another content file (e.g. a voice test) on the same lesson route
    const from = process.env.CONTENT_FROM;
    const res = await route.fetch(from ? { url: route.request().url().replace(/[^/]+\.json$/, from + '.json') } : undefined);
    const json = await res.json();
    if (theme !== 'keep') json.theme = theme;
    await route.fulfill({ response: res, json });
  });
  await p.addInitScript(() => {
    window.__media = [];
    const proto = HTMLMediaElement.prototype;
    const play = proto.play, pause = proto.pause;
    const close = (el) => {
      const open = window.__media.find((m) => m.el === el && m.end == null);
      if (open) open.end = Date.now();
    };
    proto.play = function () {
      close(this);
      if (this.src && !this.src.startsWith('data:') && !this.src.startsWith('blob:')) {
        window.__media.push({ el: this, src: this.src, at: Date.now(), from: this.currentTime });
        this.addEventListener('ended', () => close(this), { once: true });
      }
      return play.call(this);
    };
    proto.pause = function () { close(this); return pause.call(this); };
  });
  const lessonUrl = process.env.LESSON_URL || '/courses/01-tajweed-fundamentals/units/intro-tajweed/lessons/intro-lesson-1';
  const STEPS = +(process.env.STEPS || 14);
  const MISTAKE = +(process.env.MISTAKE ?? 3);
  await p.goto('http://localhost:4300' + lessonUrl, { waitUntil: 'networkidle' });
  await p.waitForTimeout(2000);

  // ── start capture only once the lesson is on screen (no blank frames) ──
  const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-c:v', 'mjpeg', '-i', '-',
    '-vf', `scale=${W}:${H}:flags=lanczos,format=yuv420p`, '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '18', `${out}/video.mp4`]);
  const cdp = await ctx.newCDPSession(p);
  let latest = null;
  cdp.on('Page.screencastFrame', (f) => {
    latest = Buffer.from(f.data, 'base64');
    cdp.send('Page.screencastFrameAck', { sessionId: f.sessionId }).catch(() => {});
  });
  await cdp.send('Page.startScreencast', { format: 'jpeg', quality: 92, maxWidth: W, maxHeight: H, everyNthFrame: 1 });
  while (!latest) await new Promise((r) => setTimeout(r, 20));
  const t0 = Date.now();
  let written = 0;
  const timer = setInterval(() => {
    const due = Math.floor(((Date.now() - t0) / 1000) * FPS);
    while (written < due) { ff.stdin.write(latest); written++; }
  }, 10);

  await p.waitForTimeout(1500);
  await p.click('.cta');
  await p.waitForTimeout(1500);
  const human = () => p.waitForTimeout(1300);
  const quiet = (ms = 120000) => p.waitForFunction(() => !document.querySelector('.coach.talking'), null, { timeout: ms });

  for (let i = 0; i < STEPS; i++) {
    const type = await p.evaluate(() => document.querySelector('.guided .scene')?.className || '');
    if (type.includes('type-quiz')) {
      await quiet(60000);
      await p.waitForTimeout(900);
      const opts = await p.$$('.option');
      if (i === MISTAKE) { await opts[2].click(); await p.waitForTimeout(2200); } // one deliberate mistake
      const correctIdx = await p.evaluate(() => {
        const c = window.ng?.getComponent?.(document.querySelector('app-guided-lesson'));
        return c ? c.step().options.findIndex((o) => o.id === c.step().correctId) : -1;
      });
      if (correctIdx >= 0) { await opts[correctIdx].click(); await p.waitForTimeout(2200); }
      for (const o of opts) {
        if (await p.$('.option.correct')) break;
        if ((await o.getAttribute('class')).includes('wrong')) continue;
        await o.click();
        await p.waitForTimeout(2200);
      }
      await p.waitForTimeout(2500);
    }
    if (type.includes('type-repeat')) {
      await p.waitForSelector('.mic.ready', { timeout: 90000 });
      await human();
      await p.click('.mic');
      await p.waitForSelector('.mic.live', { timeout: 10000 });
      await p.waitForTimeout(4500);
      await p.click('.mic');
      await quiet(30000);
    }
    if (i === STEPS - 1) { await quiet(90000); await p.waitForTimeout(3000); break; }
    await p.waitForSelector('.continue.ready', { timeout: 120000 });
    await quiet();
    await human();
    await p.click('.continue');
    await p.waitForTimeout(1500);
  }

  clearInterval(timer);
  await cdp.send('Page.stopScreencast');
  const media = await p.evaluate(() => window.__media.map(({ src, at, from, end }) => ({ src, at, from, end: end ?? Date.now() })));
  ff.stdin.end();
  await new Promise((r) => ff.on('close', r));
  await b.close();
  fs.writeFileSync(`${out}/media.json`, JSON.stringify({ t0, video: `${out}/video.mp4`, media }, null, 2));
  console.log('done', out, 'frames', written, 'seconds', written / FPS);
})();
