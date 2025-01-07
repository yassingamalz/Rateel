// src/app/shared/interfaces/unit.ts
export type UnitType = 'video' | 'listening' | 'reading' | 'exercise';

export interface Unit {
  id: string;
  title: string;
  description: string;
  courseId: string;
  type: UnitType;
  order: number;
  isLocked: boolean;
  isCompleted?: boolean;
  progress?: number;
  icon?: string;
}