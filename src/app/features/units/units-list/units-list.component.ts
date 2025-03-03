// Updated UnitsListComponent
import {
  Component,
  OnInit,
  OnDestroy,
  ViewChild,
  ElementRef,
  NgZone,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ApplicationRef
} from '@angular/core';
import {
  ActivatedRoute,
  NavigationEnd,
  Router
} from '@angular/router';
import {
  Observable,
  BehaviorSubject,
  filter,
  takeUntil,
  tap,
  finalize,
  take,
  distinctUntilChanged,
  fromEvent,
  timer
} from 'rxjs';
import { UnitsService } from '../units.service';
import { Unit } from '../../../shared/interfaces/unit';
import { StorageService } from '../../../core/services/storage.service';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { DragScrollBase } from '../../../shared/components/drag-scroll/drag-scroll.base';

@Component({
  selector: 'app-units-list',
  standalone: false,
  templateUrl: './units-list.component.html',
  styleUrls: ['./units-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('pageTransition', [
      state('void', style({
        transform: 'translateX(-100%)'
      })),
      state('*', style({
        transform: 'translateX(0)'
      })),
      state('exit', style({
        transform: 'translateX(100%)'
      })),
      transition('void => *', animate('500ms ease-out')),
      transition('* => exit', animate('500ms ease-in'))
    ]),
    trigger('fadeInOut', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('200ms ease-in', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('200ms ease-out', style({ opacity: 0 }))
      ])
    ])
  ]
})
export class UnitsListComponent extends DragScrollBase implements OnInit, OnDestroy {
  @ViewChild('unitsContainer') unitsContainer!: ElementRef<HTMLElement>;

  initialLoad = true;
  animationState: string = '*';
  loading$ = new BehaviorSubject<boolean>(true);
  transitionComplete = false;
  contentReady = false;
  private navigationInProgress = false;
  private completionHandled = new Set<string>();
  private progressUpdateCount = 0;

  units$!: Observable<Unit[]>;
  courseId!: string;
  activeUnitId: string | null = null;
  completedUnitId: string | null = null;

