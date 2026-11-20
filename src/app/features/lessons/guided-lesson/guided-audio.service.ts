import { Injectable, NgZone, OnDestroy, signal } from '@angular/core';
import { GuidedVerse } from './guided-lesson.types';

type Sfx = 'tap' | 'correct' | 'wrong' | 'reveal' | 'whoosh' | 'complete' | 'star';

/**
 * Audio engine for guided lessons:
 * - narration (pre-generated Gemini TTS mp3, falling back to the device's Arabic speech voice,
 *   then to a silent timer so the lesson never gets stuck),
 * - Quran recitation playback with per-word timing,
 * - soft UI sound effects synthesised with Web Audio (no music),
 * - microphone recording with a live input level.
 */
@Injectable()
export class GuidedAudioService implements OnDestroy {
  /** 0–1 progress of the narration currently playing. */
  readonly narrationProgress = signal(0);
  readonly narrating = signal(false);
  /** Index of the Quran word being recited, or -1. */
  readonly activeWord = signal(-1);
  readonly reciting = signal(false);
  /** 0–1 microphone level while recording. */
  readonly micLevel = signal(0);
  readonly recording = signal(false);
  readonly playingRecording = signal(false);
  readonly muted = signal(false);

  private narrationEl = new Audio();
  private verseEl = new Audio();
  private fxEl = new Audio();
  private recEl = new Audio();
  private ctx?: AudioContext;
  private raf = 0;
  private token = 0;
  private timer?: ReturnType<typeof setInterval>;

  private mediaRecorder?: MediaRecorder;
  private stream?: MediaStream;
  private recordingUrl?: string;

  constructor(private zone: NgZone) {
    for (const el of [this.narrationEl, this.verseEl, this.fxEl, this.recEl]) {
      el.preload = 'auto';
    }
  }

  // ───────────────────────────── narration ─────────────────────────────

  /** Plays a narration clip. Resolves when it ends or is interrupted by stopAll(). */
  playNarration(url: string | undefined, text: string): Promise<void> {
    this.stopAll();
    const token = ++this.token;
    this.narrationProgress.set(0);
    this.narrating.set(true);

    const finish = () => {
      if (token !== this.token) return;
      this.narrationProgress.set(1);
      this.narrating.set(false);
      this.stopLoop();
    };

    return new Promise<void>((resolve) => {
      const done = () => { finish(); resolve(); };
      if (!url) { this.speakFallback(text, token).then(done); return; }

      const el = this.narrationEl;
      el.src = url;
      el.muted = this.muted();
      el.currentTime = 0;
      el.onended = done;
      el.onerror = () => this.speakFallback(text, token).then(done);
      this.loop(() => {
        if (el.duration > 0) this.narrationProgress.set(Math.min(1, el.currentTime / el.duration));
      });
      el.play().catch(() => this.speakFallback(text, token).then(done));
      this.onInterrupt(token, resolve);
    });
  }

  /** Short one-off spoken feedback ("أحسنت!") that does not affect narration progress. */
  playFeedback(url: string): void {
    this.fxEl.pause();
    this.fxEl.src = url;
    this.fxEl.muted = this.muted();
    this.fxEl.play().catch(() => {});
  }

  private speakFallback(text: string, token: number): Promise<void> {
    return new Promise((resolve) => {
      if (token !== this.token) return resolve();
      const estimated = Math.max(2500, text.length * 75);
      const synth = typeof window !== 'undefined' ? window.speechSynthesis : undefined;
      const voice = synth?.getVoices().find((v) => v.lang?.toLowerCase().startsWith('ar'));

      if (synth && voice && !this.muted()) {
        const u = new SpeechSynthesisUtterance(text);
        u.voice = voice;
        u.lang = voice.lang;
        u.rate = 0.92;
        u.onboundary = (e) => this.narrationProgress.set(Math.min(1, e.charIndex / text.length));
        u.onend = () => resolve();
        u.onerror = () => resolve();
        synth.cancel();
        synth.speak(u);
        this.onInterrupt(token, resolve);
        return;
      }
      // Silent timer so captions still advance at reading pace.
      const start = performance.now();
      this.loop(() => {
        const p = (performance.now() - start) / estimated;
        this.narrationProgress.set(Math.min(1, p));
        if (p >= 1) resolve();
      });
      this.onInterrupt(token, resolve);
    });
  }

  private onInterrupt(token: number, resolve: () => void): void {
    clearInterval(this.timer);
    this.timer = setInterval(() => {
      if (token !== this.token) { clearInterval(this.timer); resolve(); }
    }, 100);
  }

  // ───────────────────────────── recitation ─────────────────────────────

