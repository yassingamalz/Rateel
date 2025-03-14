// Modified assessment-lesson.component.ts
import {
  Component,
  OnInit,
  OnDestroy,
  Input,
  Output,
  EventEmitter,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ComponentRef
} from '@angular/core';
import { Subscription } from 'rxjs';
import { PlatformService } from '../../../core/services/platform.service';
import { trigger, transition, style, animate } from '@angular/animations';
import { AssessmentQuestion } from './assessment-lesson.types';
import { AssessmentService, AnswerSubmittedEvent } from '../assessment/services/assessment-service.service';
import { DynamicModalService } from '../../../shared/services/dynamic-modal.service';
import { FeedbackModalComponent } from '../assessment/components/feedback-modal/feedback-modal.component';
import { CompletionModalComponent } from '../assessment/components/completion-modal/completion-modal.component';
import { QuestionDetailsModalComponent } from '../assessment/components/question-details-modal/question-details-modal.component';

@Component({
  selector: 'app-assessment-lesson',
  standalone: false,
  templateUrl: './assessment-lesson.component.html',
  styleUrls: ['./assessment-lesson.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('fadeInOut', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-in', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ opacity: 0 }))
      ])
    ])
  ],
  providers: [AssessmentService] // Provide service at component level for isolation
})
export class AssessmentLessonComponent implements OnInit, OnDestroy {
  @Input() content?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();
  @Output() modeChange = new EventEmitter<'assessment' | 'review'>();

  // Track if dark mode is enabled
  isDarkMode = false;

  // Current question for feedback modal
  currentQuestion?: AssessmentQuestion;

  // Dynamic modal references
  private currentFeedbackModal: ComponentRef<FeedbackModalComponent> | null = null;
  private currentCompletionModal: ComponentRef<CompletionModalComponent> | null = null;
  private currentDetailsModal: ComponentRef<QuestionDetailsModalComponent> | null = null;

  private currentMode: 'assessment' | 'review' = 'assessment';

  private subscriptions: Subscription[] = [];
  private isCompletionInProgress = false;

