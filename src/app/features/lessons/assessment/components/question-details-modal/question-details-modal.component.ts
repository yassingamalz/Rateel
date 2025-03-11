// src/app/features/lessons/assessment/components/question-details-modal/question-details-modal.component.ts
import {
  Component,
  OnInit,
  OnDestroy,
  Output,
  EventEmitter,
  ChangeDetectionStrategy,
  ChangeDetectorRef
} from '@angular/core';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate, state } from '@angular/animations';
import { AssessmentQuestion } from '../../../assessment-lesson/assessment-lesson.types';
import { AssessmentService } from '../../services/assessment-service.service';

@Component({
  selector: 'app-question-details-modal',
  standalone: false,
  templateUrl: './question-details-modal.component.html',
  styleUrls: ['./question-details-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('modalAnimation', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms cubic-bezier(0.4, 0.0, 0.2, 1)',
          style({ opacity: 1 }))
      ]),
      transition(':leave', [
        animate('300ms cubic-bezier(0.4, 0.0, 0.2, 1)',
          style({ opacity: 0 }))
      ])
    ]),
    trigger('contentAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'scale(0.95)' }),
        animate('300ms cubic-bezier(0.4, 0.0, 0.2, 1)',
          style({ opacity: 1, transform: 'scale(1)' }))
      ])
    ]),
    trigger('highlightAnimation', [
      state('active', style({
        background: 'rgba(218, 165, 32, 0.2)',
        boxShadow: '0 0 8px rgba(218, 165, 32, 0.4)'
      })),
      state('inactive', style({
        background: 'rgba(0, 0, 0, 0.2)',
        boxShadow: 'none'
      })),
      transition('inactive => active', [
        animate('600ms cubic-bezier(0.4, 0.0, 0.2, 1)')
      ]),
      transition('active => inactive', [
        animate('600ms cubic-bezier(0.4, 0.0, 0.2, 1)')
      ])
    ])
  ]
})
export class QuestionDetailsModalComponent implements OnInit, OnDestroy {
  @Output() closeDetails = new EventEmitter<void>();

  questionIndex: number | null = null;
  question?: AssessmentQuestion;
  questionResult: 'correct' | 'incorrect' | 'unanswered' = 'unanswered';
  highlightState: 'active' | 'inactive' = 'inactive';

  private subscriptions: Subscription[] = [];
  private highlightTimer: any;

  constructor(
    public assessmentService: AssessmentService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    // Get the selected question index from the service
    this.questionIndex = this.assessmentService.getSelectedQuestionIndex();

    if (this.questionIndex !== null) {
      // Get question details
      const content = this.assessmentService.getContent();
      if (content && this.questionIndex < content.questions.length) {
        this.question = content.questions[this.questionIndex];

        if (this.question) {
          this.questionResult = this.assessmentService.getQuestionResult(this.question.id);
        }
      }
    }

    // Start highlight animation
    this.highlightTimer = setInterval(() => {
      this.highlightState = this.highlightState === 'active' ? 'inactive' : 'active';
      this.cdr.markForCheck();
    }, 2000);
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());

    if (this.highlightTimer) {
      clearInterval(this.highlightTimer);
    }
  }

  onClose(): void {
    this.closeDetails.emit();
  }

  getUserAnswerText(): string {
    if (!this.question) return '';
    return this.assessmentService.getUserAnswerText(this.question.id);
  }

  getCorrectAnswerText(): string {
    if (!this.question) return '';
    return this.assessmentService.getCorrectAnswerText(this.question);
  }
}