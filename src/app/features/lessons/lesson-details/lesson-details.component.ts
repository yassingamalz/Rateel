// lesson-details.component.ts
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
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
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class LessonDetailsComponent implements OnInit, OnDestroy {
  lesson: Lesson | undefined;
  practiceQuestions: InteractiveQuestion[] = [];

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
    // Load lesson data
    const lessonSub = this.lessonsService
      .getLessonById(this.courseId, this.unitId, this.lessonId)
      .subscribe({
        next: (lesson) => {
          this.lesson = lesson;

          // Restore previous state
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
    }, 30000); // Save every 30 seconds
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
    this.saveCurrentState();
    this.router.navigate(['../../'], {
      relativeTo: this.route,
      queryParams: { returnTo: 'lessons' }
    });
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
          }
        },
        error: (error) => {
          console.error('Error marking lesson as completed:', error);
        }
      });

    this.subscriptions.push(completeSub);
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
      isPlaying: false, // This should be managed by video/audio player component
      ...this.lessonState$.value
    };
  }
}