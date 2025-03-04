// src/app/features/lessons/assessment-lesson/assessment-lesson.component.ts
import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ViewChild,
  ElementRef
} from '@angular/core';
import { AssessmentLessonService } from './assessment-lesson.service';
import { Subscription } from 'rxjs';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { PlatformService } from '../../../core/services/platform.service';
import { AssessmentState, AssessmentContent, AssessmentQuestion, QuestionType } from './assessment-lesson.types';

@Component({
  selector: 'app-assessment-lesson',
  standalone:false,
  templateUrl: './assessment-lesson.component.html',
  styleUrls: ['./assessment-lesson.component.scss'],
  providers: [AssessmentLessonService],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('slideInOut', [
      transition(':enter', [
        style({ transform: 'translateX(100%)' }),
        animate('300ms ease-out', style({ transform: 'translateX(0)' }))
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ transform: 'translateX(100%)' }))
      ])
    ]),
    trigger('fadeInOut', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('200ms ease-in', style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('200ms ease-out', style({ opacity: 0 }))
      ])
    ])
  ]
})
export class AssessmentLessonComponent implements OnInit, OnDestroy {
  @ViewChild('questionContainer') questionContainer!: ElementRef<HTMLElement>;
  
  @Input() content?: string;
  @Input() isCompleted?: boolean;
  @Output() onProgress = new EventEmitter<number>();
  @Output() onComplete = new EventEmitter<void>();

  state!: AssessmentState;
  parsedContent?: AssessmentContent;
  currentQuestion?: AssessmentQuestion;
  QuestionType = QuestionType; // For template access
  
  private subscriptions: Subscription[] = [];
  private isCompleting = false;

  constructor(
    protected assessmentService: AssessmentLessonService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    console.log('[AssessmentLessonComponent] Initializing with content:', this.content ? 'provided' : 'missing');
    
    if (this.content) {
      try {
        this.parsedContent = this.assessmentService.parseContent(this.content);
        console.log('[AssessmentLessonComponent] Parsed content:', this.parsedContent);
        
        // Initialize assessment with content
        this.assessmentService.initializeAssessment(this.parsedContent);
      } catch (error) {
        console.error('[AssessmentLessonComponent] Error parsing content:', error);
      }
    } else {
      console.warn('[AssessmentLessonComponent] No content provided');
    }

    // Subscribe to state changes
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        this.state = state;
        this.onProgress.emit(state.progress);
        
        // Get current question for easy access
        if (this.parsedContent && state.currentQuestionIndex >= 0 && 
            state.currentQuestionIndex < this.parsedContent.questions.length) {
          this.currentQuestion = this.parsedContent.questions[state.currentQuestionIndex];
        }

        if (state.isCompleted && !this.isCompleted && !this.isCompleting) {
          this.handleCompletion();
        }
        
        this.cdr.markForCheck();
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    this.assessmentService.resetState();
  }

  private async handleCompletion(): Promise<void> {
    if (this.isCompleting) return;
    this.isCompleting = true;

    // Provide haptic feedback on mobile
    try {
      await this.platformService.vibrateSuccess();
    } catch (error) {
      console.warn('Haptic feedback not available', error);
    }

    // Emit completion event after a delay for animation
    setTimeout(() => {
      this.onComplete.emit();
      this.isCompleting = false;
    }, 1500); // Match border fill animation duration
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
    if (!this.isCompleted && this.parsedContent) {
      this.assessmentService.setCompleted();
    }
  }

  onOptionSelected(questionId: string, optionId: string): void {
    this.assessmentService.selectOption(questionId, optionId);
  }

  onMultipleOptionSelected(questionId: string, optionId: string, checked: boolean): void {
    this.assessmentService.selectMultipleOption(questionId, optionId, checked);
  }

  onTextAnswerChange(questionId: string, answer: string): void {
    this.assessmentService.submitTextAnswer(questionId, answer);
  }

  onTrueFalseSelected(questionId: string, value: boolean): void {
    this.assessmentService.submitTrueFalseAnswer(questionId, value);
  }

  submitAnswer(): void {
    if (!this.currentQuestion) return;
    
    this.assessmentService.submitAnswer(this.currentQuestion.id);
  }

