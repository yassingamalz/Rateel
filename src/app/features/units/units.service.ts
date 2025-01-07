// src/app/features/units/units.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, of } from 'rxjs';
import { Lesson } from '../../shared/interfaces/lesson';
import { Unit } from '../../shared/interfaces/unit';

@Injectable({
  providedIn: 'root'
})
export class UnitsService {
  private currentCourseIdSubject = new BehaviorSubject<string | null>(null);
  currentCourseId$ = this.currentCourseIdSubject.asObservable();
  private mockUnits: { [key: string]: Unit[] } = {
    'noon-meem-mushaddad': [
      {
        id: 'intro-noon-meem-unit',
        title: 'تعريف النون والميم المشددتين',
        description: 'الدرس الأول: التعريف والأمثلة',
        courseId: 'noon-meem-mushaddad',
        order: 1,
        isLocked: false,
        isCompleted: false,
        progress: 0,
        lessons: [
          {
            id: 'intro-noon-meem',
            title: 'مقدمة في النون والميم',
            description: 'تعريف وشرح مبسط للنون والميم المشددتين',
            type: 'video',
            icon: 'fa-play-circle',
            duration: 5,
            order: 1,
            unitId: 'intro-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: false,
            stepNumber: 1,
            totalSteps: 3
          },
          {
            id: 'basic-examples',
            title: 'أمثلة أساسية',
            description: 'أمثلة تطبيقية أولية من القرآن الكريم',
            type: 'practice',
            icon: 'fa-book-reader',
            duration: 10,
            order: 2,
            unitId: 'intro-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 2,
            totalSteps: 3
          },
          {
            id: 'unit-test',
            title: 'اختبار الوحدة',
            description: 'اختبار قصير للتأكد من الفهم',
            type: 'test',
            icon: 'fa-check-circle',
            duration: 15,
            order: 3,
            unitId: 'intro-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 3,
            totalSteps: 3
          }
        ]
      },
      {
        id: 'practical-noon-meem-unit',
        title: 'التطبيق العملي',
        description: 'الدرس الثاني: تطبيقات وتدريبات',
        courseId: 'noon-meem-mushaddad',
        order: 2,
        isLocked: true,
        isCompleted: false,
        progress: 0,
        lessons: [
          {
            id: 'practice-rules',
            title: 'قواعد التطبيق',
            description: 'شرح مفصل لقواعد تطبيق النون والميم المشددتين',
            type: 'video',
            icon: 'fa-play-circle',
            duration: 8,
            order: 1,
            unitId: 'practical-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: false,
            stepNumber: 1,
            totalSteps: 4
          },
          {
            id: 'interactive-examples',
            title: 'أمثلة تفاعلية',
            description: 'تدريبات تفاعلية مع التصحيح الفوري',
            type: 'practice',
            icon: 'fa-laptop',
            duration: 15,
            order: 2,
            unitId: 'practical-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 2,
            totalSteps: 4
          },
          {
            id: 'recording-practice',
            title: 'تسجيل صوتي',
            description: 'تدريب على النطق الصحيح مع التسجيل',
            type: 'practice',
            icon: 'fa-microphone',
            duration: 10,
            order: 3,
            unitId: 'practical-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 3,
            totalSteps: 4
          },
          {
            id: 'final-assessment',
            title: 'التقييم النهائي',
            description: 'اختبار شامل للوحدة',
            type: 'test',
            icon: 'fa-star',
            duration: 20,
            order: 4,
            unitId: 'practical-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 4,
            totalSteps: 4
          }
        ]
      },
      {
        id: 'advanced-applications-unit',
        title: 'التطبيقات المتقدمة',
        description: 'الدرس الثالث: حالات خاصة وتطبيقات متقدمة',
        courseId: 'noon-meem-mushaddad',
        order: 3,
        isLocked: true,
        isCompleted: false,
        progress: 0,
        lessons: [
          {
            id: 'special-cases',
            title: 'الحالات الخاصة',
            description: 'شرح الحالات الاستثنائية والخاصة',
            type: 'video',
            icon: 'fa-play-circle',
            duration: 12,
            order: 1,
            unitId: 'advanced-applications-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: false,
            stepNumber: 1,
            totalSteps: 5
          },
          {
            id: 'quran-examples',
            title: 'أمثلة من القرآن',
            description: 'دراسة أمثلة متنوعة من القرآن الكريم',
            type: 'video',
            icon: 'fa-book-open',
            duration: 15,
            order: 2,
            unitId: 'advanced-applications-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 2,
            totalSteps: 5
          },
          {
            id: 'advanced-practice',
            title: 'تدريبات متقدمة',
            description: 'تطبيقات متقدمة على الحالات الخاصة',
            type: 'practice',
            icon: 'fa-tasks',
            duration: 20,
            order: 3,
            unitId: 'advanced-applications-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 3,
            totalSteps: 5
          },
          {
            id: 'peer-review',
            title: 'مراجعة الأقران',
            description: 'تدريب جماعي وتقييم الأقران',
            type: 'practice',
            icon: 'fa-users',
            duration: 25,
            order: 4,
            unitId: 'advanced-applications-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 4,
            totalSteps: 5
          },
          {
            id: 'certification-test',
            title: 'اختبار الشهادة',
            description: 'الاختبار النهائي للحصول على الشهادة',
            type: 'test',
            icon: 'fa-certificate',
            duration: 30,
            order: 5,
            unitId: 'advanced-applications-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: true,
            stepNumber: 5,
            totalSteps: 5
          }
        ]
      }
    ]
  };

  constructor(private http: HttpClient) {}

  setCurrentCourse(courseId: string) {
    this.currentCourseIdSubject.next(courseId);
  }

  getUnitsByCourseId(courseId: string): Observable<Unit[]> {
    return of(this.mockUnits[courseId] || []);
  }

  getUnitById(courseId: string, unitId: string): Observable<Unit | undefined> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    return of(unit);
  }

  getLessonsByUnitId(courseId: string, unitId: string): Observable<Lesson[]> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    return of(unit?.lessons || []);
  }

  getLessonById(courseId: string, unitId: string, lessonId: string): Observable<Lesson | undefined> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    const lesson = unit?.lessons.find(l => l.id === lessonId);
    return of(lesson);
  }

  markLessonAsCompleted(courseId: string, unitId: string, lessonId: string): Observable<void> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    if (unit) {
      const lesson = unit.lessons.find(l => l.id === lessonId);
      if (lesson) {
        lesson.isCompleted = true;
        
        // Update unit progress
        const completedLessons = unit.lessons.filter(l => l.isCompleted).length;
        unit.progress = (completedLessons / unit.lessons.length) * 100;

        // Unlock next lesson if available
        const nextLesson = unit.lessons.find(l => l.order === lesson.order + 1);
        if (nextLesson) {
          nextLesson.isLocked = false;
        } else {
          // If no more lessons in this unit, mark unit as completed and unlock next unit
          unit.isCompleted = true;
          const nextUnit = this.mockUnits[courseId]?.find(u => u.order === unit.order + 1);
          if (nextUnit) {
            nextUnit.isLocked = false;
          }
        }
      }
    }
    return of(void 0);
  }
}