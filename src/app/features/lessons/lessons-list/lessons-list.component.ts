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
import { ActivatedRoute, Router } from '@angular/router';
import { Observable, Subject } from 'rxjs';
import { tap, map, takeUntil, take, shareReplay } from 'rxjs/operators';
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
  }

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('courseId')!;
    this.unitId = this.route.snapshot.paramMap.get('unitId')!;
    this.lessonsService.setCurrentUnit(this.unitId);

    // Initialize lessons with proper state management
    this.lessons$ = this.lessonsService.getLessonsByUnitId(this.courseId, this.unitId).pipe(
      map(lessons => this.updateLessonsProgress(lessons)),
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
    const storageKey = `${this.courseId}_${this.unitId}_${lessonId}`;
    const progressData = this.storageService.getProgress('lesson', storageKey);

    // Trigger the completion animation before updating storage
    if (!progressData?.answers?.['completion_effect_shown']) {
      this.completedLessonAnimating = true;
      this.completingLessonId = lessonId;
      this.cdr.detectChanges();

      // Let the animation complete before continuing
      setTimeout(() => {
        this.storageService.saveAnswer(
          storageKey,
          'completion_effect_shown',
          true,
          true
        );
        
        // Keep animation active for full duration
        setTimeout(() => {
          this.completingLessonId = null;
          this.completedLessonAnimating = false;
          this.cdr.detectChanges();
          this.handleLessonNavigation(lessonId);
        }, 1500); // Match fill animation duration
      }, 100);
    } else {
      this.handleLessonNavigation(lessonId);
    }
  }

  // Update handleLessonNavigation to respect animation state
  private handleLessonNavigation(lessonId: string): void {
    if (this.completedLessonAnimating) return;
    
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
  }

  private handleLessonCompletion(lessonId: string): void {
    // Wait for animation to complete
    setTimeout(() => {
      this.completingLessonId = null;
      this.cdr.detectChanges();
      this.handleLessonNavigation(lessonId);
    }, 2500); // Match original animation duration
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
    super.ngOnDestroy();
  }
}