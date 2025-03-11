//feedback-modal.component.ts
import {
  Component,
  OnInit,
  OnDestroy,
  Input,
  Output,
  EventEmitter,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  ElementRef,
  AfterViewInit,
  Renderer2,
  HostListener
} from '@angular/core';
import { AssessmentQuestion } from '../../../assessment-lesson/assessment-lesson.types';
import { PlatformService } from '../../../../../core/services/platform.service';

@Component({
  selector: 'app-feedback-modal',
  standalone: false,
  templateUrl: './feedback-modal.component.html',
  styleUrls: ['./feedback-modal.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class FeedbackModalComponent implements OnInit, OnDestroy, AfterViewInit {
  // Inputs directly from parent
  @Input() questionId!: string;
  @Input() question?: AssessmentQuestion;
  @Input() questionResult: 'correct' | 'incorrect' | 'unanswered' = 'unanswered';
  @Input() currentStreak = 0;
  @Input() earnedPoints = 0;
  @Input() correctAnswerText = '';
  @Input() userAnswerText = '';

  @Output() dismissFeedback = new EventEmitter<void>();

  // Animation states
  iconBounceState = false;
  isLandscape = window.innerWidth > window.innerHeight;

  // Timers
  private autoDismissTimer?: any;
  private iconBounceTimer?: any;
  private orientationCheckTimer?: any;

  constructor(
    private platformService: PlatformService,
    private cdr: ChangeDetectorRef,
    private renderer: Renderer2,
    private elementRef: ElementRef
  ) { }

  // Track orientation changes
  @HostListener('window:resize')
  onResize() {
    const wasLandscape = this.isLandscape;
    this.isLandscape = window.innerWidth > window.innerHeight;

    // If orientation changed, force change detection
    if (wasLandscape !== this.isLandscape) {
      this.cdr.markForCheck();
    }
  }

  ngOnInit(): void {
    console.log('[FeedbackModal] Initializing with data:', {
      questionId: this.questionId,
      question: this.question,
      result: this.questionResult,
      streak: this.currentStreak,
      points: this.earnedPoints,
      isLandscape: this.isLandscape
    });

    // Start periodic orientation check to handle device rotation
    this.orientationCheckTimer = setInterval(() => {
      const newIsLandscape = window.innerWidth > window.innerHeight;
      if (this.isLandscape !== newIsLandscape) {
        this.isLandscape = newIsLandscape;
        this.cdr.markForCheck();
      }
    }, 300);

    // Trigger icon bounce animation after a short delay
    this.startIconBounceAnimation();

    // Add haptic feedback based on result
    if (this.questionResult === 'correct') {
      this.platformService.vibrateSuccess().catch(() => { });
    } else {
      this.platformService.vibrateWarning().catch(() => { });
    }
  }

  ngAfterViewInit(): void {
    // Add confetti for correct answers
    if (this.questionResult === 'correct') {
      this.createConfetti();
    }
  }

  ngOnDestroy(): void {
    // Clean up all timers
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer);
    }

    if (this.iconBounceTimer) {
      clearTimeout(this.iconBounceTimer);
    }

    if (this.orientationCheckTimer) {
      clearInterval(this.orientationCheckTimer);
    }
  }

  onDismiss(): void {
    // Play haptic feedback
    this.platformService.vibrateSuccess().catch(() => { });
    this.dismissFeedback.emit();
  }

  // Methods for animations
  private startIconBounceAnimation(): void {
    // Start with a bounce
    this.iconBounceState = true;
    this.cdr.markForCheck();

    // Reset after 300ms
    this.iconBounceTimer = setTimeout(() => {
      this.iconBounceState = false;
      this.cdr.markForCheck();

      // Add another bounce after 1s (only for correct answers)
      if (this.questionResult === 'correct') {
        this.iconBounceTimer = setTimeout(() => {
          this.iconBounceState = true;
          this.cdr.markForCheck();

          // And reset again
          this.iconBounceTimer = setTimeout(() => {
            this.iconBounceState = false;
            this.cdr.markForCheck();
          }, 300);
        }, 1000);
      }
    }, 300);
  }

  private createConfetti(): void {
    // Get confetti container element
    const container = this.elementRef.nativeElement.querySelector('.confetti-container');
    if (!container) return;

    // Confetti colors based on theme 
    const colors = [
      '#DAA520', '#FFD700', '#FCC200', // Golds
      '#D4AF37', '#1F4037', '#2D6A4F'  // Greens
    ];

    // Create fewer confetti pieces for better performance
    const pieceCount = this.isLandscape ? 30 : 50;
    const shapes = ['square', 'triangle', 'circle'];

    for (let i = 0; i < pieceCount; i++) {
      // Create confetti piece
      const piece = this.renderer.createElement('div');
      this.renderer.addClass(piece, 'confetti');

      // Add random shape
      const shape = shapes[Math.floor(Math.random() * shapes.length)];
      this.renderer.addClass(piece, shape);

      // Set random position
      const left = Math.random() * 100;
      this.renderer.setStyle(piece, 'left', `${left}%`);

      // Set random delay (shorter in landscape for better performance)
      const delay = Math.random() * (this.isLandscape ? 1 : 1.5);
      this.renderer.setStyle(piece, 'animation-delay', `${delay}s`);

      // Set random size (smaller in landscape)
      const size = 5 + Math.random() * (this.isLandscape ? 8 : 10);
      this.renderer.setStyle(piece, 'width', `${size}px`);
      this.renderer.setStyle(piece, 'height', `${size}px`);

      // Set random rotation
      const rotation = Math.random() * 360;
      this.renderer.setStyle(piece, 'transform', `rotate(${rotation}deg)`);

      // Set random color
      const color = colors[Math.floor(Math.random() * colors.length)];
      this.renderer.setStyle(piece, 'background-color', color);

      // Add to container
      this.renderer.appendChild(container, piece);
    }
  }
}