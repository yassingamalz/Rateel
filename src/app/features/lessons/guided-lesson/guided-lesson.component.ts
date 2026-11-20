import {
  ChangeDetectionStrategy, Component, EventEmitter, Input, OnChanges, OnDestroy, Output,
  SimpleChanges, computed, signal,
} from '@angular/core';
import { animate, style, transition, trigger } from '@angular/animations';
import { GuidedAudioService } from './guided-audio.service';
import { GuidedLessonContent, GuidedOption, GuidedStep, GuidedWordTimings } from './guided-lesson.types';

type QuizState = 'idle' | 'correct' | 'wrong';
type RepeatPhase = 'intro' | 'listening' | 'ready' | 'recording' | 'review' | 'unavailable';

const ARABIC_DIGITS = '٠١٢٣٤٥٦٧٨٩';

@Component({
  selector: 'app-guided-lesson',
  standalone: false,
  templateUrl: './guided-lesson.component.html',
  styleUrls: ['./guided-lesson.component.scss', './guided-lesson.ornate.scss', './guided-lesson.glassy.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [GuidedAudioService],
  animations: [
    // Calm morph-like cross-fade (rule 0.12): the old scene dissolves while the new one settles in place.
    trigger('stepSwap', [
      transition(':enter', [
        // no scale: shared elements (arch, title, cards) must not move between scenes
        style({ opacity: 0, filter: 'blur(4px)' }),
        animate('520ms 180ms cubic-bezier(0.16, 1, 0.3, 1)', style({ opacity: 1, filter: 'blur(0)' })),
      ]),
      transition(':leave', [
        animate('260ms cubic-bezier(0.4, 0, 1, 1)', style({ opacity: 0, filter: 'blur(3px)' })),
      ]),
    ]),
  ],
})
export class GuidedLessonComponent implements OnChanges, OnDestroy {
  @Input() content?: string;
  @Input() isCompleted = false;
  /** Set by the lesson shell's pause button: holds narration and recitation. */
  @Input() set paused(v: boolean) {
    if (v === this.pausedState()) return;
    this.pausedState.set(v);
    if (v) this.audio.pause(); else this.audio.resume();
  }
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  readonly lesson = signal<GuidedLessonContent | null>(null);
  readonly index = signal(0);
  readonly started = signal(false);
  readonly canContinue = signal(false);

  // quiz
  readonly quizState = signal<QuizState>('idle');
  readonly picked = signal<string | null>(null);
  readonly wrongPicks = signal<string[]>([]);
  private firstTry = new Map<string, boolean>();

  // listen / repeat
  readonly playedOnce = signal(false);
  readonly repeatPhase = signal<RepeatPhase>('intro');
  readonly countdown = signal(0);

  readonly steps = computed(() => this.lesson()?.steps ?? []);
  readonly step = computed<GuidedStep | undefined>(() => this.steps()[this.index()]);
  readonly isLast = computed(() => this.index() === this.steps().length - 1);
  readonly theme = computed(() => this.lesson()?.theme ?? 'ornate');
  /** 'glassy' builds on the ornate theme and overrides it. */
  readonly themeClass = computed(() => this.theme() === 'glassy' ? 'theme-ornate theme-glassy' : 'theme-' + this.theme());
  readonly pausedState = signal(false);
  readonly emblemSrc = computed(() => this.theme() === 'glassy'
    ? 'assets/images/guided/glassy/emblem-quran.webp' : 'assets/icons/android-chrome-192x192.png');
  /** Scene name on the root, so the theme can show per-scene decoration (e.g. the skyline). */
  readonly sceneName = computed(() => (this.started() ? this.step()?.type ?? '' : 'splash'));
  private readonly timings = signal<Record<string, GuidedWordTimings>>({});

  readonly captionWords = computed(() => {
    const s = this.step();
    const text = s?.caption ?? s?.narration ?? '';
    const words = text.split(/\s+/).filter(Boolean);
    const total = words.reduce((n, w) => n + w.length + 1, 0) || 1;
    // Exact word timings (when the caption is the narration itself): rule 3.1.
    const wt = s && !s.caption ? this.timings()[s.id] : undefined;
    const exact = wt && wt.t.length === words.length;
    let acc = 0;
    let quoted = false;
    return words.map((w, i) => {
      const at = exact ? wt!.t[i] / wt!.d : acc / total;
      acc += w.length + 1;
      if (w.includes('«')) quoted = true;
      const q = quoted;
      if (w.includes('»')) quoted = false;
      return { w, at, q };
    });
  });

  readonly stars = computed(() => {
    const quizzes = this.steps().filter((s) => s.type === 'quiz');
    if (!quizzes.length) return 3;
    const right = quizzes.filter((q) => this.firstTry.get(q.id) !== false).length;
    const ratio = right / quizzes.length;
    return ratio >= 0.85 ? 3 : ratio >= 0.5 ? 2 : 1;
  });
  readonly earnedStars = signal(0);

  // decorative layers
  readonly particles = Array.from({ length: 22 }, (_, i) => ({
    left: (i * 37) % 100,
    size: 2 + ((i * 7) % 4),
    delay: -((i * 1.7) % 14),
    duration: 12 + ((i * 5) % 10),
    drift: ((i % 5) - 2) * 18,
  }));
  readonly confetti = Array.from({ length: 46 }, (_, i) => ({
    left: (i * 23) % 100,
    delay: (i % 12) * 0.07,
    duration: 2.4 + ((i * 3) % 10) / 10,
    rotate: (i * 47) % 360,
    color: ['#FFD700', '#F5E6B3', '#2ECC71', '#DAA520', '#FFFFFF', '#95D5B2'][i % 6],
    shape: i % 3,
  }));

  constructor(public audio: GuidedAudioService) {}

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['content'] && this.content) {
      try {
        const parsed: GuidedLessonContent = JSON.parse(this.content);
        this.lesson.set(parsed);
        this.audio.preload(parsed.steps.map((s) => this.narrationUrl(s)!).filter(Boolean));
        if (parsed.wordTimings) this.loadTimings(parsed);
      } catch (e) {
        console.error('[GuidedLesson] Invalid content', e);
      }
    }
  }

  ngOnDestroy(): void {
    this.audio.stopAll();
  }

  private loadTimings(l: GuidedLessonContent): void {
    for (const s of l.steps) {
      if (!s.narration) continue;
      fetch(`${l.audioBase}/${s.id}.words.json`)
        .then((r) => (r.ok ? r.json() : null))
        .then((t: GuidedWordTimings | null) => t && this.timings.update((m) => ({ ...m, [s.id]: t })))
        .catch(() => {});
    }
  }


  // ───────────────────────────── flow ─────────────────────────────

  start(): void {
    this.audio.unlock();
    this.audio.sfx('whoosh');
    this.started.set(true);
    this.enterStep();
  }

  next(): void {
    if (!this.canContinue()) return;
    this.audio.sfx('tap');
    if (this.isLast()) {
      this.audio.stopAll();
      this.onComplete.emit();
      return;
    }
    this.goTo(this.index() + 1);
  }

  back(): void {
    if (this.index() > 0) this.goTo(this.index() - 1);
  }

  private goTo(i: number): void {
    this.audio.stopAll();
    this.audio.sfx('whoosh');
    this.index.set(i);
    this.onProgress.emit(Math.min(95, Math.round((i / Math.max(1, this.steps().length - 1)) * 95)));
    this.enterStep();
  }

  private async enterStep(): Promise<void> {
    const step = this.step();
    if (!step) return;
    const myIndex = this.index();
    const still = () => this.index() === myIndex;

    // Reset before the new step renders: the previous step's narration left progress at 1,
    // which would briefly reveal every item of the new step and then hide it again.
    this.audio.narrationProgress.set(0);
    this.audio.narrating.set(false);
    this.canContinue.set(false);
    this.quizState.set('idle');
    this.picked.set(null);
    this.wrongPicks.set([]);
    this.playedOnce.set(false);
    this.repeatPhase.set('intro');
    this.earnedStars.set(0);

    if (step.type === 'summary') this.celebrate();

    await this.wait(450); // let the entrance animation breathe
    if (!still()) return;
    await this.narrate(step);
    if (!still()) return;

    switch (step.type) {
      case 'quiz':
        break; // continue unlocks on the right answer
      case 'listen':
        await this.playVerse();
        if (still()) this.canContinue.set(true);
        break;
      case 'repeat':
        await this.playVerse();
        if (!still()) break;
        this.repeatPhase.set(this.audio.canRecord ? 'ready' : 'unavailable');
        // Recording is encouraged (the mic pulses) but never blocks progress.
        this.canContinue.set(true);
        break;
      default:
        this.canContinue.set(true);
    }
  }

  narrate(step = this.step()): Promise<void> {
    if (!step?.narration) return Promise.resolve();
    return this.audio.playNarration(this.narrationUrl(step), step.narration);
  }

  replayNarration(): void {
    this.audio.sfx('tap');
    this.narrate();
  }

  async playVerse(): Promise<void> {
    const verse = this.step()?.verse;
    if (!verse) return;
    if (this.step()?.type === 'repeat' && this.repeatPhase() !== 'review') this.repeatPhase.set('listening');
    await this.audio.playVerse(verse);
    this.playedOnce.set(true);
    if (this.step()?.type === 'repeat' && this.repeatPhase() === 'listening') this.repeatPhase.set('ready');
  }

  // ───────────────────────────── quiz ─────────────────────────────

  choose(option: GuidedOption): void {
    const step = this.step();
    if (!step || this.quizState() === 'correct' || this.wrongPicks().includes(option.id)) return;
    this.audio.stopAll();
    this.picked.set(option.id);

    if (option.id === step.correctId) {
      if (!this.firstTry.has(step.id)) this.firstTry.set(step.id, true);
      this.quizState.set('correct');
      this.audio.sfx('correct');
      this.audio.playFeedback(this.commonUrl(`correct-${1 + Math.floor(Math.random() * 3)}`));
      this.canContinue.set(true);
    } else {
      this.firstTry.set(step.id, false);
      this.quizState.set('wrong');
      this.wrongPicks.update((w) => [...w, option.id]);
      this.audio.sfx('wrong');
      this.audio.playFeedback(this.commonUrl(`wrong-${1 + Math.floor(Math.random() * 2)}`));
      setTimeout(() => { if (this.quizState() === 'wrong') this.quizState.set('idle'); }, 900);
    }
  }

  optionState(option: GuidedOption): string {
    if (this.quizState() === 'correct' && option.id === this.step()?.correctId) return 'correct';
    if (this.wrongPicks().includes(option.id)) return 'wrong';
    return '';
  }

  // ───────────────────────────── repeat ─────────────────────────────

  async record(): Promise<void> {
    if (this.audio.recording()) return this.finishRecording();
    this.audio.sfx('tap');
    this.audio.playFeedback(this.commonUrl('your-turn'));
    for (const n of [3, 2, 1]) {
      this.countdown.set(n);
      this.audio.sfx('tap');
      await this.wait(700);
    }
    this.countdown.set(0);
    const ok = await this.audio.startRecording();
    if (!ok) {
      this.repeatPhase.set('unavailable');
      this.canContinue.set(true);
      return;
    }
    this.repeatPhase.set('recording');
    const verse = this.step()?.verse;
    const ms = verse ? (verse.segments.at(-1)?.[2] ?? 4000) : 4000;
    const myIndex = this.index();
    setTimeout(() => {
      if (this.index() === myIndex && this.audio.recording()) this.finishRecording();
    }, ms * 1.6 + 2500);
  }

  private async finishRecording(): Promise<void> {
    await this.audio.stopRecording();
    this.repeatPhase.set('review');
    this.audio.sfx('correct');
    this.canContinue.set(true);
    await this.audio.playNarration(this.commonUrl('after-record'), '');
  }

  playMine(): void {
    this.audio.playRecording();
  }

  // ───────────────────────────── summary ─────────────────────────────

  private async celebrate(): Promise<void> {
    await this.wait(900);
    this.audio.sfx('complete');
    for (let i = 1; i <= this.stars(); i++) {
      await this.wait(420);
      this.earnedStars.set(i);
      this.audio.sfx('star');
    }
  }

  // ───────────────────────────── helpers ─────────────────────────────

  isRevealed(at: number | undefined): boolean {
    if (at == null) return true;
    if (this.canContinue() || !this.audio.narrating() && this.audio.narrationProgress() >= 1) return true;
    return this.audio.narrationProgress() >= at;
  }

  /** Fraction of the narration at which `key` appears: from step.reveal (exact word) or the fallback. */
  revealFrac(key: string, fallback?: number): number | undefined {
    const s = this.step();
    const word = s?.reveal?.[key];
    if (!s || word == null) return fallback;
    return this.wordFrac(word) ?? fallback;
  }

  /** Fraction of the narration where the given token is spoken. */
  wordFrac(word: string | null | undefined): number | undefined {
    const s = this.step();
    if (!s?.narration || !word) return undefined;
    const tokens = s.narration.split(/\s+/).filter(Boolean);
    const i = tokens.indexOf(word);
    if (i < 0) return undefined;
    const wt = this.timings()[s.id];
    if (wt && wt.t.length === tokens.length) return Math.max(0.001, wt.t[i] / wt.d);
    const before = tokens.slice(0, i).reduce((n, w) => n + w.length + 1, 0);
    return Math.max(0.001, before / (tokens.reduce((n, w) => n + w.length + 1, 0) || 1));
  }

  on(key: string, fallback?: number): boolean {
    return this.isRevealed(this.revealFrac(key, fallback));
  }

  isWordOn(word: string | null | undefined): boolean {
    return word == null ? true : this.isRevealed(this.wordFrac(word));
  }

  /** Index of the reading speed currently named by the voice (levels step), or -1. */
  activeSpeed(): number {
    const sp = this.step()?.speeds ?? [];
    let a = -1;
    sp.forEach((_, i) => { if (this.on('speed' + i)) a = i; });
    return a;
  }

  levelScale(): number {
    const sp = this.step()?.speeds;
    const a = this.activeSpeed();
    return sp && a >= 0 ? sp[a].scale : 1;
  }

  /** Splits a Quran word around its marked substring: [before, mark, after]. */
  markParts(word: string, i: number): [string, string, string] | null {
    const m = this.step()?.verse?.marks?.[String(i)];
    if (!m) return null;
    const at = word.indexOf(m);
    if (at < 0) return null;
    return [word.slice(0, at), m, word.slice(at + m.length)];
  }

  /** True while the reciter is on a word that carries a mark (the ghunna is sounding). */
  isMarkLive(i: number): boolean {
    return this.audio.activeWord() === i && !!this.step()?.verse?.marks?.[String(i)];
  }

  isWordSpoken(at: number): boolean {
    return this.audio.narrationProgress() > at || (!this.audio.narrating() && this.audio.narrationProgress() >= 1);
  }

  isFocus(i: number): boolean {
    return !!this.step()?.verse?.focusWords?.includes(i);
  }

  toArabicDigits(n: number | string): string {
    return String(n).replace(/\d/g, (d) => ARABIC_DIGITS[+d]);
  }

  stepNumberLabel(): string {
    return `${this.toArabicDigits(this.index() + 1)} / ${this.toArabicDigits(this.steps().length)}`;
  }

  private narrationUrl(step: GuidedStep): string | undefined {
    const base = this.lesson()?.audioBase;
    return base && step.narration ? `${base}/${step.id}.mp3` : undefined;
  }

  private commonUrl(key: string): string {
    return `${this.lesson()?.commonBase ?? 'assets/audio/guided/common'}/${key}.mp3`;
  }

  private wait(ms: number): Promise<void> {
    return new Promise((r) => setTimeout(r, ms));
  }
}
