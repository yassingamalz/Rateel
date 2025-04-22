import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-achievement-list',
  standalone: false,
  templateUrl: './achievement-list.component.html',
  styleUrls: ['./achievement-list.component.scss'],
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
export class AchievementListComponent {
  @Input() achievements: Achievement[] = [];
  @Input() achievementSlideOffset: number = 0;
  @Input() currentAchievementPage: number = 0;
  @Input() totalAchievementPages: number[] = [0];
  @Output() showDetails = new EventEmitter<Achievement>();
  @Output() previous = new EventEmitter<void>();
  @Output() next = new EventEmitter<void>();
  @Output() goToPage = new EventEmitter<number>();

  getAchievementCategoryClass(requirement: string): string {
    switch (requirement) {
      case 'lessons_completed': return 'category-lessons';
      case 'score_reached': return 'category-score';
      case 'streak': return 'category-streak';
      case 'perfect_score': return 'category-perfect';
      default: return 'category-custom';
    }
  }

  getBadgeImage(achievement: Achievement): string {
    const badgeType = achievement.type || 'bronze';
    const status = achievement.isUnlocked ? 'unlocked' : 'locked';
    return `assets/images/badges/${badgeType}_${status}.png`;
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

  onShowDetails(achievement: Achievement): void {
    this.showDetails.emit(achievement);
  }
}