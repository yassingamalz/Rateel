// src/app/features/units/units.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, of } from 'rxjs';
import { Unit } from '../../shared/interfaces/unit';
import { StorageService } from '../../core/services/storage.service';

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
    private storageService: StorageService
  ) {
    this.initializeFromStorage();
  }
 
  private initializeFromStorage(): void {
    Object.keys(this.mockUnits).forEach(courseId => {
      this.mockUnits[courseId] = this.mockUnits[courseId].map(unit => {
        const data = this.storageService.getProgress('unit', `${courseId}_${unit.id}`);
        if (!data) return unit;
 
        const previousUnit = unit.order > 1 ?
          this.mockUnits[courseId][unit.order - 2] : null;
 
        return {
          ...unit,
          progress: data.progress,
          isCompleted: data.isCompleted,
          isLocked: !(unit.order === 1 || (previousUnit?.isCompleted))
        };
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
    }
    return of(void 0);
  }
 
  updateUnitProgress(courseId: string, unitId: string, progress: number): Observable<void> {
    const unit = this.mockUnits[courseId]?.find(u => u.id === unitId);
    if (unit) {
      unit.progress = Math.min(100, Math.max(0, progress));
      const isCompleted = progress === 100;
      
      this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
        progress: unit.progress,
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