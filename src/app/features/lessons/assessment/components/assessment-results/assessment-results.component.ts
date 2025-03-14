import {
  Component,
  OnInit,
  OnDestroy,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Output,
  EventEmitter,
  AfterViewInit,
  ElementRef,
  Inject,
  Optional
} from '@angular/core';
import { Subscription } from 'rxjs';
import { trigger, transition, style, animate } from '@angular/animations';
import { AssessmentService } from '../../services/assessment-service.service';
import { AssessmentContent } from '../../../assessment-lesson/assessment-lesson.types';
import { PlatformService } from '../../../../../core/services/platform.service';

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
export class AssessmentResultsComponent implements OnInit, OnDestroy, AfterViewInit {
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
  isFirstAttempt = true;

  private subscriptions: Subscription[] = [];

  constructor(
    public assessmentService: AssessmentService,
    private cdr: ChangeDetectorRef,
    private elementRef: ElementRef,
    @Optional() private platformService?: PlatformService // Optional injection
  ) { }

  ngOnInit(): void {
    // Check if this is a first attempt
    this.isFirstAttempt = this.assessmentService.isFirstAttemptCheck();

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
    console.log('[AssessmentResults] User clicked complete button, emitting completion event');
    
    // If this is the first attempt, show a haptic feedback
    if (this.isFirstAttempt && this.platformService) {
      // Safely use the platform service if it's available
      try {
        this.platformService.vibrateSuccess().catch(err => {
          console.log('Haptic feedback failed:', err);
        });
      } catch (e) {
        console.log('Haptic feedback not available');
      }
    }
    
    // Small delay to allow any animation or feedback to register
    setTimeout(() => {
      this.completeRequested.emit();
    }, 100);
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

  ngAfterViewInit() {
    // Get scrollable elements
    const questionsList = this.elementRef.nativeElement.querySelector('.questions-summary');
    const recommendationsList = this.elementRef.nativeElement.querySelector('.recommendations-list');

    // Add scroll event listeners
    this.addScrollIndicator(questionsList, '.results-breakdown');
    this.addScrollIndicator(recommendationsList, '.recommendations-section');
  }

  private addScrollIndicator(element: HTMLElement, parentSelector: string) {
    if (!element) return;

    const parent = this.elementRef.nativeElement.querySelector(parentSelector);
    if (!parent) return;

    element.addEventListener('scroll', () => {
      // Check if scrolled to the bottom
      const isAtBottom =
        element.scrollHeight - element.scrollTop <= element.clientHeight + 1; // +1 for potential rounding issues

      const canScrollDown = element.scrollHeight > element.clientHeight && !isAtBottom;

      if (canScrollDown) {
        parent.classList.add('can-scroll-down');
      } else {
        parent.classList.remove('can-scroll-down');
      }
    });

    // Initial check
    const canScrollDown = element.scrollHeight > element.clientHeight;
    if (canScrollDown) {
      parent.classList.add('can-scroll-down');
    }
  }
}