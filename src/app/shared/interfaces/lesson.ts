// src/app/shared/interfaces/lesson.ts
export interface Lesson {
    id: string;
    title: string;
    description: string;
    type: 'video' | 'practice' | 'test';
    icon?: string;
    duration?: number;
    order: number;
    courseId: string;
    isCompleted?: boolean;
    isLocked?: boolean;
  }