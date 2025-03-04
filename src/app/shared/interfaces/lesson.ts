// src/app/shared/interfaces/lesson.ts
import { TajweedVerse } from "../../features/lessons/interactive-lesson/interactive-lesson.types";

// src/app/shared/interfaces/lesson.ts
export type LessonType = 'video' | 'practice' | 'listen' | 'read' | 'test' | 'assessment';

export interface Lesson {
  id: string;
  title: string;
  description: string;
  type: LessonType;
  icon?: string;
  duration?: number;
  order: number;
  unitId: string;
  courseId: string;
  isCompleted?: boolean;
  isLocked?: boolean;
  stepNumber: number;
  totalSteps: number;
  videoUrl?: string;
  practiceContent?: string;
  audioUrl?: string;
  verses?: TajweedVerse[];
  readingContent?: string;
  assessmentContent?: string;
  defaultContent?: string;
  contentPath?: string;
}