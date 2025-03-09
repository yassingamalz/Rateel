// src/app/shared/components/drag-scroll/drag-scroll.base.ts
import { Directive, ElementRef, Input, NgZone, OnDestroy, AfterViewInit } from '@angular/core';
import { Subject } from 'rxjs';
import { StorageService } from '../../../core/services/storage.service';

@Directive()
export abstract class DragScrollBase implements OnDestroy, AfterViewInit {
  protected destroy$ = new Subject<void>();
  protected dragStarted = false;
  protected isDragging = false;
  protected startX = 0;
  protected scrollLeft = 0;
  protected mouseInitialX = 0;
  protected lastTimestamp = 0;
  protected velocity = 0;
  protected animationFrame: number | null = null;
  protected scrollStorageKey: string | null = null;

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

  ngAfterViewInit(): void {
    // Restore scroll position when view is ready (if storage key is set)
    if (this.scrollStorageKey) {
      setTimeout(() => this.restoreScrollFromLocalStorage(), 300);
    }
  }

  /**
   * Sets up scroll position persistence with the specified key
   * @param key Unique key to use for storing the scroll position
   */
  protected setupScrollPersistence(key: string): void {
    this.scrollStorageKey = key;
    console.log(`[DragScrollBase] Setting up scroll persistence with key: ${key}`);
  }

  /**
   * Saves current scroll position to localStorage
   */
  protected saveScrollToLocalStorage(): void {
    if (!this.scrollStorageKey || !this.elementRef?.nativeElement) return;
    
    try {
      const scrollLeft = this.elementRef.nativeElement.scrollLeft;
      console.log(`[DragScrollBase] Saving scroll position: ${scrollLeft}px for key ${this.scrollStorageKey}`);
      localStorage.setItem(this.scrollStorageKey, scrollLeft.toString());
    } catch (error) {
      console.error('[DragScrollBase] Error saving scroll position:', error);
    }
  }

  /**
   * Restores scroll position from localStorage
   */
  protected restoreScrollFromLocalStorage(): void {
    if (!this.scrollStorageKey || !this.elementRef?.nativeElement) return;
    
    try {
      const savedPosition = localStorage.getItem(this.scrollStorageKey);
      if (savedPosition) {
        const scrollLeft = parseInt(savedPosition, 10);
        console.log(`[DragScrollBase] Restoring scroll position: ${scrollLeft}px for key ${this.scrollStorageKey}`);
        this.elementRef.nativeElement.scrollLeft = scrollLeft;
      } else {
        console.log(`[DragScrollBase] No saved scroll position found for key ${this.scrollStorageKey}, starting at 0px`);
        this.elementRef.nativeElement.scrollLeft = 0;
      }
    } catch (error) {
      console.error('[DragScrollBase] Error restoring scroll position:', error);
    }
  }

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
    
    console.log(`[DragScrollBase] Starting drag at scrollLeft: ${this.scrollLeft}px`);
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
    
    // Also save to localStorage if scrollStorageKey is set
    if (this.scrollStorageKey) {
      this.saveScrollToLocalStorage();
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
    if (progress?.scrollPosition !== undefined) {
      this.elementRef.nativeElement.scrollLeft = progress.scrollPosition;
      console.log(`[DragScrollBase] Restored scroll position from progress: ${progress.scrollPosition}px`);
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
      } else if (this.scrollStorageKey) {
        // Save position after inertia animation completes
        this.saveScrollToLocalStorage();
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
      
      // Save position after cleanup
      if (this.scrollStorageKey) {
        this.saveScrollToLocalStorage();
      }
    }, 50);
  }

  ngOnDestroy(): void {
    // Save final scroll position before destroying
    if (this.scrollStorageKey) {
      this.saveScrollToLocalStorage();
    }
    
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }
    this.destroy$.next();
    this.destroy$.complete();
  }
}