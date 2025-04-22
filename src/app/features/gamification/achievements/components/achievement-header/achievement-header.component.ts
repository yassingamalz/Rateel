import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-achievement-header',
  standalone: false,
  templateUrl: './achievement-header.component.html',
  styleUrls: ['./achievement-header.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AchievementHeaderComponent {
  @Input() totalPoints: number = 0;
  @Input() progressPercentage: number = 0;
  @Input() unlockedCount: number = 0;
  @Input() totalCount: number = 0;
}