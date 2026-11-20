// Guided lessons: short, narrated, animated steps (Simply-Piano-style flow).

export type GuidedStepType =
  | 'intro'     // animated title card
  | 'concept'   // keyword → meaning reveal
  | 'pillars'   // definition sentence + items revealed in sync with narration
  | 'compare'   // two contrasting cards
  | 'quiz'      // tap the right answer
  | 'listen'    // Quran recitation with word-by-word highlight
  | 'repeat'    // listen, then record yourself and compare
  | 'summary'   // stars + key takeaways
  | 'definition' // label + defining sentence + illustration (glassy)
  | 'split'     // a mushaddad letter morphs into its two letters (sākin + mutaḥarrik)
  | 'levels';   // ranked levels as bars (+ optional reading speeds that rescale them)

export interface GuidedItem {
  icon?: string;
  title: string;
  text?: string;
  /** Fraction (0–1) of the narration after which the item appears. */
  revealAt?: number;
}

export interface GuidedCard {
  icon?: string;
  /** Large letter shown as the card's emblem (e.g. «نّ»). */
  glyph?: string;
  /** Quran words shown as examples (Uthmani, Quran font). */
  examples?: string[];
  tone?: 'emerald' | 'gold' | 'ruby' | 'amber';
  title: string;
  subtitle?: string;
  verdict?: string;
  text?: string;
}

export interface GuidedOption {
  id: string;
  text: string;
}

export interface GuidedVerse {
  key: string;
  surah: string;
  ayah: number;
  audio: string;
  words: string[];
  /** [wordIndex, startMs, endMs] — from the reciter's timing data. */
  segments: [number, number, number][];
  /** Optional [startMs, endMs] to play only part of the ayah. */
  clip?: [number, number];
  focusWords?: number[];
  /** True when only part of the ayah is shown. */
  partial?: boolean;
  /** wordIndex → substring of that word to colour (e.g. the mushaddad letter «نَّ»). */
  marks?: Record<string, string>;
}

export interface GuidedMedia {
  src: string;
  alt?: string;
  /** True while the final asset is still being produced: shown with a "provisional" tag. */
  placeholder?: boolean;
}

export interface GuidedSplitPair {
  whole: string;
  parts: [string, string];
  /** Narration word on which the letter splits. */
  split: string;
  /** Narration word on which the pair appears (null = from the start). */
  show?: string | null;
}

export interface GuidedLevel {
  title: string;
  text?: string;
  /** Image shown on the level card (e.g. the crown on «أكمل»). */
  icon?: string;
}

export interface GuidedSpeed {
  title: string;
  /** Relative length of every level at this speed (proportion is kept). */
  scale: number;
}

export interface GuidedStep {
  id: string;
  type: GuidedStepType;
  narration?: string;
  caption?: string;
  title?: string;
  subtitle?: string;
  label?: string;
  keyword?: string;
  meaning?: string;
  note?: string;
  sentence?: string;
  items?: GuidedItem[];
  cards?: GuidedCard[];
  question?: string;
  options?: GuidedOption[];
  correctId?: string;
  explanation?: string;
  verse?: GuidedVerse;
  points?: string[];
  /** element key → narration word on which it appears (exact, via word timings). */
  reveal?: Record<string, string>;
  media?: GuidedMedia;
  pairs?: GuidedSplitPair[];
  partLabels?: [string, string];
  link?: string;
  levels?: GuidedLevel[];
  highlight?: number;
  speeds?: GuidedSpeed[];
  /** Quiz options are Quran words (Quran font). */
  quran?: boolean;
  /** Image icon for each summary point (same order as points). */
  pointIcons?: string[];
  /** Image shown above the scene content (e.g. the 3D shadda on the split step). */
  emblem?: string;
}

/** Word timings of a narration clip: duration and the start of every whitespace token (ms). */
export interface GuidedWordTimings {
  d: number;
  t: number[];
}

export interface GuidedLessonContent {
  version: string;
  lessonId: string;
  title: string;
  badge?: string;
  /** Visual theme: 'ornate' (arch background, gold frames — default) or 'glow' (v1). */
  theme?: 'ornate' | 'glow' | 'glassy';
  audioBase: string;
  /** Folder of the shared feedback lines (default assets/audio/guided/common). */
  commonBase?: string;
  /** Each narration has a <stepId>.words.json next to its mp3. */
  wordTimings?: boolean;
  steps: GuidedStep[];
  common?: Record<string, string>;
}
