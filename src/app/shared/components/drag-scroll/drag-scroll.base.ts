// src/app/shared/components/drag-scroll/drag-scroll.base.ts
import { Directive, ElementRef, Input, NgZone, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { StorageService } from '../../../core/services/storage.service';

@Directive()
export abstract class DragScrollBase implements OnDestroy {
  protected destroy$ = new Subject<void>();
  protected dragStarted = false;
  protected isDragging = false;
  protected startX = 0;
  protected scrollLeft = 0;
  protected mouseInitialX = 0;
  protected lastTimestamp = 0;
  protected velocity = 0;
  protected animationFrame: number | null = null;

  // Configurable parameters with defaults
  @Input() dragThreshold = 5;
  @Input() dragSpeedMultiplier = 2.5;
  @Input() inertiaMultiplier = 150;
  @Input() minDragDuration = 200;

  constructor(
    protected elementRef: ElementRef<HTMLElement>,
    protected ngZone: NgZone,
    protected storageService: StorageService
  ) {}

  protected startDrag(pageX: number, storageType?: string, id?: string): void {
    this.dragStarted = true;
    this.mouseInitialX = pageX;
    this.startX = pageX;
    this.scrollLeft = this.elementRef.nativeElement.scrollLeft;
    this.velocity = 0;
    this.lastTimestamp = Date.now();

    // Save scroll position if we have storage info
    if (storageType && id) {
      this.saveScrollPosition(storageType, id);
    }
  }

  protected handleDragMove(pageX: number): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(pageX - this.mouseInitialX);
    if (dragDistance > this.dragThreshold) {
      this.isDragging = true;
    }

    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }

    this.ngZone.runOutsideAngular(() => {
      this.animationFrame = requestAnimationFrame(() => {
        const currentTime = Date.now();
        const deltaTime = currentTime - this.lastTimestamp;

        const walk = (pageX - this.startX) * this.dragSpeedMultiplier;
        const newScrollLeft = this.scrollLeft - walk;

        if (deltaTime > 0) {
          this.velocity = (this.elementRef.nativeElement.scrollLeft - newScrollLeft) / deltaTime;
        }

        this.elementRef.nativeElement.scrollLeft = newScrollLeft;
        this.lastTimestamp = currentTime;
      });
    });
  }

  protected handleDragEnd(endX: number, storageType?: string, id?: string): void {
    const dragDistance = Math.abs(endX - this.mouseInitialX);
    const dragDuration = Date.now() - this.lastTimestamp;

    if (dragDistance > this.dragThreshold && dragDuration > this.minDragDuration) {
      this.applyInertia();
    }

    // Save final position after drag
    if (storageType && id) {
      this.saveScrollPosition(storageType, id);
    }

    this.cleanup();
  }

  private saveScrollPosition(type: string, id: string): void {
    const scrollPosition = this.elementRef.nativeElement.scrollLeft;
    this.storageService.saveProgress(type as any, id, {
      scrollPosition,
      lastUpdated: Date.now()
    });
  }

  protected restoreScrollPosition(type: string, id: string): void {
    const progress = this.storageService.getProgress(type as any, id);
    if (progress?.scrollPosition) {
      this.elementRef.nativeElement.scrollLeft = progress.scrollPosition;
    }
  }

  protected applyInertia(): void {
    const speed = Math.abs(this.velocity) * this.inertiaMultiplier;
    const direction = this.velocity > 0 ? -1 : 1;
    let startTimestamp: number;

    const animateInertia = (timestamp: number) => {
      if (!startTimestamp) startTimestamp = timestamp;
      const progress = (timestamp - startTimestamp) / 1000;
      const easing = Math.exp(-4 * progress);
      const distance = speed * easing * direction;

      if (easing > 0.01) {
        this.elementRef.nativeElement.scrollBy(distance, 0);
        requestAnimationFrame(animateInertia);
      }
    };

    requestAnimationFrame(animateInertia);
  }

  protected cleanup(): void {
    setTimeout(() => {
      this.isDragging = false;
      this.dragStarted = false;
      if (this.animationFrame) {
        cancelAnimationFrame(this.animationFrame);
        this.animationFrame = null;
      }
    }, 50);
  }

  ngOnDestroy(): void {
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }
    this.destroy$.next();
    this.destroy$.complete();
  }
}