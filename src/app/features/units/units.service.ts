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
            description: 'تعريف وشرح مبسط',
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
            description: 'أمثلة تطبيقية أولية',
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
            id: 'practice-examples',
            title: 'تدريبات متنوعة',
            description: 'مجموعة من التدريبات التطبيقية',
            type: 'practice',
            icon: 'fa-microphone',
            duration: 15,
            order: 1,
            unitId: 'practical-noon-meem-unit',
            courseId: 'noon-meem-mushaddad',
            isCompleted: false,
            isLocked: false,
            stepNumber: 1,
            totalSteps: 3
          }
          // Add more lessons...
        ]
      }
      // Add more units...
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