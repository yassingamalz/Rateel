//src\app\features\courses\courses.service.ts
import { Injectable, OnDestroy } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, of, takeUntil, filter, map, catchError, distinctUntilChanged } from 'rxjs';
import { Course } from '../../shared/interfaces/course';
import { StorageService } from '../../core/services/storage.service';

@Injectable({
  providedIn: 'root'
})
export class CoursesService implements OnDestroy {
  private coursesSubject = new BehaviorSubject<Course[]>([]);
  private destroy$ = new BehaviorSubject<boolean>(false);
  private refreshTrigger = new BehaviorSubject<string | null>(null);

  constructor(
    private http: HttpClient,
    private storageService: StorageService
  ) {
    this.initializeCourses();

    // Subscribe to storage changes for real-time progress updates
    this.storageService.getProgressChanges()
      .pipe(
        takeUntil(this.destroy$),
        filter(change => !!change && change.type === 'course')
      )
      .subscribe(change => {
        if (!change) return;

        const courseId = change.id;
        console.log(`[CoursesService] Storage change detected for course ${courseId}, progress: ${change.data.progress}%`);
        
        // Force refresh the course data
        this.refreshCourse(courseId);
      });
      
    // Listen to refresh trigger
    this.refreshTrigger
      .pipe(
        takeUntil(this.destroy$),
        distinctUntilChanged(),
        filter(id => !!id)
      )
      .subscribe(courseId => {
        if (courseId) {
          this.refreshCourse(courseId);
        }
      });
  }

  /**
   * Force refresh a specific course's data
   */
  public refreshCourse(courseId: string): void {
    const currentCourses = this.coursesSubject.getValue();
    const courseIndex = currentCourses.findIndex(c => c.id === courseId);
    
    if (courseIndex === -1) {
      console.warn(`[CoursesService] Cannot refresh course ${courseId}: not found in current courses`);
      return;
    }
    
    // Get fresh data from storage
    const progressData = this.storageService.getProgress('course', courseId);
    if (!progressData) {
      console.warn(`[CoursesService] No progress data found for course ${courseId}`);
      return;
    }
    
    // Create a new array with updated objects for change detection
    const updatedCourses = [...currentCourses];
    updatedCourses[courseIndex] = {
      ...currentCourses[courseIndex],
      progress: progressData.progress || 0,
      isCompleted: progressData.isCompleted || false,
      isLocked: progressData.isLocked || false
    };
    
    // Update the courses array with the new reference
    this.coursesSubject.next(updatedCourses);
    console.log(`[CoursesService] Refreshed course ${courseId}, progress: ${progressData.progress}%`);
  }
  
  /**
   * Force refresh all courses
   */
  public refreshAllCourses(): void {
    const currentCourses = this.coursesSubject.getValue();
    const updatedCourses = currentCourses.map(course => {
      const progressData = this.storageService.getProgress('course', course.id);
      if (progressData) {
        return {
          ...course,
          progress: progressData.progress || 0,
          isCompleted: progressData.isCompleted || false,
          isLocked: progressData.isLocked || false
        };
      }
      return course;
    });
    
    this.coursesSubject.next(updatedCourses);
    console.log(`[CoursesService] Refreshed all courses`);
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
    return this.coursesSubject.asObservable();
  }

  getCourseById(courseId: string): Observable<Course | undefined> {
    // Force refresh when requesting a specific course
    setTimeout(() => this.refreshTrigger.next(courseId), 0);
    
    return this.coursesSubject.pipe(
      map(courses => courses.find(course => course.id === courseId))
    );
  }

  updateCourseProgress(courseId: string, progress: number, isCompleted: boolean = false): void {
    // Ensure progress is between 0 and 100
    const normalizedProgress = Math.round(Math.max(0, Math.min(100, progress)));
  
    // Save progress to storage
    this.storageService.saveProgress('course', courseId, { 
      progress: normalizedProgress, 
      isCompleted 
    });
  
    // Force refresh to ensure UI updates
    setTimeout(() => this.refreshCourse(courseId), 10);
  }
  
  markCourseAsCompleted(courseId: string): Observable<void> {
    // Update progress to 100% and mark as completed
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
      
      // Force refresh the next course too
      setTimeout(() => this.refreshCourse(nextCourse.id), 20);
    }
  
    return of(void 0);
  }

  unlockCourse(courseId: string): void {
    // Mark the course as unlocked in storage
    this.storageService.saveProgress('course', courseId, {
      isLocked: false
    });
    
    // Force refresh
    setTimeout(() => this.refreshCourse(courseId), 10);
  }

  ngOnDestroy(): void {
    this.destroy$.next(true);
    this.destroy$.complete();
  }
}