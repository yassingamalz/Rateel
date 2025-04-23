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

  /**
   * Calculate a "level" based on the achievement points
   * Uses a square root curve to make higher levels require more points
   */
  calculateLevel(): number {
    if (this.totalPoints <= 0) return 1;

    // Formula: level = 1 + sqrt(totalPoints/100)
    // Level progression: 
    // 100 points = level 2
    // 400 points = level 3
    // 900 points = level 4, etc.
    const calculatedLevel = 1 + Math.floor(Math.sqrt(this.totalPoints / 100));
    return Math.min(calculatedLevel, 99); // Cap at level 99
  }

  /**
   * Calculate points needed for next level
   */
  getNextLevelPoints(): number {
    const currentLevel = this.calculateLevel();
    if (currentLevel >= 99) return 0;

    const nextLevel = currentLevel + 1;
    const pointsNeeded = (nextLevel * nextLevel * 100);
    return pointsNeeded - this.totalPoints;
  }
}