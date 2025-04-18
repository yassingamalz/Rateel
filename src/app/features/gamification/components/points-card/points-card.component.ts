import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

export interface PointsActivity {
  title: string;
  points: number;
  date: Date;
  icon?: string;
  type: 'earned' | 'spent' | 'bonus';
}

@Component({
  selector: 'app-points-card',
  standalone: false,
  templateUrl: './points-card.component.html',
  styleUrls: ['./points-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class PointsCardComponent {
  @Input() totalPoints: number = 0;
  @Input() activities: PointsActivity[] = [];
  @Input() showHistory: boolean = false;
  @Input() maxHistoryItems: number = 5;

  toggleHistory(): void {
    this.showHistory = !this.showHistory;
  }

  getActivityTypeIcon(type: 'earned' | 'spent' | 'bonus'): string {
    switch (type) {
      case 'earned': return 'fa-plus-circle';
      case 'spent': return 'fa-minus-circle';
      case 'bonus': return 'fa-gift';
      default: return 'fa-circle';
    }
  }
}