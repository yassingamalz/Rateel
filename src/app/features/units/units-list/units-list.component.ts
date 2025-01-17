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
  Router
} from '@angular/router';
import {
  Observable,
  Subject
} from 'rxjs';
import {
  takeUntil,
  shareReplay,
  distinctUntilChanged,
  catchError
} from 'rxjs/operators';

import { UnitsService } from '../units.service';
import { Unit } from '../../../shared/interfaces/unit';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { StorageService } from '../../../core/services/storage.service';

@Component({
  selector: 'app-units-list',
  standalone: false,
  templateUrl: './units-list.component.html',
  styleUrls: ['./units-list.component.scss'],
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
    ])
  ],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UnitsListComponent implements OnInit, OnDestroy {
  @ViewChild('unitsContainer') unitsContainer!: ElementRef<HTMLElement>;
  animationState: string = '*';

  units$!: Observable<Unit[]>;
  courseId!: string;
  activeUnitId: string | null = null;
  completedUnitId: string | null = null;
  isDragging = false;

  private dragStarted = false;
  private startX = 0;
  private scrollLeft = 0;
  private readonly dragThreshold = 5;
  private dragStartTime = 0;
  private mouseInitialX = 0;
  private readonly dragSpeedMultiplier = 2.5;
  private readonly inertiaMultiplier = 150;
  private animationFrame: number | null = null;
  private readonly destroy$ = new Subject<void>();
  private lastDragEvent: MouseEvent | Touch | null = null;
  private velocity = 0;
  private lastTimestamp = 0;

  constructor(
    private unitsService: UnitsService,
    private route: ActivatedRoute,
    private router: Router,
    private ngZone: NgZone,
    private cdr: ChangeDetectorRef,
    private storageService: StorageService
  ) { }

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitsService.setCurrentCourse(this.courseId);
  
    this.units$ = this.unitsService.getUnitsByCourseId(this.courseId).pipe(
      distinctUntilChanged(),
      shareReplay(1),
      takeUntil(this.destroy$),
      catchError(error => {
        console.error('Error fetching units:', error);
        return [];
      })
    );
  
    const unitId = this.route.snapshot.paramMap.get('unitId');
    if (unitId) {
      this.activeUnitId = unitId;
      this.scrollToActiveUnit();
    }
  
    // Handle query params for unit completion
    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      const completedUnitId = params['completedUnitId'];
      if (completedUnitId) {
        const progressData = this.storageService.getProgress('unit', `${this.courseId}_${completedUnitId}`);
        const currentTime = Date.now();
        
        // Check if this completion is recent (within last 2 seconds) or hasn't been shown yet
        if (!progressData?.lastUpdated || (currentTime - progressData.lastUpdated) > 2000) {
          this.handleUnitCompletion(completedUnitId);
          
          // Update storage with completion data
          this.storageService.saveProgress('unit', `${this.courseId}_${completedUnitId}`, {
            isCompleted: true,
            progress: 100,
            lastUpdated: currentTime,
          });
        }
      }
  
      if (params['returnTo'] === 'units') {
        this.animationState = '*';
      }
    });
  
    // Subscribe to storage changes to update UI
    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (change?.type === 'unit' && change.data.isCompleted) {
          const unitId = change.id.split('_')[1]; // Extract unit ID from storage key
          if (unitId !== this.completedUnitId) {
            this.cdr.detectChanges();
          }
        }
      });
  }
  
  private handleUnitCompletion(unitId: string): void {
    this.ngZone.run(() => {
      this.completedUnitId = unitId;
      this.cdr.detectChanges();
  
      const completedUnit = document.querySelector(`[data-unit-id="${unitId}"]`);
      if (completedUnit) {
        completedUnit.classList.add('unit-completed');
  
        // Schedule animation cleanup
        setTimeout(() => {
          this.ngZone.run(() => {
            this.completedUnitId = null;
            this.cdr.detectChanges();
  
            // Update scroll position after animations
            requestAnimationFrame(() => {
              completedUnit.scrollIntoView({
                behavior: 'smooth',
                block: 'nearest',
                inline: 'center'
              });
            });
          });
        }, 1500); // Match border fill animation duration
  
        // Update storage with completion timestamp
        this.storageService.saveProgress('unit', `${this.courseId}_${unitId}`, {
          isCompleted: true,
          progress: 100,
          lastUpdated: Date.now(),
          timestamp: Date.now(),
          expiresAt: Date.now() + (2 * 365 * 24 * 60 * 60 * 1000) // 2 years expiration
        });
      }
    });
  }

  ngOnDestroy(): void {
    this.cleanupDrag();
    this.destroy$.next();
    this.destroy$.complete();
  }

  trackByUnitId(_: number, unit: Unit): string {
    return unit.id;
  }

  onMouseDown(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest('.unit-item')) {
      event.preventDefault();
      this.startDrag(event.pageX);
      this.lastDragEvent = event;
      this.lastTimestamp = Date.now();
    }
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.dragStarted) return;

    event.preventDefault();
    this.handleDragMove(event.pageX);
    this.lastDragEvent = event;
  }

  onMouseUp(event: MouseEvent): void {
    if (!this.dragStarted) return;

    this.handleDragEnd(event.pageX);
  }

  onMouseLeave(): void {
    if (this.dragStarted) {
      this.cleanupDrag();
    }
  }

  onTouchEnd(event: TouchEvent): void {
    if (!this.dragStarted) return;

    this.handleDragEnd(event.changedTouches[0].pageX);
  }

  private startDrag(pageX: number): void {
    this.dragStarted = true;
    this.mouseInitialX = pageX;
    this.startX = pageX;
    this.scrollLeft = this.unitsContainer.nativeElement.scrollLeft;
    this.dragStartTime = Date.now();
    this.velocity = 0;
  }


  onTouchStart(event: TouchEvent): void {
    if ((event.target as HTMLElement).closest('.unit-item')) {
      // Don't prevent default here to allow click events
      this.startDrag(event.touches[0].pageX);
      this.lastDragEvent = event.touches[0];
      this.lastTimestamp = Date.now();
    }
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.touches[0].pageX - this.mouseInitialX);

    // Only prevent default if we're actually dragging
    if (dragDistance > this.dragThreshold) {
      event.preventDefault();
      this.handleDragMove(event.touches[0].pageX);
      this.lastDragEvent = event.touches[0];
    }
  }

  private handleDragEnd(pageX: number): void {
    const dragDistance = Math.abs(pageX - this.mouseInitialX);
    const dragDuration = Date.now() - this.dragStartTime;

    // Check for tap/click (short duration and minimal movement)
    if (dragDistance < this.dragThreshold && dragDuration < 200) {
      const unitElement = (this.lastDragEvent?.target as HTMLElement)?.closest('[data-unit-id]');
      if (unitElement) {
        const unitId = unitElement.getAttribute('data-unit-id');
        if (unitId) {
          this.handleUnitClick(unitId);
        }
      }
    } else if (dragDistance > this.dragThreshold) {
      this.applyInertia();
    }

    this.cleanupDrag();
  }

  private cleanupDrag(): void {
    // Add a small delay before removing the dragging class
    setTimeout(() => {
      this.isDragging = false;
      this.dragStarted = false;
      this.lastDragEvent = null;
      if (this.animationFrame) {
        cancelAnimationFrame(this.animationFrame);
        this.animationFrame = null;
      }
      this.cdr.detectChanges();
    }, 50); // Small delay to ensure click events can fire
  }

  private handleDragMove(pageX: number): void {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }

    this.ngZone.runOutsideAngular(() => {
      this.animationFrame = requestAnimationFrame(() => {
        const currentTime = Date.now();
        const deltaTime = currentTime - this.lastTimestamp;
        const dragDistance = Math.abs(pageX - this.mouseInitialX);

        if (dragDistance > this.dragThreshold) {
          this.isDragging = true;
          this.cdr.detectChanges();
        }

        const walk = (pageX - this.startX) * this.dragSpeedMultiplier;
        const newScrollLeft = this.scrollLeft - walk;

        if (deltaTime > 0) {
          const oldScroll = this.unitsContainer.nativeElement.scrollLeft;
          this.velocity = (oldScroll - newScrollLeft) / deltaTime;
        }

        this.unitsContainer.nativeElement.scrollLeft = newScrollLeft;
        this.lastTimestamp = currentTime;
      });
    });
  }

  private applyInertia(): void {
    const speed = Math.abs(this.velocity) * this.inertiaMultiplier;
    const direction = this.velocity > 0 ? -1 : 1;
    let startTimestamp: number;

    const animateInertia = (timestamp: number) => {
      if (!startTimestamp) startTimestamp = timestamp;
      const progress = (timestamp - startTimestamp) / 1000;
      const easing = Math.exp(-4 * progress);
      const distance = speed * easing * direction;

      if (easing > 0.01) {
        this.unitsContainer.nativeElement.scrollBy(distance, 0);
        requestAnimationFrame(animateInertia);
      }
    };

    requestAnimationFrame(animateInertia);
  }


  private handleUnitClick(unitId: string): void {
    const units = (this.units$ as any).value;
    const unit = units?.find((u: Unit) => u.id === unitId);
    if (unit && !unit.isLocked) {
      this.onUnitSelected(unit);
    }
  }


  onUnitSelected(unit: Unit): void {
    if (!unit.isLocked) {
      this.animationState = 'exit';
      setTimeout(() => {
        this.router.navigate(['/courses', this.courseId, 'units', unit.id, 'lessons']);
      }, 500); // Match animation duration
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
}