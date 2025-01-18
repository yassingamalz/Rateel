import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { BehaviorSubject, Observable, of } from "rxjs";
import { StorageService } from "../../core/services/storage.service";
import { Unit } from "../../shared/interfaces/unit";
import { CoursesService } from "../courses/courses.service";

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
        title: 'تعريف النون والميم ',
        description: 'الدرس الأول: التعريف والأمثلة',
        courseId: 'noon-meem-mushaddad',
        type: 'video',
        icon: 'fa-play-circle',
        order: 1,
        isLocked: false,
        isCompleted: false,
        progress: 0,
      },
      {
        id: 'practical-noon-meem-unit',
        title: 'التطبيق العملي',
        description: 'الدرس الثاني: تطبيقات وتدريبات',
        courseId: 'noon-meem-mushaddad',
        type: 'exercise',
        icon: 'fa-pen-to-square',
        order: 2,
        isLocked: true,
        isCompleted: false,
        progress: 0,
      },
      {
        id: 'listening-practice-unit',
        title: 'تدريبات الاستماع',
        description: 'الدرس الثالث: الاستماع والتكرار',
        courseId: 'noon-meem-mushaddad',
        type: 'listening',
        icon: 'fa-headphones',
        order: 3,
        isLocked: true,
        isCompleted: false,
        progress: 0,
      },
      {
        id: 'reading-applications-unit',
        title: 'تطبيقات القراءة',
        description: 'الدرس الرابع: القراءة والتطبيق',
        courseId: 'noon-meem-mushaddad',
        type: 'reading',
        icon: 'fa-book-open',
        order: 4,
        isLocked: true,
        isCompleted: false,
        progress: 0,
      },
      {
        id: 'advanced-applications-unit',
        title: 'التطبيقات المتقدمة',
        description: 'الدرس الخامس: حالات خاصة وتطبيقات متقدمة',
        courseId: 'noon-meem-mushaddad',
        type: 'exercise',
        icon: 'fa-graduation-cap',
        order: 5,
        isLocked: true,
        isCompleted: false,
        progress: 0,
      }
    ]
  };

  constructor(
    private http: HttpClient,
    private storageService: StorageService,
    private coursesService: CoursesService
  ) {
    this.initializeFromStorage();
  }

  private initializeFromStorage(): void {
    Object.keys(this.mockUnits).forEach(courseId => {
      const cachedCourseProgress = this.storageService.getProgress('course', courseId);

      this.mockUnits[courseId] = this.mockUnits[courseId].map((unit, index) => {
        const cachedUnitProgress = this.storageService.getProgress('unit', `${courseId}_${unit.id}`);

        if (cachedUnitProgress) {
          const previousUnit = index > 0 ? this.mockUnits[courseId][index - 1] : null;

          return {
            ...unit,
            progress: cachedUnitProgress.progress,
            isCompleted: cachedUnitProgress.isCompleted,
            isLocked: !(unit.order === 1 ||
              (previousUnit?.isCompleted) ||
              (cachedCourseProgress && cachedCourseProgress.isCompleted))
          };
        }

        return unit;
      });
    });
  }

  markUnitAsCompleted(courseId: string, unitId: string): Observable<void> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    if (unit) {
      unit.isCompleted = true;
      unit.progress = 100;

      this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
        progress: 100,
        isCompleted: true
      });

      const nextUnit = this.mockUnits[courseId]?.find(u => u.order === unit.order + 1);
      if (nextUnit) {
        nextUnit.isLocked = false;
      }

      // Check if all units are completed
      const allUnitsCompleted = this.mockUnits[courseId]?.every(u => u.isCompleted);
      if (allUnitsCompleted) {
        this.coursesService.markCourseAsCompleted(courseId).subscribe();
      }
    }
    return of(void 0);
  }

  updateUnitProgress(courseId: string, unitId: string, progress: number): Observable<void> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    if (unit) {
      // Ensure progress is between 0 and 100 and rounded to whole numbers
      const normalizedProgress = Math.round(Math.min(100, Math.max(0, progress)));
      unit.progress = normalizedProgress;

      const isCompleted = normalizedProgress === 100;

      this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
        progress: normalizedProgress,
        isCompleted
      });

      if (isCompleted) {
        unit.isCompleted = true;
        const nextUnit = this.mockUnits[courseId]?.find(u => u.order === unit.order + 1);
        if (nextUnit) {
          nextUnit.isLocked = false;
        }
      }
    }
    return of(void 0);
  }

  setCurrentCourse(courseId: string): void {
    this.currentCourseIdSubject.next(courseId);
  }

  getUnitsByCourseId(courseId: string): Observable<Unit[]> {
    // First, update units based on storage
    this.initializeFromStorage();

    // Return units for the specific course
    return of(this.mockUnits[courseId] || []);
  }

  getUnitById(courseId: string, unitId: string): Observable<Unit | undefined> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    return of(unit);
  }

  getUnitIcon(type: string): string {
    switch (type) {
      case 'video':
        return 'fa-play-circle';
      case 'listening':
        return 'fa-headphones';
      case 'reading':
        return 'fa-book-open';
      case 'exercise':
        return 'fa-pen-to-square';
      default:
        return 'fa-circle';
    }
  }
}