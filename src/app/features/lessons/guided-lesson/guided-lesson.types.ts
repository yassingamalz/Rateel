// Guided lessons: short, narrated, animated steps (Simply-Piano-style flow).

export type GuidedStepType =
  | 'intro'     // animated title card
  | 'concept'   // keyword → meaning reveal
  | 'pillars'   // definition sentence + items revealed in sync with narration
  | 'compare'   // two contrasting cards
  | 'quiz'      // tap the right answer
  | 'listen'    // Quran recitation with word-by-word highlight
  | 'repeat'    // listen, then record yourself and compare
  | 'summary';  // stars + key takeaways

export interface GuidedItem {
  icon?: string;
  title: string;
  text?: string;
  /** Fraction (0–1) of the narration after which the item appears. */
  revealAt?: number;
}

export interface GuidedCard {
  icon?: string;
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
}

export interface GuidedLessonContent {
  version: string;
  lessonId: string;
  title: string;
  badge?: string;
  /** Visual theme: 'ornate' (arch background, gold frames — default) or 'glow' (v1). */
  theme?: 'ornate' | 'glow';
  audioBase: string;
  steps: GuidedStep[];
  common?: Record<string, string>;
}
