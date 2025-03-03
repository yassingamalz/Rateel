//src\app\core\services\storage.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

export type StorageType = 'course' | 'unit' | 'lesson';

export interface ProgressData {
  progress: number;
  timestamp: number;
  expiresAt?: number;
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

export interface LessonState {
  currentPosition: number;
  volume?: number;
  isMuted?: boolean;
  isFullscreen: boolean;
  lastUpdated: number;
  currentVerseIndex?: number;
  scrollPosition?: number;
}

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
  private progressUpdateCount = 0;

  constructor() {
    this.initializeStorage();
    this.setupStorageListener();
  }

  private initializeStorage(): void {
    // Clear expired data on initialization
    this.clearExpiredData();
  }
  
  private setupStorageListener(): void {
    // Setup storage event listener for cross-tab sync
    window.addEventListener('storage', (event) => {
      if (event.key && Object.values(this.PREFIX).some(prefix => event.key!.startsWith(prefix))) {
        try {
          const type = this.getTypeFromKey(event.key);
          const id = this.getIdFromKey(event.key);
          const data = event.newValue ? JSON.parse(event.newValue) : null;
          if (type && id && data) {
            console.log(`[StorageService] Storage event: ${type} ${id} updated externally`);
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
      if (parsed.expiresAt && Date.now() > parsed.expiresAt) {
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

  saveProgress(type: StorageType, id: string, data: Partial<ProgressData>): void {
    this.progressUpdateCount++;
    const updateId = this.progressUpdateCount;
    
    const key = this.PREFIX[type] + id;
    const existingData = this.getProgress(type, id);
  
    // Create new data object with defaults for missing fields
    const newData: ProgressData = {
      progress: data.progress ?? existingData?.progress ?? 0,
      timestamp: Date.now(),
      expiresAt: data.expiresAt ?? (Date.now() + this.TWO_YEARS),
      isCompleted: data.isCompleted ?? existingData?.isCompleted ?? false,
      isLocked: data.isLocked ?? existingData?.isLocked ?? false,
      lastAccessedLesson: data.lastAccessedLesson ?? existingData?.lastAccessedLesson,
      version: this.VERSION,
      syncStatus: 'pending',
      currentPosition: data.currentPosition ?? existingData?.currentPosition ?? 0,
      volume: data.volume ?? existingData?.volume ?? 1,
      isMuted: data.isMuted ?? existingData?.isMuted ?? false,
      isFullscreen: data.isFullscreen ?? existingData?.isFullscreen ?? false,
      lastUpdated: Date.now(),
      // Preserve existing data with proper immutable updates
      answers: data.answers ?? existingData?.answers ?? {},
      bookmarks: data.bookmarks ?? existingData?.bookmarks ?? [],
      notes: data.notes ?? existingData?.notes ?? []
    };
  
    try {
      console.log(`[StorageService] Update #${updateId}: Saving ${type} ${id} progress=${newData.progress}, completed=${newData.isCompleted}`);
      
      // Save to localStorage
      localStorage.setItem(key, JSON.stringify(newData));
  
      // Create a deep clone to ensure reference changes
      const clonedData = JSON.parse(JSON.stringify(newData));
      
      // Emit changes event for subscribers
      this.changes$.next({
        type,
        id,
        data: clonedData
      });
  
      // Update parent progress after a small delay to ensure proper ordering
      setTimeout(() => {
        if (type === 'lesson') {
          // Extract courseId and unitId from composite key (courseId_unitId_lessonId)
          const parts = id.split('_');
          if (parts.length >= 2) {
            this.updateParentProgress('unit', `${parts[0]}_${parts[1]}`);
          }
        } else if (type === 'unit') {
          // Extract courseId from composite key (courseId_unitId)
          const courseId = id.split('_')[0];
          if (courseId) {
            this.updateParentProgress('course', courseId);
          }
        }
      }, 10);
    } catch (error) {
      console.error(`[StorageService] Error saving progress for ${type} ${id}:`, error);
      
      // Handle quota errors
      if (error instanceof Error && error.name === 'QuotaExceededError') {
        console.warn('[StorageService] Storage quota exceeded, clearing expired data');
        this.clearExpiredData();
        
        // Try again
        try {
          localStorage.setItem(key, JSON.stringify(newData));
          
          // Still emit the event even after recovery
          const clonedData = JSON.parse(JSON.stringify(newData));
          this.changes$.next({ type, id, data: clonedData });
        } catch (retryError) {
          console.error('[StorageService] Failed to save even after clearing expired data:', retryError);
        }
      }
    }
  }

  private updateParentProgress(type: 'course' | 'unit', parentId: string): void {
    const keyPrefix = type === 'course' ? 'unit' : 'lesson';
    const childPrefix = this.PREFIX[keyPrefix];
    const searchPrefix = `${childPrefix}${parentId}`;
    const searchPattern = type === 'course' ? new RegExp(`^${childPrefix}${parentId}_`) : new RegExp(`^${childPrefix}${parentId}`);

    let totalProgress = 0;
    let totalItems = 0;
    let allCompleted = true;
    let childItems: { id: string, progress: number, isCompleted: boolean }[] = [];

    try {
      // Collect data about all children
      for (let i = 0; i < localStorage.length; i++) {
        const storageKey = localStorage.key(i);
        if (storageKey && searchPattern.test(storageKey)) {
          const itemId = storageKey.replace(childPrefix, '');
          const progressData = this.getProgress(keyPrefix as StorageType, itemId);
          
          if (progressData) {
            totalProgress += progressData.progress || 0;
            totalItems++;
            allCompleted = allCompleted && (progressData.isCompleted || false);
            
            childItems.push({
              id: itemId,
              progress: progressData.progress || 0,
              isCompleted: progressData.isCompleted || false
            });
          }
        }
      }

      // Only update parent if we actually found child items
      if (totalItems > 0) {
        const averageProgress = Math.round(totalProgress / totalItems);
        
        console.log(`[StorageService] Updating parent ${type} ${parentId} based on ${totalItems} child items:`, 
          childItems.map(item => `${item.id}: ${item.progress}% ${item.isCompleted ? '(completed)' : ''}`).join(', '));
        
        this.saveProgress(type, parentId, {
          progress: averageProgress,
          isCompleted: allCompleted
        });
        
        console.log(`[StorageService] Set ${type} ${parentId} progress to ${averageProgress}%, completed: ${allCompleted}`);
      } else {
        console.warn(`[StorageService] No child items found for ${type} ${parentId}`);
      }
    } catch (error) {
      console.error(`[StorageService] Error updating parent progress for ${type} ${parentId}:`, error);
    }
  }

  // Save answer with proper immutability
  saveAnswer(lessonId: string, questionId: string, answer: any, isCorrect: boolean): void {
    const existingData = this.getProgress('lesson', lessonId);
    const answers = {...(existingData?.answers ?? {})};

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

  clearExpiredData(): void {
    const now = Date.now();
    try {
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && Object.values(this.PREFIX).some(prefix => key.startsWith(prefix))) {
          const data = localStorage.getItem(key);
          if (data) {
            try {
              const parsed: ProgressData = JSON.parse(data);
              if (parsed.expiresAt && now > parsed.expiresAt) {
                localStorage.removeItem(key);
                console.log(`[StorageService] Removed expired data for ${key}`);
              }
            } catch (parseError) {
              console.warn(`[StorageService] Error parsing data for ${key}, removing:`, parseError);
              localStorage.removeItem(key);
            }
          }
        }
      }
    } catch (error) {
      console.error('[StorageService] Error clearing expired data:', error);
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
    // Add any migration logic here if needed in the future
    return {
      ...data,
      isLocked: data.isLocked ?? true,
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

  // Debugging method
  debugStorage(): { [key: string]: any } {
    const result: { [key: string]: any } = {};
    
    try {
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && Object.values(this.PREFIX).some(prefix => key.startsWith(prefix))) {
          const data = localStorage.getItem(key);
          if (data) {
            try {
              result[key] = JSON.parse(data);
            } catch (e) {
              result[key] = data;
            }
          }
        }
      }
    } catch (error) {
      console.error('Error debugging storage:', error);
    }
    
    return result;
  }
}