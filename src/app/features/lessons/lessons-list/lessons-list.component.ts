// src/app/features/lessons/lessons-list/lessons-list.component.ts
import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Observable, BehaviorSubject, combineLatest, of, Subject } from 'rxjs';
import { tap, map, filter, take, catchError, shareReplay, takeUntil } from 'rxjs/operators';
import { trigger, transition, style, animate } from '@angular/animations';
import { LessonsService } from '../lessons.service';
import { UnitsService } from '../../units/units.service';
import { StorageService } from '../../../core/services/storage.service';
import { Lesson } from '../../../shared/interfaces/lesson';

@Component({
  selector: 'app-lessons-list',
  standalone: false,
  templateUrl: './lessons-list.component.html',
  styleUrls: ['./lessons-list.component.scss'],
  animations: [
    trigger('slideInOut', [
      transition(':enter', [
        style({ transform: 'translateX(100%)' }),
        animate('300ms ease-out', style({ transform: 'translateX(0)' }))
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ transform: 'translateX(-100%)' }))
      ])
    ])
  ]
})
export class LessonsListComponent implements OnInit {
  @ViewChild('lessonsContainer') lessonsContainer!: ElementRef;
  private destroy$ = new Subject<void>();

  completingLessonId: string | null = null;

  lessons$!: Observable<Lesson[]>;
  courseId!: string;
  unitId!: string;
  currentLessonIndex = new BehaviorSubject<number>(0);
  isDragging = false;
  dragStarted = false;
  startX = 0;
  scrollLeft = 0;
  dragThreshold = 5;
  dragStartTime = Date.now();
  mouseInitialX = 0;
  dragSpeedMultiplier = 2.5;
  inertiaMultiplier = 200;
  activeLessonId: string | null = null;

  constructor(
    private lessonsService: LessonsService,
    private unitsService: UnitsService,
    private storageService: StorageService,
    public route: ActivatedRoute,
    public router: Router
  ) { }


  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitId = this.route.snapshot.paramMap.get('unitId')!;
    this.lessonsService.setCurrentUnit(this.unitId);

