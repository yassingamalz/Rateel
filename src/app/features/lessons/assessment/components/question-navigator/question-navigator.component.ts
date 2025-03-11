import { 
  Component, 
  OnInit, 
  OnDestroy, 
  ChangeDetectionStrategy, 
  ChangeDetectorRef, 
  Output, 
  EventEmitter 
} from '@angular/core';
import { Subscription, interval } from 'rxjs';
import { AssessmentQuestion } from '../../../assessment-lesson/assessment-lesson.types';
import { AssessmentService } from '../../services/assessment-service.service';

@Component({
  selector: 'app-question-navigator',
  standalone: false,
  templateUrl: './question-navigator.component.html',
  styleUrls: ['./question-navigator.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class QuestionNavigatorComponent implements OnInit, OnDestroy {
  @Output() nextQuestionClicked = new EventEmitter<void>();
  @Output() previousQuestionClicked = new EventEmitter<void>();
  @Output() finishAssessmentClicked = new EventEmitter<void>();

  currentQuestionIndex = 0;
  totalQuestions = 0;
  questions: AssessmentQuestion[] = [];
  isReviewMode = false;
  showingPulseAnimation = false; // Tracks which button should pulse
  
  private subscriptions: Subscription[] = [];

  constructor(
    public assessmentService: AssessmentService, // Changed to public for template access
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    // Alternate pulse animation between next and previous buttons
    this.subscriptions.push(
      interval(5000).subscribe(() => {
        this.showingPulseAnimation = !this.showingPulseAnimation;
        this.cdr.markForCheck();
      })
    );
    
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        const content = this.assessmentService.getContent();
        
        if (content) {
          this.currentQuestionIndex = state.currentQuestionIndex;
          this.questions = content.questions;
          this.totalQuestions = content.questions.length;
          this.isReviewMode = state.mode === 'review';
          
          this.cdr.markForCheck();
        }
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  // Progress calculation
  getProgressPercentage(): number {
    if (this.totalQuestions === 0) return 0;
    
    let answeredCount = 0;
    this.questions.forEach(question => {
      if (this.isAnswered(question.id)) {
        answeredCount++;
      }
    });
    
    return Math.round((answeredCount / this.totalQuestions) * 100);
  }

  // Navigation methods
  goToQuestion(index: number): void {
    this.assessmentService.goToQuestion(index);
  }

  nextQuestion(): void {
    this.assessmentService.goToNextQuestion();
    this.nextQuestionClicked.emit();
  }

  previousQuestion(): void {
    this.assessmentService.goToPreviousQuestion();
    this.previousQuestionClicked.emit();
  }

  finishAssessment(): void {
    this.assessmentService.finishAssessment();
    this.finishAssessmentClicked.emit();
  }

  // Helper methods
  isAnswered(questionId: string): boolean {
    return this.assessmentService.isAnswered(questionId);
  }

  getQuestionResult(questionId: string): 'correct' | 'incorrect' | 'unanswered' {
    return this.assessmentService.getQuestionResult(questionId);
  }

  isCurrentQuestion(index: number): boolean {
    return this.currentQuestionIndex === index;
  }

  isLastQuestion(): boolean {
    return this.currentQuestionIndex === this.totalQuestions - 1;
  }

  isFirstQuestion(): boolean {
    return this.currentQuestionIndex === 0;
  }
  
  // Method to determine if a question should be available to navigate to
  isQuestionUnlocked(index: number): boolean {
    // First question is always unlocked
    if (index === 0) return true;
    
    // Questions can be accessed if they're already answered
    if (index < this.questions.length && this.isAnswered(this.questions[index].id)) {
      return true;
    }
    
    // Previous question must be answered to unlock next one
    const previousIndex = index - 1;
    if (previousIndex >= 0 && previousIndex < this.questions.length) {
      return this.isAnswered(this.questions[previousIndex].id);
    }
    
    return false;
  }
}