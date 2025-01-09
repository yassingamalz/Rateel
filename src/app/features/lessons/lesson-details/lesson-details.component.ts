// lesson-details.component.ts
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { LessonsService } from '../lessons.service';
import { LessonState, ProgressData, StorageService } from '../../../core/services/storage.service';
import { Lesson } from '../../../shared/interfaces/lesson';
import { InteractiveQuestion } from '../interactive-lesson/interactive-lesson.types';
import { Subscription, BehaviorSubject } from 'rxjs';

@Component({
  selector: 'app-lesson-details',
  standalone: false,
  templateUrl: './lesson-details.component.html',
  styleUrls: ['./lesson-details.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('slideDown', [
      state('void', style({
        transform: 'translateY(-100%)'
      })),
      state('*', style({
        transform: 'translateY(0)'
      })),
      state('exit', style({
        transform: 'translateX(100%)' // Changed to slide right for PowerPoint style
      })),
      transition('* => exit', animate('500ms ease-in')),
      transition('void => *', animate('500ms ease-out'))
    ])
  ]
})
export class LessonDetailsComponent implements OnInit, OnDestroy {
  lesson: Lesson | undefined;
  practiceQuestions: InteractiveQuestion[] = [];
  animationState: string = '*';

  // State management
  currentProgress$ = new BehaviorSubject<number>(0);
  lessonState$ = new BehaviorSubject<LessonState>({
    currentPosition: 0,
    isFullscreen: false,
    lastUpdated: Date.now()
  });

  isMenuOpen = false;

  private courseId: string;
  private unitId: string;
  private lessonId: string;
  private autoSaveInterval: any;
  private subscriptions: Subscription[] = [];

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private lessonsService: LessonsService,
    private storageService: StorageService,
    private cdr: ChangeDetectorRef,
  ) {
    this.courseId = this.route.snapshot.paramMap.get('courseId') || '';
    this.unitId = this.route.snapshot.paramMap.get('unitId') || '';
    this.lessonId = this.route.snapshot.paramMap.get('lessonId') || '';
  }

  ngOnInit(): void {
    this.initializeLesson();
    this.setupAutoSave();
  }

  ngOnDestroy(): void {
    this.clearAutoSave();
    this.saveCurrentState();
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  // Getters for template
  get currentProgress(): number {
    return this.currentProgress$.value;
  }

  get isPlaying(): boolean {
    return this.getPlayerState()?.isPlaying || false;
  }

  private initializeLesson(): void {
    const lessonSub = this.lessonsService
      .getLessonById(this.courseId, this.unitId, this.lessonId)
      .subscribe({
        next: (lesson) => {
          this.lesson = lesson;
          const savedProgress = this.storageService.getProgress('lesson', this.lessonId);
          if (savedProgress) {
            this.restoreState(savedProgress);
          }
          this.cdr.markForCheck();
        },
        error: (error) => {
          console.error('Error loading lesson:', error);
        }
      });

    this.subscriptions.push(lessonSub);
  }

  private restoreState(savedProgress: ProgressData): void {
    this.currentProgress$.next(savedProgress.progress);

    this.lessonState$.next({
      currentPosition: savedProgress.currentPosition || 0,
      volume: savedProgress.volume || 1,
      isMuted: savedProgress.isMuted || false,
      isFullscreen: savedProgress.isFullscreen || false,
      lastUpdated: Date.now()
    });
  }

  // Playback Controls
  togglePlayback(): void {
    const currentState = this.lessonState$.value;
    const newState = {
      ...currentState,
      isPlaying: !this.isPlaying,
      lastUpdated: Date.now()
    };

    this.lessonState$.next(newState);
    this.saveCurrentState();
    this.cdr.markForCheck();
  }

  toggleMute(): void {
    const currentState = this.lessonState$.value;
    const newState = {
      ...currentState,
      isMuted: !currentState.isMuted,
      lastUpdated: Date.now()
    };

    this.lessonState$.next(newState);
    this.saveCurrentState();
    this.cdr.markForCheck();
  }

  setVolume(value: number): void {
    const currentState = this.lessonState$.value;
    const newState = {
      ...currentState,
      volume: Math.max(0, Math.min(1, value)),
      lastUpdated: Date.now()
    };

    this.lessonState$.next(newState);
    this.saveCurrentState();
    this.cdr.markForCheck();
  }

  restart(): void {
    const currentState = this.lessonState$.value;
    const newState = {
      ...currentState,
      currentPosition: 0,
      lastUpdated: Date.now()
    };

    this.lessonState$.next(newState);
    this.saveCurrentState();
    this.cdr.markForCheck();
  }

  // Progress Management
  updateProgress(progress: number): void {
    this.currentProgress$.next(progress);
    this.saveCurrentState();

    if (progress >= 100 && !this.lesson?.isCompleted) {
      this.markAsCompleted();
    }

    this.cdr.markForCheck();
  }

  private saveCurrentState(): void {
    const currentState = this.lessonState$.value;
    const progress = this.currentProgress$.value;

    this.storageService.saveProgress('lesson', this.lessonId, {
      progress,
      currentPosition: currentState.currentPosition,
      volume: currentState.volume,
      isMuted: currentState.isMuted,
      isFullscreen: currentState.isFullscreen,
      lastUpdated: Date.now()
    });
  }

  private setupAutoSave(): void {
    this.autoSaveInterval = setInterval(() => {
      this.saveCurrentState();
    }, 30000); // Auto save every 30 seconds
  }

  private clearAutoSave(): void {
    if (this.autoSaveInterval) {
      clearInterval(this.autoSaveInterval);
    }
  }

  // Menu Controls
  toggleMenu(): void {
    this.isMenuOpen = !this.isMenuOpen;
    this.cdr.markForCheck();
  }

  // Navigation
  onNavigateBack(): void {
    this.animationState = 'exit';
    this.saveCurrentState();
    
    setTimeout(() => {
      // Navigate to the lessons list by removing the lesson ID from the path
      this.router.navigate(['../'], {
        relativeTo: this.route,
        queryParams: { returnTo: 'lessons' }
      });
    }, 500); // Match animation duration
  }

  // Completion
  markAsCompleted(): void {
    if (this.lesson?.isCompleted) return;

    const completeSub = this.lessonsService
      .markLessonAsCompleted(this.courseId, this.unitId, this.lessonId)
      .subscribe({
        next: () => {
          if (this.lesson) {
            this.lesson.isCompleted = true;
            this.updateProgress(100);
            this.handleCompletion();
          }
        },
        error: (error) => {
          console.error('Error marking lesson as completed:', error);
        }
      });

    this.subscriptions.push(completeSub);
  }

  // Handle completion animation and navigation with PowerPoint-style exit
  private handleCompletion(): void {
    // Ensure progress is at 100%
    this.currentProgress$.next(100);
    this.saveCurrentState();
    
    // Trigger exit animation - slide to right
    this.animationState = 'exit';
    
    // Wait for animation to complete before navigation
    setTimeout(() => {
      this.router.navigate(['../'], {
        relativeTo: this.route,
        queryParams: { returnTo: 'lessons' }
      });
    }, 500); // Match animation duration
  }

  // Handle practice answers
  handleAnswer(event: { questionId: string; answer: any; isCorrect: boolean }): void {
    this.storageService.saveAnswer(
      this.lessonId,
      event.questionId,
      event.answer,
      event.isCorrect
    );
  }

  private getPlayerState() {
    return {
      isPlaying: false,
      ...this.lessonState$.value
    };
  }
}