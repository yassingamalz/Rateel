import {
  Component,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Output,
  EventEmitter
} from '@angular/core';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate } from '@angular/animations';
import { AssessmentQuestion, QuestionType } from '../../../assessment-lesson/assessment-lesson.types';
import { AssessmentService } from '../../services/assessment-service.service';

@Component({
  selector: 'app-question-card',
  standalone: false,
  templateUrl: './question-card.component.html',
  styleUrls: ['./question-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('cardAnimation', [
      transition(':increment', [
        style({ transform: 'translateX(-100%)', opacity: 0 }),
        animate('400ms ease-out', style({ transform: 'translateX(0)', opacity: 1 }))
      ]),
      transition(':decrement', [
        style({ transform: 'translateX(100%)', opacity: 0 }),
        animate('400ms ease-out', style({ transform: 'translateX(0)', opacity: 1 }))
      ])
    ]),
    trigger('slideDown', [
      transition(':enter', [
        style({ opacity: 0, height: 0, overflow: 'hidden' }),
        animate('300ms ease-out', style({ opacity: 1, height: '*', overflow: 'hidden' }))
      ]),
      transition(':leave', [
        style({ overflow: 'hidden' }),
        animate('300ms ease-out', style({ opacity: 0, height: 0, overflow: 'hidden' }))
      ])
    ])
  ]
})
export class QuestionCardComponent implements OnInit, OnDestroy {
  @Output() answerSubmitted = new EventEmitter<void>();

  // Question data
  currentQuestion?: AssessmentQuestion;
  currentQuestionIndex = 0;
  QuestionType = QuestionType; // For template access

  // UI state
  showHint = false;
  textAnswer = '';

  private subscriptions: Subscription[] = [];

  constructor(
    protected assessmentService: AssessmentService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    // Subscribe to changes in the assessment state
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        this.currentQuestionIndex = state.currentQuestionIndex;

        // Get current question
        const content = this.assessmentService.getContent();
        if (content && state.currentQuestionIndex < content.questions.length) {
          this.currentQuestion = content.questions[state.currentQuestionIndex];

          // Get saved text answer if any
          if (this.currentQuestion && this.currentQuestion.type === QuestionType.TEXT_INPUT) {
            this.textAnswer = this.assessmentService.getTextAnswer(this.currentQuestion.id);
          }
        }

        this.cdr.markForCheck();
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  // Option selection methods
  onOptionSelected(questionId: string, optionId: string): void {
    if (this.isAnswered(questionId)) return;
    this.assessmentService.selectOption(questionId, optionId);
  }

  onMultipleOptionSelected(questionId: string, optionId: string, checked: boolean): void {
    if (this.isAnswered(questionId)) return;
    this.assessmentService.selectMultipleOption(questionId, optionId, checked);
  }

  onTrueFalseSelected(questionId: string, value: boolean): void {
    if (this.isAnswered(questionId)) return;
    this.assessmentService.submitTrueFalseAnswer(questionId, value);
  }

  onTextAnswerChange(questionId: string, value: string | Event): void {
    if (this.isAnswered(questionId)) return;

    // Handle both string input and Event objects
    let textValue: string;
    if (typeof value === 'string') {
      textValue = value;
    } else {
      // It's an event, so extract the value from the target
      textValue = (value.target as HTMLInputElement)?.value || '';
    }

    console.log(`[QuestionCard] Text answer changed for ${questionId}: "${textValue}"`);

    // Update local component state
    this.textAnswer = textValue;

    // Store the text input without submitting the answer
    this.assessmentService.setTextAnswer(questionId, textValue);

    // Force external updates to ensure button state is updated
    this.answerSubmitted.emit();

    // Force change detection
    this.cdr.markForCheck();
  }

  // UI interaction methods
  toggleHint(): void {
    this.showHint = !this.showHint;
    this.cdr.markForCheck();
  }

  // Helper methods
  isAnswered(questionId: string): boolean {
    return this.assessmentService.isAnswered(questionId);
  }

  isOptionSelected(questionId: string, optionId: string): boolean {
    return this.assessmentService.isOptionSelected(questionId, optionId);
  }

  isCorrectOption(question: AssessmentQuestion, optionId: string): boolean {
    return this.assessmentService.isCorrectOption(question, optionId);
  }

  isIncorrectSelectedOption(questionId: string, optionId: string): boolean {
    return this.assessmentService.isIncorrectSelectedOption(questionId, optionId);
  }

  getQuestionResult(questionId: string): 'correct' | 'incorrect' | 'unanswered' {
    return this.assessmentService.getQuestionResult(questionId);
  }

  getCorrectAnswerText(question?: AssessmentQuestion): string {
    return this.assessmentService.getCorrectAnswerText(question);
  }
}