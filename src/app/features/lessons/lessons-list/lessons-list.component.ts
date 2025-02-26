// src/app/features/lessons/lessons-list/lessons-list.component.ts
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
import { ActivatedRoute, NavigationEnd, Router } from '@angular/router';
import { Observable, Subject } from 'rxjs';
import { tap, map, takeUntil, take, shareReplay, filter } from 'rxjs/operators';
import { LessonsService } from '../lessons.service';
import { UnitsService } from '../../units/units.service';
import { StorageService } from '../../../core/services/storage.service';
import { Lesson } from '../../../shared/interfaces/lesson';
import { trigger, transition, style, animate, state } from '@angular/animations';
import { DragScrollBase } from '../../../shared/components/drag-scroll/drag-scroll.base';

@Component({
  selector: 'app-lessons-list',
  standalone: false,
  templateUrl: './lessons-list.component.html',
  styleUrls: ['./lessons-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('slideInOut', [
      transition(':enter', [
        style({ transform: 'translateX(100%)' }),
        animate('300ms ease-out', style({ transform: 'translateX(0)' }))
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ transform: 'translateX(-100%)' }))
      ])
    ]),
    trigger('lessonItem', [
      state('completing', style({
        transform: 'scale(1.1)',
        filter: 'brightness(1.2)'
      })),
      transition('* => completing', animate('500ms ease-out')),
      transition('completing => *', animate('300ms ease-in'))
    ])
  ]
})
export class LessonsListComponent extends DragScrollBase implements OnInit, OnDestroy {
  @ViewChild('lessonsContainer') lessonsContainer!: ElementRef;

  lessons$!: Observable<Lesson[]>;
  courseId!: string;
  unitId!: string;
  activeLessonId: string | null = null;
  completingLessonId: string | null = null;
  private isNavigating = false;
  private completionHandled = new Set<string>();
  private completionInProgress = false;