  /** Plays a Quran clip, updating activeWord from the reciter's segment timings. */
  playVerse(verse: GuidedVerse): Promise<void> {
    this.stopAll();
    const token = ++this.token;
    const el = this.verseEl;
    const [clipStart, clipEnd] = verse.clip ?? [0, Number.POSITIVE_INFINITY];
    this.reciting.set(true);
    this.activeWord.set(-1);

    return new Promise<void>((resolve) => {
      const done = () => {
        if (token === this.token) {
          el.pause();
          this.reciting.set(false);
          this.activeWord.set(-1);
          this.stopLoop();
        }
        resolve();
      };
      el.src = verse.audio;
      el.muted = this.muted();
      el.onended = done;
      el.onerror = done;
      const start = () => {
        el.currentTime = clipStart / 1000;
        el.play().catch(done);
      };
      if (el.readyState >= 1) start(); else el.onloadedmetadata = start;

      this.loop(() => {
        const ms = el.currentTime * 1000;
        if (ms >= clipEnd) { done(); return; }
        const seg = verse.segments.find(([, s, e]) => ms >= s - 40 && ms <= e + 60);
        this.activeWord.set(seg ? seg[0] : (ms > (verse.segments.at(-1)?.[2] ?? 0) ? -1 : this.activeWord()));
      });
      this.onInterrupt(token, done);
    });
  }

  // ───────────────────────────── recording ─────────────────────────────

  get canRecord(): boolean {
    return typeof navigator !== 'undefined' && !!navigator.mediaDevices?.getUserMedia
      && typeof MediaRecorder !== 'undefined';
  }