  constructor(
    elementRef: ElementRef,
    ngZone: NgZone,
    storageService: StorageService,
    private unitsService: UnitsService,
    private route: ActivatedRoute,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private appRef: ApplicationRef
  ) {
    super(elementRef, ngZone, storageService);

    // Clear any stale completion states on navigation
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd),
      takeUntil(this.destroy$)
    ).subscribe(() => {
      this.completedUnitId = null;
      this.animationState = '*';
      this.navigationInProgress = false;
    });

    // Configure drag behavior for units
    this.dragThreshold = 5;
    this.inertiaMultiplier = 150;

    // Handle initial load state
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe(() => {
      this.initialLoad = false;
    });
  }

  ngOnInit(): void {
    console.log('[UnitsList] Component initializing');

    this.loading$.next(true);
    this.contentReady = false;

    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitsService.setCurrentCourse(this.courseId);

    // Initialize units with progress tracking and better change detection
    this.units$ = this.unitsService.getUnitsByCourseId(this.courseId).pipe(
      tap(units => {
        console.log(`[UnitsList] Received ${units.length} units with data:`, 
          units.map(u => ({ id: u.id, progress: u.progress, completed: u.isCompleted })));
          
        this.ngZone.run(() => {
          this.contentReady = true;
          this.loading$.next(false);
          // Force immediate change detection
          this.cdr.detectChanges();
          
          // Schedule another change detection after a short delay to ensure UI is updated
          // This helps with timing issues in complex component trees
          setTimeout(() => this.cdr.detectChanges(), 100);
        });
      }),
      finalize(() => this.loading$.next(false))
    );

    // Set up enhanced progress tracking
    this.setupProgressTracking();

    // Handle unit ID from route
    const unitId = this.route.snapshot.paramMap.get('unitId');
    if (unitId) {
      this.activeUnitId = unitId;
      this.scrollToActiveUnit();
    }

    // Handle unit completion
    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      if (params['completedUnitId'] && !this.navigationInProgress) {
        this.handleUnitCompletion(params['completedUnitId']);
      }

      if (params['returnTo'] === 'units') {
        this.animationState = '*';
      }
    });

    // Setup visibility change listener to refresh data when tab becomes visible
    fromEvent(document, 'visibilitychange')
      .pipe(takeUntil(this.destroy$))
      .subscribe(() => {
        if (document.visibilityState === 'visible' && this.courseId) {
          console.log('[UnitsList] Tab became visible, refreshing units data');
          this.unitsService.refreshUnitsByCourse(this.courseId);
          this.cdr.detectChanges();
        }
      });
  }

  private setupProgressTracking(): void {
    // Enhanced direct storage change tracking with immediate UI updates
    this.storageService.getProgressChanges()
      .pipe(
        takeUntil(this.destroy$),
        filter(change => !!change && change.type === 'unit' && change.id.startsWith(`${this.courseId}_`))
      )
      .subscribe(change => {
        if (!change) return;
        
        const unitId = change.id.split('_')[1];
        console.log(`[UnitsList] Storage change detected for unit ${unitId}, progress: ${change.data.progress}%`);
        
        // Track update count for debugging
        this.progressUpdateCount++;
        
        // Force immediate change detection to update the UI
        this.cdr.detectChanges();
        
        // Schedule another update after a short delay to ensure UI is updated
        timer(50).subscribe(() => {
          this.cdr.detectChanges();
          console.log(`[UnitsList] Forced change detection after update #${this.progressUpdateCount}`);
        });
      });

    // Also track the units observable for structural changes
    this.units$.pipe(
      takeUntil(this.destroy$),
      distinctUntilChanged((prev, curr) => {
        // Only skip update if arrays are identical by value
        if (prev.length !== curr.length) return false;
        
        for (let i = 0; i < prev.length; i++) {
          const prevUnit = prev[i];
          const currUnit = curr[i];
          
          if (
            prevUnit.id !== currUnit.id ||
            prevUnit.progress !== currUnit.progress ||
            prevUnit.isCompleted !== currUnit.isCompleted ||
            prevUnit.isLocked !== currUnit.isLocked
          ) {
            console.log(`[UnitsList] Detected change in unit ${currUnit.id}:`, 
              { 
                prevProgress: prevUnit.progress, 
                newProgress: currUnit.progress,
                prevCompleted: prevUnit.isCompleted,
                newCompleted: currUnit.isCompleted
              }
            );
            return false;
          }
        }
        return true;
      })
    ).subscribe(units => {
      console.log(`[UnitsList] Units updated (${units.length}), forcing re-render`);
      // Force immediate change detection
      this.cdr.detectChanges();
    });
  }

  private handleUnitCompletion(unitId: string): void {
    console.log('[UnitsList] Starting unit completion handler for:', unitId);

    if (this.navigationInProgress || this.completionHandled.has(unitId)) {
      console.log('[UnitsList] Skipping - navigation in progress or already handled');
      return;
    }

    this.navigationInProgress = true;
    this.completionHandled.add(unitId);

    // Use a specific key for the unit's animation flag
    const storageKey = `${this.courseId}_${unitId}`;
    const unitAnimationKey = `unit_animation_${storageKey}`;

    // Check if this unit has had its animation shown before
    const animationShown = localStorage.getItem(unitAnimationKey) === 'true';

    console.log('[UnitsList] First completion:', !animationShown);

    // Immediately mark the animation as shown for future reference
    localStorage.setItem(unitAnimationKey, 'true');

    // Force refresh the unit data from localStorage
    this.unitsService.refreshUnitProgress(this.courseId, unitId);
    
    // Force immediate change detection
    this.cdr.detectChanges();

    if (!animationShown) {
      // First time showing this animation
      console.log('[UnitsList] Starting first completion animation');
      this.completedUnitId = unitId;
      this.cdr.detectChanges();

      // Wait for animation
      setTimeout(() => {
        console.log('[UnitsList] Completion animation finished');
        this.completedUnitId = null;
        this.cdr.detectChanges();
        this.navigateAfterCompletion(unitId);
      }, 1500); // Match animation duration
    } else {
      // Already shown before, use shorter delay
      console.log('[UnitsList] Skipping animation for subsequent completion');
      setTimeout(() => {
        this.navigateAfterCompletion(unitId);
      }, 1000); // Shorter delay
    }
  }

  private navigateAfterCompletion(unitId: string): void {
    this.units$.pipe(take(1)).subscribe(units => {
      const currentIndex = units.findIndex(u => u.id === unitId);
      const nextUnit = units[currentIndex + 1];

      console.log('[UnitsList] Current unit index:', currentIndex);
      console.log('[UnitsList] Next unit:', nextUnit);
      console.log('[UnitsList] Is last unit:', !nextUnit);

      if (nextUnit && !nextUnit.isLocked) {
        // Save next unit's unlocked state
        this.storageService.saveProgress('unit', `${this.courseId}_${nextUnit.id}`, {
          isLocked: false,
          progress: 0,
          isCompleted: false,
          lastUpdated: Date.now(),
          timestamp: Date.now()
        });

        // Navigate to next unit's lessons
        console.log('[UnitsList] Navigating to next unit lessons');
        this.router.navigate(['/courses', this.courseId, 'units', nextUnit.id, 'lessons'], {
          replaceUrl: true
        }).then(() => {
          console.log('[UnitsList] Navigation to next unit lessons complete');
          setTimeout(() => {
            this.navigationInProgress = false;
            console.log('[UnitsList] Navigation lock released');
          }, 500);
        });
      } else {
        console.log('[UnitsList] No next unit, navigating to courses');
        // No next unit, navigate back to courses
        this.router.navigate(['/courses'], {
          queryParams: { completedCourseId: this.courseId },
          replaceUrl: true
        }).then(() => {
          console.log('[UnitsList] Navigation to courses complete');
          setTimeout(() => {
            this.navigationInProgress = false;
            console.log('[UnitsList] Navigation lock released');
          }, 500);
        });
      }
    });
  }

  // Check progress in console for debugging
  logCurrentProgress(): void {
    this.units$.pipe(take(1)).subscribe(units => {
      console.table(units.map(u => ({ 
        id: u.id, 
        title: u.title,
        progress: u.progress || 0,
        completed: u.isCompleted || false,
        locked: u.isLocked || false
      })));
    });
  }

  // Force manual refresh of unit data (can be triggered from UI if needed)
  forceRefreshUnits(): void {
    console.log('[UnitsList] Manually forcing refresh of all units');
    this.unitsService.refreshUnitsByCourse(this.courseId);
    this.cdr.detectChanges();
  }

  // Event handlers
  onMouseDown(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest('.unit-item')) {
      super.startDrag(event.pageX, 'course', this.courseId);
    }
  }

  onMouseMove(event: MouseEvent): void {
    super.handleDragMove(event.pageX);
  }

  onMouseUp(event: MouseEvent): void {
    const dragDistance = Math.abs(event.pageX - this.mouseInitialX);

    if (!this.isDragging && dragDistance < this.dragThreshold) {
      const unitElement = (event.target as HTMLElement).closest('[data-unit-id]');
      if (unitElement) {
        const unitId = unitElement.getAttribute('data-unit-id');
        if (unitId) {
          this.handleUnitClick(unitId);
        }
      }
    }

    super.handleDragEnd(event.pageX, 'course', this.courseId);
  }

  // Touch event handlers
  onTouchStart(event: TouchEvent): void {
    if ((event.target as HTMLElement).closest('.unit-item')) {
      super.startDrag(event.touches[0].pageX, 'course', this.courseId);
    }
  }

  onTouchMove(event: TouchEvent): void {
    super.handleDragMove(event.touches[0].pageX);
  }

  onTouchEnd(event: TouchEvent): void {
    super.handleDragEnd(event.changedTouches[0].pageX, 'course', this.courseId);
  }

  private handleUnitClick(unitId: string): void {
    this.units$.pipe(
      take(1),
      tap(units => {
        const unit = units.find(u => u.id === unitId);
        if (unit && !unit.isLocked) {
          this.onUnitSelected(unit);
        }
      })
    ).subscribe();
  }

  onUnitSelected(unit: Unit): void {
    if (!unit.isLocked) {
      this.animationState = 'exit';
      setTimeout(() => {
        this.router.navigate(['/courses', this.courseId, 'units', unit.id, 'lessons']);
      }, 500);
    }
  }

  getConnectorProgress(currentUnit: Unit, nextUnit: Unit): number {
    if (currentUnit.isCompleted) return 100;
    if (nextUnit.isLocked) return 0;
    return (currentUnit.progress || 0) / 2;
  }

  private scrollToActiveUnit(): void {
    setTimeout(() => {
      const activeElement = document.querySelector('.unit-item--active');
      if (activeElement) {
        activeElement.scrollIntoView({
          behavior: 'smooth',
          block: 'nearest',
          inline: 'center'
        });
      }
    }, 100);
  }

  trackByUnitId(_: number, unit: Unit): string {
    return unit.id;
  }

  onAnimationComplete(): void {
    this.transitionComplete = true;
  }

  // Cleanup
  override ngOnDestroy(): void {
    console.log('[UnitsList] Component destroying');
    this.navigationInProgress = false;
    this.completionHandled.clear();
    super.ngOnDestroy();
  }
}