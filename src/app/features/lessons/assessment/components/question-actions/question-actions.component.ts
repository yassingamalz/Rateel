import { 
  Component, 
  OnInit, 
  OnDestroy,
  ChangeDetectionStrategy, 
  ChangeDetectorRef, 
  Output, 
  EventEmitter,
  Input
} from '@angular/core';
import { Subscription } from 'rxjs';
import { AssessmentService } from '../../services/assessment-service.service';

@Component({
  selector: 'app-question-actions',
  standalone: false,
  templateUrl: './question-actions.component.html',
  styleUrls: ['./question-actions.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class QuestionActionsComponent implements OnInit, OnDestroy {
  @Input() questionId?: string;
  @Output() answerSubmitted = new EventEmitter<void>();

  isAnswered = false;
  isLastQuestion = false;
  canSubmit = false;
  isFirstAttempt = true;

  private subscriptions: Subscription[] = [];

  constructor(
    private assessmentService: AssessmentService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    // Check if this is a first attempt
    this.isFirstAttempt = this.assessmentService.isFirstAttemptCheck();
    
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        if (this.questionId) {
          this.isAnswered = this.assessmentService.isAnswered(this.questionId);
          
          // Check if this is the last question
          const content = this.assessmentService.getContent();
          if (content) {
            this.isLastQuestion = state.currentQuestionIndex === content.questions.length - 1;
          }
          
          // Check if user can submit an answer
          this.canSubmit = this.questionId ? 
                          this.assessmentService.canSubmitAnswer(this.questionId) : 
                          false;
                          
          this.cdr.markForCheck();
        }
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  submitAnswer(): void {
    if (this.questionId && this.canSubmit) {
      // Call the assessment service to submit the answer
      // This is where the answer submission happens and triggers the feedback
      this.assessmentService.submitAnswer(this.questionId);
      
      // Emit event to parent component to handle UI updates
      this.answerSubmitted.emit();
    }
  }

  nextQuestion(): void {
    this.assessmentService.goToNextQuestion();
  }

  finishAssessment(): void {
    this.assessmentService.finishAssessment();
  }
}