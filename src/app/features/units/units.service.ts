// src/app/features/units/units.service.ts
import { Injectable, OnDestroy } from "@angular/core";
import { BehaviorSubject, catchError, map, Observable, of, takeUntil, tap, distinctUntilChanged, filter } from "rxjs";
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
  private refreshTrigger = new BehaviorSubject<string | null>(null);

  constructor(
    private http: HttpClient,
    private storageService: StorageService,
    private coursesService: CoursesService
  ) {
    // Enhanced storage change subscription with immediate refresh
    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (!change) return;

        if (change.type === 'unit') {
          // Extract courseId and unitId from the composite key
          const [courseId, unitId] = change.id.split('_');
          if (courseId && unitId) {
            console.log(`[UnitsService] Storage change detected for unit ${unitId} in course ${courseId}, progress: ${change.data.progress}%`);
            
            // Immediately reload all units for this course to ensure freshness
            this.refreshUnitsByCourse(courseId);
            
            // Also trigger a refresh on the specific unit (belt and suspenders approach)
            this.refreshTrigger.next(`${courseId}_${unitId}`);
          }
        }
      });

    // Subscribe to refresh trigger to update specific units
    this.refreshTrigger
      .pipe(
        takeUntil(this.destroy$),
        distinctUntilChanged(),
        filter(key => !!key)
      )
      .subscribe(key => {
        if (!key) return;
        
        const [courseId, unitId] = key.split('_');
        if (courseId && unitId) {
          this.refreshUnitProgress(courseId, unitId);
        }
      });
  }

  /**
   * New method to force refresh all units for a course
   */
  public refreshUnitsByCourse(courseId: string): void {
    console.log(`[UnitsService] Refreshing all units for course ${courseId}`);
    
    // Get current units
    const currentUnits = this.unitsSubject.getValue();
    const units = currentUnits[courseId] || [];
    
    if (units.length === 0) {
      // If no units loaded yet, load them from scratch
      this.initializeUnitsForCourse(courseId);
      return;
    }
    
    // Otherwise, refresh each unit's progress from storage
    const updatedUnits = units.map(unit => {
      const storageKey = `${courseId}_${unit.id}`;
      const progressData = this.storageService.getProgress('unit', storageKey);
      
      if (progressData) {
        // Create a new object to ensure reference changes for change detection
        return {
          ...unit,
          progress: progressData.progress || 0,
          isCompleted: progressData.isCompleted || false,
          isLocked: progressData.isLocked ?? unit.isLocked
        };
      }
      return unit;
    });
    
    // Update the subject with new reference to trigger change detection
    this.unitsSubject.next({
      ...currentUnits,
      [courseId]: updatedUnits
    });
    
    console.log(`[UnitsService] Refreshed ${updatedUnits.length} units for course ${courseId}`);
  }

  public refreshUnitProgress(courseId: string, unitId: string): void {
    // Force-refresh a specific unit's progress
    const currentUnits = this.unitsSubject.getValue();
    const units = currentUnits[courseId] || [];

    if (units.length > 0) {
      const progressData = this.storageService.getProgress('unit', `${courseId}_${unitId}`);

      if (progressData) {
        // Create a new array with updated unit objects to ensure reference changes
        const updatedUnits = units.map(unit => {
          if (unit.id === unitId) {
            return {
              ...unit,
              progress: progressData.progress || 0,
              isCompleted: progressData.isCompleted || false,
              isLocked: progressData.isLocked ?? unit.isLocked
            };
          }
          return unit;
        });

        // Update the subject with new references to trigger change detection
        this.unitsSubject.next({
          ...currentUnits,
          [courseId]: updatedUnits
        });
        
        console.log(`[UnitsService] Force-refreshed unit ${unitId} progress to ${progressData.progress}%`);
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
      
      console.log(`[UnitsService] Initialized ${units.length} units for course ${courseId}`);
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
    } else {
      // If already loaded, refresh to ensure latest data
      this.refreshUnitsByCourse(courseId);
    }
  }

  getUnitsByCourseId(courseId: string): Observable<Unit[]> {
    const currentUnits = this.unitsSubject.getValue()[courseId];
    if (!currentUnits) {
      // Load and initialize if not already loaded
      this.initializeUnitsForCourse(courseId);
    } else {
      // If already loaded, silently refresh to ensure latest data
      setTimeout(() => this.refreshUnitsByCourse(courseId), 0);
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