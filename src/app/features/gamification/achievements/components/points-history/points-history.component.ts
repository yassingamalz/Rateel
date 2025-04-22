import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { PointsActivity } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-points-history',
  standalone: false,
  templateUrl: './points-history.component.html',
  styleUrls: ['./points-history.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('fadeIn', [
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-out', style({ opacity: 1 }))
      ])
    ])
  ]
})
export class PointsHistoryComponent {
  @Input() earnedPoints: number = 0;
  @Input() bonusPoints: number = 0;
  @Input() spentPoints: number = 0;
  @Input() activities: PointsActivity[] = [];
  @Input() activitySlideOffset: number = 0;
  @Input() currentActivityPage: number = 0;
  @Input() totalActivityPages: number[] = [0];

  @Output() previous = new EventEmitter<void>();
  @Output() next = new EventEmitter<void>();
  @Output() goToPage = new EventEmitter<number>();

  getActivityIcon(activity: PointsActivity): string {
    switch (activity.type) {
      case 'earned': return 'fa-plus-circle';
      case 'spent': return 'fa-minus-circle';
      case 'bonus': return 'fa-gift';
      default: return 'fa-circle';
    }
  }

  previousPage(): void {
    this.previous.emit();
  }

  nextPage(): void {
    this.next.emit();
  }

  navigateToPage(page: number): void {
    this.goToPage.emit(page);
  }
}