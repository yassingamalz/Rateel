// courses-list.component.ts
import { Component, OnInit, ViewChild, ElementRef, ChangeDetectionStrategy, AfterViewInit } from '@angular/core';
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
  startX = 0;
  scrollLeft = 0;

  private readonly DRAG_THRESHOLD = 5;
  private dragDistance = 0;
  private observer: IntersectionObserver | null = null;

  constructor(
    private coursesService: CoursesService,
    private router: Router
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
    this.isDragging = false;
    this.dragDistance = 0;
    this.startX = event.pageX - this.coursesContainer.nativeElement.offsetLeft;
    this.scrollLeft = this.coursesContainer.nativeElement.scrollLeft;
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.startX) return;

    event.preventDefault();
    const x = event.pageX - this.coursesContainer.nativeElement.offsetLeft;
    const walk = (x - this.startX) * 1.5;

    this.dragDistance = Math.abs(walk);
    if (this.dragDistance > this.DRAG_THRESHOLD) {
      this.isDragging = true;
    }

    requestAnimationFrame(() => {
      if (this.coursesContainer?.nativeElement) {
        this.coursesContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
      }
    });
  }

  onMouseUp(): void {
    this.startX = 0;
    setTimeout(() => this.isDragging = false, 50);
  }

  onMouseLeave(): void {
    this.startX = 0;
    this.isDragging = false;
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
    if (!this.isDragging) {
      this.router.navigate(['/courses', course.id, 'units']);
    }
  }

  ngOnDestroy(): void {
    if (this.observer) {
      this.observer.disconnect();
    }
  }
}