// src/app/features/lessons/assessment/components/feedback-modal/feedback-modal.component.ts
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
import { trigger, transition, style, animate, state } from '@angular/animations';
import { AssessmentQuestion } from '../../../assessment-lesson/assessment-lesson.types';
import { AssessmentService } from '../../services/assessment-service.service';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-feedback-modal',
  standalone: false,
  templateUrl: './feedback-modal.component.html',
  styleUrls: ['./feedback-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('modalAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.8)' }),
        animate('300ms cubic-bezier(0.4, 0.0, 0.2, 1)',
          style({ opacity: 1, transform: 'scale(1)' }))
      ]),
      transition(':leave', [
        animate('200ms cubic-bezier(0.4, 0.0, 0.2, 1)',
          style({ opacity: 0, transform: 'scale(0.8)' }))
      ])
    ]),
    trigger('iconBounce', [
      state('bounce', style({ transform: 'scale(1.2)' })),
      state('normal', style({ transform: 'scale(1)' })),
      transition('normal <=> bounce', animate('300ms ease-in-out'))
    ])
  ]
})
export class FeedbackModalComponent implements OnInit, OnDestroy {
  @Input() questionId?: string;
  @Output() dismissFeedback = new EventEmitter<void>();

  question?: AssessmentQuestion;
  questionResult: 'correct' | 'incorrect' | 'unanswered' = 'unanswered';
  iconState: 'normal' | 'bounce' = 'normal';
  currentStreak = 0;
  earnedPoints = 0;

  private subscriptions: Subscription[] = [];

  constructor(
    public assessmentService: AssessmentService,
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    // Get current question if not explicitly provided
    if (!this.questionId) {
      const currentQuestion = this.assessmentService.getCurrentQuestion();
      if (currentQuestion) {
        this.questionId = currentQuestion.id;
      }
    }

    if (this.questionId) {
      // Get question details
      const content = this.assessmentService.getContent();
      if (content) {
        this.question = content.questions.find(q => q.id === this.questionId);
        this.questionResult = this.assessmentService.getQuestionResult(this.questionId);
      }

      // Get streak and points
      this.currentStreak = this.assessmentService.getCurrentStreak();
      this.earnedPoints = this.questionResult === 'correct' ?
        this.assessmentService.getQuestionPoints() : 0;
    }

    // Start animation
    setTimeout(() => {
      this.iconState = 'bounce';
      this.cdr.markForCheck();

      // Reset animation after a delay
      setTimeout(() => {
        this.iconState = 'normal';
        this.cdr.markForCheck();
      }, 500);
    }, 300);
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  onDismiss(): void {
    this.dismissFeedback.emit();
    this.platformService.vibrateSuccess().catch(() => { });
  }

  getCorrectAnswerText(): string {
    if (!this.question) return '';
    return this.assessmentService.getCorrectAnswerText(this.question);
  }

  getUserAnswerText(): string {
    if (!this.questionId) return '';
    return this.assessmentService.getUserAnswerText(this.questionId);
  }
}