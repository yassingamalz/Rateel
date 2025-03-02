// src/app/core/interfaces/progress.interface.ts
export interface ProgressData {
  progress: number;
  timestamp: number;
  expiresAt: number;
  isCompleted: boolean;
  isLocked?: boolean;
  currentVerseIndex?: number;
  scrollPosition?: number;
  lastAccessedLesson?: string;
  version?: string;
  syncStatus?: 'pending' | 'synced' | 'error';
  // New fields for lesson tracking
  currentPosition?: number;    // Current playback position for video/audio
  volume?: number;            // Volume level (0-1)
  isMuted?: boolean;         // Mute state
  isFullscreen?: boolean;    // Fullscreen state
  lastUpdated?: number;      // Last time progress was updated
  answers?: {                // Store practice lesson answers
    [questionId: string]: {
      answer: any;
      isCorrect: boolean;
      timestamp: number;
    }
  };
  bookmarks?: {             // Store lesson bookmarks
    position: number;
    label: string;
    timestamp: number;
  }[];
  notes?: {                 // Store user notes
    position: number;
    text: string;
    timestamp: number;
  }[];
}

// src/app/core/interfaces/lesson-state.interface.ts
export interface LessonState {
  currentPosition: number;
  volume?: number;
  isMuted?: boolean;
  isFullscreen: boolean;
  lastUpdated: number;
  currentVerseIndex?: number;
  scrollPosition?: number;
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

  private changes$ = new BehaviorSubject<{ type: StorageType; id: string; data: ProgressData } | null>(null);

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

  getProgressChanges(): Observable<{ type: StorageType; id: string; data: ProgressData } | null> {
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

  saveProgress(type: StorageType, id: string, data: Partial<ProgressData>): void {
    const key = this.PREFIX[type] + id;
    const existingData = this.getProgress(type, id);
  
    const newData: ProgressData = {
      progress: data.progress ?? existingData?.progress ?? 0,
      timestamp: Date.now(),
      expiresAt: Date.now() + this.TWO_YEARS,
      isCompleted: data.isCompleted ?? existingData?.isCompleted ?? false,
      isLocked: data.isLocked ?? existingData?.isLocked ?? true,
      lastAccessedLesson: data.lastAccessedLesson ?? existingData?.lastAccessedLesson,
      version: this.VERSION,
      syncStatus: 'pending',
      currentPosition: data.currentPosition ?? existingData?.currentPosition ?? 0,
      volume: data.volume ?? existingData?.volume ?? 1,
      isMuted: data.isMuted ?? existingData?.isMuted ?? false,
      isFullscreen: data.isFullscreen ?? existingData?.isFullscreen ?? false,
      lastUpdated: Date.now(),
      // Preserve existing data
      answers: data.answers ?? existingData?.answers ?? {},
      bookmarks: data.bookmarks ?? existingData?.bookmarks ?? [],
      notes: data.notes ?? existingData?.notes ?? []
    };
  
    try {
      localStorage.setItem(key, JSON.stringify(newData));
  
      // Check if important values have changed
      const hasImportantChanges = 
        !existingData || 
        existingData.progress !== newData.progress || 
        existingData.isCompleted !== newData.isCompleted ||
        existingData.isLocked !== newData.isLocked;
  
      // Only emit changes when important properties change
      if (hasImportantChanges) {
        console.log(`[StorageService] Emitting change for ${type} ${id}: progress=${newData.progress}, completed=${newData.isCompleted}`);
        
        // Create a deep copy for the change event to ensure reference changes
        this.changes$.next({
          type,
          id,
          data: JSON.parse(JSON.stringify(newData))
        });
      }
  
      if (type === 'lesson') {
        this.updateParentProgress('unit', id.split('_')[0]);
      } else if (type === 'unit') {
        this.updateParentProgress('course', id.split('_')[0]);
      }
    } catch (error) {
      console.error('Error saving progress:', error);
      if (error instanceof Error && error.name === 'QuotaExceededError') {
        this.clearExpiredData();
        localStorage.setItem(key, JSON.stringify(newData));
      }
    }
  }

  // New method to save lesson state
  saveLessonState(lessonId: string, state: Partial<LessonState>): void {
    const existingData = this.getProgress('lesson', lessonId);

    this.saveProgress('lesson', lessonId, {
      ...existingData,
      currentPosition: state.currentPosition,
      volume: state.volume,
      isMuted: state.isMuted,
      isFullscreen: state.isFullscreen,
      lastUpdated: Date.now()
    });
  }

  // New method to add bookmark
  addBookmark(lessonId: string, position: number, label: string): void {
    const existingData = this.getProgress('lesson', lessonId);
    const bookmarks = existingData?.bookmarks ?? [];

    bookmarks.push({
      position,
      label,
      timestamp: Date.now()
    });

    this.saveProgress('lesson', lessonId, {
      ...existingData,
      bookmarks
    });
  }

  // New method to add note
  addNote(lessonId: string, position: number, text: string): void {
    const existingData = this.getProgress('lesson', lessonId);
    const notes = existingData?.notes ?? [];

    notes.push({
      position,
      text,
      timestamp: Date.now()
    });

    this.saveProgress('lesson', lessonId, {
      ...existingData,
      notes
    });
  }

  // New method to save answer
  saveAnswer(lessonId: string, questionId: string, answer: any, isCorrect: boolean): void {
    const existingData = this.getProgress('lesson', lessonId);
    const answers = existingData?.answers ?? {};

    answers[questionId] = {
      answer,
      isCorrect,
      timestamp: Date.now()
    };

    this.saveProgress('lesson', lessonId, {
      ...existingData,
      answers
    });
  }

  private migrateData(data: ProgressData): ProgressData {
    return {
      ...data,
      isLocked: data.isLocked ?? true, // Add this with default
      currentPosition: data.currentPosition ?? 0,
      volume: data.volume ?? 1,
      isMuted: data.isMuted ?? false,
      isFullscreen: data.isFullscreen ?? false,
      lastUpdated: data.lastUpdated ?? Date.now(),
      answers: data.answers ?? {},
      bookmarks: data.bookmarks ?? [],
      notes: data.notes ?? [],
      version: this.VERSION
    };
  }
}