  async startRecording(): Promise<boolean> {
    this.stopAll();
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: { echoCancellation: true, noiseSuppression: true } });
    } catch {
      return false;
    }
    const chunks: Blob[] = [];
    this.mediaRecorder = new MediaRecorder(this.stream);
    this.mediaRecorder.ondataavailable = (e) => e.data.size && chunks.push(e.data);
    this.mediaRecorder.onstop = () => {
      if (this.recordingUrl) URL.revokeObjectURL(this.recordingUrl);
      this.recordingUrl = URL.createObjectURL(new Blob(chunks, { type: this.mediaRecorder?.mimeType || 'audio/webm' }));
    };
    this.mediaRecorder.start();
    this.recording.set(true);

    const ctx = this.audioCtx();
    if (ctx) {
      const analyser = ctx.createAnalyser();
      analyser.fftSize = 512;
      ctx.createMediaStreamSource(this.stream).connect(analyser);
      const data = new Uint8Array(analyser.fftSize);
      this.loop(() => {
        analyser.getByteTimeDomainData(data);
        let sum = 0;
        for (const v of data) sum += ((v - 128) / 128) ** 2;
        const rms = Math.sqrt(sum / data.length);
        this.micLevel.set(Math.min(1, this.micLevel() * 0.6 + Math.min(1, rms * 5) * 0.4));
      });
    }
    return true;
  }

  stopRecording(): Promise<void> {
    return new Promise((resolve) => {
      this.stopLoop();
      this.micLevel.set(0);
      this.recording.set(false);
      const rec = this.mediaRecorder;
      if (!rec || rec.state === 'inactive') { this.releaseMic(); return resolve(); }
      rec.addEventListener('stop', () => { this.releaseMic(); setTimeout(resolve, 0); }, { once: true });
      rec.stop();
    });
  }

  get hasRecording(): boolean {
    return !!this.recordingUrl;
  }

  playRecording(): Promise<void> {
    this.stopAll();
    if (!this.recordingUrl) return Promise.resolve();
    const token = ++this.token;
    this.playingRecording.set(true);
    return new Promise((resolve) => {
      const done = () => { if (token === this.token) this.playingRecording.set(false); resolve(); };
      this.recEl.src = this.recordingUrl!;
      this.recEl.onended = done;
      this.recEl.onerror = done;
      this.recEl.play().catch(done);
      this.onInterrupt(token, done);
    });
  }

  private releaseMic(): void {
    this.stream?.getTracks().forEach((t) => t.stop());
    this.stream = undefined;
  }

  // ───────────────────────────── effects ─────────────────────────────

  /** Soft, non-musical UI cues synthesised on the fly. */
  sfx(kind: Sfx): void {
    const ctx = this.audioCtx();
    if (!ctx || this.muted()) return;
    const t = ctx.currentTime;
    const tone = (freq: number, start: number, dur: number, gain: number, type: OscillatorType = 'sine', glideTo?: number) => {
      const o = ctx.createOscillator();
      const g = ctx.createGain();
      o.type = type;
      o.frequency.setValueAtTime(freq, t + start);
      if (glideTo) o.frequency.exponentialRampToValueAtTime(glideTo, t + start + dur);
      g.gain.setValueAtTime(0.0001, t + start);
      g.gain.exponentialRampToValueAtTime(gain, t + start + 0.015);
      g.gain.exponentialRampToValueAtTime(0.0001, t + start + dur);
      o.connect(g).connect(ctx.destination);
      o.start(t + start);
      o.stop(t + start + dur + 0.05);
    };
    switch (kind) {
      case 'tap': tone(660, 0, 0.08, 0.05, 'triangle'); break;
      case 'reveal': tone(880, 0, 0.25, 0.035); tone(1320, 0.05, 0.3, 0.02); break;
      case 'whoosh': tone(300, 0, 0.35, 0.025, 'sine', 900); break;
      case 'correct': tone(784, 0, 0.18, 0.08); tone(1175, 0.09, 0.35, 0.07); break;
      case 'wrong': tone(220, 0, 0.22, 0.07, 'triangle', 160); break;
      case 'star': tone(1047, 0, 0.3, 0.05); tone(1568, 0.04, 0.35, 0.03); break;
      case 'complete':
        [523, 659, 784, 1047].forEach((f, i) => tone(f, i * 0.11, 0.5, 0.05));
        break;
    }
  }

  /** Must be called from a user gesture once, so later audio may start automatically. */
  unlock(): void {
    const ctx = this.audioCtx();
    if (ctx?.state === 'suspended') ctx.resume().catch(() => {});
    window.speechSynthesis?.getVoices();
    for (const el of [this.narrationEl, this.verseEl, this.fxEl]) {
      if (!el.src) {
        el.src = 'data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA//tQAAAAAAAAAAAAAAAAAAAAAAAASW5mbwAAAA8AAAACAAABhgC7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7u7//////////////////////////////////////////////////////////////////8AAAAATGF2YzU4LjEzAAAAAAAAAAAAAAAAJAAAAAAAAAAAAYYoRBqpAAAAAAAAAAAAAAAAAAAA';
        el.play().then(() => el.pause()).catch(() => {});
      }
    }
  }

  /** Pauses whatever narration / recitation is playing (resume() continues it). */
  pause(): void {
    for (const el of [this.narrationEl, this.verseEl, this.recEl]) {
      if (!el.paused && !el.ended && el.src) { (el as any).__held = true; HTMLMediaElement.prototype.pause.call(el); }
    }
    window.speechSynthesis?.pause();
  }

  resume(): void {
    for (const el of [this.narrationEl, this.verseEl, this.recEl]) {
      if ((el as any).__held) { (el as any).__held = false; el.play().catch(() => {}); }
    }
    window.speechSynthesis?.resume();
  }

  toggleMute(): void {
    this.muted.update((m) => !m);
    for (const el of [this.narrationEl, this.verseEl, this.fxEl, this.recEl]) el.muted = this.muted();
    if (this.muted()) window.speechSynthesis?.cancel();
  }

  preload(urls: string[]): void {
    for (const url of urls) {
      const a = new Audio();
      a.preload = 'auto';
      a.src = url;
    }
  }

  stopAll(): void {
    this.token++;
    clearInterval(this.timer);
    this.stopLoop();
    for (const el of [this.narrationEl, this.verseEl, this.recEl]) {
      el.onended = el.onerror = el.onloadedmetadata = null;
      (el as any).__held = false;
      el.pause();
    }
    window.speechSynthesis?.cancel();
    this.narrating.set(false);
    this.reciting.set(false);
    this.playingRecording.set(false);
    this.activeWord.set(-1);
  }

  ngOnDestroy(): void {
    this.stopAll();
    this.fxEl.pause();
    if (this.mediaRecorder?.state === 'recording') this.mediaRecorder.stop();
    this.releaseMic();
    if (this.recordingUrl) URL.revokeObjectURL(this.recordingUrl);
    this.ctx?.close().catch(() => {});
  }

  private audioCtx(): AudioContext | undefined {
    if (!this.ctx) {
      const Ctor = window.AudioContext || (window as any).webkitAudioContext;
      if (!Ctor) return undefined;
      this.ctx = new Ctor();
    }
    if (this.ctx.state === 'suspended') this.ctx.resume().catch(() => {});
    return this.ctx;
  }

  private loop(fn: () => void): void {
    this.stopLoop();
    this.zone.runOutsideAngular(() => {
      const tick = () => { fn(); this.raf = requestAnimationFrame(tick); };
      this.raf = requestAnimationFrame(tick);
    });
  }

  private stopLoop(): void {
    cancelAnimationFrame(this.raf);
    this.raf = 0;
  }
}
