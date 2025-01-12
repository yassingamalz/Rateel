import {
  Component,
  OnInit,
  OnDestroy,
  ViewChild,
  ElementRef,
  NgZone,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  AfterViewInit,
  Renderer2
} from '@angular/core';
import {
  ActivatedRoute,
  Router
} from '@angular/router';
import {
  Observable,
  Subject,
  fromEvent,
  merge,
  animationFrameScheduler,
  timer
} from 'rxjs';
import {
  takeUntil,
  shareReplay,
  distinctUntilChanged,
  catchError,
  tap,
  debounceTime,
  observeOn,
  filter
} from 'rxjs/operators';

import { UnitsService } from '../units.service';
import { Unit } from '../../../shared/interfaces/unit';

interface ScrollState {
  isDragging: boolean;
  startX: number;
  scrollLeft: number;
  momentumVelocity: number;
}

@Component({
  selector: 'app-units-list',
  standalone: false,
  templateUrl: './units-list.component.html',
  styleUrls: ['./units-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    '[class.is-dragging]': 'isDragging'
  }
})
export class UnitsListComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('unitsContainer', { static: true }) unitsContainer!: ElementRef<HTMLElement>;

  // Public properties
  units$!: Observable<Unit[]>;
  courseId!: string;
  activeUnitId: string | null = null;
  isDragging = false;
  isScrolling = false;

  // Private properties
  private scrollState: ScrollState = {
    isDragging: false,
    startX: 0,
    scrollLeft: 0,
    momentumVelocity: 0
  };

  private readonly destroy$ = new Subject<void>();
  private observer: IntersectionObserver | null = null;
  private rafId: number | null = null;
  private momentumId: number | null = null;
  private resizeObserver: ResizeObserver | null = null;
  private currentVisibleUnit: string | null = null;
  private touchStartTime = 0;
  private lastTouchX = 0;
  private velocityTracker: number[] = [];
  private lastFrameTime = 0;

  // Constants
  private readonly DRAG_THRESHOLD = 5;
  private readonly FRICTION = 0.97;
  private readonly MINIMUM_VELOCITY = 0.2;
  private readonly VELOCITY_HISTORY = 5;
  private readonly SNAP_THRESHOLD = 0.3;
  private readonly ANIMATION_DURATION = 500;

  constructor(
    private unitsService: UnitsService,
    private route: ActivatedRoute,
    private router: Router,
    private ngZone: NgZone,
    private cdr: ChangeDetectorRef,
    private renderer: Renderer2
  ) { }

  ngOnInit(): void {
    this.initializeComponent();
    this.setupEventListeners();
  }

  ngAfterViewInit(): void {
    this.setupScrollBehavior();
    this.setupIntersectionObserver();
    this.setupResizeObserver();
  }

  private initializeComponent(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitsService.setCurrentCourse(this.courseId);

    this.units$ = this.unitsService.getUnitsByCourseId(this.courseId).pipe(
      distinctUntilChanged(),
      shareReplay(1),
      tap(units => {
        if (units.length > 0) {
          timer(100).pipe(
            observeOn(animationFrameScheduler),
            takeUntil(this.destroy$)
          ).subscribe(() => this.scrollToActiveUnit());
        }
      }),
      catchError(error => {
        console.error('Error fetching units:', error);
        return [];
      })
    );

    const unitId = this.route.snapshot.paramMap.get('unitId');
    if (unitId) {
      this.activeUnitId = unitId;
    }
  }

  private setupEventListeners(): void {
    fromEvent(window, 'resize').pipe(
      debounceTime(150),
      takeUntil(this.destroy$)
    ).subscribe(() => {
      this.handleResize();
    });

    fromEvent(this.unitsContainer.nativeElement, 'scroll').pipe(
      debounceTime(150),
      filter(() => !this.isDragging),
      takeUntil(this.destroy$)
    ).subscribe(() => {
      this.handleScrollEnd();
    });
  }



  private setupScrollBehavior(): void {
    if (!this.unitsContainer?.nativeElement) return;

    const container = this.unitsContainer.nativeElement;

    this.renderer.setStyle(container, 'scroll-behavior', 'smooth');
    this.renderer.setStyle(container, 'scroll-snap-type', 'x mandatory');
    this.renderer.setStyle(container, '-webkit-overflow-scrolling', 'touch');

    const units = Array.from(container.querySelectorAll<HTMLElement>('.unit-item'));
    units.forEach(unit => {
      this.renderer.setStyle(unit, 'scroll-snap-align', 'center');
    });
  }

  private setupResizeObserver(): void {
    this.resizeObserver = new ResizeObserver(entries => {
      for (const entry of entries) {
        if (entry.target === this.unitsContainer.nativeElement) {
          this.handleResize();
        }
      }
    });

    this.resizeObserver.observe(this.unitsContainer.nativeElement);
  }

  // Event Handlers
  onMouseDown(event: MouseEvent): void {
    event.preventDefault();
    this.startDrag(event.pageX);
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.scrollState.isDragging) return;
    event.preventDefault();
    this.handleDragMove(event.pageX);
  }

  onMouseUp(event: MouseEvent): void {
    if (!this.scrollState.isDragging) return;
    this.handleDragEnd(event.pageX);
  }

  onTouchStart(event: TouchEvent): void {
    this.touchStartTime = Date.now();
    this.startDrag(event.touches[0].pageX);
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.scrollState.isDragging) return;
    event.preventDefault();
    this.handleDragMove(event.touches[0].pageX);
  }

  onTouchEnd(event: TouchEvent): void {
    if (!this.scrollState.isDragging) return;
    this.handleDragEnd(event.changedTouches[0].pageX);
  }

  onMouseLeave(): void {
    if (this.scrollState.isDragging) {
      this.handleDragEnd(this.lastTouchX);
    }
  }

  private startDrag(pageX: number): void {
    this.stopAllAnimations();

    const container = this.unitsContainer.nativeElement;
    this.scrollState = {
      isDragging: true,
      startX: pageX - container.offsetLeft,
      scrollLeft: container.scrollLeft,
      momentumVelocity: 0
    };

    this.velocityTracker = [];
    this.lastFrameTime = performance.now();
    this.lastTouchX = pageX;
    this.isDragging = true;

    this.renderer.addClass(container, 'dragging');
    this.renderer.setStyle(container, 'scroll-snap-type', 'none');
    this.cdr.detectChanges();
  }

  private handleDragMove(pageX: number): void {
    if (!this.scrollState.isDragging) return;

    const container = this.unitsContainer.nativeElement;
    const x = pageX - container.offsetLeft;
    const walk = (x - this.scrollState.startX) * 2;

    // Track velocity
    const currentTime = performance.now();
    const timeDelta = currentTime - this.lastFrameTime;
    const velocity = (pageX - this.lastTouchX) / (timeDelta || 1);

    this.velocityTracker.push(velocity);
    if (this.velocityTracker.length > this.VELOCITY_HISTORY) {
      this.velocityTracker.shift();
    }

    this.lastTouchX = pageX;
    this.lastFrameTime = currentTime;

    this.rafId = requestAnimationFrame(() => {
      container.scrollLeft = this.scrollState.scrollLeft - walk;
    });
  }

  private handleTap(pageX: number): void {
    const element = document.elementFromPoint(pageX, this.unitsContainer.nativeElement.offsetTop);
    if (!element) return;

    const unitElement = (element as HTMLElement).closest('[data-unit-id]');
    if (!unitElement) return;

    const unitId = (unitElement as HTMLElement).getAttribute('data-unit-id');
    if (unitId) {
      this.handleUnitClick(unitId);
    }
  }

  private handleDragEnd(pageX: number): void {
    const container = this.unitsContainer.nativeElement;
    const dragDuration = Date.now() - this.touchStartTime;
    const dragDistance = Math.abs(pageX - (this.scrollState.startX + container.offsetLeft));

    const finalVelocity = this.calculateFinalVelocity();

    this.renderer.removeClass(container, 'dragging');
    this.scrollState.isDragging = false;
    this.isDragging = false;

    if (dragDistance < this.DRAG_THRESHOLD && dragDuration < 200) {
      const target = document.elementFromPoint(pageX, container.offsetTop);
      if (target) {
        const unitElement = (target as HTMLElement).closest('[data-unit-id]');
        if (unitElement) {
          const unitId = (unitElement as HTMLElement).getAttribute('data-unit-id');
          if (unitId) {
            this.handleUnitClick(unitId);
          }
        }
      }
    } else {
      this.ngZone.runOutsideAngular(() => {
        this.applyMomentum(finalVelocity);
      });
    }
  }

  private setupIntersectionObserver(): void {
    const options: IntersectionObserverInit = {
      root: this.unitsContainer.nativeElement,
      threshold: [0.1, 0.5, 0.9],
      rootMargin: '0px'
    };

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && entry.intersectionRatio >= 0.5) {
          const targetElement = entry.target as HTMLElement;
          const unitId = targetElement.getAttribute('data-unit-id');
          if (unitId && this.currentVisibleUnit !== unitId && !this.isDragging) {
            this.currentVisibleUnit = unitId;
            this.updateActiveUnit(unitId);
          }
        }
      });
    }, options);

    this.observeUnits();
  }

  private handleScrollEnd(): void {
    if (this.isDragging) return;

    const container = this.unitsContainer.nativeElement;
    const units = Array.from(container.querySelectorAll('.unit-item'));
    let nearestUnit: Element | null = null;
    let minDistance = Infinity;

    units.forEach((unitElement) => {
      const rect = unitElement.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();
      const distance = Math.abs(
        (rect.left + rect.right) / 2 -
        (containerRect.left + containerRect.right) / 2
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestUnit = unitElement;
      }
    });

    if (nearestUnit) {
      const unitId = (nearestUnit as HTMLElement).getAttribute('data-unit-id');
      if (unitId) {
        this.updateActiveUnit(unitId);
      }
    }
  }

  private calculateFinalVelocity(): number {
    if (this.velocityTracker.length === 0) return 0;

    const weights = this.velocityTracker.map((_, i) => i + 1);
    const weightSum = weights.reduce((a, b) => a + b, 0);

    return this.velocityTracker.reduce((sum, velocity, i) => {
      return sum + (velocity * weights[i]);
    }, 0) / weightSum * 1000; // Scale for better feel
  }

  private applyMomentum(initialVelocity: number): void {
    let velocity = initialVelocity;

    const animate = () => {
      if (Math.abs(velocity) > this.MINIMUM_VELOCITY) {
        velocity *= this.FRICTION;

        const container = this.unitsContainer.nativeElement;
        const scrollLeft = container.scrollLeft;

        // Apply easing
        const ease = this.calculateEasing(velocity);
        container.scrollLeft += velocity * ease;

        this.momentumId = requestAnimationFrame(animate);
      } else {
        this.snapToNearestUnit();
      }
    };

    this.momentumId = requestAnimationFrame(animate);
  }

  private calculateEasing(velocity: number): number {
    return 1 - Math.pow(1 - Math.abs(velocity) / 10, 3);
  }

  private snapToNearestUnit(): void {
    const container = this.unitsContainer.nativeElement;
    this.renderer.setStyle(container, 'scroll-behavior', 'smooth');

    const unitWidth = this.getUnitWidth();
    const currentScroll = container.scrollLeft;
    const nearestUnit = Math.round(currentScroll / unitWidth) * unitWidth;

    container.scrollLeft = nearestUnit;

    setTimeout(() => {
      this.renderer.setStyle(container, 'scroll-snap-type', 'x mandatory');
    }, this.ANIMATION_DURATION);
  }

  private getUnitWidth(): number {
    const unitElement = this.unitsContainer.nativeElement.querySelector<HTMLElement>('.unit-item');
    return unitElement ? unitElement.clientWidth : 0;
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
      this.router.navigate(['/courses', this.courseId, 'units', unit.id, 'lessons']);
    }
  }

  private scrollToActiveUnit(behavior: ScrollBehavior = 'smooth'): void {
    const container = this.unitsContainer.nativeElement;
    const activeElement = container.querySelector<HTMLElement>('.unit-item--active');

    if (activeElement) {
      const containerWidth = container.offsetWidth;
      const elementWidth = activeElement.clientWidth;
      const elementLeft = activeElement.offsetLeft;

      const scrollTo = elementLeft - (containerWidth - elementWidth) / 2;

      container.scrollTo({
        left: scrollTo,
        behavior
      });
    }
  }

  // Track units for performance
  trackByUnitId(_: number, unit: Unit): string {
    return unit.id;
  }

  // Calculate connector progress
  getConnectorProgress(currentUnit: Unit, nextUnit: Unit): number {
    if (currentUnit.isCompleted) return 100;
    if (nextUnit.isLocked) return 0;
    return (currentUnit.progress || 0) * 100;
  }

  private updateActiveUnit(unitId: string): void {
    if (this.activeUnitId !== unitId) {
      this.activeUnitId = unitId;
      this.cdr.detectChanges();
    }
  }

  private handleResize(): void {
    this.stopAllAnimations();
    this.scrollToActiveUnit('auto');
  }

  private observeUnits(): void {
    if (!this.observer) return;

    const units = Array.from(this.unitsContainer.nativeElement.querySelectorAll<HTMLElement>('.unit-item'));
    units.forEach(unit => {
      this.observer?.observe(unit);
    });
  }

  private stopAllAnimations(): void {
    if (this.momentumId) {
      cancelAnimationFrame(this.momentumId);
      this.momentumId = null;
    }
    if (this.rafId) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }
  }



  // Utility methods for type-safe DOM operations
  private getUnitElementById(unitId: string): HTMLElement | null {
    return this.unitsContainer.nativeElement.querySelector<HTMLElement>(
      `[data-unit-id="${unitId}"]`
    );
  }

  private getAllUnitElements(): HTMLElement[] {
    return Array.from(
      this.unitsContainer.nativeElement.querySelectorAll<HTMLElement>('.unit-item')
    );
  }

  // Performance optimization methods
  private optimizeForAnimation(): void {
    const container = this.unitsContainer.nativeElement;
    const units = this.getAllUnitElements();

    units.forEach(unit => {
      this.renderer.setStyle(unit, 'will-change', 'transform');
    });

    // Reset will-change after animation
    setTimeout(() => {
      units.forEach(unit => {
        this.renderer.setStyle(unit, 'will-change', 'auto');
      });
    }, this.ANIMATION_DURATION);
  }

  // Error handling and recovery
  private handleScrollError(): void {
    console.warn('Scroll animation interrupted or failed');
    this.stopAllAnimations();
    this.isDragging = false;
    this.scrollState.isDragging = false;

    const container = this.unitsContainer.nativeElement;
    this.renderer.removeClass(container, 'dragging');
    this.renderer.setStyle(container, 'scroll-snap-type', 'x mandatory');
    this.scrollToActiveUnit();
    this.cdr.detectChanges();
  }

  // Cleanup
  ngOnDestroy(): void {
    this.stopAllAnimations();

    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }

    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }

    // Clean up any remaining RAF callbacks
    if (this.rafId) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }

    if (this.momentumId) {
      cancelAnimationFrame(this.momentumId);
      this.momentumId = null;
    }

    // Complete and clean up all subscriptions
    this.destroy$.next();
    this.destroy$.complete();
  }
}