  constructor(
    public assessmentService: AssessmentService,
    private platformService: PlatformService,
    private dynamicModalService: DynamicModalService,
    protected cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    console.log('[AssessmentLessonComponent] Initializing with content:', this.content ? 'provided' : 'missing');

    if (this.content) {
      try {
        const parsedContent = this.assessmentService.parseContent(this.content);
        console.log('[AssessmentLessonComponent] Parsed content:', parsedContent);

        // Initialize assessment with content
        this.assessmentService.initializeAssessment(parsedContent);
      } catch (error) {
        console.error('[AssessmentLessonComponent] Error parsing content:', error);
      }
    } else {
      console.warn('[AssessmentLessonComponent] No content provided');
    }

    const initialState = this.assessmentService.getCurrentState();
    if (initialState.mode) {
      this.currentMode = initialState.mode;
      this.modeChange.emit(this.currentMode);
      console.log(`[AssessmentLesson] Initial mode: ${this.currentMode}`);
    }

    // Subscribe to state changes
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        this.onProgress.emit(state.progress);

        // Update current question
        if (state.currentQuestionIndex >= 0) {
          const content = this.assessmentService.getContent();
          if (content && state.currentQuestionIndex < content.questions.length) {
            this.currentQuestion = content.questions[state.currentQuestionIndex];
          }
        }

        // Trigger completion if needed
        if (state.isCompleted && !this.isCompleted && !this.isCompletionInProgress) {
          this.handleCompletion();
        }

        // Emit mode change event only when it actually changes
        if (state.mode && state.mode !== this.currentMode) {
          console.log(`[AssessmentLesson] Mode changed from ${this.currentMode} to ${state.mode}`);
          this.currentMode = state.mode;
          this.modeChange.emit(state.mode);
        }
        
        this.cdr.markForCheck();
      })
    );
    
    // Subscribe to answer submitted events for immediate feedback
    this.subscriptions.push(
      this.assessmentService.getAnswerSubmittedEvents().subscribe(event => {
        this.handleAnswerSubmitted(event);
      })
    );

    // Track completion animation state
    this.subscriptions.push(
      this.assessmentService.getCompletionAnimationState().subscribe(isShowing => {
        if (isShowing) {
          this.showCompletionModal();
        } else if (this.currentCompletionModal) {
          this.dynamicModalService.close(this.currentCompletionModal);
          this.currentCompletionModal = null;
        }
        this.cdr.markForCheck();
      })
    );

    // Track question details state
    this.subscriptions.push(
      this.assessmentService.getSelectedQuestionIndexState().subscribe(index => {
        if (index !== null) {
          this.showQuestionDetailsModal(index);
        } else if (this.currentDetailsModal) {
          this.dynamicModalService.close(this.currentDetailsModal);
          this.currentDetailsModal = null;
        }
        this.cdr.markForCheck();
      })
    );
  }

  ngOnDestroy(): void {
    // Close any open modals
    if (this.currentFeedbackModal) {
      this.dynamicModalService.close(this.currentFeedbackModal);
    }
    
    if (this.currentCompletionModal) {
      this.dynamicModalService.close(this.currentCompletionModal);
    }
    
    if (this.currentDetailsModal) {
      this.dynamicModalService.close(this.currentDetailsModal);
    }

    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.assessmentService.resetState();
  }
  
  // New handler for answer submitted events
  private handleAnswerSubmitted(event: AnswerSubmittedEvent): void {
    // Skip feedback for non-first attempts
    if (!this.assessmentService.isFirstAttemptCheck()) {
      console.log('[AssessmentLesson] Skipping feedback for repeat attempt');
      return;
    }
    
    console.log(`[AssessmentLesson] Answer submitted: ${event.questionId}, result: ${event.result}, isLast: ${event.isLastQuestion}`);
    
    // Get question details
    const content = this.assessmentService.getContent();
    if (!content) return;
    
    const question = content.questions.find(q => q.id === event.questionId);
    if (!question) return;
    
    // Show feedback immediately
    this.showFeedbackModal(event.questionId);
  }

  private showFeedbackModal(questionId: string): void {
    // Skip feedback for repeat attempts
    if (!this.assessmentService.isFirstAttemptCheck()) {
      return;
    }
    
    // Close any existing modal first
    if (this.currentFeedbackModal) {
      this.dynamicModalService.close(this.currentFeedbackModal);
      this.currentFeedbackModal = null;
    }

    console.log('[AssessmentLesson] Opening feedback modal for question:', questionId);

    // Get complete question details and prepare all required data
    const content = this.assessmentService.getContent();
    const question = content?.questions.find(q => q.id === questionId);

    if (!question) {
      console.error('[AssessmentLesson] Could not find question with id:', questionId);
      return;
    }

    // Get all the data needed for the modal
    const questionResult = this.assessmentService.getQuestionResult(questionId);
    const currentStreak = this.assessmentService.getCurrentStreak();
    const earnedPoints = questionResult === 'correct' ?
      this.assessmentService.getQuestionPoints() : 0;
    const correctAnswerText = this.assessmentService.getCorrectAnswerText(question);
    const userAnswerText = this.assessmentService.getUserAnswerText(questionId);

    // Create the modal component with all necessary data
    this.currentFeedbackModal = this.dynamicModalService.open(FeedbackModalComponent, {
      questionId,
      question,
      questionResult,
      currentStreak,
      earnedPoints,
      correctAnswerText,
      userAnswerText
    });

    // Handle dismiss event
    const instance = this.currentFeedbackModal.instance;
    instance.dismissFeedback.subscribe(() => {
      if (this.currentFeedbackModal) {
        this.dynamicModalService.close(this.currentFeedbackModal);
        this.currentFeedbackModal = null;
        this.assessmentService.dismissFeedback();
        this.cdr.markForCheck();
      }
    });
  }

  private showCompletionModal(): void {
    // Close existing modal if open
    if (this.currentCompletionModal) {
      this.dynamicModalService.close(this.currentCompletionModal);
    }

    // Create completion modal
    this.currentCompletionModal = this.dynamicModalService.open(CompletionModalComponent);
    
    // Set up props and event handling
    const instance = this.currentCompletionModal.instance;
    
    // Pass necessary data from assessmentService
    const state = this.assessmentService.getCurrentState();
    instance.score = state.score;
    instance.totalPoints = this.assessmentService.getTotalPoints();
    
    // Get passing score from content
    const content = this.assessmentService.getContent();
    if (content?.passingScore) {
      instance.passingScore = content.passingScore;
    }
    
    instance.isPassed = state.score >= instance.passingScore;
    
    // Handle completion event
    instance.completed.subscribe(() => {
      if (this.currentCompletionModal) {
        this.dynamicModalService.close(this.currentCompletionModal);
        this.currentCompletionModal = null;
        this.onCompletionClosed();
      }
    });
  }

  private showQuestionDetailsModal(index: number): void {
    // Close existing modal if open
    if (this.currentDetailsModal) {
      this.dynamicModalService.close(this.currentDetailsModal);
    }

    // Get question data
    const content = this.assessmentService.getContent();
    if (!content || index >= content.questions.length) {
      console.error('[AssessmentLesson] Invalid question index:', index);
      return;
    }

    const question = content.questions[index];
    const questionResult = this.assessmentService.getQuestionResult(question.id);

    // Create modal
    this.currentDetailsModal = this.dynamicModalService.open(QuestionDetailsModalComponent);
    
    // Set up props and event handling
    const instance = this.currentDetailsModal.instance;
    instance.question = question;
    instance.questionIndex = index;
    instance.questionResult = questionResult;
    
    // Handle close event
    instance.closeDetails.subscribe(() => {
      if (this.currentDetailsModal) {
        this.dynamicModalService.close(this.currentDetailsModal);
        this.currentDetailsModal = null;
        this.onDetailsModalClosed();
      }
    });
  }

  private async handleCompletion(): Promise<void> {
    if (this.isCompletionInProgress) return;
    this.isCompletionInProgress = true;

    // Provide haptic feedback on mobile
    try {
      await this.platformService.vibrateSuccess();
    } catch (error) {
      console.warn('Haptic feedback not available', error);
    }

    // Show completion animation only on first completion
    if (this.assessmentService.isFirstAttemptCheck()) {
      this.assessmentService.setShowCompletionAnimation(true);
    } else {
      // For repeat attempts, just complete without animation
      this.onComplete.emit();
    }
    
    this.cdr.markForCheck();
  }

  handleSkip(): void {
    console.log("[AssessmentLessonComponent] Skip button clicked, isCompleted:", this.isCompleted);

    // Always emit completion event immediately for any click
    this.onComplete.emit();

    // Add haptic feedback
    this.platformService.vibrateSuccess().catch(() => {
      // Ignore errors if vibration is not available
    });

    // If not already completed, also mark as completed
    if (!this.isCompleted) {
      this.assessmentService.setCompleted();
    }
  }

  toggleTheme(): void {
    this.isDarkMode = !this.isDarkMode;
    this.cdr.markForCheck();
  }

  // Event handlers for child components
  onCompletionClosed(): void {
    this.assessmentService.setShowCompletionAnimation(false);
    this.onComplete.emit();
    this.isCompletionInProgress = false;
    this.cdr.markForCheck();
  }

  onDetailsModalClosed(): void {
    this.assessmentService.setSelectedQuestionIndex(null);
    this.cdr.markForCheck();
  }

  // Helper for review mode
  showQuestionDetails(index: number): void {
    this.assessmentService.setSelectedQuestionIndex(index);
    this.cdr.markForCheck();
  }
}