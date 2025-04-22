import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy, afterNextRender } from '@angular/core';
import { Achievement } from '../../../services/gamification.service';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-badges-collection',
  standalone: false,
  templateUrl: './badges-collection.component.html',
  styleUrls: ['./badges-collection.component.scss'],
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
export class BadgesCollectionComponent {
  @Input() lessonAchievements: Achievement[] = [];
  @Input() scoreAchievements: Achievement[] = [];
  @Input() streakAchievements: Achievement[] = [];
  @Input() categorySlideOffset: number = 0;
  @Input() currentCategoryPage: number = 0;
  @Input() totalCategoryPages: number[] = [0, 1, 2];

  @Output() showDetails = new EventEmitter<Achievement>();
  @Output() previous = new EventEmitter<void>();
  @Output() next = new EventEmitter<void>();
  @Output() goToPage = new EventEmitter<number>();

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