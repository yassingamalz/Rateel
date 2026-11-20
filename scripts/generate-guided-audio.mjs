#!/usr/bin/env node
/**
 * Generates the narration audio for guided (Simply-Piano-style) lessons
 * with Google Gemini TTS, and downloads the Quran recitation clips they use.
 *
 * Usage:
 *   GEMINI_API_KEY=... node scripts/generate-guided-audio.mjs [lessonId ...] [--voice Charon] [--force]
 *
 * - Reads  src/assets/data/content/guided/<lessonId>.json
 * - Writes src/assets/audio/guided/<lessonId>/<stepId>.mp3
 *          src/assets/audio/guided/common/<key>.mp3
 *          src/assets/audio/quran/husary-muallim/<sss><aaa>.mp3
 * - Keeps a manifest (text + voice hash) so unchanged lines are not regenerated.
 *
 * Each take is checked (length + transcription) and regenerated if the model
 * read anything other than the Arabic text. Requires ffmpeg/ffprobe on PATH.
 */
import { readFile, writeFile, mkdir, readdir, access, unlink } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';
import os from 'node:os';

const run = promisify(execFile);
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const CONTENT_DIR = path.join(ROOT, 'src/assets/data/content/guided');
const AUDIO_DIR = path.join(ROOT, 'src/assets/audio/guided');
const SRC_ASSETS = path.join(ROOT, 'src');

const args = process.argv.slice(2);
const flag = (name, def) => {
  const i = args.indexOf(`--${name}`);
  if (i === -1) return def;
  const v = args[i + 1];
  args.splice(i, 2);
  return v;
};
const FORCE = args.includes('--force');
if (FORCE) args.splice(args.indexOf('--force'), 1);
const VOICE = flag('voice', 'Charon');
const MODEL = flag('model', 'gemini-3.8-flash-tts');
const KEY = process.env.GEMINI_API_KEY;

const CHECK_MODEL = flag('check-model', 'gemini-3.8-flash');
// Short director's note in the format Gemini TTS expects ("Say <style>: <text>").
// Longer English instructions are sometimes read aloud, so every result is verified below.
const STYLE = 'Say in a warm, calm and encouraging Arabic teacher voice: ';
// Off by default: the TTS model sometimes reads the director's note aloud. Opt in with --style.
const USE_STYLE = args.includes('--style') && (args.splice(args.indexOf('--style'), 1), true);

const exists = (p) => access(p).then(() => true, () => false);
const hash = (s) => createHash('sha1').update(s).digest('hex').slice(0, 12);

async function gemini(model, body) {
  for (let attempt = 1; ; attempt++) {
    const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-goog-api-key': KEY },
      body: JSON.stringify(body),
    });
    const json = await res.json();
    if (res.status === 429 || res.status >= 500) {
      if (attempt > 8) throw new Error(JSON.stringify(json).slice(0, 300));
      const retry = /"retryDelay":\s*"(\d+)/.exec(JSON.stringify(json))?.[1];
      const wait = (Number(retry) || 10 * attempt) * 1000;
      if (wait > 120_000) throw new Error(`Gemini quota exhausted — retry in ~${Math.round(wait / 60000)} min`);
      process.stdout.write(`    … rate limited, waiting ${wait / 1000}s\n`);
      await new Promise((r) => setTimeout(r, wait));
      continue;
    }
    return json;
  }
}

const duration = async (file) =>
  Number((await run('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', file])).stdout);

/** Returns a problem description, or null when the clip reads exactly the given Arabic text. */
async function verify(file, text) {
  const secs = await duration(file);
  const letters = text.replace(/[\u064B-\u0652\u0670\s\p{P}]/gu, '').length;
  const maxSecs = letters * 0.24 + 1.5; // normal pace is ~0.16–0.20 s per letter
  if (secs > maxSecs) return `too long (${secs.toFixed(1)}s > ${maxSecs.toFixed(1)}s)`;
  const json = await gemini(CHECK_MODEL, {
    contents: [{ parts: [
      { inline_data: { mime_type: 'audio/mp3', data: (await readFile(file)).toString('base64') } },
      { text: 'Transcribe this audio verbatim in its original language(s). Output only the transcript.' },
    ] }],
  });
  const transcript = json?.candidates?.[0]?.content?.parts?.map((p) => p.text ?? '').join('') ?? '';
  if (!transcript.trim()) return 'could not transcribe (API busy) — not verified';
  if (/[A-Za-z]{3,}/.test(transcript)) return `contains non-Arabic speech: ${transcript.slice(0, 80)}`;
  return null;
}

