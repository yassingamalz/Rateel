// courses.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { Course } from '../../shared/interfaces/course';

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

  constructor() {}

  getCourses(): Observable<Course[]> {
    return this.courses$;
  }

  updateCourseProgress(courseId: string, progress: number): void {
    const updatedCourses = this.tajweedCourses.map(course => 
      course.id === courseId ? { ...course, progress } : course
    );
    this.coursesSubject.next(updatedCourses);
  }

  unlockCourse(courseId: string): void {
    const updatedCourses = this.tajweedCourses.map(course =>
      course.id === courseId ? { ...course, isLocked: false } : course
    );
    this.coursesSubject.next(updatedCourses);
  }
}