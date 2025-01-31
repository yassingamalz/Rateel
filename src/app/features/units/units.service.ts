import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { BehaviorSubject, catchError, map, Observable, of } from "rxjs";
import { StorageService } from "../../core/services/storage.service";
import { Unit } from "../../shared/interfaces/unit";
import { CoursesService } from "../courses/courses.service";

@Injectable({
  providedIn: 'root'
})
export class UnitsService {
  private currentCourseIdSubject = new BehaviorSubject<string | null>(null);
  currentCourseId$ = this.currentCourseIdSubject.asObservable();
  private unitsSubject = new BehaviorSubject<{ [key: string]: Unit[] }>({});

  constructor(
    private http: HttpClient,
    private storageService: StorageService,
    private coursesService: CoursesService
  ) { }

  private loadUnitsData(courseId: string): Observable<Unit[]> {
    return this.http.get<{ version: string, courseId: string, units: Unit[] }>
      (`assets/data/units/${courseId}.json`).pipe(
        map(response => response.units),
        catchError(error => {
          console.error('Error loading units:', error);
          return of([]);
        })
      );
  }

  private initializeUnitsForCourse(courseId: string): void {
    this.loadUnitsData(courseId).pipe(
      map(units => this.initializeWithProgress(courseId, units))
    ).subscribe(units => {
      const currentUnits = this.unitsSubject.getValue();
      this.unitsSubject.next({
        ...currentUnits,
        [courseId]: units
      });
    });
  }

  private initializeWithProgress(courseId: string, units: Unit[]): Unit[] {
    const cachedCourseProgress = this.storageService.getProgress('course', courseId);
    let previousUnitCompleted = true; // First unit is always unlocked

    return units.map((unit, index) => {
      const cachedUnitProgress = this.storageService.getProgress(
        'unit',
        `${courseId}_${unit.id}`
      );

      // Previous unit completion or course completion unlocks next unit
      const isUnlocked = unit.order === 1 || 
                        previousUnitCompleted || 
                        cachedCourseProgress?.isCompleted;

      if (cachedUnitProgress) {
        previousUnitCompleted = cachedUnitProgress.isCompleted;
        return {
          ...unit,
          progress: cachedUnitProgress.progress || 0,
          isCompleted: cachedUnitProgress.isCompleted || false,
          isLocked: !isUnlocked // Use calculated unlock state
        };
      }

      // For units with no saved progress
      previousUnitCompleted = false;
      return {
        ...unit,
        progress: 0,
        isCompleted: false,
        isLocked: !isUnlocked
      };
    });
  }

  markUnitAsCompleted(courseId: string, unitId: string): Observable<void> {
    const currentUnits = this.unitsSubject.getValue();
    const units = currentUnits[courseId] || [];
    const unit = units.find(u => u.id === unitId);

    if (unit) {
      unit.isCompleted = true;
      unit.progress = 100;

      // Save unit progress
      this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
        progress: 100,
        isCompleted: true,
        lastUpdated: Date.now()
      });

      // Unlock next unit and save its state
      const nextUnit = units.find(u => u.order === unit.order + 1);
      if (nextUnit) {
        nextUnit.isLocked = false;
        // Save unlocked state for next unit
        this.storageService.saveProgress('unit', `${courseId}_${nextUnit.id}`, {
          progress: 0,
          isCompleted: false,
          isLocked: false,
          lastUpdated: Date.now()
        });
      }

      // Check if all units are completed
      const allUnitsCompleted = units.every(u => u.isCompleted);
      if (allUnitsCompleted) {
        this.coursesService.markCourseAsCompleted(courseId).subscribe();
      }

      // Update subject
      this.unitsSubject.next({
        ...currentUnits,
        [courseId]: units
      });
    }

    return of(void 0);
  }

  updateUnitProgress(courseId: string, unitId: string, progress: number): Observable<void> {
    const currentUnits = this.unitsSubject.getValue();
    const units = currentUnits[courseId] || [];
    const unit = units.find(u => u.id === unitId);

    if (unit) {
      const normalizedProgress = Math.round(Math.min(100, Math.max(0, progress)));
      unit.progress = normalizedProgress;
      const isCompleted = normalizedProgress === 100;

      this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
        progress: normalizedProgress,
        isCompleted
      });

      if (isCompleted) {
        unit.isCompleted = true;
        const nextUnit = units.find(u => u.order === unit.order + 1);
        if (nextUnit) {
          nextUnit.isLocked = false;
        }
      }

      this.unitsSubject.next({
        ...currentUnits,
        [courseId]: units
      });
    }
    return of(void 0);
  }

  setCurrentCourse(courseId: string): void {
    this.currentCourseIdSubject.next(courseId);
    // Load units data if not already loaded
    if (!this.unitsSubject.getValue()[courseId]) {
      this.initializeUnitsForCourse(courseId);
    }
  }

  getUnitsByCourseId(courseId: string): Observable<Unit[]> {
    const currentUnits = this.unitsSubject.getValue()[courseId];
    if (!currentUnits) {
      // Load and initialize if not already loaded
      this.initializeUnitsForCourse(courseId);
    }
    return this.unitsSubject.pipe(
      map(units => units[courseId] || [])
    );
  }

  getUnitById(courseId: string, unitId: string): Observable<Unit | undefined> {
    return this.getUnitsByCourseId(courseId).pipe(
      map(units => units.find(u => u.id === unitId))
    );
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