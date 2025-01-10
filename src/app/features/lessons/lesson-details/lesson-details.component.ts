// lesson-details.component.ts
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { LessonsService } from '../lessons.service';
import { LessonState, ProgressData, StorageService } from '../../../core/services/storage.service';
import { Lesson } from '../../../shared/interfaces/lesson';
import { Subscription, BehaviorSubject } from 'rxjs';
import { TajweedVerse } from '../interactive-lesson/interactive-lesson.types';

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
          console.log('Loaded lesson:', lesson);
          this.lesson = lesson;
          
          // Add this check to ensure verses are available for practice lessons
          if (lesson?.type === 'practice' && !lesson.verses) {
            console.warn('Practice lesson has no verses, attempting to load from service');
            // Try to get verses from service if not included in lesson
            this.lesson = {
              ...lesson,
              verses: this.lessonsService.mockVerses
            };
          }

          const savedProgress = this.storageService.getProgress('lesson', this.lessonId);
          if (savedProgress) {
            this.restoreState(savedProgress);
          }

          // Initialize practice-specific state if needed
          if (this.lesson?.type === 'practice' && this.lesson.verses) {
            console.log('Initializing practice state with verses:', this.lesson.verses);
            this.initializePracticeState(this.lesson.verses);
          }

          this.cdr.markForCheck();
        },
        error: (error) => {
          console.error('Error loading lesson:', error);
        }
      });

    this.subscriptions.push(lessonSub);
  }

  // Update the practice state initialization
  private initializePracticeState(verses: TajweedVerse[]): void {
    if (!verses || verses.length === 0) {
      console.warn('No verses provided for practice state initialization');
      return;
    }

    const currentState = this.lessonState$.value;
    this.lessonState$.next({
      ...currentState,
      currentVerseIndex: currentState.currentVerseIndex || 0,
      scrollPosition: currentState.scrollPosition || 0,
    });
  }

  private restoreState(savedProgress: ProgressData): void {
    this.currentProgress$.next(savedProgress.progress);

    this.lessonState$.next({
      currentPosition: savedProgress.currentPosition || 0,
      volume: savedProgress.volume || 1,
      isMuted: savedProgress.isMuted || false,
      isFullscreen: savedProgress.isFullscreen || false,
      lastUpdated: Date.now(),
      // Restore practice-specific state
      currentVerseIndex: savedProgress.currentVerseIndex,
      scrollPosition: savedProgress.scrollPosition
    });
  }

  private saveCurrentState(): void {
    const currentState = this.lessonState$.value;
    const progress = this.currentProgress$.value;

    const stateToSave: ProgressData = {
      progress,
      timestamp: Date.now(),
      expiresAt: Date.now() + (2 * 365 * 24 * 60 * 60 * 1000), // 2 years from now
      isCompleted: progress >= 100,
      currentPosition: currentState.currentPosition,
      volume: currentState.volume,
      isMuted: currentState.isMuted,
      isFullscreen: currentState.isFullscreen,
      lastUpdated: Date.now(),
      version: '1.0.0', // Add version if required
      syncStatus: 'pending' // Add sync status
    };

    // Add practice-specific state if it's a practice lesson
    if (this.lesson?.type === 'practice') {
      stateToSave.currentVerseIndex = currentState.currentVerseIndex;
      stateToSave.scrollPosition = currentState.scrollPosition;
    }

    this.storageService.saveProgress('lesson', this.lessonId, stateToSave);
  }

  // Update restart to handle practice lessons
  restart(): void {
    const currentState = this.lessonState$.value;
    const newState = {
      ...currentState,
      currentPosition: 0,
      currentVerseIndex: 0,
      scrollPosition: 0,
      lastUpdated: Date.now()
    };

    this.lessonState$.next(newState);
    this.saveCurrentState();
    this.cdr.markForCheck();
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


  // Progress Management
  updateProgress(progress: number): void {
    this.currentProgress$.next(progress);
    this.saveCurrentState();

    if (progress >= 100 && !this.lesson?.isCompleted) {
      this.markAsCompleted();
    }

    this.cdr.markForCheck();
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

  private handleCompletion(): void {
    // Update progress bar
    this.currentProgress$.next(100);
    this.saveCurrentState();
  
    // Mark lesson as completed in service
    this.lessonsService.markLessonAsCompleted(
      this.courseId,
      this.unitId,
      this.lessonId
    ).subscribe(() => {
      // Trigger exit animation
      this.animationState = 'exit';
      
      // Navigate back after animation
      setTimeout(() => {
        this.router.navigate(['../'], { 
          relativeTo: this.route,
          queryParams: { 
            completedLessonId: this.lessonId 
          }
        });
      }, 500);
    });
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