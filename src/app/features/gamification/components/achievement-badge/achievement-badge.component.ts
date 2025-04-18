import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

export type BadgeType = 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond';

@Component({
  selector: 'app-achievement-badge',
  standalone: false,
  templateUrl: './achievement-badge.component.html',
  styleUrls: ['./achievement-badge.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AchievementBadgeComponent {
  @Input() type: BadgeType = 'bronze';
  @Input() icon: string = 'trophy';
  @Input() title: string = '';
  @Input() description: string = '';
  @Input() isLocked: boolean = false;
  @Input() progress: number = 0;
  @Input() showProgress: boolean = false;

  getIconClass(): string {
    return `fa-${this.icon}`;
  }
}