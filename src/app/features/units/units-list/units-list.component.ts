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
  finalize
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

    // Handle unit completion
    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      if (params['completedUnitId']) {
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

  private handleUnitCompletion(unitId: string): void {
    const progress = this.storageService.getProgress('unit', `${this.courseId}_${unitId}`);
    const currentTime = Date.now();

    if (!progress?.lastUpdated || (currentTime - progress.lastUpdated) > 2000) {
      this.ngZone.run(() => {
        this.completedUnitId = unitId;
        this.cdr.detectChanges();

        const completedUnit = document.querySelector(`[data-unit-id="${unitId}"]`);
        if (completedUnit) {
          completedUnit.classList.add('unit-completed');

          setTimeout(() => {
            this.ngZone.run(() => {
              this.completedUnitId = null;
              this.cdr.detectChanges();

              requestAnimationFrame(() => {
                completedUnit.scrollIntoView({
                  behavior: 'smooth',
                  block: 'nearest',
                  inline: 'center'
                });
              });
            });
          }, 1500);

          // Update storage
          this.storageService.saveProgress('unit', `${this.courseId}_${unitId}`, {
            isCompleted: true,
            progress: 100,
            lastUpdated: currentTime,
            timestamp: currentTime
          });
        }
      });
    }
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
    super.ngOnDestroy();
  }
}