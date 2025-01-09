// courses-list.component.ts
import { Component, OnInit, ViewChild, ElementRef, ChangeDetectionStrategy, AfterViewInit, NgZone } from '@angular/core';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
import { Course } from '../../../shared/interfaces/course';
import { CoursesService } from '../courses.service';
import { trigger, transition, style, animate, query, stagger } from '@angular/animations';

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
          style({
            opacity: 0,
            transform: 'translateY(30px) scale(0.95)'
          }),
          stagger(80, [
            animate('400ms cubic-bezier(0.35, 0, 0.25, 1)',
              style({
                opacity: 1,
                transform: 'translateY(0) scale(1)'
              })
            )
          ])
        ], { optional: true })
      ])
    ])
  ]
})
export class CoursesListComponent implements OnInit, AfterViewInit {
  @ViewChild('coursesContainer') coursesContainer!: ElementRef;
  courses$: Observable<Course[]>;
  currentCourseIndex = 0;
  isDragging = false;
  
  // Smooth scrolling properties
  private startX = 0;
  private startScrollLeft = 0;
  private isPointerDown = false;
  private rafId: number | null = null;
  private velocity = 0;
  private lastPosition = 0;
  private momentumId: number | null = null;

  private readonly DRAG_THRESHOLD = 5;
  private readonly FRICTION = 0.95;
  private readonly MINIMUM_VELOCITY = 0.5;

  private observer: IntersectionObserver | null = null;

  constructor(
    private coursesService: CoursesService,
    private router: Router,
    private ngZone: NgZone
  ) {
    this.courses$ = this.coursesService.getCourses();
  }

  ngOnInit(): void {}

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
            this.currentCourseIndex = courseIndex;
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
    // Stop any ongoing momentum scroll
    if (this.momentumId) {
      cancelAnimationFrame(this.momentumId);
      this.momentumId = null;
    }

    // Cancel any previous RAF
    if (this.rafId) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }

    this.isPointerDown = true;
    this.startX = event.pageX - this.coursesContainer.nativeElement.offsetLeft;
    this.startScrollLeft = this.coursesContainer.nativeElement.scrollLeft;
    this.velocity = 0;
    this.lastPosition = this.startX;

    // Add dragging class
    this.coursesContainer.nativeElement.classList.add('dragging');
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.isPointerDown) return;

    event.preventDefault();
    const x = event.pageX - this.coursesContainer.nativeElement.offsetLeft;
    const walk = (x - this.startX) * 2; // Increased multiplier for smoother feel

    // Calculate velocity
    this.velocity = x - this.lastPosition;
    this.lastPosition = x;

    this.rafId = requestAnimationFrame(() => {
      if (this.coursesContainer?.nativeElement) {
        this.coursesContainer.nativeElement.scrollLeft = this.startScrollLeft - walk;
      }
    });
  }

  onMouseUp(): void {
    // Remove dragging class
    this.coursesContainer.nativeElement.classList.remove('dragging');

    // If not dragged far enough, apply momentum scroll
    this.isPointerDown = false;
    this.startX = 0;

    // Start momentum scroll
    this.ngZone.runOutsideAngular(() => {
      this.momentumScroll();
    });
  }

  private momentumScroll(): void {
    // Apply momentum with deceleration
    if (Math.abs(this.velocity) > this.MINIMUM_VELOCITY) {
      this.velocity *= this.FRICTION;

      if (this.coursesContainer?.nativeElement) {
        this.coursesContainer.nativeElement.scrollLeft += this.velocity;
      }

      // Continue momentum scroll
      this.momentumId = requestAnimationFrame(() => this.momentumScroll());
    } else {
      // Stop momentum
      if (this.momentumId) {
        cancelAnimationFrame(this.momentumId);
        this.momentumId = null;
      }
    }
  }

  onMouseLeave(): void {
    if (this.isPointerDown) {
      this.onMouseUp();
    }
    this.coursesContainer.nativeElement.classList.remove('dragging');
  }

  onScroll(event: Event): void {
    const container = event.target as HTMLElement;
    const scrollPosition = container.scrollLeft;
    const cardWidth = container.clientWidth;

    const newIndex = Math.round(scrollPosition / cardWidth);
    if (newIndex !== this.currentCourseIndex) {
      this.currentCourseIndex = newIndex;
    }
  }

  isCourseCompleted(index: number): boolean {
    return index <= this.currentCourseIndex;
  }

  onCourseSelected(course: Course): void {
    // Prevent navigation if dragging
    const dragThreshold = 10;
    const isDraggingFar = Math.abs(this.velocity) > dragThreshold;
    
    if (!isDraggingFar) {
      this.router.navigate(['/courses', course.id, 'units']);
    }
  }

  ngOnDestroy(): void {
    // Clean up observers and animations
    if (this.observer) {
      this.observer.disconnect();
    }

    if (this.rafId) {
      cancelAnimationFrame(this.rafId);
    }

    if (this.momentumId) {
      cancelAnimationFrame(this.momentumId);
    }
  }
}