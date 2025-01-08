import { Injectable } from '@angular/core';
import { Observable, BehaviorSubject, of } from 'rxjs';
import { Lesson } from '../../shared/interfaces/lesson';
import { StorageService } from '../../core/services/storage.service';
import { UnitsService } from '../units/units.service';

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
          totalSteps: 5,
          videoUrl:"https://www.youtube.com/watch?v=XfDdA9UgOVQ&list=PLhSrwfCNArc69Wixtzt9v4dLth6k7DrWh&index=1&pp=iAQB"
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
          type: 'read',
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
          type: 'listen',
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
      'practical-noon-meem-unit': [
        {
          id: 'practical-lesson-1',
          title: 'تطبيقات عملية',
          description: 'تمارين تطبيقية على النون والميم المشددتين',
          type: 'practice',
          icon: 'fa-pen-to-square',
          duration: 15,
          order: 1,
          unitId: 'practical-noon-meem-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: false,
          stepNumber: 1,
          totalSteps: 3
        }
      ],
      'listening-practice-unit': [
        {
          id: 'listening-lesson-1',
          title: 'تدريبات سمعية',
          description: 'الاستماع إلى أمثلة صوتية للنون والميم المشددتين',
          type: 'listen',
          icon: 'fa-headphones',
          duration: 10,
          order: 1,
          unitId: 'listening-practice-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: false,
          stepNumber: 1,
          totalSteps: 2
        }
      ],
      'reading-applications-unit': [
        {
          id: 'reading-lesson-1',
          title: 'قراءة وتطبيق',
          description: 'قراءة نصوص تحتوي على النون والميم المشددتين',
          type: 'read',
          icon: 'fa-book-open',
          duration: 12,
          order: 1,
          unitId: 'reading-applications-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: false,
          stepNumber: 1,
          totalSteps: 3
        }
      ],
      'advanced-applications-unit': [
        {
          id: 'advanced-lesson-1',
          title: 'التطبيقات المتقدمة',
          description: 'حالات خاصة وتطبيقات متقدمة للنون والميم المشددتين',
          type: 'practice',
          icon: 'fa-graduation-cap',
          duration: 20,
          order: 1,
          unitId: 'advanced-applications-unit',
          courseId: 'noon-meem-mushaddad',
          isCompleted: false,
          isLocked: false,
          stepNumber: 1,
          totalSteps: 4
        }
      ]
    }
  };


  constructor(
    private storageService: StorageService,
    private unitsService: UnitsService
  ) {
    this.initializeFromStorage();
  }

  markLessonAsCompleted(courseId: string, unitId: string, lessonId: string): Observable<void> {
    const lessons = this.mockLessons[courseId]?.[unitId] || [];
    const lesson = lessons.find(l => l.id === lessonId);

    if (lesson) {
      lesson.isCompleted = true;
      lesson.isLocked = false;

      this.storageService.saveProgress('lesson', `${courseId}_${unitId}_${lessonId}`, {
        progress: 100,
        isCompleted: true
      });

      // Unlock next lesson
      const nextLesson = lessons.find(l => l.order === lesson.order + 1);
      if (nextLesson) {
        nextLesson.isLocked = false;
      }

      // Check if all lessons are completed
      const allLessonsCompleted = lessons.every(l => l.isCompleted);
      if (allLessonsCompleted) {
        // Mark unit as completed and unlock next unit
        this.unitsService.markUnitAsCompleted(courseId, unitId).subscribe();
      }
    }

    return of(void 0);
  }

  getLessonsByUnitId(courseId: string, unitId: string): Observable<Lesson[]> {
    return of(this.mockLessons[courseId]?.[unitId] || []);
  }

  getLessonById(courseId: string, unitId: string, lessonId: string): Observable<Lesson | undefined> {
    const lessons = this.mockLessons[courseId]?.[unitId] || [];
    return of(lessons.find(l => l.id === lessonId));
  }

  private initializeFromStorage(): void {
    Object.keys(this.mockLessons).forEach(courseId => {
      Object.keys(this.mockLessons[courseId]).forEach(unitId => {
        this.mockLessons[courseId][unitId] = this.mockLessons[courseId][unitId].map(lesson => {
          const data = this.storageService.getProgress('lesson', `${courseId}_${unitId}_${lesson.id}`);
          if (!data) return lesson;

          const previousLesson = lesson.order > 1 ?
            this.mockLessons[courseId][unitId][lesson.order - 2] : null;

          return {
            ...lesson,
            isCompleted: data.isCompleted,
            isLocked: !(lesson.order === 1 || (previousLesson?.isCompleted))
          };
        });
      });
    });
  }

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
    return of(lessons.find(l => !l.isCompleted && !l.isLocked));
  }

  setCurrentUnit(unitId: string): void {
    this.currentUnitIdSubject.next(unitId);
  }
}