  nextQuestion(): void {
    this.assessmentService.goToNextQuestion();
    
    // Scroll to top of question container
    setTimeout(() => {
      if (this.questionContainer) {
        this.questionContainer.nativeElement.scrollTop = 0;
      }
    }, 100);
  }

  previousQuestion(): void {
    this.assessmentService.goToPreviousQuestion();
    
    // Scroll to top of question container
    setTimeout(() => {
      if (this.questionContainer) {
        this.questionContainer.nativeElement.scrollTop = 0;
      }
    }, 100);
  }

  showExplanation(): void {
    this.assessmentService.toggleExplanation(true);
  }

  hideExplanation(): void {
    this.assessmentService.toggleExplanation(false);
  }
  
  finishAssessment(): void {
    this.assessmentService.finishAssessment();
  }
  
  restartAssessment(): void {
    this.assessmentService.restartAssessment();
  }
  
  // Helper methods for the template
  isAnswered(questionId: string): boolean {
    return this.state?.answers.has(questionId) || false;
  }
  
  isOptionSelected(questionId: string, optionId: string): boolean {
    const selectedOptions = this.state?.selectedOptions.get(questionId) || [];
    return selectedOptions.includes(optionId);
  }
  
  isCorrectOption(question: AssessmentQuestion, optionId: string): boolean {
    if (!question.options) return false;
    
    const option = question.options.find(opt => opt.id === optionId);
    return option?.isCorrect || false;
  }
  
  isIncorrectSelectedOption(questionId: string, optionId: string): boolean {
    if (!this.isOptionSelected(questionId, optionId)) return false;
    
    const question = this.parsedContent?.questions.find(q => q.id === questionId);
    if (!question) return false;
    
    return !this.isCorrectOption(question, optionId);
  }
  
  getQuestionResult(questionId: string): 'correct' | 'incorrect' | 'unanswered' {
    if (!this.state.answers.has(questionId)) return 'unanswered';
    
    const question = this.parsedContent?.questions.find(q => q.id === questionId);
    if (!question) return 'unanswered';
    
    const userAnswer = this.state.answers.get(questionId);
    
    if (question.type === QuestionType.MULTIPLE_CHOICE) {
      // For multiple choice, check if selected options match correct options
      const correctOptionIds = question.options
        ?.filter(opt => opt.isCorrect)
        .map(opt => opt.id) || [];
      
      const selectedOptions = this.state.selectedOptions.get(questionId) || [];
      
      // Check if arrays have the same contents (order doesn't matter)
      const isCorrect = 
        correctOptionIds.length === selectedOptions.length &&
        correctOptionIds.every(id => selectedOptions.includes(id));
      
      return isCorrect ? 'correct' : 'incorrect';
    } else if (question.type === QuestionType.SINGLE_CHOICE || 
               question.type === QuestionType.TRUE_FALSE) {
      // For single choice, direct comparison with correct answer
      return userAnswer === question.correctAnswer ? 'correct' : 'incorrect';
    } else if (question.type === QuestionType.TEXT_INPUT) {
      // For text input, compare with possible correct answers (case insensitive)
      const correctAnswers = Array.isArray(question.correctAnswer) 
        ? question.correctAnswer 
        : [question.correctAnswer || ''];
      
      const normalizedUserAnswer = String(userAnswer).toLowerCase().trim();
      const isCorrect = correctAnswers.some(ans => 
        String(ans).toLowerCase().trim() === normalizedUserAnswer
      );
      
      return isCorrect ? 'correct' : 'incorrect';
    }
    
    return 'unanswered';
  }
  
  calculateProgress(): number {
    if (!this.parsedContent) return 0;
    
    const totalQuestions = this.parsedContent.questions.length;
    if (totalQuestions === 0) return 0;
    
    const answeredQuestions = this.state.answers.size;
    return (answeredQuestions / totalQuestions) * 100;
  }
  
  calculateScore(): number {
    if (!this.parsedContent) return 0;
    
    const totalQuestions = this.parsedContent.questions.length;
    if (totalQuestions === 0) return 0;
    
    let correctAnswers = 0;
    
    this.parsedContent.questions.forEach(question => {
      const result = this.getQuestionResult(question.id);
      if (result === 'correct') {
        correctAnswers++;
      }
    });
    
    return Math.round((correctAnswers / totalQuestions) * 100);
  }
}