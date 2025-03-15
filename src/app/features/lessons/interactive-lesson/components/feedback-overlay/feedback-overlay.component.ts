import { Component, Input, ChangeDetectionStrategy } from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';

@Component({
  selector: 'app-feedback-overlay',
  standalone: false,
  templateUrl: './feedback-overlay.component.html',
  styleUrls: ['./feedback-overlay.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('feedbackAnimation', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(-30px)' }),
        animate('300ms cubic-bezier(0.4, 0, 0.2, 1)', style({ opacity: 1, transform: 'translateY(0)' }))
      ]),
      transition(':leave', [
        animate('250ms cubic-bezier(0.4, 0, 0.2, 1)', style({ opacity: 0, transform: 'translateY(-30px)' }))
      ])
    ])
  ]
})
export class FeedbackOverlayComponent {
  @Input() message: string | undefined;
  
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