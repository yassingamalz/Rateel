// src/app/features/lessons/lessons-list/lessons-list.component.ts
import {
  Component,
  OnInit,
  OnDestroy,
  ViewChild,
  ElementRef,
  NgZone,
  ChangeDetectionStrategy,
  AfterViewInit
} from '@angular/core';
import {
  ActivatedRoute,
  Router
} from '@angular/router';
import {
  Observable,
  BehaviorSubject,
  Subscription
} from 'rxjs';
import {
  trigger,
  transition,
  style,
  animate
} from '@angular/animations';

import { LessonsService } from '../lessons.service';
import { UnitsService } from '../../units/units.service';
import { Lesson } from '../../../shared/interfaces/lesson';

@Component({
  selector: 'app-lessons-list',
  standalone: false,
  templateUrl: './lessons-list.component.html',
  styleUrls: ['./lessons-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('lessonsAnimation', [
      transition(':enter', [
        style({ transform: 'translateX(100%)' }),
        animate('300ms ease-out', style({ transform: 'translateX(0)' }))
      ])
    ])
  ]
})
export class LessonsListComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('lessonsContainer') lessonsContainer!: ElementRef;

  lessons$!: Observable<Lesson[]>;
  courseId!: string;
  unitId!: string;
  activeLessonId: string | null = null;
  completingLessonId: string | null = null;
  currentLessonIndex = new BehaviorSubject<number>(0);
  isDragging = false;

  // Enhanced dragging properties
  private startX = 0;
  private startScrollLeft = 0;
  private isPointerDown = false;
  private rafId: number | null = null;
  private velocity = 0;
  private lastPosition = 0;
  private lastTimestamp = 0;
  private momentumId: number | null = null;

  // Dragging configuration
  private readonly DRAG_THRESHOLD = 5;
  private readonly FRICTION = 0.95;
  private readonly MINIMUM_VELOCITY = 0.5;
  private readonly DRAG_SPEED_MULTIPLIER = 2;
  private readonly ANIMATION_FPS = 60;
  private readonly FRAME_TIME = 1000 / 60;

  private observer: IntersectionObserver | null = null;
  private subscriptions: Subscription[] = [];

  constructor(
    private lessonsService: LessonsService,
    private unitsService: UnitsService,
    public route: ActivatedRoute,
    public router: Router,
    private ngZone: NgZone
  ) {}

  ngOnInit(): void {
    this.initializeLessons();
    this.handleRouteParameters();
  }

  ngAfterViewInit(): void {
    this.setupScrollBehavior();
    this.setupIntersectionObserver();
  }

  private initializeLessons(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitId = this.route.snapshot.paramMap.get('unitId')!;
    this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId);

    const sub = this.lessons$.subscribe(lessons => {
      const lessonId = this.route.snapshot.paramMap.get('lessonId');
      if (lessonId) {
        this.activeLessonId = lessonId;
      } else {
        const nextLesson = lessons.find(l => !l.isCompleted && !l.isLocked);
        this.activeLessonId = nextLesson?.id || lessons[0]?.id;
      }
    });
    this.subscriptions.push(sub);
  }

  private handleRouteParameters(): void {
    const sub = this.route.queryParams.subscribe(params => {
      const completedLessonId = params['completedLessonId'];
      if (completedLessonId) {
        this.handleLessonCompletion(completedLessonId);
      }
    });
    this.subscriptions.push(sub);
  }

  private setupScrollBehavior(): void {
    if (!this.lessonsContainer?.nativeElement) return;

    const container = this.lessonsContainer.nativeElement;
    container.style.scrollSnapType = 'x mandatory';
    container.style.overscrollBehaviorX = 'contain';

    const lessons = container.querySelectorAll('.lesson-item');
    lessons.forEach((lesson: HTMLElement, index: number) => {
      lesson.style.scrollSnapAlign = 'center';
      lesson.setAttribute('data-index', index.toString());
    });
  }

  private setupIntersectionObserver(): void {
    const options = {
      root: this.lessonsContainer.nativeElement,
      threshold: 0.7
    };

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const lessonIndex = parseInt(entry.target.getAttribute('data-index') || '0');
          if (lessonIndex !== this.currentLessonIndex.value) {
            this.currentLessonIndex.next(lessonIndex);
          }
        }
      });
    }, options);

    const lessons = this.lessonsContainer.nativeElement.querySelectorAll('.lesson-item');
    lessons.forEach((lesson: HTMLElement) => {
      this.observer?.observe(lesson);
    });
  }

  // Enhanced Mouse Event Handlers
  onMouseDown(event: MouseEvent): void {
    event.preventDefault();
    this.startDragging(event.pageX);
  }

  onMouseMove(event: MouseEvent): void {
    event.preventDefault();
    this.continueDragging(event.pageX);
  }

  onMouseUp(): void {
    this.endDragging();
  }

  onMouseLeave(): void {
    if (this.isPointerDown) {
      this.endDragging();
    }
  }

  // Enhanced Touch Event Handlers
  onTouchStart(event: TouchEvent): void {
    event.preventDefault();
    this.startDragging(event.touches[0].pageX);
  }

  onTouchMove(event: TouchEvent): void {
    event.preventDefault();
    this.continueDragging(event.touches[0].pageX);
  }

  onTouchEnd(): void {
    this.endDragging();
  }

  // Enhanced Dragging Logic
  private startDragging(pageX: number): void {
    // Stop any ongoing animations
    this.stopAllAnimations();

    const container = this.lessonsContainer.nativeElement;
    this.isPointerDown = true;
    this.isDragging = true;
    this.startX = pageX;
    this.startScrollLeft = container.scrollLeft;
    this.lastPosition = pageX;
    this.lastTimestamp = performance.now();
    this.velocity = 0;

    container.classList.add('dragging');
    container.style.scrollSnapType = 'none';
  }

  private continueDragging(pageX: number): void {
    if (!this.isPointerDown) return;

    const container = this.lessonsContainer.nativeElement;
    const currentTime = performance.now();
    const timeElapsed = currentTime - this.lastTimestamp;
    
    if (timeElapsed > this.FRAME_TIME) {
      const x = pageX;
      const walk = (this.startX - x) * this.DRAG_SPEED_MULTIPLIER;
      const newScrollPosition = this.startScrollLeft + walk;

      // Calculate velocity (pixels per millisecond)
      this.velocity = (x - this.lastPosition) / timeElapsed;
      
      this.rafId = requestAnimationFrame(() => {
        container.scrollLeft = newScrollPosition;
      });

      this.lastPosition = x;
      this.lastTimestamp = currentTime;
    }
  }

  private endDragging(): void {
    if (!this.isPointerDown) return;

    const container = this.lessonsContainer.nativeElement;
    this.isPointerDown = false;
    this.isDragging = false;
    container.classList.remove('dragging');

    // Re-enable snap points after momentum scroll
    setTimeout(() => {
      container.style.scrollSnapType = 'x mandatory';
    }, 100);

    // Apply momentum scroll if velocity is significant
    if (Math.abs(this.velocity) > this.MINIMUM_VELOCITY) {
      this.ngZone.runOutsideAngular(() => {
        this.applyMomentumScroll();
      });
    }
  }

  private applyMomentumScroll(): void {
    const container = this.lessonsContainer.nativeElement;
    const startTime = performance.now();
    let currentVelocity = this.velocity * 1000; // Convert to pixels per second

    const animate = (currentTime: number) => {
      const elapsed = currentTime - startTime;
      
      // Apply friction
      currentVelocity *= this.FRICTION;
      
      // Update scroll position
      container.scrollLeft += currentVelocity;

      // Continue animation if velocity is above threshold
      if (Math.abs(currentVelocity) > this.MINIMUM_VELOCITY) {
        this.momentumId = requestAnimationFrame(animate);
      } else {
        this.stopAllAnimations();
      }
    };

    this.momentumId = requestAnimationFrame(animate);
  }

  private stopAllAnimations(): void {
    if (this.rafId) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }
    if (this.momentumId) {
      cancelAnimationFrame(this.momentumId);
      this.momentumId = null;
    }
  }

  // Lesson Selection and Completion
  onLessonSelected(lesson: Lesson): void {
    if (!lesson.isLocked && !this.isDragging) {
      this.activeLessonId = lesson.id;
      this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', lesson.id]);
    }
  }

  handleLessonCompletion(lessonId: string): void {
    this.completingLessonId = lessonId;
    setTimeout(() => {
      this.completingLessonId = null;
      const lessons = (this.lessons$ as any).value;
      const currentIndex = lessons.findIndex((l: Lesson) => l.id === lessonId);
      const nextLesson = lessons[currentIndex + 1];

      if (nextLesson && !nextLesson.isLocked) {
        this.onLessonSelected(nextLesson);
      }
    }, 1500);
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.stopAllAnimations();
    
    if (this.observer) {
      this.observer.disconnect();
    }
  }
}