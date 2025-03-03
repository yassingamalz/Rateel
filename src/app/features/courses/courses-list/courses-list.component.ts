// src/app/features/courses/courses-list/courses-list.component.ts
import {
  Component,
  OnInit,
  ViewChild,
  ElementRef,
  NgZone,
  ChangeDetectionStrategy,
  AfterViewInit,
  ChangeDetectorRef,
  OnDestroy,
  ApplicationRef
} from '@angular/core';
import { Router } from '@angular/router';
import { Observable, Subject, takeUntil, filter, distinctUntilChanged, fromEvent, take, timer } from 'rxjs';
import { Course } from '../../../shared/interfaces/course';
import { CoursesService } from '../courses.service';
import { StorageService } from '../../../core/services/storage.service';
import { trigger, transition, query, stagger, style, animate } from '@angular/animations';
import { DragScrollBase } from '../../../shared/components/drag-scroll/drag-scroll.base';

@Component({
  selector: 'app-courses-list',
  standalone: false,
  templateUrl: './courses-list.component.html',
  styleUrls: ['./courses-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('cardsAnimation', [
      transition(':enter', [
        query('.course-item', [
          style({ opacity: 0, transform: 'translateY(30px) scale(0.95)' }),
          stagger(80, [
            animate('400ms cubic-bezier(0.35, 0, 0.25, 1)', style({ opacity: 1, transform: 'translateY(0) scale(1)' }))
          ])
        ], { optional: true })
      ])
    ])
  ]
})
export class CoursesListComponent extends DragScrollBase implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('coursesContainer') coursesContainer!: ElementRef;

  courses$: Observable<Course[]>;
  currentCourseIndex = 0;
  private progressUpdateCount = 0;
  override destroy$ = new Subject<void>();
  private observer: IntersectionObserver | null = null;

  constructor(
    elementRef: ElementRef,
    ngZone: NgZone,
    storageService: StorageService,
    private coursesService: CoursesService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private appRef: ApplicationRef
  ) {
    super(elementRef, ngZone, storageService);
    this.courses$ = this.coursesService.getCourses();

    // Configure drag behavior for courses
    this.dragThreshold = 10;
    this.inertiaMultiplier = 200;
    this.dragSpeedMultiplier = 2;
  }

  ngOnInit(): void {
    // Force refresh all courses data at startup
    setTimeout(() => this.coursesService.refreshAllCourses(), 0);

    // Subscribe to storage progress changes
    this.storageService.getProgressChanges()
      .pipe(
        takeUntil(this.destroy$),
        filter(change => change?.type === 'course')
      )
      .subscribe(change => {
        if (change) {
          // Track update count for debugging
          this.progressUpdateCount++;
          console.log(`[CoursesListComponent] Course progress update #${this.progressUpdateCount} - ${change.id}: ${change.data.progress}%`);

          // Force immediate change detection
          this.cdr.detectChanges();

          // Schedule another update after a delay to ensure UI is updated
          timer(50).subscribe(() => {
            this.cdr.detectChanges();
            console.log(`[CoursesListComponent] Forced change detection after update #${this.progressUpdateCount}`);
          });
        }
      });

    // Also track the courses observable for structural changes
    this.courses$.pipe(
      takeUntil(this.destroy$),
      distinctUntilChanged((prev, curr) => {
        // Skip update only if arrays are identical by value
        if (prev.length !== curr.length) return false;

        for (let i = 0; i < prev.length; i++) {
          const prevCourse = prev[i];
          const currCourse = curr[i];

          if (
            prevCourse.id !== currCourse.id ||
            prevCourse.progress !== currCourse.progress ||
            prevCourse.isCompleted !== currCourse.isCompleted ||
            prevCourse.isLocked !== currCourse.isLocked
          ) {
            console.log(`[CoursesListComponent] Detected change in course ${currCourse.id}:`,
              {
                prevProgress: prevCourse.progress,
                newProgress: currCourse.progress,
                prevCompleted: prevCourse.isCompleted,
                newCompleted: currCourse.isCompleted
              }
            );
            return false;
          }
        }
        return true;
      })
    ).subscribe(courses => {
      console.log(`[CoursesListComponent] Courses updated (${courses.length}), forcing re-render`);
      // Force immediate change detection
      this.cdr.detectChanges();
    });

    // Setup visibility change listener to refresh data when tab becomes visible
    fromEvent(document, 'visibilitychange')
      .pipe(takeUntil(this.destroy$))
      .subscribe(() => {
        if (document.visibilityState === 'visible') {
          console.log('[CoursesListComponent] Tab became visible, refreshing courses data');
          this.coursesService.refreshAllCourses();
          this.cdr.detectChanges();
        }
      });
  }

  ngAfterViewInit(): void {
    this.setupScrollBehavior();
    this.setupIntersectionObserver();
  }

  private setupScrollBehavior(): void {
    if (!this.coursesContainer?.nativeElement) return;

    const container = this.coursesContainer.nativeElement;
    container.style.scrollSnapType = 'x mandatory';
    container.style.overscrollBehaviorX = 'contain';

    const cards = container.querySelectorAll('.course-item');
    cards.forEach((card: HTMLElement) => {
      card.style.scrollSnapAlign = 'center';
    });
  }

  private setupIntersectionObserver(): void {
    const options = {
      root: this.coursesContainer.nativeElement,
      // Use more threshold points for better detection
      threshold: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    };

    this.observer = new IntersectionObserver((entries) => {
      // Find the most visible card (highest intersection ratio)
      let maxRatio = 0;
      let mostVisibleCardIndex = -1;

      entries.forEach(entry => {
        if (entry.isIntersecting) {
          // Store the entry with highest visibility ratio
          if (entry.intersectionRatio > maxRatio) {
            maxRatio = entry.intersectionRatio;
            mostVisibleCardIndex = parseInt(entry.target.getAttribute('data-index') || '0');
          }
        }
      });

      // Only update if we found a visible card and it's different from current
      if (mostVisibleCardIndex >= 0 && mostVisibleCardIndex !== this.currentCourseIndex) {
        this.ngZone.run(() => {
          console.log(`[CoursesListComponent] Updating current course from ${this.currentCourseIndex} to ${mostVisibleCardIndex} (intersection ratio: ${maxRatio.toFixed(2)})`);
          this.currentCourseIndex = mostVisibleCardIndex;
          this.cdr.detectChanges();
        });
      }
    }, options);

    // Observe all course items with a slight delay to ensure DOM is ready
    setTimeout(() => {
      const cards = this.coursesContainer.nativeElement.querySelectorAll('.course-item');
      cards.forEach((card: HTMLElement) => {
        this.observer?.observe(card);
      });
    }, 150);
  }

  // Debugging helper - manually check progress
  logCurrentProgress(): void {
    this.courses$.pipe(take(1)).subscribe(courses => {
      console.table(courses.map(c => ({
        id: c.id,
        title: c.title,
        progress: c.progress || 0,
        completed: c.isCompleted || false,
        locked: c.isLocked || false
      })));
    });
  }

  // Force refresh manually if needed
  forceRefreshCourses(): void {
    console.log('[CoursesListComponent] Manually forcing refresh of all courses');
    this.coursesService.refreshAllCourses();
    this.cdr.detectChanges();
  }

  onMouseDown(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest('.course-item')) {
      super.startDrag(event.pageX);
    }
  }

  onMouseMove(event: MouseEvent): void {
    super.handleDragMove(event.pageX);
  }

  onMouseUp(event: MouseEvent): void {
    const dragThreshold = 10;
    const isDraggingFar = Math.abs(this.velocity) > dragThreshold;

    if (!isDraggingFar && !this.isDragging) {
      // Handle as click if not dragged significantly
      const courseElement = (event.target as HTMLElement).closest('[data-course-id]');
      if (courseElement) {
        const courseId = courseElement.getAttribute('data-course-id');
        if (courseId) {
          this.handleCourseClick(courseId);
        }
      }
    }

    super.handleDragEnd(event.pageX);
  }

  onScroll(event: Event): void {
    const container = event.target as HTMLElement;
    const scrollPosition = container.scrollLeft;
    const containerWidth = container.clientWidth;

    // Get all course items
    const cards = container.querySelectorAll('.course-item');

    // Find the most visible card
    let bestVisibility = 0;
    let bestIndex = this.currentCourseIndex;

    cards.forEach((card, index) => {
      const rect = card.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();

      // Calculate how much of the card is visible in the container
      const leftVisible = Math.max(rect.left, containerRect.left);
      const rightVisible = Math.min(rect.right, containerRect.right);
      const visibleWidth = Math.max(0, rightVisible - leftVisible);
      const visibility = visibleWidth / rect.width;

      if (visibility > bestVisibility) {
        bestVisibility = visibility;
        bestIndex = index;
      }
    });

    // Update current index if the best visible card is different
    if (bestIndex !== this.currentCourseIndex) {
      this.ngZone.run(() => {
        this.currentCourseIndex = bestIndex;
        this.cdr.detectChanges();
      });
    }
  }

  private handleCourseClick(courseId: string): void {
    this.courses$.pipe(take(1)).subscribe(courses => {
      const course = courses.find(c => c.id === courseId);
      if (course && !course.isLocked) {
        this.router.navigate(['/courses', courseId, 'units']);
      }
    });
  }

  isCourseCompleted(index: number): boolean {
    return index <= this.currentCourseIndex;
  }

  override ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();

    if (this.observer) {
      this.observer.disconnect();
    }

    super.ngOnDestroy();
  }
}