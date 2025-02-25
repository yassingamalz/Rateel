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

  completedLessonAnimating = false;
  lessons$!: Observable<Lesson[]>;
  courseId!: string;
  unitId!: string;
  activeLessonId: string | null = null;
  completingLessonId: string | null = null;
  private isNavigating = false;
  private totalLessons = 0;
  private navigationTimeout: any = null;

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
    });
  }

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitId = this.route.snapshot.paramMap.get('unitId')!;
    this.lessonsService.setCurrentUnit(this.unitId);

    // Clear any stuck navigation state
    window.localStorage.removeItem('lastNavigationTime');
    this.isNavigating = false;

    // Initialize lessons with proper state management
    this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId).pipe(
      map(lessons => {
        this.totalLessons = lessons.length;
        return this.updateLessonsProgress(lessons);
      }),
      tap(() => {
        const params = this.route.snapshot.queryParams;
        if (params['completedLessonId']) {
          this.checkAndHandleLessonCompletion(params['completedLessonId']);
        }
      }),
      shareReplay(1)
    );

    this.route.queryParams.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      if (params['completedLessonId']) {
        this.checkAndHandleLessonCompletion(params['completedLessonId']);
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
    console.log('[LessonsList] Current navigating state:', this.isNavigating);
    
    // Reset navigation state if it's been more than 5 seconds
    this.clearStuckNavigationState();

    if (this.isNavigating) {
      console.log('[LessonsList] Navigation already in progress, skipping');
      return;
    }
    
    this.isNavigating = true;
    localStorage.setItem('lastNavigationTime', Date.now().toString());
    
    const storageKey = `${this.courseId}_${this.unitId}_${lessonId}`;
    const progressData = this.storageService.getProgress('lesson', storageKey);
    const isFirstCompletion = !progressData?.answers?.['completion_effect_shown'];

    console.log('[LessonsList] First completion:', isFirstCompletion);
    console.log('[LessonsList] Current completing lessonId:', this.completingLessonId);
    console.log('[LessonsList] Total lessons in unit:', this.totalLessons);

    // Skip if already handling completion
    if (this.completingLessonId === lessonId) {
      console.log('[LessonsList] Already handling completion for this lesson');
      return;
    }

    // Mark that we've shown the completion effect
    if (isFirstCompletion) {
      this.storageService.saveAnswer(
        storageKey,
        'completion_effect_shown',
        true,
        true
      );
      
      // Show animation only for first completion
      this.completingLessonId = lessonId;
      this.cdr.detectChanges();

      setTimeout(() => {
        console.log('[LessonsList] Completion animation started');
        
        // Wait for animation then navigate
        setTimeout(() => {
          console.log('[LessonsList] Completion animation finished, preparing navigation');
          this.completingLessonId = null;
          this.cdr.detectChanges();
          this.handleLessonNavigation(lessonId);
        }, 1500); // Animation duration
      }, 100);
    } else {
      // Skip animation for subsequent completions
      console.log('[LessonsList] Skipping animation for subsequent completion');
      this.handleLessonNavigation(lessonId);
    }
  }

  private clearStuckNavigationState() {
    const lastNavTime = localStorage.getItem('lastNavigationTime');
    const currentTime = Date.now();
    if (lastNavTime && (currentTime - parseInt(lastNavTime)) > 5000) {
      console.log('[LessonsList] Resetting stuck navigation state');
      this.isNavigating = false;
      localStorage.removeItem('lastNavigationTime');
    }
    
    // Clear any existing timeout
    if (this.navigationTimeout) {
      clearTimeout(this.navigationTimeout);
      this.navigationTimeout = null;
    }
  }

  private handleLessonNavigation(lessonId: string): void {
    console.log('[LessonsList] Handling lesson navigation for:', lessonId);

    this.lessons$.pipe(take(1)).subscribe(lessons => {
      const currentIndex = lessons.findIndex(l => l.id === lessonId);
      const isLastLesson = currentIndex === lessons.length - 1;
      const nextLesson = lessons[currentIndex + 1];
      const isSingleLessonUnit = lessons.length === 1;

      console.log('[LessonsList] Current lesson index:', currentIndex);
      console.log('[LessonsList] Is last lesson:', isLastLesson);
      console.log('[LessonsList] Is single lesson unit:', isSingleLessonUnit);
      console.log('[LessonsList] Next lesson:', nextLesson);

      // For single lesson unit or last lesson, handle differently
      if (isSingleLessonUnit || isLastLesson) {
        console.log('[LessonsList] This is a single lesson unit or last lesson in unit');
        this.navigateAfterUnitCompletion();
      } else if (nextLesson && !nextLesson.isLocked) {
        console.log('[LessonsList] Navigating to next lesson:', nextLesson.id);
        // Navigate to next lesson directly
        this.router.navigate(['/courses', this.courseId, 'units', this.unitId, 'lessons', nextLesson.id], {
          replaceUrl: true
        }).then(() => {
          console.log('[LessonsList] Navigation to next lesson complete');
          this.finishNavigation();
        });
      } else {
        // If there's no valid navigation target, release the lock
        console.log('[LessonsList] No valid navigation target, releasing lock');
        this.finishNavigation();
      }
    });
  }

  private navigateAfterUnitCompletion(): void {
    // Try to get next unit in the course
    this.unitsService.getUnitsByCourseId(this.courseId).pipe(take(1)).subscribe(units => {
      const currentUnit = units.find(u => u.id === this.unitId);
      const nextUnit = units.find(u => !u.isLocked && u.order === (currentUnit?.order || 0) + 1);
      
      if (nextUnit) {
        console.log('[LessonsList] Found next unit:', nextUnit.id);
        // Navigate to next unit
        this.router.navigate(['/courses', this.courseId, 'units'], {
          queryParams: { 
            completedUnitId: this.unitId,
            nextUnitId: nextUnit.id
          },
          replaceUrl: true
        }).then(() => {
          console.log('[LessonsList] Navigation to units list with next unit complete');
          this.finishNavigation();
        });
      } else {
        console.log('[LessonsList] No next unit found, navigating to units list');
        // No next unit, navigate back to units list
        this.router.navigate(['/courses', this.courseId, 'units'], {
          queryParams: { completedUnitId: this.unitId },
          replaceUrl: true
        }).then(() => {
          console.log('[LessonsList] Navigation to units list complete');
          this.finishNavigation();
        });
      }
    });
  }

  private finishNavigation(): void {
    // Release the navigation lock with a short delay
    this.navigationTimeout = setTimeout(() => {
      this.isNavigating = false;
      localStorage.removeItem('lastNavigationTime');
      console.log('[LessonsList] Navigation lock released');
      this.navigationTimeout = null;
    }, 300);
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

  override ngOnDestroy(): void {
    console.log('[LessonsList] Component destroying, cleaning up');
    this.isNavigating = false;
    localStorage.removeItem('lastNavigationTime');
    this.completingLessonId = null;
    
    if (this.navigationTimeout) {
      clearTimeout(this.navigationTimeout);
      this.navigationTimeout = null;
    }
    
    super.ngOnDestroy();
  }
}