    // Initialize lessons with proper state management
    this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId).pipe(
      map(lessons => {
        let previousLessonCompleted = true; // First lesson should be unlocked

        // Calculate how many lessons are completed
        const completedLessons = lessons.filter(lesson => {
          const storageKey = `${this.courseId}_${this.unitId}_${lesson.id}`;
          const progressData = this.storageService.getProgress('lesson', storageKey);
          return progressData?.isCompleted;
        }).length;

        // Calculate unit progress percentage
        const unitProgress = Math.round((completedLessons * 100) / lessons.length);

        // Save unit progress
        this.storageService.saveProgress('unit', `${this.courseId}_${this.unitId}`, {
          progress: unitProgress,
          isCompleted: unitProgress === 100,
          timestamp: Date.now()
        });

        return lessons.map(lesson => {
          const storageKey = `${this.courseId}_${this.unitId}_${lesson.id}`;
          const progressData = this.storageService.getProgress('lesson', storageKey);

          // Determine locked state based on previous lesson completion
          const isLocked = lesson.order !== 1 && !previousLessonCompleted;
          const isCompleted = progressData?.isCompleted || false;

          // Update for next iteration
          previousLessonCompleted = isCompleted;

          return {
            ...lesson,
            isCompleted,
            isLocked
          };
        });
      }),
      tap(lessons => {
        // Handle query params
        const params = this.route.snapshot.queryParams;
        if (params['completedLessonId']) {
          this.checkAndHandleLessonCompletion(params['completedLessonId']);
        }
      }),
      shareReplay(1)
    );

    // Subscribe to query params and storage changes
    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      const completedLessonId = params['completedLessonId'];
      if (completedLessonId) {
        this.checkAndHandleLessonCompletion(completedLessonId);
      }
    });
  }

  private checkAndHandleLessonCompletion(lessonId: string) {
    const storageKey = `${this.courseId}_${this.unitId}_${lessonId}`;
    const progressData = this.storageService.getProgress('lesson', storageKey);

    // Check if this is the first time completing this lesson
    if (!progressData?.answers?.['completion_effect_shown']) {
      // Set the completion effect flag
      this.storageService.saveAnswer(
        storageKey,
        'completion_effect_shown',
        true,
        true
      );

      // Trigger the completion effect
      this.completingLessonId = lessonId;
      this.handleLessonCompletion(lessonId);
    } else {
      // Skip animation and handle navigation directly
      this.handleLessonNavigation(lessonId);
    }
  }

  private handleLessonNavigation(lessonId: string): void {
    setTimeout(() => {
      this.lessons$.pipe(take(1)).subscribe(lessons => {
        const currentIndex = lessons.findIndex(l => l.id === lessonId);
        const isLastLesson = lessons.every((lesson, index) =>
          index === currentIndex || lesson.isCompleted
        );

        if (isLastLesson) {
          this.router.navigate(['/courses', this.courseId, 'units'], {
            queryParams: {
              completedUnitId: this.unitId,
              lastCompletedLesson: lessonId
            }
          });
        } else {
          const nextLesson = lessons[currentIndex + 1];
          if (nextLesson && !nextLesson.isLocked) {
            this.onLessonSelected(nextLesson);
          }
        }
      });
    }, 1500); // Same delay as completion animation
  }

  handleLessonCompletion(lessonId: string): void {
    // Wait for animation to complete
    setTimeout(() => {
      this.completingLessonId = null;
      this.handleLessonNavigation(lessonId);
    }, 2500); // Match your animation duration
  }

  onLessonSelected(lesson: Lesson): void {
    if (!lesson.isLocked) {
      this.activeLessonId = lesson.id;
      this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', lesson.id]);
    }
  }

  // Mouse Event Handlers
  onMouseDown(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest('.lesson-item')) {
      this.dragStarted = true;
      this.mouseInitialX = event.pageX;
      this.startX = event.pageX;
      this.scrollLeft = this.lessonsContainer.nativeElement.scrollLeft;
      this.dragStartTime = Date.now();
    }
  }

  onMouseMove(event: MouseEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.pageX - this.mouseInitialX);
    if (dragDistance > this.dragThreshold) {
      this.isDragging = true;
    }

    const walk = (event.pageX - this.startX) * this.dragSpeedMultiplier;
    this.lessonsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onMouseUp(event: MouseEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.pageX - this.mouseInitialX);
    const dragDuration = Date.now() - this.dragStartTime;

    if (!this.isDragging && dragDistance < this.dragThreshold && dragDuration < 200) {
      const lessonElement = (event.target as HTMLElement).closest('[data-lesson-id]');
      if (lessonElement) {
        const lessonId = lessonElement.getAttribute('data-lesson-id');
        this.lessons$.pipe(take(1)).subscribe(lessons => {
          const lesson = lessons.find(l => l.id === lessonId);
          if (lesson && !lesson.isLocked) {
            this.onLessonSelected(lesson);
          }
        });
      }
    } else if (dragDistance > this.dragThreshold) {
      const speed = dragDistance / dragDuration;
      const inertiaDistance = speed * this.inertiaMultiplier;

      this.lessonsContainer.nativeElement.scrollBy({
        left: -inertiaDistance,
        behavior: 'smooth'
      });
    }

    this.isDragging = false;
    this.dragStarted = false;
  }

  onMouseLeave(): void {
    if (this.dragStarted) {
      this.isDragging = false;
      this.dragStarted = false;
    }
  }

  // Touch Event Handlers
  onTouchStart(event: TouchEvent): void {
    if ((event.target as HTMLElement).closest('.lesson-item')) {
      this.dragStarted = true;
      this.mouseInitialX = event.touches[0].pageX;
      this.startX = event.touches[0].pageX;
      this.scrollLeft = this.lessonsContainer.nativeElement.scrollLeft;
      this.dragStartTime = Date.now();
    }
  }

  onTouchMove(event: TouchEvent): void {
    if (!this.dragStarted) return;

    const dragDistance = Math.abs(event.touches[0].pageX - this.mouseInitialX);
    if (dragDistance > this.dragThreshold) {
      this.isDragging = true;
    }

    const walk = (event.touches[0].pageX - this.startX) * this.dragSpeedMultiplier;
    this.lessonsContainer.nativeElement.scrollLeft = this.scrollLeft - walk;
  }

  onTouchEnd(event: TouchEvent): void {
    if (!this.dragStarted) return;

    const touch = event.changedTouches[0];
    const dragDistance = Math.abs(touch.pageX - this.mouseInitialX);
    const dragDuration = Date.now() - this.dragStartTime;

    if (!this.isDragging && dragDistance < this.dragThreshold && dragDuration < 200) {
      const lessonElement = (event.target as HTMLElement).closest('[data-lesson-id]');
      if (lessonElement) {
        const lessonId = lessonElement.getAttribute('data-lesson-id');
        this.lessons$.pipe(take(1)).subscribe(lessons => {
          const lesson = lessons.find(l => l.id === lessonId);
          if (lesson && !lesson.isLocked) {
            this.onLessonSelected(lesson);
          }
        });
      }
    } else if (dragDistance > this.dragThreshold) {
      const speed = dragDistance / dragDuration;
      const inertiaDistance = speed * this.inertiaMultiplier;

      this.lessonsContainer.nativeElement.scrollBy({
        left: -inertiaDistance,
        behavior: 'smooth'
      });
    }

    this.isDragging = false;
    this.dragStarted = false;
  }

  ngOnDestroy(): void {
    if (this.destroy$) {
      this.destroy$.next();
      this.destroy$.complete();
    }
  }
}