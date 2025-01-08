// src/app/features/lessons/reading-lesson/reading-lesson.types.ts
export interface TajweedRule {
    id: string;
    name: string;
    color: string;
    description: string;
    example?: string;
  }
  
  export interface TajweedMark {
    text: string;
    ruleId: string;
    startIndex: number;
    endIndex: number;
  }
  
  export interface ReadingState {
    fontSize: number;
    showRules: boolean;
    currentVerse?: number;
    progress: number;
    isCompleted: boolean;
    selectedRule?: TajweedRule;
  }
  
  export interface VerseSection {
    text: string;
    marks: TajweedMark[];
    translation?: string;
    explanation?: string;
  }
  
  export interface ReadingContent {
    verses: VerseSection[];
    title: string;
    description?: string;
  }