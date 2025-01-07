import { Lesson } from "./lesson";

// src/app/shared/interfaces/unit.ts
export interface Unit {
  id: string;
  title: string;
  description: string;
  courseId: string;
  order: number;
  isLocked: boolean;
  isCompleted?: boolean;
  progress?: number;
  lessons: Lesson[];
}