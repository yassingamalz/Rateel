// Enhanced question-actions.component.ts with better state management
import { 
  Component, 
  OnInit, 
  OnDestroy,
  ChangeDetectionStrategy, 
  ChangeDetectorRef, 
  Output, 
  EventEmitter,
  Input,
  NgZone
} from '@angular/core';
import { Subscription } from 'rxjs';
import { AssessmentService } from '../../services/assessment-service.service';

@Component({
  selector: 'app-question-actions',
  standalone: false,
  templateUrl: './question-actions.component.html',
  styleUrls: ['./question-actions.component.scss'],
  // Use Default change detection for more immediate updates
  changeDetection: ChangeDetectionStrategy.Default
})
export class QuestionActionsComponent implements OnInit, OnDestroy {
  @Input() questionId?: string;
  @Output() answerSubmitted = new EventEmitter<void>();

  isAnswered = false;
  isLastQuestion = false;
  canSubmit = false;
  isFirstAttempt = true;

  private subscriptions: Subscription[] = [];
  private checkButtonStateInterval: any;

  constructor(
    private assessmentService: AssessmentService,
    private cdr: ChangeDetectorRef,
    private ngZone: NgZone
  ) {}

  ngOnInit(): void {
    console.log(`[QuestionActions] Initializing for question: ${this.questionId}`);
    
    // Check if this is a first attempt
    this.isFirstAttempt = this.assessmentService.isFirstAttemptCheck();
    
    // Initial update
    this.updateButtonState();
    
    // Set up periodic check for button state (will run outside Angular zone)
    this.ngZone.runOutsideAngular(() => {
      this.checkButtonStateInterval = setInterval(() => {
        if (this.questionId) {
          const newState = this.assessmentService.canSubmitAnswer(this.questionId);
          if (newState !== this.canSubmit) {
            this.ngZone.run(() => {
              this.canSubmit = newState;
              console.log(`[QuestionActions] Button state updated (interval): ${this.canSubmit}`);
              this.cdr.markForCheck();
            });
          }
        }
      }, 500); // Check every 500ms
    });
    
    // Subscribe to state changes
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        if (this.questionId) {
          this.isAnswered = this.assessmentService.isAnswered(this.questionId);
          
          // Check if this is the last question
          const content = this.assessmentService.getContent();
          if (content) {
            this.isLastQuestion = state.currentQuestionIndex === content.questions.length - 1;
          }
          
          // Update button state
          this.updateButtonState();
          
          // Force change detection
          this.cdr.markForCheck();
        }
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    if (this.checkButtonStateInterval) {
      clearInterval(this.checkButtonStateInterval);
    }
  }

  submitAnswer(): void {
    console.log(`[QuestionActions] Submit button clicked, canSubmit: ${this.canSubmit}`);
    
    if (this.questionId && this.canSubmit) {
      // Call the assessment service to submit the answer
      this.assessmentService.submitAnswer(this.questionId);
      
      // Emit event to parent component
      this.answerSubmitted.emit();
      
      // Force detection
      this.cdr.markForCheck();
    }
  }

  nextQuestion(): void {
    this.assessmentService.goToNextQuestion();
  }

  finishAssessment(): void {
    this.assessmentService.finishAssessment();
  }

  // Helper method to update button state
  private updateButtonState(): void {
    if (this.questionId) {
      const previousState = this.canSubmit;
      this.canSubmit = this.assessmentService.canSubmitAnswer(this.questionId);
      
      if (previousState !== this.canSubmit) {
        console.log(`[QuestionActions] Button state changed from ${previousState} to ${this.canSubmit}`);
      }
    }
  }
}