import { Injectable } from '@angular/core';
import { Observable, BehaviorSubject, of } from 'rxjs';
import { Lesson } from '../../shared/interfaces/lesson';

@Injectable({
  providedIn: 'root'
})
export class LessonsService {
  private currentUnitIdSubject = new BehaviorSubject<string | null>(null);
  currentUnitId$ = this.currentUnitIdSubject.asObservable();

  private mockLessons: { [key: string]: { [key: string]: Lesson[] } } = {
    'noon-meem-mushaddad': {
      'intro-noon-meem-unit': [
        {
          id: 'intro-lesson',
          title: 'مقدمة في النون والميم',
          description: 'تعريف وشرح مبسط للنون والميم المشددتين مع أمثلة توضيحية',
          type: 'video',
          icon: 'fa-play-circle',
          duration: 5,
          order: 1,
          unitId: 'intro-noon-meem-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: false,
          stepNumber: 1,
          totalSteps: 5
        },
        {
          id: 'pronunciation-basics',
          title: 'أساسيات النطق',
          description: 'تدريب على النطق الصحيح للنون والميم المشددتين',
          type: 'practice',
          icon: 'fa-microphone',
          duration: 10,
          order: 2,
          unitId: 'intro-noon-meem-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 2,
          totalSteps: 5
        },
        {
          id: 'interactive-drill',
          title: 'تدريب تفاعلي',
          description: 'تمارين تفاعلية مع التصحيح الفوري',
          type: 'practice',
          icon: 'fa-laptop',
          duration: 15,
          order: 3,
          unitId: 'intro-noon-meem-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 3,
          totalSteps: 5
        },
        {
          id: 'quran-examples',
          title: 'أمثلة قرآنية',
          description: 'دراسة أمثلة من القرآن الكريم',
          type: 'video',
          icon: 'fa-book-open',
          duration: 12,
          order: 4,
          unitId: 'intro-noon-meem-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 4,
          totalSteps: 5
        },
        {
          id: 'unit-assessment',
          title: 'التقييم النهائي',
          description: 'اختبار شامل للوحدة',
          type: 'test',
          icon: 'fa-check-circle',
          duration: 20,
          order: 5,
          unitId: 'intro-noon-meem-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 5,
          totalSteps: 5
        }
      ],
      'advanced-practice-unit': [
        {
          id: 'common-mistakes',
          title: 'الأخطاء الشائعة',
          description: 'تحليل وتصحيح الأخطاء الشائعة في النطق',
          type: 'video',
          icon: 'fa-exclamation-circle',
          duration: 8,
          order: 1,
          unitId: 'advanced-practice-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: false,
          stepNumber: 1,
          totalSteps: 6
        },
        {
          id: 'advanced-rules',
          title: 'القواعد المتقدمة',
          description: 'شرح مفصل للحالات الخاصة والاستثناءات',
          type: 'video',
          icon: 'fa-play-circle',
          duration: 15,
          order: 2,
          unitId: 'advanced-practice-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 2,
          totalSteps: 6
        },
        {
          id: 'recording-session',
          title: 'جلسة تسجيل',
          description: 'تسجيل صوتي مع التقييم والملاحظات',
          type: 'practice',
          icon: 'fa-microphone-alt',
          duration: 20,
          order: 3,
          unitId: 'advanced-practice-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 3,
          totalSteps: 6
        },
        {
          id: 'peer-review',
          title: 'مراجعة الأقران',
          description: 'جلسة تدريب جماعية مع الزملاء',
          type: 'practice',
          icon: 'fa-users',
          duration: 25,
          order: 4,
          unitId: 'advanced-practice-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 4,
          totalSteps: 6
        },
        {
          id: 'advanced-quiz',
          title: 'اختبار متقدم',
          description: 'اختبار شامل للمستوى المتقدم',
          type: 'test',
          icon: 'fa-star',
          duration: 30,
          order: 5,
          unitId: 'advanced-practice-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 5,
          totalSteps: 6
        },
        {
          id: 'certification',
          title: 'اختبار الشهادة',
          description: 'الاختبار النهائي للحصول على الشهادة',
          type: 'test',
          icon: 'fa-certificate',
          duration: 45,
          order: 6,
          unitId: 'advanced-practice-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: true,
          stepNumber: 6,
          totalSteps: 6
        }
      ]
    }
  };

  constructor() {}

  setCurrentUnit(unitId: string) {
    this.currentUnitIdSubject.next(unitId);
  }

  getLessonsByUnitId(courseId: string, unitId: string): Observable<Lesson[]> {
    return of(this.mockLessons[courseId]?.[unitId] || []);
  }

  getLessonById(courseId: string, unitId: string, lessonId: string): Observable<Lesson | undefined> {
    const lessons = this.mockLessons[courseId]?.[unitId] || [];
    const lesson = lessons.find(l => l.id === lessonId);
    return of(lesson);
  }

  markLessonAsCompleted(courseId: string, unitId: string, lessonId: string): Observable<void> {
    const lessons = this.mockLessons[courseId]?.[unitId] || [];
    const lesson = lessons.find(l => l.id === lessonId);
    
    if (lesson) {
      lesson.isCompleted = true;
      
      // Unlock next lesson if available
      const nextLesson = lessons.find(l => l.order === lesson.order + 1);
      if (nextLesson) {
        nextLesson.isLocked = false;
      }
    }
    
    return of(void 0);
  }

  // Additional helper methods
  getProgress(courseId: string, unitId: string): Observable<number> {
    const lessons = this.mockLessons[courseId]?.[unitId] || [];
    const totalLessons = lessons.length;
    const completedLessons = lessons.filter(l => l.isCompleted).length;
    
    return of(totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0);
  }

  isUnitCompleted(courseId: string, unitId: string): Observable<boolean> {
    const lessons = this.mockLessons[courseId]?.[unitId] || [];
    return of(lessons.length > 0 && lessons.every(l => l.isCompleted));
  }

  getNextIncompleteLesson(courseId: string, unitId: string): Observable<Lesson | undefined> {
    const lessons = this.mockLessons[courseId]?.[unitId] || [];
    const nextLesson = lessons.find(l => !l.isCompleted && !l.isLocked);
    return of(nextLesson);
  }
}