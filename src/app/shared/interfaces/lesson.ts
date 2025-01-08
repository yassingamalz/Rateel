  // src/app/shared/interfaces/lesson.ts
  export type LessonType = 'video' | 'practice' | 'listen' | 'read' | 'test';

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
    readingContent?: string;
    defaultContent?: string;
  }
