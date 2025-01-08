// courses.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { Course } from '../../shared/interfaces/course';
import { StorageService } from '../../core/services/storage.service';

@Injectable({
  providedIn: 'root'
})
export class CoursesService {
  private tajweedCourses: Course[] = [
    {
      id: 'noon-meem-mushaddad',
      title: 'النون والميم المشددتان',
      description: 'تعلم أحكام النون والميم المشددتين في القرآن الكريم',
      icon: 'book-quran',
      progress: 0,
      isLocked: false,
      badge: { type: 'achievement', value: 'مكتمل' }
    },
    {
      id: 'noon-tanween',
      title: 'النون الساكنه والتنوين',
      description: 'دراسة أحكام النون الساكنة والتنوين',
      icon: 'book-quran',
      progress: 0,
      isLocked: true
    },
    {
      id: 'meem-sakinah',
      title: 'الميم الساكنة',
      description: 'تعرف على أحكام الميم الساكنة',
      icon: 'book-quran',
      progress: 0,
      isLocked: true
    },
    {
      id: 'natural-madd',
      title: 'المد الطبيعي',
      description: 'أساسيات المد الطبيعي وتطبيقاته',
      icon: 'book-quran',
      progress: 0,
      isLocked: true
    },
    {
      id: 'derived-madd',
      title: 'المد الفرعي',
      description: 'دراسة أنواع المد الفرعي',
      icon: 'book-quran',
      progress: 0,
      isLocked: true
    },
    {
      id: 'madd-badal',
      title: 'مد البدل',
      description: 'فهم وتطبيق مد البدل',
      icon: 'book-quran',
      progress: 0,
      isLocked: true
    },
    {
      id: 'madd-arid',
      title: 'المد العارض للسكون',
      description: 'تعلم أحكام المد العارض للسكون',
      icon: 'book-quran',
      progress: 0,
      isLocked: true
    },
    {
      id: 'madd-lazim',
      title: 'المد اللازم',
      description: 'دراسة المد اللازم وأنواعه',
      icon: 'book-quran',
      progress: 0,
      isLocked: true
    }
  ];
  private coursesSubject = new BehaviorSubject<Course[]>(this.tajweedCourses);
  courses$ = this.coursesSubject.asObservable();
 
  constructor(private storageService: StorageService) {
    this.initializeFromStorage();
  }
 
  private initializeFromStorage(): void {
    this.tajweedCourses = this.tajweedCourses.map(course => {
      const data = this.storageService.getProgress('course', course.id);
      if (!data) return course;
 
      let nextCourse = this.tajweedCourses.find(c => 
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
        progress: data.progress,
        isCompleted: data.isCompleted,
        isLocked: course.isLocked && !data.isCompleted
      };
    });
    
    this.coursesSubject.next(this.tajweedCourses);
  }
 
  updateCourseProgress(courseId: string, progress: number, isCompleted: boolean = false): void {
    this.storageService.saveProgress('course', courseId, { progress, isCompleted });
    
    const updatedCourses = this.tajweedCourses.map(course => {
      if (course.id === courseId) {
        return { ...course, progress, isCompleted };
      }
      if (isCompleted && course.isLocked) {
        return { ...course, isLocked: false };
      }
      return course;
    });
 
    this.tajweedCourses = updatedCourses;
    this.coursesSubject.next(updatedCourses);
  }
 
  unlockCourse(courseId: string): void {
    const updatedCourses = this.tajweedCourses.map(course =>
      course.id === courseId ? { ...course, isLocked: false } : course
    );
    this.tajweedCourses = updatedCourses;
    this.coursesSubject.next(updatedCourses);
  }
 
  getCourses(): Observable<Course[]> {
    return this.courses$;
  }
 
  getCourseById(courseId: string): Course | undefined {
    return this.tajweedCourses.find(course => course.id === courseId);
  }
  
  markCourseAsCompleted(courseId: string): Observable<void> {
    this.updateCourseProgress(courseId, 100, true);
    
    const nextCourse = this.tajweedCourses.find(course => 
      course.isLocked && course.id !== courseId
    );
    
    if (nextCourse) {
      this.unlockCourse(nextCourse.id);
    }
  
    return of(void 0);
  }
 }