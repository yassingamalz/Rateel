// src/app/features/courses/courses-list/courses-list.component.ts
import {
  Component,
  OnInit,
  ViewChild,
  ElementRef,
  NgZone,
  ChangeDetectionStrategy,
  AfterViewInit,
  ChangeDetectorRef
} from '@angular/core';
import { Router } from '@angular/router';
import { Observable, Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
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
export class CoursesListComponent extends DragScrollBase implements OnInit, AfterViewInit {
  @ViewChild('coursesContainer') coursesContainer!: ElementRef;

  courses$: Observable<Course[]>;
  currentCourseIndex = 0;
  override destroy$ = new Subject<void>();
  private observer: IntersectionObserver | null = null;

  constructor(
    elementRef: ElementRef,
    ngZone: NgZone,
    storageService: StorageService,
    private coursesService: CoursesService,
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {
    super(elementRef, ngZone, storageService);
    this.courses$ = this.coursesService.getCourses();

    // Configure drag behavior for courses
    this.dragThreshold = 10;
    this.inertiaMultiplier = 200;
    this.dragSpeedMultiplier = 2;
  }

  ngOnInit(): void {
    // Subscribe to storage progress changes
    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (change?.type === 'course') {
          // Trigger change detection to update course progress
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
      threshold: 0.7
    };

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const courseIndex = parseInt(entry.target.getAttribute('data-index') || '0');
          if (courseIndex !== this.currentCourseIndex) {
            this.ngZone.run(() => {
              this.currentCourseIndex = courseIndex;
              this.cdr.detectChanges();
            });
          }
        }
      });
    }, options);

    // Observe all course items
    const cards = this.coursesContainer.nativeElement.querySelectorAll('.course-item');
    cards.forEach((card: HTMLElement) => {
      this.observer?.observe(card);
    });
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
    const cardWidth = container.clientWidth;

    const newIndex = Math.round(scrollPosition / cardWidth);
    if (newIndex !== this.currentCourseIndex) {
      this.ngZone.run(() => {
        this.currentCourseIndex = newIndex;
        this.cdr.detectChanges();
      });
    }
  }

  private handleCourseClick(courseId: string): void {
    this.courses$.subscribe(courses => {
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