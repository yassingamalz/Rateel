import { Injectable, OnDestroy } from '@angular/core';
import { Observable, BehaviorSubject, of, catchError, map, switchMap, takeUntil, filter } from 'rxjs';
import { Lesson } from '../../shared/interfaces/lesson';
import { StorageService } from '../../core/services/storage.service';
import { UnitsService } from '../units/units.service';
import { TajweedVerse } from './interactive-lesson/interactive-lesson.types';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class LessonsService implements OnDestroy {
  private currentUnitIdSubject = new BehaviorSubject<string | null>(null);
  currentUnitId$ = this.currentUnitIdSubject.asObservable();
  private lessonsSubject = new BehaviorSubject<{ [key: string]: { [key: string]: Lesson[] } }>({});
  private destroy$ = new BehaviorSubject<boolean>(false);

  constructor(
    private http: HttpClient,
    private storageService: StorageService,
    private unitsService: UnitsService
  ) {
    // Set up subscription to storage changes for real-time updates
    this.setupProgressTracking();
  }

  private setupProgressTracking(): void {
    this.storageService.getProgressChanges()
      .pipe(
        takeUntil(this.destroy$),
        filter(change => !!change && change.type === 'lesson')
      )
      .subscribe(change => {
        if (!change) return;

        // Extract course, unit, and lesson IDs from the composite key
        const parts = change.id.split('_');
        if (parts.length >= 3) {
          const courseId = parts[0];
          const unitId = parts[1];
          const lessonId = parts[2];
          
          // Check if we have these lessons loaded
          const currentLessons = this.lessonsSubject.getValue();
          const unitLessons = currentLessons[courseId]?.[unitId];
          
          if (unitLessons) {
            // Create a new array with updated lesson objects
            const updatedLessons = unitLessons.map(lesson => {
              if (lesson.id === lessonId) {
                // Create a new lesson object with updated progress
                return {
                  ...lesson,
                  progress: change.data.progress,
                  isCompleted: change.data.isCompleted
                };
              }
              return lesson;
            });
            
            // Update with new references to trigger change detection
            this.lessonsSubject.next({
              ...currentLessons,
              [courseId]: {
                ...(currentLessons[courseId] || {}),
                [unitId]: updatedLessons
              }
            });
            
            console.debug(`[LessonsService] Updated lesson ${lessonId} progress to ${change.data.progress}%`);
          }
        }
      });
  }

  private loadLessonsData(courseId: string, unitId: string): Observable<Lesson[]> {
    return this.http.get<{ version: string, unitId: string, courseId: string, lessons: Lesson[] }>
      (`assets/data/lessons/${courseId}/${unitId}.json`).pipe(
        map(response => response.lessons),
        catchError(error => {
          console.error(`Error loading lessons for unit ${unitId}:`, error);
          return of([]);
        })
      );
  }

  private loadVerses(lessonId: string): Observable<TajweedVerse[]> {
    return this.http.get<{ version: string, lessonId: string, verses: TajweedVerse[] }>
      (`assets/data/content/verses/${lessonId}.json`).pipe(
        map(response => response.verses),
        catchError(error => {
          console.error(`Error loading verses for lesson ${lessonId}:`, error);
          return of([]);
        })
      );
  }

  private initializeLessonsForUnit(courseId: string, unitId: string): void {
    this.loadLessonsData(courseId, unitId).pipe(
      map(lessons => this.initializeWithProgress(courseId, unitId, lessons))
    ).subscribe(lessons => {
      const currentLessons = this.lessonsSubject.getValue();
      this.lessonsSubject.next({
        ...currentLessons,
        [courseId]: {
          ...(currentLessons[courseId] || {}),
          [unitId]: lessons
        }
      });
    });
  }

  private initializeWithProgress(courseId: string, unitId: string, lessons: Lesson[]): Lesson[] {
    let previousLessonCompleted = true;

    return lessons.map(lesson => {
      const storageKey = `${courseId}_${unitId}_${lesson.id}`;
      const progressData = this.storageService.getProgress('lesson', storageKey);
      const shouldBeLocked = lesson.order !== 1 && !previousLessonCompleted;

      const updatedLesson = {
        ...lesson,
        isCompleted: progressData?.isCompleted || false,
        isLocked: shouldBeLocked
      };

      previousLessonCompleted = updatedLesson.isCompleted;
      return updatedLesson;
    });
  }

  markLessonAsCompleted(courseId: string, unitId: string, lessonId: string): Observable<void> {
    const currentLessons = this.lessonsSubject.getValue();
    const lessons = currentLessons[courseId]?.[unitId] || [];
    
    // Find the lesson to complete
    const lessonIndex = lessons.findIndex(l => l.id === lessonId);
    if (lessonIndex === -1) {
      console.warn(`Lesson ${lessonId} not found in unit ${unitId}`);
      return of(void 0);
    }
    
    // Create a new array with updated lesson objects
    const updatedLessons = lessons.map((lesson, index) => {
      if (lesson.id === lessonId) {
        // Create a new lesson object for the completed lesson
        return {
          ...lesson,
          isCompleted: true,
          progress: 100
        };
      } else if (index === lessonIndex + 1) {
        // Unlock the next lesson
        return {
          ...lesson,
          isLocked: false
        };
      }
      return lesson;
    });

    // Save lesson progress to storage
    this.storageService.saveProgress('lesson', `${courseId}_${unitId}_${lessonId}`, {
      progress: 100,
      isCompleted: true,
      lastUpdated: Date.now()
    });

    // Calculate unit progress and update it
    const completedLessons = updatedLessons.filter(l => l.isCompleted).length;
    const unitProgress = Math.round((completedLessons * 100) / lessons.length);

    // Save unit progress
    this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
      progress: unitProgress,
      isCompleted: unitProgress === 100,
      lastUpdated: Date.now()
    });

    // Mark unit as completed if all lessons are done
    if (unitProgress === 100) {
      this.unitsService.markUnitAsCompleted(courseId, unitId).subscribe();
    }

    // Update subject with new references
    this.lessonsSubject.next({
      ...currentLessons,
      [courseId]: {
        ...(currentLessons[courseId] || {}),
        [unitId]: updatedLessons
      }
    });
    
    return of(void 0);
  }

  getLessonsByUnitId(courseId: string, unitId: string): Observable<Lesson[]> {
    const currentLessons = this.lessonsSubject.getValue()[courseId]?.[unitId];
    if (!currentLessons) {
      this.initializeLessonsForUnit(courseId, unitId);
    }
    return this.lessonsSubject.pipe(
      map(lessons => lessons[courseId]?.[unitId] || [])
    );
  }

  getLessonById(courseId: string, unitId: string, lessonId: string): Observable<Lesson | undefined> {
    return this.getLessonsByUnitId(courseId, unitId).pipe(
      map(lessons => lessons.find(l => l.id === lessonId)),
      switchMap(lesson => {
        if (lesson?.type === 'practice' && !lesson.verses) {
          // Load verses for practice lessons
          return this.loadVerses(lesson.id).pipe(
            map(verses => verses ? { ...lesson, verses } : lesson)
          );
        }
        return of(lesson);
      })
    );
  }

  getProgress(courseId: string, unitId: string): Observable<number> {
    return this.getLessonsByUnitId(courseId, unitId).pipe(
      map(lessons => {
        const totalLessons = lessons.length;
        if (totalLessons === 0) return 0;

        const lessonProgresses = lessons.map(lesson => {
          const savedProgress = this.storageService.getProgress(
            'lesson',
            `${courseId}_${unitId}_${lesson.id}`
          );
          return savedProgress?.progress || (lesson.isCompleted ? 100 : 0);
        });

        const totalProgress = lessonProgresses.reduce((sum, progress) => sum + progress, 0);
        return Math.round(totalProgress / totalLessons);
      })
    );
  }

  isUnitCompleted(courseId: string, unitId: string): Observable<boolean> {
    return this.getLessonsByUnitId(courseId, unitId).pipe(
      map(lessons => lessons.length > 0 && lessons.every(l => l.isCompleted))
    );
  }

  getNextIncompleteLesson(courseId: string, unitId: string): Observable<Lesson | undefined> {
    return this.getLessonsByUnitId(courseId, unitId).pipe(
      map(lessons => lessons.find(l => !l.isCompleted && !l.isLocked))
    );
  }

  getVerseContent(contentPath: string): Observable<{ verses: TajweedVerse[] }> {
    return this.http.get<{
      version: string,
      verses: TajweedVerse[]
    }>(`assets/data${contentPath}`).pipe(
      catchError(error => {
        console.error(`Error loading verse content from ${contentPath}:`, error);
        return of({ verses: [] });
      })
    );
  }

  setCurrentUnit(unitId: string): void {
    this.currentUnitIdSubject.next(unitId);
  }
  
  ngOnDestroy(): void {
    this.destroy$.next(true);
    this.destroy$.complete();
  }
}