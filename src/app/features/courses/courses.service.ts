// src/app/features/courses/courses.service.ts
import { Injectable, OnDestroy } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, of, takeUntil } from 'rxjs';
import { map, catchError } from 'rxjs/operators';
import { Course } from '../../shared/interfaces/course';
import { StorageService } from '../../core/services/storage.service';

@Injectable({
  providedIn: 'root'
})
export class CoursesService implements OnDestroy {
  private coursesSubject = new BehaviorSubject<Course[]>([]);
  courses$ = this.coursesSubject.asObservable();
  private destroy$ = new BehaviorSubject<boolean>(false);

  constructor(
    private http: HttpClient,
    private storageService: StorageService
  ) {
    this.initializeCourses();

    // Subscribe to storage changes to update courses reactively
    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (!change) return;

        if (change.type === 'course') {
          const courseId = change.id;
          const currentCourses = this.coursesSubject.getValue();
          
          // Create new array with updated course objects
          const updatedCourses = currentCourses.map(course => {
            if (course.id === courseId) {
              // Create a new course object with updated values
              return {
                ...course,
                progress: change.data.progress,
                isCompleted: change.data.isCompleted,
                isLocked: change.data.isLocked ?? course.isLocked
              };
            }
            return course;
          });

          // Update subject with new references
          this.coursesSubject.next(updatedCourses);
        }
      });
  }

  private initializeCourses(): void {
    this.loadCoursesData().pipe(
      map(courses => this.processCoursesInitialState(courses))
    ).subscribe(courses => {
      this.coursesSubject.next(courses);
    });
  }

  private loadCoursesData(): Observable<Course[]> {
    return this.http.get<{ version: string, courses: Course[] }>('assets/data/courses.json').pipe(
      map(response => response.courses),
      catchError(error => {
        console.error('Error loading courses:', error);
        return of([]);
      })
    );
  }

  private processCoursesInitialState(courses: Course[]): Course[] {
    return courses.map((course, index) => {
      // Prepare storage key
      const storageKey = course.id;

      // Check existing progress
      const existingProgress = this.storageService.getProgress('course', storageKey);

      // Determine if course should be unlocked
      const shouldBeUnlocked = index === 0 || 
        (index > 0 && this.storageService.getProgress('course', courses[index-1].id)?.isCompleted);

      // Initialize progress if not exists or for the first course
      if (!existingProgress || index === 0) {
        this.storageService.saveProgress('course', storageKey, {
          progress: index === 0 ? 0 : undefined,
          isCompleted: false,
          isLocked: !shouldBeUnlocked
        });
      }

      // Return processed course
      return {
        ...course,
        progress: existingProgress?.progress ?? (index === 0 ? 0 : undefined),
        isCompleted: existingProgress?.isCompleted ?? false,
        isLocked: !shouldBeUnlocked
      };
    });
  }

  getCourses(): Observable<Course[]> {
    return this.courses$;
  }

  getCourseById(courseId: string): Observable<Course | undefined> {
    return this.courses$.pipe(
      map(courses => courses.find(course => course.id === courseId))
    );
  }

  updateCourseProgress(courseId: string, progress: number, isCompleted: boolean = false): void {
    // Ensure progress is between 0 and 100
    const normalizedProgress = Math.max(0, Math.min(100, progress));
  
    // Save progress
    this.storageService.saveProgress('course', courseId, { 
      progress: normalizedProgress, 
      isCompleted 
    });
  
    // Update local state with new object references to trigger change detection
    const currentCourses = this.coursesSubject.getValue();
    const updatedCourses = currentCourses.map(course => {
      if (course.id === courseId) {
        return { 
          ...course, // Create a new object with updated values
          progress: normalizedProgress, 
          isCompleted 
        };
      }
      return course;
    });
  
    this.coursesSubject.next(updatedCourses); // New array triggers change detection
  }
  
  markCourseAsCompleted(courseId: string): Observable<void> {
    // Update progress to 100%
    this.updateCourseProgress(courseId, 100, true);
  
    // Find and potentially unlock next course
    const courses = this.coursesSubject.getValue();
    const currentIndex = courses.findIndex(c => c.id === courseId);
    
    if (currentIndex < courses.length - 1) {
      const nextCourse = courses[currentIndex + 1];
      
      // Unlock next course
      this.storageService.saveProgress('course', nextCourse.id, {
        isLocked: false
      });
      
      // Update courses array with new object references
      const updatedCourses = courses.map((course, index) => {
        if (index === currentIndex + 1) {
          return { ...course, isLocked: false };
        }
        return course;
      });
      
      this.coursesSubject.next(updatedCourses);
    }
  
    return of(void 0);
  }

  unlockCourse(courseId: string): void {
    const currentCourses = this.coursesSubject.getValue();
    const updatedCourses = currentCourses.map(course =>
      course.id === courseId 
        ? { ...course, isLocked: false } 
        : course
    );

    // Save unlock state
    this.storageService.saveProgress('course', courseId, {
      isLocked: false
    });

    this.coursesSubject.next(updatedCourses);
  }

  ngOnDestroy(): void {
    this.destroy$.next(true);
    this.destroy$.complete();
  }
}