  constructor(
    elementRef: ElementRef,
    ngZone: NgZone,
    protected override storageService: StorageService,
    private lessonsService: LessonsService,
    private unitsService: UnitsService,
    public route: ActivatedRoute,
    public router: Router,
    private cdr: ChangeDetectorRef
  ) {
    super(elementRef, ngZone, storageService);

    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd),
      takeUntil(this.destroy$)
    ).subscribe(() => {
      this.completingLessonId = null;
      this.completionInProgress = false;
      this.completionHandled.clear();
    });
  }

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitId = this.route.snapshot.paramMap.get('unitId')!;
    this.lessonsService.setCurrentUnit(this.unitId);

    // Initialize lessons with proper state management
    this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId).pipe(
      map(lessons => this.updateLessonsProgress(lessons)),
      tap(() => {
        // After updating progress, check for a completed lesson in the query params
        const params = this.route.snapshot.queryParams;
        if (params['completedLessonId'] && !this.completionInProgress) {
          this.checkAndHandleLessonCompletion(params['completedLessonId']);
        }
      }),
      shareReplay(1)
    );

    // Monitor query params for completion signals
    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      if (params['completedLessonId'] && !this.completionInProgress) {
        this.checkAndHandleLessonCompletion(params['completedLessonId']);
      }
    });

    // Monitor storage changes
    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (change?.type === 'lesson' && change.id.startsWith(`${this.courseId}_${this.unitId}`)) {
          this.cdr.detectChanges();
        }
      });
  }

  private updateLessonsProgress(lessons: Lesson[]): Lesson[] {
    let previousLessonCompleted = true;
    const completedLessons = lessons.filter(lesson => {
      const storageKey = `${this.courseId}_${this.unitId}_${lesson.id}`;
      const progressData = this.storageService.getProgress('lesson', storageKey);
      return progressData?.isCompleted;
    }).length;

    const unitProgress = Math.round((completedLessons * 100) / lessons.length);
    this.storageService.saveProgress('unit', `${this.courseId}_${this.unitId}`, {
      progress: unitProgress,
      isCompleted: unitProgress === 100,
      timestamp: Date.now()
    });

    return lessons.map(lesson => {
      const storageKey = `${this.courseId}_${this.unitId}_${lesson.id}`;
      const progressData = this.storageService.getProgress('lesson', storageKey);
      const isLocked = lesson.order !== 1 && !previousLessonCompleted;
      const isCompleted = progressData?.isCompleted || false;
      previousLessonCompleted = isCompleted;
      return { ...lesson, isCompleted, isLocked };
    });
  }

  private checkAndHandleLessonCompletion(lessonId: string): void {
    console.log('[LessonsList] Starting lesson completion check for:', lessonId);
    
    // Prevent multiple simultaneous completion handling
    if (this.completionInProgress) {
      console.log('[LessonsList] Completion already in progress, skipping');
      return;
    }
    
    // Prevent handling the same completion multiple times
    if (this.completionHandled.has(lessonId)) {
      console.log('[LessonsList] Already handled this completion, skipping');
      return;
    }
    
    this.completionInProgress = true;
    this.completionHandled.add(lessonId);
    
    const storageKey = `${this.courseId}_${this.unitId}_${lessonId}`;
    // Use a more specific key that's unique for lessons vs units
    const completionShownKey = `lesson_completion_shown_${lessonId}`;
    const progressData = this.storageService.getProgress('lesson', storageKey);
    const isFirstCompletion = !progressData?.answers?.[completionShownKey];
    
    console.log('[LessonsList] First completion:', isFirstCompletion);
    
    this.lessons$.pipe(take(1)).subscribe(lessons => {
      const currentIndex = lessons.findIndex(l => l.id === lessonId);
      const nextLesson = currentIndex < lessons.length - 1 ? lessons[currentIndex + 1] : null;
      const isLastLesson = currentIndex === lessons.length - 1;
      
      console.log(`[LessonsList] Lesson ${currentIndex + 1}/${lessons.length}, has next:`, !!nextLesson);
      
      const navigateToNextLesson = () => {
        if (isLastLesson) {
          console.log('[LessonsList] Last lesson completed, navigating to unit completion');
          
          // Last lesson in unit, navigate to units page with completion param
          this.router.navigate(['/courses', this.courseId, 'units'], {
            queryParams: { completedUnitId: this.unitId },
            replaceUrl: true
          }).then(() => {
            this.resetCompletionState();
          });
        } else if (nextLesson && !nextLesson.isLocked) {
          console.log('[LessonsList] Navigating to next lesson:', nextLesson.id);
          
          // Navigate to next lesson
          this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', nextLesson.id], {
            replaceUrl: true
          }).then(() => {
            this.resetCompletionState();
          });
        } else {
          console.log('[LessonsList] No valid next lesson found');
          this.resetCompletionState();
        }
      };
      
      // Show animation for first-time completion only
      if (isFirstCompletion) {
        console.log('[LessonsList] Showing first-time completion animation');
        
        // Mark that we've shown the completion animation with the more specific key
        this.storageService.saveAnswer(
          storageKey,
          completionShownKey,
          true,
          true
        );
        
        // Show animation
        this.completingLessonId = lessonId;
        this.cdr.detectChanges();
        
        // Wait for animation to complete, then navigate
        setTimeout(navigateToNextLesson, 1500); // Match animation duration
      } else {
        console.log('[LessonsList] Subsequent completion, skipping animation');
        // For subsequent completions, skip animation but use a small delay for nice UX
        setTimeout(navigateToNextLesson, 500);
      }
    });
  }

  private resetCompletionState(): void {
    console.log('[LessonsList] Resetting completion state');
    setTimeout(() => {
      this.completionInProgress = false;
    }, 500); // Add a small buffer before handling new completions
  }

  override ngOnDestroy(): void {
    console.log('[LessonsList] Component destroying, cleaning up');
    this.completionInProgress = false;
    this.completionHandled.clear();
    super.ngOnDestroy();
  }

  onLessonSelected(lesson: Lesson): void {
    if (!lesson.isLocked) {
      this.activeLessonId = lesson.id;
      this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', lesson.id]);
    }
  }

  getLessonState(lesson: Lesson): string {
    return lesson.id === this.completingLessonId ? 'completing' : 'default';
  }

  // Mouse event handlers using super class methods
  onMouseDown(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest('.lesson-item')) {
      super.startDrag(event.pageX);
    }
  }

  onMouseMove(event: MouseEvent): void {
    super.handleDragMove(event.pageX);
  }

  onMouseUp(event: MouseEvent): void {
    if (!this.isDragging) {
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
    }
    super.handleDragEnd(event.pageX);
  }

  onTouchStart(event: TouchEvent): void {
    if ((event.target as HTMLElement).closest('.lesson-item')) {
      super.startDrag(event.touches[0].pageX);
    }
  }

  onTouchMove(event: TouchEvent): void {
    super.handleDragMove(event.touches[0].pageX);
  }

  onTouchEnd(event: TouchEvent): void {
    if (!this.isDragging) {
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
    }
    super.handleDragEnd(event.changedTouches[0].pageX);
  }

  onMouseLeave(): void {
    super.cleanup();
  }
}