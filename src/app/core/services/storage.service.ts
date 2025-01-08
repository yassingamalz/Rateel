// src/app/core/services/storage.service.ts
import { Injectable } from "@angular/core";

export interface ProgressData {
  progress: number;
  timestamp: number;
  expiresAt: number;
  isCompleted: boolean;
  lastAccessedLesson?: string;
}

type StorageType = 'course' | 'unit' | 'lesson';

@Injectable({
  providedIn: 'root'
})
export class StorageService {
  private readonly PREFIX = {
    course: 'tajweed_course_',
    unit: 'tajweed_unit_',
    lesson: 'tajweed_lesson_'
  } as const;
  
  private readonly TWO_YEARS = 2 * 365 * 24 * 60 * 60 * 1000;

  saveProgress(type: StorageType, id: string, data: Partial<ProgressData>): void {
    const key = this.PREFIX[type] + id;
    const existingData = this.getProgress(type, id);
    
    const newData: ProgressData = {
      progress: data.progress ?? existingData?.progress ?? 0,
      timestamp: Date.now(),
      expiresAt: Date.now() + this.TWO_YEARS,
      isCompleted: data.isCompleted ?? existingData?.isCompleted ?? false,
      lastAccessedLesson: data.lastAccessedLesson ?? existingData?.lastAccessedLesson
    };

    localStorage.setItem(key, JSON.stringify(newData));
    
    if (type === 'lesson') {
      this.updateParentProgress('unit', id.split('_')[0]);
    } else if (type === 'unit') {
      this.updateParentProgress('course', id.split('_')[0]);
    }
  }

  getProgress(type: StorageType, id: string): ProgressData | null {
    const key = this.PREFIX[type] + id;
    const data = localStorage.getItem(key);
    if (!data) return null;

    const parsed: ProgressData = JSON.parse(data);
    if (Date.now() > parsed.expiresAt) {
      localStorage.removeItem(key);
      return null;
    }
    return parsed;
  }

  private updateParentProgress(type: 'course' | 'unit', parentId: string): void {
    const prefix = type === 'course' ? this.PREFIX.unit : this.PREFIX.lesson;
    const pattern = new RegExp(`^${prefix}${parentId}_`);
    
    let totalProgress = 0;
    let totalItems = 0;
    let allCompleted = true;

    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && pattern.test(key)) {
        const data = this.getProgress(
          type === 'course' ? 'unit' : 'lesson', 
          key.replace(prefix, '')
        );
        if (data) {
          totalProgress += data.progress;
          totalItems++;
          allCompleted = allCompleted && data.isCompleted;
        }
      }
    }

    if (totalItems > 0) {
      this.saveProgress(type, parentId, {
        progress: totalProgress / totalItems,
        isCompleted: allCompleted
      });
    }
  }

  clearExpiredData(): void {
    const now = Date.now();
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && Object.values(this.PREFIX).some(prefix => key.startsWith(prefix))) {
        const data = localStorage.getItem(key);
        if (data) {
          const parsed: ProgressData = JSON.parse(data);
          if (now > parsed.expiresAt) {
            localStorage.removeItem(key);
          }
        }
      }
    }
  }
}