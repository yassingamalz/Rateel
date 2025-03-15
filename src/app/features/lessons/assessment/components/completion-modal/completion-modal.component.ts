import {
  Component,
  OnInit,
  OnDestroy,
  Output,
  EventEmitter,
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Input
} from '@angular/core';
import { trigger, transition, style, animate, stagger, query } from '@angular/animations';
import { Subscription } from 'rxjs';
import { PlatformService } from '../../../../../core/services/platform.service';

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
  
  // Properties that will be set when created by the dynamic modal service
  @Input() score = 0;
  @Input() totalPoints = 0;
  @Input() isPassed = false;
  @Input() passingScore = 60;
  
  // Auto-close timeout in milliseconds, different for pass/fail
  @Input() autoCloseTimeoutPass = 6000;  // 6 seconds for pass
  @Input() autoCloseTimeoutFail = 8000;  // 8 seconds for fail
  
  animationComplete = false;
  particles: { tx: string, ty: string, size: string, delay: string, color: string }[] = [];
  
  // Countdown for auto-close
  timeLeft = 0; 
  showCountdown = false;
  
  private subscriptions: Subscription[] = [];
  private autoCloseTimer: any;
  private countdownTimer: any;

  constructor(
    private cdr: ChangeDetectorRef,
    private platformService: PlatformService
  ) { }

  ngOnInit(): void {
    // Generate random particles for the animation
    this.generateParticles();

    // Determine auto-close timeout based on pass/fail status
    const autoCloseTimeout = this.isPassed ? this.autoCloseTimeoutPass : this.autoCloseTimeoutFail;
    
    // Add haptic feedback based on result
    if (this.isPassed) {
      this.platformService.vibrateSuccess().catch(() => {});
    } else {
      this.platformService.vibrateWarning().catch(() => {});
    }
    
    // Set animation complete after a delay
    setTimeout(() => {
      this.animationComplete = true;
      this.cdr.markForCheck();
      
      // Show countdown only after animation is complete
      this.showCountdown = true;
      this.timeLeft = Math.round(autoCloseTimeout / 1000) - 2; // Convert to seconds, account for delay
      this.startCountdown();
    }, 2500);

    // Auto-close after the determined delay
    this.autoCloseTimer = setTimeout(() => {
      this.onComplete();
    }, autoCloseTimeout);
    
    console.log(`[CompletionModal] Initialized with auto-close in ${autoCloseTimeout}ms, pass status: ${this.isPassed}`);
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());

    if (this.autoCloseTimer) {
      clearTimeout(this.autoCloseTimer);
    }
    
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
    }
  }

  onComplete(): void {
    this.completed.emit();
  }
  
  // Countdown timer display
  private startCountdown(): void {
    this.countdownTimer = setInterval(() => {
      this.timeLeft--;
      this.cdr.markForCheck();
      
      if (this.timeLeft <= 0) {
        clearInterval(this.countdownTimer);
      }
    }, 1000);
  }

  private generateParticles(): void {
    // Create more particles for success, fewer for failure
    const particleCount = this.isPassed ? 30 : 15;
    
    // Use more vibrant colors for success
    const successColors = ['#DAA520', '#FFD700', '#FCC200', '#95D5B2', '#2ECC71'];
    const failureColors = ['#DAA520', '#2D6A4F', '#95D5B2']; // More subdued palette
    
    const colors = this.isPassed ? successColors : failureColors;
    
    // Create random particles with different properties
    this.particles = Array(particleCount).fill(0).map(() => {
      const angle = Math.random() * Math.PI * 2;
      const distance = 50 + Math.random() * 150;
      const tx = Math.cos(angle) * distance;
      const ty = Math.sin(angle) * distance;
      const size = 5 + Math.random() * 15;
      const delay = Math.random() * 0.5;

      // Select a random color from the appropriate palette
      const color = colors[Math.floor(Math.random() * colors.length)];

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