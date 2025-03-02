import { Injectable, OnDestroy } from "@angular/core";
import { BehaviorSubject, catchError, map, Observable, of, takeUntil } from "rxjs";
import { StorageService } from "../../core/services/storage.service";
import { Unit } from "../../shared/interfaces/unit";
import { CoursesService } from "../courses/courses.service";
import { HttpClient } from "@angular/common/http";

interface UnitsResponse {
  version: string;
  courseId: string;
  units: Unit[];
}

@Injectable({
  providedIn: 'root'
})
export class UnitsService implements OnDestroy {
  private currentCourseIdSubject = new BehaviorSubject<string | null>(null);
  currentCourseId$ = this.currentCourseIdSubject.asObservable();
  private unitsSubject = new BehaviorSubject<{ [key: string]: Unit[] }>({});
  private destroy$ = new BehaviorSubject<boolean>(false);

  constructor(
    private http: HttpClient,
    private storageService: StorageService,
    private coursesService: CoursesService
  ) {
    // Subscribe to storage changes for real-time progress updates
    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (!change) return;

        if (change.type === 'unit') {
          // Extract courseId and unitId from the composite key
          const [courseId, unitId] = change.id.split('_');
          if (courseId && unitId) {
            // Get current units state
            const currentUnits = this.unitsSubject.getValue();
            const courseUnits = currentUnits[courseId];

            if (courseUnits) {
              // Create new array with updated unit objects to trigger change detection
              const updatedUnits = courseUnits.map(unit => {
                if (unit.id === unitId) {
                  // Create a new object to ensure reference change
                  return {
                    ...unit,
                    progress: change.data.progress,
                    isCompleted: change.data.isCompleted,
                    isLocked: change.data.isLocked ?? unit.isLocked
                  };
                }
                return unit;
              });

              // Update subject with new references
              this.unitsSubject.next({
                ...currentUnits,
                [courseId]: updatedUnits
              });
              
              console.debug(`[UnitsService] Updated unit ${unitId} progress to ${change.data.progress}%`);
            }
          }
        }
      });
  }

  public refreshUnitProgress(courseId: string, unitId: string): void {
    // Force-refresh a specific unit's progress
    const currentUnits = this.unitsSubject.getValue();
    const units = currentUnits[courseId] || [];

    if (units.length > 0) {
      const progressData = this.storageService.getProgress('unit', `${courseId}_${unitId}`);

      if (progressData) {
        // Create a new array with updated unit objects
        const updatedUnits = units.map(unit => {
          if (unit.id === unitId) {
            return {
              ...unit,
              progress: progressData.progress,
              isCompleted: progressData.isCompleted
            };
          }
          return unit;
        });

        // Update the subject with new references
        this.unitsSubject.next({
          ...currentUnits,
          [courseId]: updatedUnits
        });
        
        console.debug(`[UnitsService] Force-refreshed unit ${unitId} progress to ${progressData.progress}%`);
      }
    }
  }

  private loadUnitsData(courseId: string): Observable<Unit[]> {
    return this.http.get<UnitsResponse>(`assets/data/units/${courseId}.json`).pipe(
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

    // Find completed unit first to avoid type errors
    const completedUnit = units.find(u => u.id === unitId);
    const nextUnitOrder = completedUnit?.order ? completedUnit.order + 1 : -1;

    // Create new array with new unit objects to trigger change detection
    const updatedUnits = units.map(unit => {
      if (unit.id === unitId) {
        // Create a new object instead of modifying in place
        return {
          ...unit,
          isCompleted: true,
          progress: 100
        };
      } else if (completedUnit && unit.order === nextUnitOrder) {
        // Create a new object for the next unit to unlock it
        return {
          ...unit,
          isLocked: false
        };
      }
      return unit;
    });

    // Save unit progress
    this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
      progress: 100,
      isCompleted: true,
      lastUpdated: Date.now()
    });

    // Update next unit's unlocked state if it exists
    if (completedUnit) {
      const nextUnit = units.find(u => u.order === completedUnit.order + 1);
      if (nextUnit) {
        this.storageService.saveProgress('unit', `${courseId}_${nextUnit.id}`, {
          isLocked: false,
          lastUpdated: Date.now()
        });
      }
    }

    // Update subject with new array reference to trigger change detection
    this.unitsSubject.next({
      ...currentUnits,
      [courseId]: updatedUnits
    });

    return of(void 0);
  }

  updateUnitProgress(courseId: string, unitId: string, progress: number): Observable<void> {
    const currentUnits = this.unitsSubject.getValue();
    const units = currentUnits[courseId] || [];

    // Create a new array with updated units to ensure change detection
    const updatedUnits = units.map(unit => {
      if (unit.id === unitId) {
        const normalizedProgress = Math.round(Math.min(100, Math.max(0, progress)));
        const isCompleted = normalizedProgress === 100;

        // Create a new unit object reference
        return {
          ...unit,
          progress: normalizedProgress,
          isCompleted: isCompleted || unit.isCompleted
        };
      }
      return unit;
    });

    // Save progress to storage
    this.storageService.saveProgress('unit', `${courseId}_${unitId}`, {
      progress: Math.round(Math.min(100, Math.max(0, progress))),
      isCompleted: progress === 100
    });

    // Update subject with new object references
    this.unitsSubject.next({
      ...currentUnits,
      [courseId]: updatedUnits
    });

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

  // Cleanup on service destruction
  ngOnDestroy(): void {
    this.destroy$.next(true);
    this.destroy$.complete();
  }
}