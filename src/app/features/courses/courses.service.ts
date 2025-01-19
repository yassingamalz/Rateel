// src/app/features/courses/courses.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { map, tap, catchError } from 'rxjs/operators';
import { Course } from '../../shared/interfaces/course';
import { StorageService } from '../../core/services/storage.service';

@Injectable({
  providedIn: 'root'
})
export class CoursesService {
  private coursesSubject = new BehaviorSubject<Course[]>([]);
  courses$ = this.coursesSubject.asObservable();

  constructor(
    private http: HttpClient,
    private storageService: StorageService
  ) {
    this.initializeCourses();
  }

  private initializeCourses(): void {
    this.loadCoursesData().pipe(
      map(courses => this.initializeWithProgress(courses))
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

  private initializeWithProgress(courses: Course[]): Course[] {
    return courses.map(course => {
      const data = this.storageService.getProgress('course', course.id);
      if (!data) return course;

      let nextCourse = courses.find(c =>
        c.isLocked && c.id !== course.id
      );

      if (data.isCompleted && nextCourse) {
        nextCourse.isLocked = false;
        this.storageService.saveProgress('course', nextCourse.id, {
          progress: 0,
          isCompleted: false
        });
      }

      return {
        ...course,
        progress: data.progress ?? 0,
        isCompleted: data.isCompleted ?? false,
        isLocked: course.isLocked && !data.isCompleted
      };
    });
  }

  updateCourseProgress(courseId: string, progress: number, isCompleted: boolean = false): void {
    this.storageService.saveProgress('course', courseId, { progress, isCompleted });

    const currentCourses = this.coursesSubject.getValue();
    const updatedCourses = currentCourses.map(course => {
      if (course.id === courseId) {
        return { ...course, progress, isCompleted };
      }
      if (isCompleted && course.isLocked) {
        return { ...course, isLocked: false };
      }
      return course;
    });

    this.coursesSubject.next(updatedCourses);
  }

  unlockCourse(courseId: string): void {
    const currentCourses = this.coursesSubject.getValue();
    const updatedCourses = currentCourses.map(course =>
      course.id === courseId ? { ...course, isLocked: false } : course
    );
    this.coursesSubject.next(updatedCourses);
  }

  getCourses(): Observable<Course[]> {
    return this.courses$;
  }

  getCourseById(courseId: string): Course | undefined {
    return this.coursesSubject.getValue().find(course => course.id === courseId);
  }

  markCourseAsCompleted(courseId: string): Observable<void> {
    this.updateCourseProgress(courseId, 100, true);

    const courses = this.coursesSubject.getValue();
    const nextCourse = courses.find(course =>
      course.isLocked && course.id !== courseId
    );

    if (nextCourse) {
      this.unlockCourse(nextCourse.id);
    }

    return of(void 0);
  }
}