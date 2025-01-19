import { Injectable } from '@angular/core';
import { Observable, BehaviorSubject, of, catchError, map, switchMap } from 'rxjs';
import { Lesson } from '../../shared/interfaces/lesson';
import { StorageService } from '../../core/services/storage.service';
import { UnitsService } from '../units/units.service';
import { TajweedVerse } from './interactive-lesson/interactive-lesson.types';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class LessonsService {
  private currentUnitIdSubject = new BehaviorSubject<string | null>(null);
  currentUnitId$ = this.currentUnitIdSubject.asObservable();
  private lessonsSubject = new BehaviorSubject<{ [key: string]: { [key: string]: Lesson[] } }>({});

  constructor(
    private http: HttpClient,
    private storageService: StorageService,
    private unitsService: UnitsService
  ) { }

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
    const lesson = lessons.find(l => l.id === lessonId);

    if (lesson) {
      lesson.isCompleted = true;

      this.storageService.saveProgress('lesson', `${courseId}_${unitId}_${lessonId}`, {
        progress: 100,
        isCompleted: true,
        lastUpdated: Date.now()
      });

      const completedLessons = lessons.filter(l => l.isCompleted).length;
      const unitProgress = Math.round((completedLessons * 100) / lessons.length);

      this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
        progress: unitProgress,
        isCompleted: unitProgress === 100,
        lastUpdated: Date.now()
      });

      const nextLesson = lessons.find(l => l.order === lesson.order + 1);
      if (nextLesson) {
        nextLesson.isLocked = false;
      }

      if (completedLessons === lessons.length) {
        this.unitsService.markUnitAsCompleted(courseId, unitId).subscribe();
      }

      // Update subject
      this.lessonsSubject.next({
        ...currentLessons,
        [courseId]: {
          ...currentLessons[courseId],
          [unitId]: lessons
        }
      });
    }

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
}