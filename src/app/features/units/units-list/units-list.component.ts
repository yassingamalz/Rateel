// src/app/features/units/units-list/units-list.component.ts
import {
  Component,
  OnInit,
  OnDestroy,
  ViewChild,
  ElementRef,
  NgZone,
  ChangeDetectionStrategy,
  ChangeDetectorRef
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
  take
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
  private completionInProgress = false;
  private completionHandled = new Set<string>();

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
    private cdr: ChangeDetectorRef
  ) {
    super(elementRef, ngZone, storageService);

    // Clear any stale completion states on navigation
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd),
      takeUntil(this.destroy$)
    ).subscribe(() => {
      this.completedUnitId = null;
      this.animationState = '*';
      this.completionInProgress = false; // Reset completion state on navigation
      this.completionHandled.clear();
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

  private handleUnitCompletion(unitId: string): void {
    console.log('[UnitsList] Starting unit completion handler for:', unitId);
    
    // Prevent multiple simultaneous completion handling
    if (this.completionInProgress) {
      console.log('[UnitsList] Completion already in progress, skipping');
      return;
    }
    
    // Prevent handling the same completion multiple times
    if (this.completionHandled.has(unitId)) {
      console.log('[UnitsList] Already handled this completion, skipping');
      return;
    }
    
    this.completionInProgress = true;
    this.completionHandled.add(unitId);
    
    const storageKey = `${this.courseId}_${unitId}`;
    // Use a more specific key that's unique for units vs lessons
    const completionShownKey = `unit_completion_shown_${unitId}`;
    const progressData = this.storageService.getProgress('unit', storageKey);
    const isFirstCompletion = !progressData?.answers?.[completionShownKey];

    console.log('[UnitsList] First completion:', isFirstCompletion);

    // Save progress and mark unit as completed
    this.storageService.saveProgress('unit', storageKey, {
      isCompleted: true,
      progress: 100,
      lastUpdated: Date.now(),
      timestamp: Date.now(),
      isLocked: false
    });

    const navigateToNextUnit = () => {
      this.units$.pipe(take(1)).subscribe(units => {
        const currentIndex = units.findIndex(u => u.id === unitId);
        const nextUnit = units[currentIndex + 1];
        const isLastUnit = currentIndex === units.length - 1;
        
        console.log('[UnitsList] Current unit index:', currentIndex);
        console.log('[UnitsList] Next unit:', nextUnit);
        console.log('[UnitsList] Is last unit:', isLastUnit);
  
        if (isLastUnit || !nextUnit || nextUnit.isLocked) {
          console.log('[UnitsList] Last unit or next unit locked, navigating to courses page');
          // Last unit or next unit is locked, navigate to courses
          this.router.navigate(['/courses'], {
            queryParams: { completedCourseId: this.courseId },
            replaceUrl: true
          }).then(() => {
            this.resetCompletionState();
          });
        } else {
          console.log('[UnitsList] Navigating to next unit lessons');
          
          // Navigate to the first lesson of the next unit
          this.router.navigate(['/courses', this.courseId, 'units', nextUnit.id, 'lessons']).then(() => {
            console.log('[UnitsList] Navigation to next unit lessons complete');
            this.resetCompletionState();
          });
        }
      });
    };

    // Show animation only for first completion
    if (isFirstCompletion) {
      console.log('[UnitsList] Starting first completion animation');
      
      // Mark that we've shown the completion animation with the more specific key
      this.storageService.saveAnswer(storageKey, completionShownKey, true, true);
      
      // Set the completedUnitId to trigger animation
      this.completedUnitId = unitId;
      this.cdr.detectChanges();

      // Wait for animation then navigate
      setTimeout(() => {
        console.log('[UnitsList] Completion animation finished');
        this.completedUnitId = null;
        this.cdr.detectChanges();
        
        navigateToNextUnit();
      }, 1500); // Animation duration
    } else {
      // Skip animation for subsequent completions
      console.log('[UnitsList] Subsequent completion, skipping animation');
      setTimeout(navigateToNextUnit, 500); // Shorter delay without animation
    }
  }

  private resetCompletionState(): void {
    console.log('[UnitsList] Resetting completion state');
    setTimeout(() => {
      this.completionInProgress = false;
    }, 500); // Small buffer before allowing new completions
  }

  ngOnInit(): void {
    console.log('[UnitsList] Component initializing');
    
    this.loading$.next(true);
    this.contentReady = false;

    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitsService.setCurrentCourse(this.courseId);

    // Initialize units with progress tracking
    this.units$ = this.unitsService.getUnitsByCourseId(this.courseId).pipe(
      tap(() => {
        this.ngZone.run(() => {
          this.contentReady = true;
          this.loading$.next(false);
          this.cdr.detectChanges();
        });
      }),
      finalize(() => this.loading$.next(false))
    );

    // Handle unit ID from route
    const unitId = this.route.snapshot.paramMap.get('unitId');
    if (unitId) {
      this.activeUnitId = unitId;
      this.scrollToActiveUnit();
    }

    // Handle unit completion (from query params)
    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      if (params['completedUnitId'] && !this.completionInProgress) {
        this.handleUnitCompletion(params['completedUnitId']);
      }

      if (params['returnTo'] === 'units') {
        this.animationState = '*';
      }
    });

    // Handle storage changes
    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (change?.type === 'unit' && change.data.isCompleted) {
          const unitId = change.id.split('_')[1];
          if (unitId !== this.completedUnitId) {
            this.cdr.detectChanges();
          }
        }
      });
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

  override ngOnDestroy(): void {
    console.log('[UnitsList] Component destroying');
    this.completionInProgress = false;
    this.completionHandled.clear();
    super.ngOnDestroy();
  }
}