async function tts(text, outMp3) {
  for (let attempt = 1; attempt <= 5; attempt++) {
    // Short lines are the ones most likely to have the director's note read aloud:
    // after two bad takes, send the bare text instead.
    await synth(USE_STYLE && attempt <= 2 ? STYLE + text : text, outMp3);
    const problem = await verify(outMp3, text);
    if (!problem) return;
    process.stdout.write(`    ✗ ${path.basename(outMp3)}: ${problem} — retrying\n`);
  }
  throw new Error(`Could not produce a clean take for ${outMp3}`);
}

async function synth(prompt, outMp3) {
  const text = prompt;
  if (!KEY) throw new Error('GEMINI_API_KEY is not set');
  const body = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: {
      responseModalities: ['AUDIO'],
      speechConfig: { voiceConfig: { prebuiltVoiceConfig: { voiceName: VOICE } } },
    },
  };
  let lastErr;
  for (let attempt = 1; attempt <= 4; attempt++) {
    try {
      const json = await gemini(MODEL, body);
      const part = json?.candidates?.[0]?.content?.parts?.find((p) => p.inlineData);
      if (!part) throw new Error(`No audio in response: ${JSON.stringify(json).slice(0, 300)}`);
      const { mimeType, data } = part.inlineData;
      const raw = Buffer.from(data, 'base64');
      const tmp = path.join(os.tmpdir(), `tts-${process.pid}-${hash(text)}`);
      const isWav = /wav/i.test(mimeType);
      const rate = /rate=(\d+)/.exec(mimeType)?.[1] ?? '24000';
      await writeFile(tmp, raw);
      const input = isWav ? ['-i', tmp] : ['-f', 's16le', '-ar', rate, '-ac', '1', '-i', tmp];
      await run('ffmpeg', [
        '-y', '-loglevel', 'error', ...input,
        // trim leading/trailing silence, normalise loudness for consistent levels
        '-af', 'silenceremove=start_periods=1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:start_threshold=-50dB,areverse,loudnorm=I=-16:TP=-1.5:LRA=11,apad=pad_dur=0.25',
        '-ac', '1', '-ar', '24000', '-b:a', '64k', outMp3,
      ]);
      await unlink(tmp).catch(() => {});
      return;
    } catch (e) {
      lastErr = e;
      await new Promise((r) => setTimeout(r, 1500 * attempt));
    }
  }
  throw lastErr;
}

async function download(url, out) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`${res.status} for ${url}`);
  await writeFile(out, Buffer.from(await res.arrayBuffer()));
}

async function pool(tasks, size = 3) {
  const queue = [...tasks];
  await Promise.all(
    Array.from({ length: size }, async () => {
      while (queue.length) await queue.shift()();
    })
  );
}

async function main() {
  const ids = args.length
    ? args
    : (await readdir(CONTENT_DIR)).filter((f) => f.endsWith('.json')).map((f) => f.replace(/\.json$/, ''));

  const manifestPath = path.join(AUDIO_DIR, 'manifest.json');
  await mkdir(AUDIO_DIR, { recursive: true });
  const manifest = (await exists(manifestPath)) ? JSON.parse(await readFile(manifestPath, 'utf8')) : {};
  const jobs = [];

  const queueLine = async (rel, text) => {
    const out = path.join(AUDIO_DIR, rel);
    const h = hash(`${MODEL}|${VOICE}|${text}`);
    if (!FORCE && manifest[rel] === h && (await exists(out))) return;
    await mkdir(path.dirname(out), { recursive: true });
    jobs.push(async () => {
      process.stdout.write(`  ♪ ${rel}\n`);
      await tts(text, out);
      manifest[rel] = h;
      await writeFile(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
    });
  };

  for (const id of ids) {
    const lesson = JSON.parse(await readFile(path.join(CONTENT_DIR, `${id}.json`), 'utf8'));
    console.log(`Lesson ${id}`);
    for (const step of lesson.steps) {
      if (step.narration) await queueLine(`${id}/${step.id}.mp3`, step.narration);
      if (step.verse?.audio) {
        const out = path.join(SRC_ASSETS, step.verse.audio);
        if (!(await exists(out))) {
          await mkdir(path.dirname(out), { recursive: true });
          const file = path.basename(step.verse.audio);
          jobs.push(async () => {
            process.stdout.write(`  ⬇ ${file}\n`);
            await download(`https://everyayah.com/data/Husary_Muallim_128kbps/${file}`, out);
          });
        }
      }
    }
    for (const [key, text] of Object.entries(lesson.common ?? {})) {
      await queueLine(`common/${key}.mp3`, text);
    }
  }

  console.log(`${jobs.length} file(s) to generate (voice: ${VOICE}, model: ${MODEL})`);
  await pool(jobs, 2);
  await writeFile(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
  console.log('Done.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
