// Final fixed LessonsListComponent with improved highlight timing
import {
  Component,
  OnInit,
  OnDestroy,
  ViewChild,
  ElementRef,
  NgZone,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  AfterViewInit
} from '@angular/core';
import { ActivatedRoute, NavigationEnd, Router, NavigationStart } from '@angular/router';
import { Observable, Subject, of } from 'rxjs';
import { tap, map, takeUntil, take, shareReplay, filter, delay } from 'rxjs/operators';
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
    ]),
    trigger('lessonsAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(20px)' }),
        animate('300ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ])
  ]
})
export class LessonsListComponent extends DragScrollBase implements OnInit, OnDestroy, AfterViewInit {
  @ViewChild('lessonsContainer') lessonsContainer!: ElementRef;

  completedLessonAnimating = false;
  lessons$!: Observable<Lesson[]>;
  courseId!: string;
  unitId!: string;
  activeLessonId: string | null = null;
  completingLessonId: string | null = null;
  private isNavigating = false;
  private completionHandled = new Set<string>();
  private currentQueryParams: any = {};
  private isNavigatingFromLessonCompletion = false;
  private isNavigatingFromLessonDetails = false;
  private activeStorageKey = '';
  private unitVisitKey = '';
  private isCompletionInProgress = false;

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

    // Track navigation events to detect the source
    this.router.events.pipe(
      filter(event => event instanceof NavigationStart || event instanceof NavigationEnd),
      takeUntil(this.destroy$)
    ).subscribe(event => {
      if (event instanceof NavigationStart) {
        // Detect navigation from lesson details
        const lessonDetailsPattern = /\/courses\/.*\/units\/.*\/lessons\/[^\/]+$/;
        this.isNavigatingFromLessonDetails = lessonDetailsPattern.test(event.url);

        // Check query params for lesson completion
        const hasCompletionParam = event.url.includes('completedLessonId=');
        this.isNavigatingFromLessonCompletion = hasCompletionParam;

        console.log(`[LessonsList] Navigation starting from: ${event.url}`);
        console.log(`[LessonsList] Is from lesson details: ${this.isNavigatingFromLessonDetails}`);
        console.log(`[LessonsList] Is from lesson completion: ${this.isNavigatingFromLessonCompletion}`);
      }

      if (event instanceof NavigationEnd) {
        if (this.completingLessonId) {
          this.completingLessonId = null;
          this.cdr.detectChanges();
        }
        this.isNavigating = false;
        this.isCompletionInProgress = false;
      }
    });
  }

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitId = this.route.snapshot.paramMap.get('unitId')!;
    this.lessonsService.setCurrentUnit(this.unitId);

    // Set up active lesson storage key
    this.activeStorageKey = `active_lesson_${this.courseId}_${this.unitId}`;
    this.unitVisitKey = `unit_visited_${this.courseId}_${this.unitId}`;
    console.log(`[LessonsList] Active lesson storage key: ${this.activeStorageKey}`);

    // Initialize lessons with proper state management
    this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId).pipe(
      map(lessons => this.updateLessonsProgress(lessons)),
      shareReplay(1)
    );

    // Store current query params to avoid reprocessing the same params
    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      // Only process if params are different from previously handled ones
      const completedLessonId = params['completedLessonId'];
      if (completedLessonId &&
        completedLessonId !== this.currentQueryParams['completedLessonId'] &&
        !this.isNavigating) {
        console.log(`[LessonsList] Processing completion for lesson: ${completedLessonId}`);
        this.currentQueryParams = { ...params };
        this.checkAndHandleLessonCompletion(completedLessonId);
      }
    });

    this.storageService.getProgressChanges()
      .pipe(takeUntil(this.destroy$))
      .subscribe(change => {
        if (change?.type === 'lesson' && change.id.startsWith(`${this.courseId}_${this.unitId}`)) {
          this.cdr.detectChanges();
        }
      });
  }

  override ngAfterViewInit(): void {
    // Don't restore position if coming from lesson completion
    if (!this.isNavigatingFromLessonCompletion && !this.isCompletionInProgress) {
      setTimeout(() => {
        // Check if this is the first visit to this unit
        const hasVisitedBefore = localStorage.getItem(this.unitVisitKey) === 'true';

        // Check for stored active lesson
        const storedActiveLessonId = localStorage.getItem(this.activeStorageKey);

        if (storedActiveLessonId && hasVisitedBefore) {
          console.log(`[LessonsList] Found stored active lesson: ${storedActiveLessonId}`);

          // Find lesson to check if it's the first one
          this.lessons$.pipe(take(1)).subscribe(lessons => {
            const lesson = lessons.find(l => l.id === storedActiveLessonId);

            // Set active but don't scroll for first lesson
            this.activeLessonId = storedActiveLessonId;

            if (lesson && lesson.order !== 1) {
              // Only scroll to non-first lessons after a slight delay
              setTimeout(() => {
                this.scrollToLesson(storedActiveLessonId);

                // Add highlight after scrolling is complete
                setTimeout(() => {
                  this.addHighlightToLesson(storedActiveLessonId);
                  this.cdr.detectChanges();
                }, 500);
              }, 200);
            } else {
              // Reset to beginning for first lesson
              this.resetScrollToBeginning();

              // Still add highlight after a brief moment
              setTimeout(() => {
                this.addHighlightToLesson(storedActiveLessonId);
                this.cdr.detectChanges();
              }, 300);
            }
          });
        } else {
          // If first visit or no active lesson stored, just highlight the first lesson
          this.findAndSetCurrentLesson(hasVisitedBefore);
        }

        // Mark as visited for future navigation
        localStorage.setItem(this.unitVisitKey, 'true');
      }, 300);
    }
  }

  /**
   * Adds a brief visual highlight to a lesson element
   */
  private addHighlightToLesson(lessonId: string): void {
    if (!this.lessonsContainer) return;

    const lessonElement = this.lessonsContainer.nativeElement.querySelector(`[data-lesson-id="${lessonId}"]`);
    if (lessonElement) {
      lessonElement.classList.add('focus-highlight');
      setTimeout(() => {
        lessonElement.classList.remove('focus-highlight');
      }, 1500);
    }
  }

  private findAndSetCurrentLesson(shouldScroll: boolean): void {
    this.lessons$.pipe(take(1)).subscribe(lessons => {
      if (lessons.length === 0) {
        console.log(`[LessonsList] No lessons found`);
        return;
      }

      // Find the first unlocked, uncompleted lesson
      const nextLesson = lessons.find(l => !l.isCompleted && !l.isLocked);

      if (nextLesson) {
        this.activeLessonId = nextLesson.id;
        console.log(`[LessonsList] Found next uncompleted lesson: ${nextLesson.id}`);

        // Only scroll if this is not the first visit to the unit AND it's not the first lesson
        if (shouldScroll && nextLesson.order !== 1) {
          setTimeout(() => {
            this.scrollToLesson(nextLesson.id);

            // Add highlight after scrolling is complete
            setTimeout(() => {
              this.addHighlightToLesson(nextLesson.id);
            }, 500);
          }, 200);
        } else {
          if (nextLesson.order === 1) {
            console.log(`[LessonsList] Not scrolling to first lesson (order=1)`);
            this.resetScrollToBeginning();

            // Add brief highlight after a delay
            setTimeout(() => {
              this.addHighlightToLesson(nextLesson.id);
            }, 300);
          } else {
            console.log(`[LessonsList] First visit to unit, NOT scrolling`);
          }
        }
      } else if (lessons.length > 0) {
        // If all lessons are completed, highlight the last one
        const lastLesson = lessons[lessons.length - 1];
        this.activeLessonId = lastLesson.id;
        console.log(`[LessonsList] All lessons completed, setting active lesson: ${lastLesson.id}`);

        // Only scroll if this is not the first visit to the unit AND it's not the first lesson
        if (shouldScroll && lastLesson.order !== 1) {
          setTimeout(() => {
            this.scrollToLesson(lastLesson.id);

            // Add highlight after scrolling is complete
            setTimeout(() => {
              this.addHighlightToLesson(lastLesson.id);
            }, 500);
          }, 200);
        } else {
          if (lastLesson.order === 1) {
            console.log(`[LessonsList] Not scrolling to first lesson (order=1)`);
            this.resetScrollToBeginning();

            // Add brief highlight after a delay
            setTimeout(() => {
              this.addHighlightToLesson(lastLesson.id);
            }, 300);
          } else {
            console.log(`[LessonsList] First visit to unit, NOT scrolling`);
          }
        }
      }

      this.cdr.detectChanges();
    });
  }

  /**
   * Resets the scroll position to the beginning of the list (0)
   */
  private resetScrollToBeginning(): void {
    if (this.lessonsContainer && this.lessonsContainer.nativeElement) {
      console.log(`[LessonsList] Resetting scroll position to 0`);
      this.lessonsContainer.nativeElement.scrollLeft = 0;
    }
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

  private checkAndHandleLessonCompletion(lessonId: string) {
    console.log('[LessonsList] Starting lesson completion check for:', lessonId);

    if (this.isNavigating || this.isCompletionInProgress) {
      console.log('[LessonsList] Navigation already in progress, skipping');
      return;
    }

    // Avoid duplicate handling
    if (this.completionHandled.has(lessonId)) {
      console.log('[LessonsList] Already handled this completion, skipping');
      return;
    }

    this.completionHandled.add(lessonId); // Mark as handled
    this.isNavigating = true;
    this.isCompletionInProgress = true;

    const storageKey = `${this.courseId}_${this.unitId}_${lessonId}`;
    const progressData = this.storageService.getProgress('lesson', storageKey);
    const isFirstCompletion = !progressData?.answers?.['completion_effect_shown'];

    console.log('[LessonsList] First completion:', isFirstCompletion);

    // Save completion shown status regardless of animation
    this.storageService.saveAnswer(storageKey, 'completion_effect_shown', true, true);

    // Get lesson info for navigation decisions
    this.lessons$.pipe(take(1)).subscribe(lessons => {
      const currentIndex = lessons.findIndex(l => l.id === lessonId);
      const nextLesson = lessons[currentIndex + 1];
      const isLastLesson = currentIndex === lessons.length - 1;

      console.log('[LessonsList] Lesson ' + (currentIndex + 1) + '/' + lessons.length +
        ', has next:', !!nextLesson);

      // Clear BOTH active lesson ID and completing lesson ID to avoid any highlighting
      this.activeLessonId = null;
      this.completingLessonId = null;
      this.cdr.detectChanges();

      if (isFirstCompletion) {
        // First completion - show animation
        this.completingLessonId = lessonId;
        this.cdr.detectChanges();

        console.log('[LessonsList] Showing first-time completion animation');

        // Allow enough time for animation
        setTimeout(() => {
          this.completingLessonId = null;
          this.cdr.detectChanges();
          this.navigateAfterCompletion(lessonId, isLastLesson, nextLesson);
        }, 1500); // Match animation duration
      } else {
        // Subsequent completion - skip animation
        console.log('[LessonsList] Subsequent completion, skipping animation');

        setTimeout(() => {
          this.navigateAfterCompletion(lessonId, isLastLesson, nextLesson);
        }, 500); // Shorter delay for better experience
      }
    });
  }

  private navigateAfterCompletion(lessonId: string, isLastLesson: boolean, nextLesson?: Lesson): void {
    if (isLastLesson) {
      console.log('[LessonsList] Last lesson completed, navigating to unit completion');

      // First scroll to the last lesson so user can see the completion state
      this.scrollToLesson(lessonId);

      // Set it as active to highlight it
      this.activeLessonId = lessonId;
      this.cdr.detectChanges();

      // Navigate after a longer delay to allow the animation and scrolling to complete
      setTimeout(() => {
        this.router.navigate(['/courses', this.courseId, 'units'], {
          queryParams: {
            completedUnitId: this.unitId,
            t: Date.now() // Prevent caching
          },
          replaceUrl: true
        }).then(() => {
          console.log('[LessonsList] Navigation to units with completion successful');
          setTimeout(() => {
            this.isNavigating = false;
            this.isCompletionInProgress = false;
            this.resetCompletionState();
          }, 100);
        }).catch(err => {
          console.error('[LessonsList] Navigation failed:', err);
          this.isNavigating = false;
          this.isCompletionInProgress = false;
          this.resetCompletionState();
        });
      }, 1200); // Increased delay to match the animation timing

    } else if (nextLesson && !nextLesson.isLocked) {
      console.log('[LessonsList] Navigating to next lesson:', nextLesson.id);

      // Store the active lesson BEFORE navigation, but don't highlight it yet
      localStorage.setItem(this.activeStorageKey, nextLesson.id);
      console.log(`[LessonsList] Stored active lesson: ${nextLesson.id}`);

      // Scroll to next lesson without highlighting
      if (nextLesson.order !== 1) {
        this.scrollToLesson(nextLesson.id);
      } else {
        console.log(`[LessonsList] Next lesson is first lesson, resetting scroll position`);
        this.resetScrollToBeginning();
      }

      // Navigate after a delay
      setTimeout(() => {
        this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', nextLesson.id], {
          replaceUrl: true
        }).then(() => {
          setTimeout(() => {
            this.isNavigating = false;
            this.isCompletionInProgress = false;
            this.resetCompletionState();
          }, 100);
        });
      }, 800); // Delay to allow scrolling to complete

    } else {
      this.isNavigating = false;
      this.isCompletionInProgress = false;
      this.resetCompletionState();
    }
  }

  /**
   * Scrolls to a specific lesson card adding a highlight
   */
  private scrollToLessonWithHighlight(lessonId: string): void {
    // Wait for the DOM to update
    setTimeout(() => {
      if (!this.lessonsContainer) {
        console.log('[LessonsList] Cannot scroll, container not available');
        return;
      }

      // Find the lesson element by data attribute
      const lessonElement = this.lessonsContainer.nativeElement.querySelector(`[data-lesson-id="${lessonId}"]`);
      if (!lessonElement) {
        console.log(`[LessonsList] Cannot find lesson element with ID: ${lessonId}`);
        return;
      }

      // Find the lesson object to check if it's the first lesson
      this.lessons$.pipe(take(1)).subscribe(lessons => {
        const lesson = lessons.find(l => l.id === lessonId);

        if (lesson && lesson.order === 1) {
          // If it's the first lesson, just reset to the beginning
          console.log(`[LessonsList] Found first lesson (order=1), resetting scroll to 0`);
          this.resetScrollToBeginning();
          return;
        }

        console.log(`[LessonsList] Scrolling to lesson ${lessonId} (without highlight)`);

        // Get container dimensions
        const containerRect = this.lessonsContainer.nativeElement.getBoundingClientRect();
        const containerWidth = containerRect.width;

        // Calculate the scroll position to center the lesson
        const lessonRect = lessonElement.getBoundingClientRect();
        const lessonWidth = lessonRect.width;

        // For RTL layout, scroll calculation is different (right-to-left)
        const targetScrollLeft =
          lessonElement.offsetLeft - (containerWidth / 2) + (lessonWidth / 2);

        console.log(`[LessonsList] Target scroll position: ${targetScrollLeft}px`);

        // Scroll with smooth animation
        this.lessonsContainer.nativeElement.scrollTo({
          left: targetScrollLeft,
          behavior: 'smooth'
        });
        this.addHighlightToLesson(lessonId);
      });
    }, 100); // Short delay to ensure DOM is updated
  }

  /**
   * Scrolls to a specific lesson card with smooth animation and highlight
   */
  private scrollToLesson(lessonId: string): void {
    this.scrollToLessonWithHighlight(lessonId);

  }

  private resetCompletionState(): void {
    console.log('[LessonsList] Resetting completion state');
    this.completingLessonId = null;
    this.cdr.detectChanges();
  }

  onLessonSelected(lesson: Lesson): void {
    if (!lesson.isLocked) {
      this.activeLessonId = lesson.id;

      // Store the active lesson in localStorage
      localStorage.setItem(this.activeStorageKey, lesson.id);
      console.log(`[LessonsList] Stored active lesson before navigation: ${lesson.id}`);

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

  override ngOnDestroy(): void {
    console.log('[LessonsList] Component destroying, cleaning up');
    this.isNavigating = false;
    this.isCompletionInProgress = false;
    this.resetCompletionState();
    super.ngOnDestroy();
  }
}