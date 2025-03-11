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
import { AssessmentService } from '../../services/assessment-service.service';
import { AssessmentContent } from '../../../assessment-lesson/assessment-lesson.types';

@Component({
  selector: 'app-assessment-results',
  standalone: false,
  templateUrl: './assessment-results.component.html',
  styleUrls: ['./assessment-results.component.scss'],
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
    ]),
    trigger('scaleIn', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.8)' }),
        animate('400ms ease-out', style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ])
  ]
})
export class AssessmentResultsComponent implements OnInit, OnDestroy {
  @Output() questionDetailsRequested = new EventEmitter<number>();
  @Output() restartRequested = new EventEmitter<void>();
  @Output() completeRequested = new EventEmitter<void>();

  content?: AssessmentContent;
  score = 0;
  passingScore = 60;
  correctAnswers = 0;
  incorrectAnswers = 0;
  totalPoints = 0;
  recommendations: string[] = [];

  private subscriptions: Subscription[] = [];

  constructor(
    public assessmentService: AssessmentService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    this.subscriptions.push(
      this.assessmentService.getState().subscribe(state => {
        this.score = state.score;

        // Get content 
        this.content = this.assessmentService.getContent();
        if (this.content?.passingScore) {
          this.passingScore = this.content.passingScore;
        }

        // Get stats
        this.correctAnswers = this.assessmentService.getCorrectAnswersCount();
        this.incorrectAnswers = this.assessmentService.getIncorrectAnswersCount();
        this.totalPoints = this.assessmentService.getTotalPoints();

        // Get recommendations
        this.recommendations = this.assessmentService.getRecommendations();

        this.cdr.markForCheck();
      })
    );
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  showQuestionDetails(index: number): void {
    this.questionDetailsRequested.emit(index);
  }

  restart(): void {
    this.restartRequested.emit();
  }

  complete(): void {
    this.completeRequested.emit();
  }

  getQuestionResult(questionId: string): 'correct' | 'incorrect' | 'unanswered' {
    return this.assessmentService.getQuestionResult(questionId);
  }

  isPassed(): boolean {
    return this.score >= this.passingScore;
  }

  getScoreCircleValue(): string {
    // Circle circumference is 2πr = 2 * π * 45 ≈ 283
    const circumference = 283;
    const value = (this.score / 100) * circumference;
    return `${value}, ${circumference}`;
  }
}