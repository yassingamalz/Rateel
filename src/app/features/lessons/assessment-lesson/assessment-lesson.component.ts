// src/app/features/lessons/assessment-lesson/assessment-lesson.component.ts
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
import { AssessmentService } from '../assessment/services/assessment-service.service';
import { DynamicModalService } from '../../../shared/services/dynamic-modal.service';
import { FeedbackModalComponent } from '../assessment/components/feedback-modal/feedback-modal.component';

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

  // Track if dark mode is enabled
  isDarkMode = false;

  // Modal visibility states
  showCompletionModal = false;
  showDetailsModal = false;

  // Current question for feedback modal
  currentQuestion?: AssessmentQuestion;
  selectedQuestionIndex: number | null = null;

  // Dynamic modal reference
  private currentFeedbackModal: ComponentRef<FeedbackModalComponent> | null = null;

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

        // Check if feedback should be shown
        if (this.currentQuestion &&
          state.answers.has(this.currentQuestion.id) &&
          !this.assessmentService.isFeedbackDismissed()) {
          this.showFeedbackModal(this.currentQuestion.id);
          this.assessmentService.dismissFeedback();
        }

        // Trigger completion if needed
        if (state.isCompleted && !this.isCompleted && !this.isCompletionInProgress) {
          this.handleCompletion();
        }

        this.cdr.markForCheck();
      })
    );

    // Track completion animation state
    this.subscriptions.push(
      this.assessmentService.getCompletionAnimationState().subscribe(isShowing => {
        this.showCompletionModal = isShowing;
        this.cdr.markForCheck();
      })
    );

    // Track question details state
    this.subscriptions.push(
      this.assessmentService.getSelectedQuestionIndexState().subscribe(index => {
        this.selectedQuestionIndex = index;
        this.showDetailsModal = index !== null;
        this.cdr.markForCheck();
      })
    );
  }

  ngOnDestroy(): void {
    // Close any open modals
    if (this.currentFeedbackModal) {
      this.dynamicModalService.close(this.currentFeedbackModal);
    }

    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.assessmentService.resetState();
  }
  private showFeedbackModal(questionId: string): void {
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

    // Log what we're passing to help debug any issues
    console.log('[AssessmentLesson] Feedback modal data:', {
      question: question?.text?.substring(0, 30) + '...',
      result: questionResult,
      streak: currentStreak,
      points: earnedPoints,
      correctAnswer: correctAnswerText?.substring(0, 30) + '...',
      userAnswer: userAnswerText?.substring(0, 30) + '...'
    });

    // Handle dismiss event
    const instance = this.currentFeedbackModal.instance;
    instance.dismissFeedback.subscribe(() => {
      if (this.currentFeedbackModal) {
        this.dynamicModalService.close(this.currentFeedbackModal);
        this.currentFeedbackModal = null;
        this.cdr.markForCheck();
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

    // Show completion animation
    this.assessmentService.setShowCompletionAnimation(true);
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
    this.showCompletionModal = false;
    this.onComplete.emit();
    this.isCompletionInProgress = false;
    this.cdr.markForCheck();
  }

  onDetailsModalClosed(): void {
    this.assessmentService.setSelectedQuestionIndex(null);
    this.showDetailsModal = false;
    this.cdr.markForCheck();
  }

  // Helper for review mode
  showQuestionDetails(index: number): void {
    this.assessmentService.setSelectedQuestionIndex(index);
    this.showDetailsModal = true;
    this.cdr.markForCheck();
  }
}