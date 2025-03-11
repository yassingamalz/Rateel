// src/app/features/lessons/assessment-lesson/assessment-lesson.component.ts
import {
  Component,
  OnInit,
  OnDestroy,
  Input,
  Output,
  EventEmitter,
  ChangeDetectionStrategy,
  ChangeDetectorRef
} from '@angular/core';
import { Subscription } from 'rxjs';
import { PlatformService } from '../../../core/services/platform.service';
import { trigger, transition, style, animate } from '@angular/animations';
import { AssessmentQuestion } from './assessment-lesson.types';
import { AssessmentService } from '../assessment/services/assessment-service.service';

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
  showFeedbackModal = false;
  showCompletionModal = false;
  showDetailsModal = false;

  // Current question for feedback modal
  currentQuestion?: AssessmentQuestion;
  selectedQuestionIndex: number | null = null;

  private subscriptions: Subscription[] = [];
  private isCompletionInProgress = false;

  constructor(
    public assessmentService: AssessmentService,
    private platformService: PlatformService,
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
          this.showFeedbackModal = true;
        } else {
          this.showFeedbackModal = false;
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
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.assessmentService.resetState();
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
  onFeedbackDismissed(): void {
    this.assessmentService.dismissFeedback();
    this.showFeedbackModal = false;
    this.cdr.markForCheck();
  }

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