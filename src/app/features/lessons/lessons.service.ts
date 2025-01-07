// src/app/features/lessons/lessons.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, of } from 'rxjs';
import { Lesson } from '../../shared/interfaces/lesson';

@Injectable({
  providedIn: 'root'
})
export class LessonsService {
  private currentCourseIdSubject = new BehaviorSubject<string | null>(null);
  currentCourseId$ = this.currentCourseIdSubject.asObservable();

  private mockLessons: { [key: string]: Lesson[] } = {
    'noon-meem-mushaddad': [
      {
        id: 'intro-noon-meem',
        title: 'مقدمة في النون والميم المشددتين',
        description: 'تعريف وشرح مبسط عن النون والميم المشددتين',
        type: 'video',
        icon: 'fa-play-circle',
        duration: 5,
        order: 1,
        courseId: 'noon-meem-mushaddad',
        isCompleted: false,
        isLocked: false
      },
      {
        id: 'noon-mushaddad-examples',
        title: 'أمثلة على النون المشددة',
        description: 'تطبيقات وأمثلة من القرآن الكريم',
        type: 'practice',
        icon: 'fa-book-reader',
        duration: 10,
        order: 2,
        courseId: 'noon-meem-mushaddad',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'meem-mushaddad-examples',
        title: 'أمثلة على الميم المشددة',
        description: 'شرح وتطبيق عملي للميم المشددة',
        type: 'practice',
        icon: 'fa-microphone',
        duration: 10,
        order: 3,
        courseId: 'noon-meem-mushaddad',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'practice-noon-meem',
        title: 'تدريب عملي',
        description: 'تطبيق عملي على النون والميم المشددتين',
        type: 'practice',
        icon: 'fa-tasks',
        duration: 15,
        order: 4,
        courseId: 'noon-meem-mushaddad',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'final-test-noon-meem',
        title: 'اختبار نهائي',
        description: 'اختبار شامل على النون والميم المشددتين',
        type: 'test',
        icon: 'fa-check-circle',
        duration: 20,
        order: 5,
        courseId: 'noon-meem-mushaddad',
        isCompleted: false,
        isLocked: true
      }
    ],
    'noon-tanween': [
      {
        id: 'intro-noon-tanween',
        title: 'مقدمة في النون الساكنة والتنوين',
        description: 'شرح أساسي للنون الساكنة والتنوين',
        type: 'video',
        icon: 'fa-play-circle',
        duration: 8,
        order: 1,
        courseId: 'noon-tanween',
        isCompleted: false,
        isLocked: false
      },
      {
        id: 'idgham-rules',
        title: 'أحكام الإدغام',
        description: 'شرح مفصل لأحكام الإدغام بأنواعه',
        type: 'video',
        icon: 'fa-video',
        duration: 12,
        order: 2,
        courseId: 'noon-tanween',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'ikhfa-rules',
        title: 'أحكام الإخفاء',
        description: 'شرح وتطبيق أحكام الإخفاء',
        type: 'practice',
        icon: 'fa-microphone',
        duration: 15,
        order: 3,
        courseId: 'noon-tanween',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'idhar-rules',
        title: 'أحكام الإظهار',
        description: 'شرح وتطبيق أحكام الإظهار',
        type: 'practice',
        icon: 'fa-microphone',
        duration: 15,
        order: 4,
        courseId: 'noon-tanween',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'iqlab-rules',
        title: 'حكم الإقلاب',
        description: 'شرح وتطبيق حكم الإقلاب',
        type: 'practice',
        icon: 'fa-microphone',
        duration: 10,
        order: 5,
        courseId: 'noon-tanween',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'final-exam-noon-tanween',
        title: 'الاختبار النهائي',
        description: 'اختبار شامل على جميع الأحكام',
        type: 'test',
        icon: 'fa-check-circle',
        duration: 30,
        order: 6,
        courseId: 'noon-tanween',
        isCompleted: false,
        isLocked: true
      }
    ],
    'meem-sakinah': [
      {
        id: 'intro-meem-sakinah',
        title: 'مقدمة في الميم الساكنة',
        description: 'تعريف وشرح مبسط للميم الساكنة',
        type: 'video',
        icon: 'fa-play-circle',
        duration: 6,
        order: 1,
        courseId: 'meem-sakinah',
        isCompleted: false,
        isLocked: false
      },
      {
        id: 'idgham-shafawi',
        title: 'الإدغام الشفوي',
        description: 'شرح وتطبيق الإدغام الشفوي',
        type: 'practice',
        icon: 'fa-microphone',
        duration: 12,
        order: 2,
        courseId: 'meem-sakinah',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'ikhfa-shafawi',
        title: 'الإخفاء الشفوي',
        description: 'شرح وتطبيق الإخفاء الشفوي',
        type: 'practice',
        icon: 'fa-microphone',
        duration: 12,
        order: 3,
        courseId: 'meem-sakinah',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'idhar-shafawi',
        title: 'الإظهار الشفوي',
        description: 'شرح وتطبيق الإظهار الشفوي',
        type: 'practice',
        icon: 'fa-microphone',
        duration: 12,
        order: 4,
        courseId: 'meem-sakinah',
        isCompleted: false,
        isLocked: true
      },
      {
        id: 'final-test-meem-sakinah',
        title: 'اختبار نهائي',
        description: 'اختبار شامل على أحكام الميم الساكنة',
        type: 'test',
        icon: 'fa-check-circle',
        duration: 20,
        order: 5,
        courseId: 'meem-sakinah',
        isCompleted: false,
        isLocked: true
      }
    ]
  };

  constructor(private http: HttpClient) {}

  setCurrentCourse(courseId: string) {
    this.currentCourseIdSubject.next(courseId);
  }

   getLessonsByCourseId(courseId: string): Observable<Lesson[]> {
    // Return mock data instead of HTTP call
    return of(this.mockLessons[courseId] || []);
  }

  getLessonById(courseId: string, lessonId: string): Observable<Lesson> {
    const lesson = this.mockLessons[courseId]?.find(l => l.id === lessonId);
    return of(lesson!);
  }

  markLessonAsCompleted(courseId: string, lessonId: string): Observable<void> {
    // Update mock data
    if (this.mockLessons[courseId]) {
      const lessonIndex = this.mockLessons[courseId].findIndex(l => l.id === lessonId);
      if (lessonIndex !== -1) {
        this.mockLessons[courseId][lessonIndex].isCompleted = true;
        
        // Unlock next lesson if available
        if (lessonIndex + 1 < this.mockLessons[courseId].length) {
          this.mockLessons[courseId][lessonIndex + 1].isLocked = false;
        }
      }
    }
    return of(void 0);
  }
}