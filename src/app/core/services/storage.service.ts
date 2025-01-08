// src/app/core/interfaces/progress.interface.ts
export interface ProgressData {
  progress: number;
  timestamp: number;
  expiresAt: number;
  isCompleted: boolean;
  lastAccessedLesson?: string;
  version?: string;
  syncStatus?: 'pending' | 'synced' | 'error';
}

// src/app/core/services/storage.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

export type StorageType = 'course' | 'unit' | 'lesson';

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
  private readonly VERSION = '1.0.0';

  private changes$ = new BehaviorSubject<{type: StorageType; id: string; data: ProgressData} | null>(null);

  constructor() {
    this.initializeStorage();
  }

  private initializeStorage(): void {
    // Clear expired data on initialization
    this.clearExpiredData();
    
    // Setup storage event listener for cross-tab sync
    window.addEventListener('storage', (event) => {
      if (event.key && Object.values(this.PREFIX).some(prefix => event.key!.startsWith(prefix))) {
        try {
          const type = this.getTypeFromKey(event.key);
          const id = this.getIdFromKey(event.key);
          const data = event.newValue ? JSON.parse(event.newValue) : null;
          if (type && id && data) {
            this.changes$.next({ type, id, data });
          }
        } catch (error) {
          console.error('Error processing storage event:', error);
        }
      }
    });
  }

  saveProgress(type: StorageType, id: string, data: Partial<ProgressData>): void {
    const key = this.PREFIX[type] + id;
    const existingData = this.getProgress(type, id);

    const newData: ProgressData = {
      progress: data.progress ?? existingData?.progress ?? 0,
      timestamp: Date.now(),
      expiresAt: Date.now() + this.TWO_YEARS,
      isCompleted: data.isCompleted ?? existingData?.isCompleted ?? false,
      lastAccessedLesson: data.lastAccessedLesson ?? existingData?.lastAccessedLesson,
      version: this.VERSION,
      syncStatus: 'pending'
    };

    try {
      localStorage.setItem(key, JSON.stringify(newData));
      this.changes$.next({ type, id, data: newData });

      if (type === 'lesson') {
        this.updateParentProgress('unit', id.split('_')[0]);
      } else if (type === 'unit') {
        this.updateParentProgress('course', id.split('_')[0]);
      }
    } catch (error) {
      console.error('Error saving progress:', error);
      // Handle storage quota exceeded
      if (error instanceof Error && error.name === 'QuotaExceededError') {
        this.clearExpiredData();
        // Retry save
        localStorage.setItem(key, JSON.stringify(newData));
      }
    }
  }

  getProgress(type: StorageType, id: string): ProgressData | null {
    try {
      const key = this.PREFIX[type] + id;
      const data = localStorage.getItem(key);
      if (!data) return null;

      const parsed: ProgressData = JSON.parse(data);
      
      // Handle data expiration
      if (Date.now() > parsed.expiresAt) {
        localStorage.removeItem(key);
        return null;
      }

      // Handle version mismatch
      if (parsed.version !== this.VERSION) {
        // Implement version migration if needed
        return this.migrateData(parsed);
      }

      return parsed;
    } catch (error) {
      console.error('Error getting progress:', error);
      return null;
    }
  }

  getProgressChanges(): Observable<{type: StorageType; id: string; data: ProgressData} | null> {
    return this.changes$.asObservable();
  }

  private updateParentProgress(type: 'course' | 'unit', parentId: string): void {
    const prefix = type === 'course' ? this.PREFIX.unit : this.PREFIX.lesson;
    const pattern = new RegExp(`^${prefix}${parentId}_`);

    let totalProgress = 0;
    let totalItems = 0;
    let allCompleted = true;

    try {
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
    } catch (error) {
      console.error('Error updating parent progress:', error);
    }
  }

  clearExpiredData(): void {
    const now = Date.now();
    try {
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
    } catch (error) {
      console.error('Error clearing expired data:', error);
    }
  }

  private getTypeFromKey(key: string): StorageType | null {
    for (const [type, prefix] of Object.entries(this.PREFIX)) {
      if (key.startsWith(prefix)) {
        return type as StorageType;
      }
    }
    return null;
  }

  private getIdFromKey(key: string): string | null {
    for (const prefix of Object.values(this.PREFIX)) {
      if (key.startsWith(prefix)) {
        return key.slice(prefix.length);
      }
    }
    return null;
  }

  private migrateData(data: ProgressData): ProgressData {
    // Implement version migration logic here
    return {
      ...data,
      version: this.VERSION
    };
  }
}