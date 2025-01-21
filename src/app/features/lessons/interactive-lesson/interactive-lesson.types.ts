import { EventEmitter } from "@angular/core";

// interactive-lesson.types.ts
export interface TajweedVerse {
  id: string;
  text: string;
  translation?: string;
  highlights?: {
    start: number;
    end: number;
    rule: string;
    color: string;
  }[];
  audioUrl?: string;
}

export interface InteractionState {
  currentVerseIndex: number;
  answers: Map<string, string | boolean>;
  score: number;
  isCompleted: boolean;
  progress: number;
  feedback?: string;
  isRecording?: boolean;
  currentAudio?: string;
  scrollPosition: number;
  currentWordIndex?: number;
  recognizedWords?: Set<number>;
}

export interface InteractiveLessonProps {
  verses: TajweedVerse[]; 
  isCompleted?: boolean;
  onProgress: EventEmitter<number>;
  onComplete: EventEmitter<void>;
}