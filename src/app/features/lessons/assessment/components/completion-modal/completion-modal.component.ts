// src/app/features/lessons/assessment/components/completion-modal/completion-modal.component.ts
import {
  Component,
  OnInit,
  OnDestroy,
  Output,
  EventEmitter,
  ChangeDetectionStrategy,
  ChangeDetectorRef
} from '@angular/core';
import { trigger, transition, style, animate, stagger, query } from '@angular/animations';
import { Subscription } from 'rxjs';
import { AssessmentService } from '../../services/assessment-service.service';

@Component({
  selector: 'app-completion-modal',
  standalone: false,
  templateUrl: './completion-modal.component.html',
  styleUrls: ['./completion-modal.component.scss'],
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
        style({ opacity: 0, transform: 'translateY(30px)' }),
        animate('600ms 150ms cubic-bezier(0.4, 0.0, 0.2, 1)',
          style({ opacity: 1, transform: 'translateY(0)' }))
      ])
    ]),
    trigger('itemsAnimation', [
      transition(':enter', [
        query('.animated-item', [
          style({ opacity: 0, transform: 'translateY(20px)' }),
          stagger(100, [
            animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)',
              style({ opacity: 1, transform: 'translateY(0)' }))
          ])
        ], { optional: true })
      ])
    ]),
    trigger('particles', [
      transition(':enter', [
        query('.particle', [
          style({ transform: 'scale(0) translate(0, 0)', opacity: 0 }),
          stagger(50, [
            animate('1s cubic-bezier(0.4, 0.0, 0.2, 1)',
              style({ transform: 'scale(1) translate(var(--tx), var(--ty))', opacity: 0.8 }))
          ])
        ], { optional: true }),
      ])
    ])
  ]
})
export class CompletionModalComponent implements OnInit, OnDestroy {
  @Output() completed = new EventEmitter<void>();

  score = 0;
  totalPoints = 0;
  isPassed = false;
  passingScore = 60;
  animationComplete = false;
  particles: { tx: string, ty: string, size: string, delay: string, color: string }[] = [];

  private subscriptions: Subscription[] = [];
  private autoCloseTimer: any;

  constructor(
    public assessmentService: AssessmentService,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    // Get score and points
    const state = this.assessmentService.getCurrentState();
    this.score = state.score;
    this.totalPoints = this.assessmentService.getTotalPoints();

    // Get passing score from content
    const content = this.assessmentService.getContent();
    if (content?.passingScore) {
      this.passingScore = content.passingScore;
    }

    this.isPassed = this.score >= this.passingScore;

    // Generate random particles for the animation
    this.generateParticles();

    // Set animation complete after a delay
    setTimeout(() => {
      this.animationComplete = true;
      this.cdr.markForCheck();
    }, 2500);

    // Auto-close after a longer delay
    this.autoCloseTimer = setTimeout(() => {
      this.onComplete();
    }, 5000);
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());

    if (this.autoCloseTimer) {
      clearTimeout(this.autoCloseTimer);
    }
  }

  onComplete(): void {
    this.completed.emit();
  }

  private generateParticles(): void {
    // Create 20 random particles with different properties
    this.particles = Array(20).fill(0).map(() => {
      const angle = Math.random() * Math.PI * 2;
      const distance = 50 + Math.random() * 150;
      const tx = Math.cos(angle) * distance;
      const ty = Math.sin(angle) * distance;
      const size = 5 + Math.random() * 15;
      const delay = Math.random() * 0.5;

      // Use theme colors with a bit of randomness
      let color: string;
      const colorRandom = Math.random();

      if (colorRandom < 0.5) {
        color = '#DAA520'; // Gold
      } else if (colorRandom < 0.8) {
        color = '#2D6A4F'; // Forest green
      } else {
        color = '#95D5B2'; // Light green
      }

      return {
        tx: `${tx}px`,
        ty: `${ty}px`,
        size: `${size}px`,
        delay: `${delay}s`,
        color
      };
    });
  }
}