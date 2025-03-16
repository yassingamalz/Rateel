import { Component, Input, ChangeDetectionStrategy, OnChanges, SimpleChanges } from '@angular/core';
import { trigger, state, style, transition, animate, keyframes } from '@angular/animations';

@Component({
  selector: 'app-feedback-overlay',
  standalone: false,
  templateUrl: './feedback-overlay.component.html',
  styleUrls: ['./feedback-overlay.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('notificationAnimation', [
      transition(':enter', [
        style({
          opacity: 0,
          transform: 'translateX(-50%) translateY(-20px) scale(0.95)'
        }),
        animate('400ms cubic-bezier(0.34, 1.56, 0.64, 1)',
          style({
            opacity: 1,
            transform: 'translateX(-50%) translateY(0) scale(1)'
          })
        )
      ]),
      transition(':leave', [
        animate('300ms cubic-bezier(0.4, 0.0, 0.2, 1)',
          style({
            opacity: 0,
            transform: 'translateX(-50%) translateY(-20px) scale(0.95)'
          })
        )
      ])
    ])
  ]
})
export class FeedbackOverlayComponent implements OnChanges {
  @Input() message: string | undefined;

  // Timer for auto-hiding the notification
  private hideTimer: any;

  ngOnChanges(changes: SimpleChanges): void {
    // When message changes and is not empty, set a timer to hide it
    if (changes['message'] && this.message) {
      // Clear any existing timer
      if (this.hideTimer) {
        clearTimeout(this.hideTimer);
      }

      // Auto-hide the notification after 2.5 seconds (slightly longer)
      this.hideTimer = setTimeout(() => {
        this.message = undefined;
      }, 2500);
    }
  }

  /**
   * Determines if the feedback is a success message
   */
  isSuccessFeedback(): boolean {
    if (!this.message) return false;

    return this.message.includes('أحسنت') ||
      this.message.includes('ممتاز') ||
      this.message.includes('رائع');
  }
}